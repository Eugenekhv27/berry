/// Проверка данных в классах
Class p6.ClassValidate Extends %Library.RegisteredObject [ ClassType = "", ProcedureBlock ]
{

Parameter CAPTION = "Проверка данных в классах";

/// Проверка данных в классе
ClassMethod Class(class As %String = "", ByRef report As %String) As %Status [ Final, PublicList = (z, Id) ]
{
 	if (class = "") { quit $$$OK } //#
 	set result=##class(%ResultSet).%New("%DynamicQuery:SQL")
	do result.Prepare("SELECT ID FROM "_class)
	do result.Execute(10000)
	for  {
	   quit:'result.Next()  //#
		do Verify
	}
	do result.Close()
	kill result
	quit $$$OK
	
	/// проверка загрузки и корректности данных в объекте
Verify	
   set $ztrap = "ErrVerify"
   set Id = result.Data("ID")
   xecute "set z = ##class("_class_").%OpenId(Id)"
   set $zobjmod(z,0)=1 // IsModified for validation
   set sc = z.%ValidateObject()
   if ( 'sc ) {
      set scText = sc
      if (class="fd.FinDoc") {set Id=Id_" <"_z.Aka_">"}
      set report($increment(report)) = $lb(class,Id,scText)
      Write Id,", "
   }
   kill z
	quit  //Verify
	
	/// обработка ошибки открытия объекта
ErrVerify
    set $ztrap = ""
    set scText = $$$ERROR(10000,$ze)
    set scText = $translate(scText,"<>","()")
    set report($increment(report)) = $lb(class,Id,scText)
	quit  // ErrVerify
}

/// Проверяет данные во всех хранимых классах в текущей области
ClassMethod AllClasses(ByRef report As %String, silent As %Library.String = "", admin As p6.dt.Boolean = 0) As %Status [ Final, PublicList = className ]
{
 // список всех классов в области
 set time = $piece($h,",",2)
 set result=##class(%Library.ResultSet).%New("%Library.ClassDefinition:ClassInfo")
 do result.Execute()
 while (result.Next()) {
    if ( result.Get("Persistent") && ('result.Get("System")) ) {
       if ('silent) { write !,result.Get("Name"),":",result.Get("Persistent"),":",
       result.Get("System")      //,":",result.Get("Super")
       write " - "
    }
    set className = result.Get("Name")
    // не проверять вспомогательные классы
    if (className["admin.Log" ) {}
    else  {
	    do ..Class(className,.report)
       if ('silent) {
	       write $j("",30-$length(className))," - Varified..." }
       }
    }       
 }
 do result.Close()
 kill result
 set time = $piece($h,",",2) - time
 write !,"время работы: ",time\60," мин. ",time#60," сек.",!
 quit $$$OK
}

/// Проверяет все глобали в текущей области на соответствие
/// последнего значения индекса 1 уровня данному на уровне глобали
ClassMethod AllGlobals() As %Status
{
	// список всех глобалей в области
	set rs = ##class(%ResultSet).%New("%SYS.GlobalQuery:NameSpaceList")
 	
	Set sc=rs.Execute($znspace,,0) 
	If $$$ISERR(sc) Do DisplayError^%apiOBJ(sc) Quit sc

	write !,"    Сверка счетчиков на классах с последним индексом 1 уровня"
	write !,"        - печатаются только глобали с отличающимися значениями"
	write !!,"^имя = счетчик / наибольшее значение"
	While rs.Next(.sc) {
		If $$$ISERR(sc) Quit
		set name = "^"_rs.Data("Name")
	 	// проверка на наличие счетчика на уровне имени (число)
	 	if $get(@name)=+$get(@name) {
	 		set last = $order(@(name_"("""")"),-1)
	 		if ($get(@name)'=last) {
	 			write !,name," = ",$get(@name)," / ",last
	 		}
	 	}
	}
	If $$$ISERR(sc) Do DisplayError^%apiOBJ(sc) Quit sc
		
	quit $$$OK
}

}

