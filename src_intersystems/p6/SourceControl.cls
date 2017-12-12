/// Организация работы с MS VSSDB 
/// Dimas 2003, logist, shu 031018 - cache 5.04 - добавлены параметры в методы
Class p6.SourceControl Extends %Studio.SourceControl.Base [ ClassType = "", ProcedureBlock ]
{

XData Menu
{
<MenuBase>
 <Menu Name="p&amp;5" Type="0">
 <MenuItem Name="&amp;1 - Go to class" Enabled="1"/>
 <MenuItem Name="&amp;2 - Go to page" Enabled="1"/>
 <MenuItem Name="&amp;3 - Go to test" Enabled="1"/>
 <MenuItem Name="&amp;4 - Run test" Enabled="1"/>
 </Menu>
 </MenuBase>
}

Method UserAction(Type As %Integer, Name As %String, InternalName As %String, SelectedText As %String, ByRef Action As %String, ByRef Target As %String, ByRef Msg As %String, ByRef Reload As %Boolean) As %Status
{
	// Выделяем название класса из пришедшего названия файла
	set className="undefined"
	if InternalName[".CLS" {
		set className=$extract(InternalName,1,$l(InternalName)-4)
		if '((Type=0) && (Name="p&5,&4 - Run test")) {
			if $e(className,1,4)="zui." set $e(className,1,4)=""
			if $e(className,1,4)="src." set $e(className,1,4)=""
		}
	} elseif $ZCVT(InternalName,"U")[".CSP" {
		set className=$extract(InternalName,1,$l(InternalName)-4)
		set className=$piece(className,"/",4,999)
		set className=$translate(className,"/",".")
	}
	if (Type=0) && (Name="p&5,&1 - Go to class") {
		set Action=5,Target=className_".CLS",Reload=0
	} elseif (Type=0) && (Name="p&5,&2 - Go to page") {
		set Action=5,Target="zui."_className_".CLS",Reload=0
	} elseif (Type=0) && (Name="p&5,&3 - Go to test") {
		if ##class(%Dictionary.CompiledClass).%ExistsId("test."_className) {
			set Action=5,Target="test."_className_".CLS",Reload=0
		} elseif ##class(%Dictionary.CompiledClass).%ExistsId("src."_className) {
			set Action=5,Target="src."_className_".CLS",Reload=0
		}
	} elseif (Type=0) && (Name="p&5,&4 - Run test") {
		if $$$isWINDOWS {
			do ..CreateTestScript(className)
			set Action=3,Target="C:\test.bat",Reload=0
		}else {
			w !
			s oldNs=$znspace
			zn $znspace_"TEST"
			set Manager=##class(p6.unit.Manager).%New()
			set Manager.Listener=##class(p6.unit.listener.Console).%New()
			set Manager.Reporter=##class(p6.unit.reporter.Console).%New()
			set Manager.Reporter.Listener=Manager.Listener
			set Manager.Debug=0
			set Manager.ClassList("one",className)=""
			do Manager.RunClassList()
			zn oldNs
			w !
		}
	} else {
		Set Action=0,Target="",Reload=0
	}
	Quit $$$OK
}

/// The username of this source control user.
/// This just calls the <method>Login</method> to perform an initialisation.
/// Note that you must call <method>SourceControlCreate</method> to create an instance
/// of the source control class, do not call %New directly.   
/// Perform any login step here.
Method Login(Name As %String, Password As %String) As %Status
{
 Quit $$$OK
}

/// Import the file from the external format into Cache.
/// This is called before the actual load of data to give the chance
/// to load the item from an external format.
Method OnBeforeLoad(InternalName As %String) As %Status
{
	Set filename=..ExternalName(InternalName)
 If filename="" Quit $$$OK
 #; If no file then skip the import
 If ($zu(140,1,filename)<0) { 
 	Write:'$get(^ClearCase("nodisplay")) !,"File ",filename," not found, skipping import" 
 	Quit $$$OK
 }
 If ($zu(140,2,filename)=$get(^ClearCase(0,"FileTimeStamp",InternalName))) {
	 Write:'$get(^ClearCase("nodisplay")) !,"File ",filename," is up to date, skipping import" 
	 Quit $$$OK
 }
 Set name=$Piece(InternalName,".",1,$Length(InternalName,".")-1)
 Set ext=$ZConvert($Piece(InternalName,".",$Length(InternalName,".")),"U")
 If ( (ext="CLS") || (ext="MAC") || (ext="PRJ") ) {
 	Set sc=$$Import^%occSAX(filename,"-d-l")
 } Else {
 	Set sc=$$Import^%apiRTN(filename,"all,replace,nocompile,lock=0",,,,"-d")
 }
 If ($$$ISOK(sc)) {
 	Write:'$get(^ClearCase("nodisplay")) !,"Imported '",InternalName,"' from file '",filename,"'"
 	Set ^ClearCase(0,"FileTimeStamp",InternalName)=$zu(140,2,filename)
 } Else {
  	do DecomposeStatus^%apiOBJ(sc,.errors)
  	Do:'$get(^ClearCase("nodisplay"))&($g(errors(1,"code"))'=6301) DecomposeStatus^%apiOBJ(sc,.errors,"d")
 }
 Quit sc
}

/// Export the routine/class/csp file to the external format.
/// This is called after the item has been saved to the database.
Method OnAfterSave(InternalName As %String, Object As %RegisteredObject = {$$$NULLOREF}) As %Status
{
 Set filename=..ExternalName(InternalName)
 If filename="" Quit $$$OK
 Set name=$Piece(InternalName,".",1,$Length(InternalName,".")-1)
 Set ext=$ZConvert($Piece(InternalName,".",$Length(InternalName,".")),"U")
 If ( $zu(140,1,filename)<0 ) { Do ..MakeDir(filename) }
 If ( (ext="CLS") ) {
 	Set sc=$system.OBJ.Export(InternalName,filename,"/diffexport") 
 }
 If $$$ISOK(sc) {
 	Write:'$get(^ClearCase("nodisplay")) !,"Exported '",InternalName,"' to file '",filename,"'"
 	Set ^ClearCase(0,"FileTimeStamp",InternalName)=$zu(140,2,filename)
 } Else {
  	do DecomposeStatus^%apiOBJ(sc,.errors)
  	Do:'$get(^ClearCase("nodisplay"))&($g(errors(1,"code"))'=6301) DecomposeStatus^%apiOBJ(sc,.errors,"d")
 }
 Quit $$$OK
}

/// Called before the item is saved to the Cache database it is passed
/// a reference to the current temporary storage of this item so that it
/// can be modified before the save completes. If you quit with an error
/// value then it will abort the save.
Method OnBeforeSave(InternalName As %String, Location As %String, Object As %RegisteredObject = {$$$NULLOREF}) As %Status
{
 Quit $$$OK
}

/// Called before the compile of the item is done.
Method OnBeforeCompile(InternalName As %String) As %Status
{
 Quit $$$OK
}

/// Called after the compile of the item is done.
Method OnAfterCompile(InternalName As %String) As %Status
{
   Set filename=..ExternalName(InternalName)
   If filename="" Quit $$$OK
   Set name=$Piece(InternalName,".",1,$Length(InternalName,".")-1)
   Set ext=$ZConvert($Piece(InternalName,".",$Length(InternalName,".")),"U")
   If ( (ext'="CLS") ) { Quit $$$OK } //#
	// don't export ...admin.Build...
 	If ( $zu(140,1,filename)<0 ) { Do ..MakeDir(filename) }
 	If ( (ext="CLS") ) {
	 	Set sc=$system.OBJ.Export(InternalName,filename,"/diffexport") 
 	}
   If $$$ISOK(sc) {
      Write:'$get(^ClearCase("nodisplay")) !,"Exported '",InternalName,"' to file '",filename,"'"
      Set ^ClearCase(0,"FileTimeStamp",InternalName)=$zu(140,2,filename)
   } Else {
  	do DecomposeStatus^%apiOBJ(sc,.errors)
  	Do:'$get(^ClearCase("nodisplay"))&($g(errors(1,"code"))'=6301) DecomposeStatus^%apiOBJ(sc,.errors,"d")
   }
   
   Quit $$$OK
}

/// Create test script on drive c:\
Method CreateTestScript(aClassName As %String) As %Status
{
	set ScriptFile=##class(%File).%New("c:\test.scr")
	do ScriptFile.Open("WSN")

	do ScriptFile.WriteLine("send: zn """_$znspace_"TEST""<CR>")
	do ScriptFile.WriteLine("send: set Manager=##class(p6.unit.Manager).%New()<CR>")
	do ScriptFile.WriteLine("send: set Manager.Listener=##class(p6.unit.listener.Console).%New()<CR>")
	do ScriptFile.WriteLine("send: set Manager.Reporter=##class(p6.unit.reporter.Console).%New()<CR>")
	do ScriptFile.WriteLine("send: set Manager.Reporter.Listener=Manager.Listener<CR>")
	do ScriptFile.WriteLine("send: set Manager.Debug=1<CR>")

	do ScriptFile.WriteLine("send: set Manager.ClassList(""one"","""_aClassName_""")=""""<CR>")
	
	do ScriptFile.WriteLine("send: do Manager.RunClassList()<CR>")

	do ScriptFile.Close()
	
	set config=$zu(86)
	set configPath=$piece($piece(config,"*",1),"\",1,$length($piece(config,"*",1),"\")-1)
	set configName=$piece(config,"*",2)
	

	set BatchFile=##class(%File).%New("c:\test.bat")
	do BatchFile.Open("WSN")
	do BatchFile.WriteLine(configPath_"\Bin\cterm.exe /console=cn_ap:"_configName_"[USER] c:\test.scr")
	do BatchFile.Close()

	Quit $$$OK
}

/// Check this routine/class/csp file into source control.
Method CheckIn(InternalName As %String, Description As %String) As %Status
{
 Quit $$$ERROR(10000,"Работать с контролем версий можно только из VSSDB")
}

/// Check this routine/class/csp file out of source control.
Method CheckOut(InternalName As %String, Description As %String) As %Status
{
 Quit $$$ERROR(10000,"Работать с контролем версий можно только из VSSDB")
}

/// Get the latest version of this file from source control.
Method GetLatest(InternalName As %String) As %Status
{
 Quit $$$ERROR(10000,"Работать с контролем версий можно только из VSSDB")
}

/// Return information about this entity.
Method GetStatus(InternalName As %String, ByRef IsInSourceControl As %Boolean, ByRef Editable As %Boolean, ByRef IsCheckedOut As %Boolean, ByRef UserCheckedOut As %String) As %Status
{
   Set Editable=1,IsCheckedOut=0,UserCheckedOut=""
   Set filename=..ExternalName(InternalName)
   Set IsInSourceControl=(filename'="")
   If ( filename="" ) { Quit $$$OK } //#
   If ($zu(140,1,filename)<0) { Quit $$$OK } //#
   Open filename:"W":0 Set Editable=$T Close filename
   If ('Editable) {
	   Write:'$get(^ClearCase("nodisplay")) !,InternalName," locked in SourceControl"
   }
   Quit $$$OK
}

/// Add this routine/class/csp file to source control.
Method AddToSourceControl(InternalName As %String, Description As %String) As %Status
{
   Quit $$$OK
}

/// Remove this routine/class/csp file from source control.
Method RemoveFromSourceControl(InternalName As %String, Description As %String = "") As %Status
{
   Quit $$$OK
}

/// Returns true if this item is in source control and false otherwise.
Method IsInSourceControl(InternalName As %String) As %Boolean
{
   Quit ..ExternalName(InternalName)'=""
}

/// Convert the internal name, e.g. TEST.MAC to an external name that is used to export
/// the routine/class/csp item. This is often a filename to write the file out to.
Method ExternalName(InternalName As %String) As %String
{
    set nSpace=$zconvert($znspace,"L")	
   Set nam=$p(InternalName,".",1,$l(InternalName,".")-1),
   	ext=$p(InternalName,".",$l(InternalName,".")),
   	ext=$zcvt(ext,"u") 	

   If ( nam="" ) { Quit "" } //#
	If ( ext="CLS" ) {
		if $$$isWINDOWS {
			if ($GET(^p6("SourceDirWin"),"")="") {
				Write !," Set ^p6(""SourceDirWin"") to source directory. Setting default..."
				Quit "c:\Source\"_nSpace_"\classes\"_$translate(nam,".","\")_".xml"
			}else {
				Quit ##class(%Library.File).GetDirectory(^p6("SourceDirWin")_"\classes\")_$translate(nam,".","\")_".xml"
			}
		}else {
			if ($GET(^p6("SourceDirLinux"),"")="") {
				Write !," Set ^p6(""SourceDirLinux"") to source directory. Setting default..."
				Quit "/opt/Source/"_nSpace_"/classes/"_$translate(nam,".","/")_".xml"
			}else {
				Quit ##class(%Library.File).GetDirectory(^p6("SourceDirLinux")_"/classes/")_$translate(nam,".","/")_".xml"
			}
		} 
	}
	Quit ""
}

Method MakeDir(filename As %String) [ Private ]
{
 Set filename=$piece(filename,"\",1,$length(filename,"\")-1)
 If ( $zu(12,filename,2)="" ) {
 	For i=1:1:$length(filename,"\") Do $ZU(140,9,$piece(filename,"\",1,i))
 }
}

}

