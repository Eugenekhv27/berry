Class Util.SourceControl Extends %Studio.SourceControl.File
{

/// 2 - export in classname.cls (udl format)
/// 1 - export in classname.cls.xml (compatible with cache-tort-git), 
/// 0 - export in classname.xml   
Parameter ExpMode = 2;

/// resource name is used to wait for system event
/// do not change
Parameter ResourceName = "searchResource";

/// specifies where exported files should be stored
Parameter SourceFolder = "c:/Gitlab/";

/// specifies the frequency of checking for new files in the SourceFolder
Parameter RefreshTime = 2;

/// setup control version for namespace and export all .cls, .mac, .int, .dfi files
/// omits generated classes and classes with masks: %.*, csp.*, Ens.*, CSPX.*, INFORMATION.SCHEMA.*
/// reponame - name of the repository.
ClassMethod Init(reponame As %String) As %Status
{
	if $g(reponame)="" s reponame=$znspace
	// init variables and globals
	kill ^Sources
	set ^Sources = ..#SourceFolder_reponame_"/"_ "src_intersystems" _ "/"
	set ^Sources("CLS","*") = "cls/"
	set ^Sources("DFI","*") = "dfi/"
	set ^Sources("MAC","*") = "mac/"
	set ^Sources("INT","*") = "int/"
	set ^Sources("INC", "*") = "inc/"
	set sourceControl = ..%New("")
	set sc = $$$OK
	set currentLocation = ##class(%SYS.Namespace).GetPackageDest($namespace, "")

	// fetch all classes 
	&sql(DECLARE classCursor cursor for
		 SELECT ID 
		 FROM %Dictionary.ClassDefinition 
		 WHERE (NOT (ID %STARTSWITH '%')) 
		 	AND NOT (ID %STARTSWITH 'Util.SourceControl') 
		 	AND NOT (ID %STARTSWITH 'Ens') 
		 	AND NOT (ID %STARTSWITH 'CSPX') 
		 	AND NOT (ID %STARTSWITH 'csp') 
		 	AND NOT (ID %STARTSWITH 'INFORMATION.SCHEMA')
		 	AND (GeneratedBy IS NULL)
		 	AND NOT (ID LIKE '%.xml') )
	&sql(OPEN classCursor)
	for {
		&sql(FETCH classCursor INTO :className)
		quit:(SQLCODE '= 0)
		w !," -- "_className
		// check for mapped files
		//set classLocation = ##class(%SYS.Namespace).GetPackageDest($namespace, className)
		//if classLocation '= currentLocation {
		//	continue
		//}
		
		set sc = sourceControl.OnAfterSave(className _ ".cls")
		if $$$ISERR(sc) {
			do $system.OBJ.DisplayError(sc)
		}
	}
	&sql(CLOSE classCursor)
	
	&sql(DECLARE deepseeCursor CURSOR FOR
		 SELECT documentname 
		 FROM %DeepSee_UserLibrary.FolderItem)
	&sql(OPEN deepseeCursor)
	for {
		&sql(FETCH deepseeCursor INTO :name)
		quit:(SQLCODE '= 0)
		set sc = sourceControl.OnAfterSave(name)
		if $$$ISERR(sc) {
			do $system.OBJ.DisplayError(sc)
		}
	}
	&sql(CLOSE deepseeCursor)

	// fetch all routines
	set st = ##class(%SQL.Statement).%New()
	set qStatus = st.%PrepareClassQuery("%RoutineMgr","StudioOpenDialog")
	if $$$ISOK(qStatus) {
	 	set rs = st.%Execute("*")
	 	
	 	while rs.%Next() {
	 		set fileName = rs.%GetData(1)
	 		if ($find(fileName, ".mac")) 
	 			|| ($find(fileName, ".int") 
	 			|| ($find(fileName, ".DFI")) 
	 			|| ($find(fileName, ".inc"))) {
	 			set sc = sourceControl.OnAfterSave(fileName)
	 			if $$$ISERR(sc) {
	 				do $system.Status.DisplayError(sc)
	 			}
	 		}
	 	}
	}


	// start a job - execute each RefreshTime seconds
	if '$system.Event.Defined(..#ResourceName) {
		job ..SearchForNewFiles()
	}
	
 	
 	return $$$OK
}

Method OnAfterSave(InternalName As %String, Object As %RegisteredObject) As %Status
{
	
	set filename=..ExternalName(InternalName)
	
	#; File not mapped so nothing to do
	if filename="" quit $$$OK
	set name=$Piece(InternalName,".",1,$Length(InternalName,".")-1)
	
	#; CSP files are already files so not additional work needed
	if name["/" quit $$$OK
	set ext=$Piece(InternalName,".",$Length(InternalName,"."))
	
	#; do not export the default projects
	if ext="prj",$zconvert($extract(name,1,$length("default_")),"l")="default_" {
		return $$$OK
	}
	
	#; By convention items starting with Z,z,%z,%Z are not exported
	if (ext="prj")||($extract($translate(name,"Z%","z"))="z") {
		//return $$$OK
	}
	
	#; if time already matches nothing to do
	// TODO
	if ##class(%RoutineMgr).TS(InternalName)=$get(^Sources(0,"ItemTimeStamp",InternalName)) {
		return $$$OK
	}
	
	if (##class(%File).Exists(filename)) && (##class(%File).ReadOnly(filename)) {
		write !,"File ",filename," is read only, not exporting" quit $$$OK
	}
	
	do ##class(%File).CreateDirectoryChain(##class(%File).GetDirectory(filename))
	
	set sc = ""
	
	if ..#ExpMode = 2 {
		set sc = ..ExportUDL(filename, InternalName)
	} 
	else {
		set sc = $system.OBJ.Export(InternalName, filename, "-d /diffexport")
	}
	if $$$ISOK(sc) {
		write !,"Exported '",InternalName,"' to file '",filename,"'"
		set ^Sources(0,"FileTimeStamp",InternalName) = $zu(140,2,filename,1)
		set ^Sources(0,"ItemTimeStamp",InternalName) = ##class(%RoutineMgr).TS(InternalName)
	} else {
		do $system.Status.DecomposeStatus(sc,,"d")
		quit sc
	}
	quit $$$OK
}

Method OnBeforeLoad(InternalName As %String, display As %Boolean = 1) As %Status
{
	set filename = ..ExternalName(InternalName)
	
	#; File not mapped so nothing to do
	if filename = "" {
		return $$$OK
	}
	
	#; CSP files are already files so not work needed
	if InternalName["/" {
		return $$$OK
	}
	
	#; if no file then skip the import
	if '##class(%File).Exists(filename) {
		 write:display !,"File ",filename," not found, skipping import" 
		 return $$$OK
	}
	
	#; if time already matches then no work to do
	if ##class(%File).GetFileDateModified(filename,1)=$get(^Sources(0,"FileTimeStamp",InternalName)),##class(%RoutineMgr).TS(InternalName)=$get(^Sources(0,"ItemTimeStamp",InternalName)) {
		return $$$OK
	}
	set name = $Piece(InternalName,".",1,$Length(InternalName,".")-1)
	set ext = $ZConvert($Piece(InternalName,".",$Length(InternalName,".")),"U")
	
	set sc = ""
	if ..#ExpMode = 2 {
		set sc = ..ImportUDL(InternalName, filename)
	}
	else {
		set sc = $system.OBJ.Load(filename,"fv-d-l")
	}
	if $$$ISOK(sc) {
		write !,"Imported '",InternalName,"' from file '",filename,"'"
		set ^Sources(0,"FileTimeStamp",InternalName) = ##class(%File).GetFileDateModified(filename,1)
		set ^Sources(0,"ItemTimeStamp",InternalName) = ##class(%RoutineMgr).TS(InternalName)
	} else {
		do $system.Status.DecomposeStatus(sc,.errors,"d")
	}
	
	
	// start a job - execute each RefreshTime seconds
	if '$system.Event.Defined(..#ResourceName) {
		job ..SearchForNewFiles()
	}
	
	return sc
}

/// Import a file with location at fileLocation and name as InternalName
/// This file should contain code in UDL format
ClassMethod ImportUDL(InternalName As %String, fileLocation As %String) As %Status
{
	set status = $$$OK
	
	if $find(fileLocation, ".cls") {
		set status = ##class(%Compiler.UDL.TextServices).SetTextFromFile($namespace, InternalName, fileLocation)
	} 
	
	else {
		set file = ##class(%File).%New(fileLocation)
		return:$$$ISERR(file) file
		
		set status = file.Open()
		return:$$$ISERR(status) status
		
		set rtn = ##class(%RoutineMgr).%OpenId(InternalName)
		return:$$$ISERR(rtn) rtn
		
		set status = rtn.Code.CopyFrom(file)
		return:$$$ISERR(status) status
		
		set status = rtn.%Save()
	}
	return status
}

ClassMethod GetExt(fileName As %String) As %String
{
	return $zconvert($piece(fileName, ".", *), "l")
}

/// exports fileName to fileLocation file using UDL format
Method ExportUDL(fileLocation As %String, fileName As %String) As %Status
{
	#include %occErrors
	if ('$data(fileLocation)) || ('$data(fileName)) {
		return $$$ERROR($$$InvalidArgument, "not all fields are passed to the method")
	}
		
	
	set ext = ..GetExt(fileName)
	
	if ext = "cls" {
		return ..ExportUDLClass(fileLocation, fileName)
	} 
	elseif (ext = "mac") || (ext = "inc") || (ext = "int") {
		return ..ExportUDLOther(fileLocation, fileName, ext)
	} 
	elseif (ext = "dfi") {
		return ..ExportUDLDFI(fileLocation, fileName)
	}
	return $$$OK
}

/// Exports a class to fileLocation with the name of fileName 
ClassMethod ExportUDLClass(fileLocation As %String, fileName As %String) As %Status
{
	set namespace = $namespace
	set clsformat = ".cls"
	set status = ""
	
	set $piece(fileName, ".", *) = ""
	set className = $extract(fileName, 0, * - 1) 
	
	// get class content
	set status = ##class(%Compiler.UDL.TextServices).GetTextAsString(namespace, className, .classContent)
	return:$$$ISERR(status) status
	
	// write class content to file
	set fileStream = ##class(%FileCharacterStream).%New()
	set fileStream.Filename = fileLocation
	
	set status = fileStream.Write(classContent)
	return:$$$ISERR(status) status
	
	set status = fileStream.SaveStream()
	return status
}

/// Exports .mac, .inc files to fileLocation with the name of fileName
ClassMethod ExportUDLOther(fileLocation As %String, fileName As %String, ext As %String) As %Status
{
	set rtn = ##class(%RoutineMgr).%OpenId(fileName)
 	
 	// write content to file
	set fileStream = ##class(%FileCharacterStream).%New()
	set fileStream.Filename = fileLocation
	
	// transform routine.mac -> routine
	set routineName = $extract(fileName, 0, $find(fileName, ".") - 2)
	
	if ext = "mac" {
		do fileStream.WriteLine("ROUTINE " _ routineName)
	} elseif ext = "inc" {
		do fileStream.WriteLine("ROUTINE " _ routineName _ " [Type=INC]")
	} elseif ext = "int" {
		do fileStream.WriteLine("ROUTINE " _ routineName _ " [Type=INT,Generated]")
	}
	
	while 'rtn.Code.AtEnd {
		do fileStream.WriteLine(rtn.Code.ReadLine())
	}
	
	do fileStream.%Save()
		
	return $$$OK
}

ClassMethod ExportUDLDFI(fileLocation As %String, fileName As %String) As %Status
{
	set rtn = ##class(%RoutineMgr).%OpenId(fileName)
 	
 	// write content to file
	set fileStream = ##class(%FileCharacterStream).%New()
	set fileStream.Filename = fileLocation
	
	set status = fileStream.CopyFromAndSave(rtn.Code)
	return:$$$ISERR(status) status
	
	return status
}

/// Return filename of this item
ClassMethod ExtName(InternalName As %String) As %String [ Private ]
{
	set name = ..Name(InternalName)	
	if ..#ExpMode = 2 {
		set $piece(name, ".", *) = $zconvert($piece(InternalName, ".", *), "l")
	}
	return $select(name="":"",1:^Sources_$translate(name,"\","/"))
}

/// Return the name of this item without the prefix to be added by ExtName
ClassMethod Name(InternalName As %String) As %String [ Private ]
{
	if $data(^Sources)'=11 Write !,"^Sources is not setup so hooks will not work" quit ""
		
	// for an abstract document, use the GetOther() method to try to determine its "real" class
	if ##class(%RoutineMgr).UserType(InternalName,.docclass,.doctype) {
		// Check for a real abstract document subclass (or GetOther() may not work)
		if $classmethod(docclass,"%IsA","%Studio.AbstractDocument") {
			// Grab the actual name
			set actualName = $classmethod(docclass,"GetOther",InternalName)
			// The actualName is only valid if we get a single .cls as a result
			if actualName'[",",$ZCVT($P(actualName,".",$L(actualName,".")),"U")="CLS" {
				// We use what GetOther() gives us, thus Demo.Loan.FindRateProcess.bpl becomes Demo.Loan.FindRateProcess.cls
				set InternalName = actualName
			}
		}
	}	
	
	if $$CheckProtect^%qccServer(InternalName) quit ""
	set nam=$p(InternalName,".",1,$l(InternalName,".")-1),ext=$p(InternalName,".",$l(InternalName,".")),ext=$zcvt(ext,"u")
	if nam="" quit ""
	if ext="PRJ",nam["Default_" quit ""
	if ext="CLS",$$$defClassKeyGet(nam,$$$cCLASSgeneratedby)'="" quit ""
	set default=0
	set p=$order(^Sources(ext,nam)) for  s p=$order(^Sources(ext,p),-1) quit:p=""  if $extract(nam,1,$length(p))=p,$data(^Sources(ext,p),found) quit
	
	if $data(found)=0,$data(^Sources(ext,"*"),found) set default=1
	if $data(found)=0 quit ""
	if InternalName["/" {
		set InternalName=$extract(InternalName,$length(p)+1,*)
		return $translate(found_$translate(InternalName,"%","_"),"\","/")
	}
	if ext="CLS"||(ext="PRJ")||(##class(%RoutineMgr).UserType(InternalName)) {
		if ext = "DFI" {
			set fileLocation = found _ nam
		}
		else {
			set fileLocation = found _ $translate(nam, ".%", "/")
		}
		if ..#ExpMode = 0 {
			set fileLocation = fileLocation _ ".xml"
		}
		elseif ..#ExpMode = 1 {
			set fileLocation = fileLocation _ "." _ $zconvert(ext, "l") _".xml"
		} 
		else {
			set fileLocation = fileLocation _ "." _ $zconvert(ext, "l")
		}
		set fileLocation = $translate(fileLocation, "\", "/")
		return fileLocation
	}
	return $translate($g(found)_$tr(nam,"%"_$s(default:".",1:""),"_/")_".xml","\","/")
}

/// Searches for new files(files that are not in project) in source control directory
/// Is executed on another process
ClassMethod SearchForNewFiles()
{
	if '$system.Event.Defined(..#ResourceName) {
		do $system.Event.Create(..#ResourceName)
	}
	for {
		do $system.Event.Wait(..#ResourceName, ..#RefreshTime)
		set dir = ^Sources
		do ##class(Util.SourceControl).TraverseFileTree(dir)
	}
}

/// Gets the name of a file at fileLocation
ClassMethod GetInternalName(fileLocation As %String) As %String
{
	set defLocation = $translate(^Sources, "/", "\")
	set internalName = $translate($extract(fileLocation, $find(fileLocation, defLocation) + 4, *), "\", ".")
	return internalName
}

/// Traverses the file tree starting at source control directory
ClassMethod TraverseFileTree(dir As %String) As %Status
{
	set list = ""
	set trs = ##class(%ResultSet).%New("%Library.File:FileSet")
 	set tsc = trs.Execute(dir, "*")
	while trs.Next() {
		set name = trs.Get("Name")
 		set type = trs.Get("Type")
 		if type = "D" {
 			do ..TraverseFileTree(name)
 		}
 		else {
	 		set internalName = ..GetInternalName(name)
	 		set internalNameUpper = internalName
	 		set $piece(internalNameUpper, ".", *) = $zconvert($piece(internalNameUpper, ".", *), "U")
 			if ('$data(^Sources(0, "FileTimeStamp", internalName))) 
 				&& ('$data(^Sources(0, "FileTimeStamp", internalNameUpper))) {
	 			write !, name
				set st = ..CreateFile(internalName, name, .list)
				if $$$ISERR(st) {
					do $system.Status.DisplayError(st)
				}
	 		}
 		}
 	}
 	do $system.OBJ.CompileList(.list, "cuk /checkuptodate=expandedonly")
 	return $$$OK
}

/// Creates new file with the name of internalName which is stored at fileLocation
ClassMethod CreateFile(internalName As %String, fileLocation As %String, ByRef list) As %Status
{
	set st = ""
	if $find(fileLocation, "\cls\") {
		set st = ..CreateClass(internalName, fileLocation, .list)
	}
	elseif $find(fileLocation, "\dfi\") {
		set st = ..CreateDFI(internalName, fileLocation, .list)
	} 
	else {
		set st = ..CreateOther(internalName, fileLocation, .list)
	}
	return $$$OK
}

/// Creates a class with the name of internalName which is stored at fileLocation
ClassMethod CreateClass(internalName As %String, fileLocation As %String, ByRef list) As %Status
{
	set clsDef = ##class(%Dictionary.ClassDefinition).%New()
	set clsDef.Name = $replace(internalName, ".cls", "")
	set st = clsDef.%Save()
	return:$$$ISERR(st) st
	
	set st = ..ImportUDL(internalName, fileLocation)
	set list(internalName) = ""
	return st
}

ClassMethod CreateDFI(internalName As %String, fileLocation As %String, ByRef list) As %Status
{
	set st = $$$OK
    try {
        set stream = ##class(%Stream.FileCharacter).%New()
        set st = stream.LinkToFile(fileLocation)
        return:$$$ISERR(st) st
        
        set tDoc = ##class(%DeepSee.UI.FolderItemDocument).%New(internalName)
        set st = tDoc.ImportFromXML(stream)
        return:$$$ISERR(st) st
        
        set st = tDoc.Save()
        return:$$$ISERR(st) st
    } Catch e {
        set st = e.AsStatus()
    }
    return st
}

/// Creates .mac, .int, .dfi file with the name of intrernalName which is stored at fileLocation
ClassMethod CreateOther(internalName As %String, fileLocation As %String, ByRef list) As %Status
{
	set fileLocation = $translate(fileLocation, "\", "/")
	set $piece(internalName, ".", *) = $zconvert($piece(internalName, ".", *), "U")
	
	set file = ##class(%File).%New(fileLocation)
	
	set rtn = ##class(%Routine).%New(internalName)
	set status = rtn.CopyFrom(file)
	return:$$$ISERR(status) status
	
	set status = rtn.Save()
 	return:$$$ISERR(status) status
 	
 	set list(internalName) = ""
 	return status
}

ClassMethod SetSetting() As %Status
{
	set ^Sources("tempDir")="D:\Temp"
	set ^Sources("remoteRepo")="git@gitlab.com:Vassil2010/bonusclub-poseidon.git"
	set ^Sources("repoDir")="src_intersystems"
	quit $$$OK
}

ClassMethod UpdateProduction() As %Status
{
	set tempDir=^Sources("tempDir")
	set repo=^Sources("remoteRepo")
	set repoDir=^Sources("repoDir")
	
	// Удалить временные файлы
	do ##class(%Library.File).RemoveDirectoryTree(tempDir_"\"_repoDir)
	do ##class(%Library.File).Delete(tempDir_"\source.zip")
	if '##class(%Library.File).DirectoryExists(tempDir) {
		do ##class(%Library.File).CreateDirectory(tempDir)
	}
	do ##class(%Library.File).CreateNewDir(tempDir,repoDir)
	
	
	
		
	set status = $ZF(-1,"git archive --format=zip --output="_tempDir_"\source.zip --remote="_repo_" HEAD "_repoDir)
	if status'=0 {
		quit $$$ERROR(1000,"не удалось загрузить исходный текст")
	}
	
	// распаковываем
	
	set status = $ZF(-1,"""C:\Program Files\7-Zip\7z.exe"" x -o"_tempDir_" "_tempDir_"\source.zip ")
	
	if status'=0 {
		quit $$$ERROR(10000,"не удалось распаковать архив")
	}
	
	// fetch all classes 
	&sql(DECLARE classCursorDel cursor for
		 SELECT ID 
		 FROM %Dictionary.ClassDefinition 
		 WHERE (NOT (ID %STARTSWITH '%')) 
		 	AND NOT (ID %STARTSWITH 'Util.SourceControl') 
		 	AND NOT (ID %STARTSWITH 'Ens') 
		 	AND NOT (ID %STARTSWITH 'CSPX') 
		 	AND NOT (ID %STARTSWITH 'csp') 
		 	AND NOT (ID %STARTSWITH 'INFORMATION.SCHEMA')
		 	AND (GeneratedBy IS NULL)
		 	AND NOT (ID LIKE '%.xml')
		 	 )
	&sql(OPEN classCursorDel)
	for {
		&sql(FETCH classCursorDel INTO :className)
		quit:(SQLCODE '= 0)
		
		do ##class(%Dictionary.ClassDefinition).%DeleteId(className)
	}
	&sql(CLOSE classCursorDel)
	
	
	write !,"загрузка описаний классов из "_tempDir_":",!
 	do $System.OBJ.ImportDir(tempDir,"*.xml;*.cls;*.mac;*.int;*.inc;*.dfi","",,1)
 	
 	 set rset = ##class(%ResultSet).%New()
 do rset.Prepare("select ID from %Dictionary.ClassDefinition where System=0 and not (ID['%')")
 do rset.Execute()
 while (rset.Next(.sc)) {
	set className=rset.GetData(1)
	if (className["component")||(className["auxiliary") {
		set firstTimeCompile(className_".CLS")=""
	}
	else  {
		set secondTimeCompile(className_".CLS")=""
		
	}
 }
 
 
 // скомпилировать все классы
 write !,"перекомпиляция описаний всех классов в области:",!
 
 //m ^a.firstTimeCompile=firstTimeCompile
 //m ^a.secondTimeCompile=secondTimeCompile
  
 do $system.OBJ.CompileList(.firstTimeCompile,,.sc) 
 do $system.OBJ.CompileList(.secondTimeCompile,,.sc) 
 
 write !,"перекомпиляция описаний сообщений:",!
 set rset = ##class(%ResultSet).%New()
 do rset.Prepare("select ID from %Dictionary.ClassDefinition where System=0  and not (ID['%')")
 do rset.Execute()
 while (rset.Next(.sc)) {
	set className=rset.GetData(1)
	if '((className["component")||(className["auxiliary")) {
		if '$data(secondTimeCompile(className_".CLS")) {	
			set thirdTimeCompile(className_".CLS")=""
		}
	}
	
 }
 do $system.OBJ.CompileList(.thirdTimeCompile,,.sc) 
 	
 do ##class(p6.ClassUtils).UpdateIndices()
 	
 	
	
	
	quit $$$OK
}

}

