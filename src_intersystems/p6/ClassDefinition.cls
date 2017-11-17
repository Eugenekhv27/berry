Include (%occCompiler, %occReferenceStorage)

/// *********************************************************************************
/// **
/// **
/// **    Класс для работы с определениями классов, свойств и т.п.
/// **
/// **
/// *********************************************************************************
Class p6.ClassDefinition Extends %Library.RegisteredObject [ ClassType = "", ProcedureBlock ]
{

/// делает глобаль - определение классов и их свойств
/// работать с этой глобалью можно только через методы
ClassMethod UpdateData() As %Status
{
	quit $$$OK
}

ClassMethod IsClassPersistent(className As %String = "") As p6.dt.Boolean
{
  if (className="") quit ""
  quit $$$comClassKeyGet(className,$$$cCLASSclasstype)="persistent"
}

ClassMethod IsClassSerial(className As %String = "") As p6.dt.Boolean
{
  if (className="") quit ""
  quit $$$comClassKeyGet(className,$$$cCLASSclasstype)="serial"
}

ClassMethod GetClassDescription(className As %String = "") As %String
{
  if (className="") quit ""
  quit $$$comClassKeyGet(className,$$$cCLASSdescription)
}

ClassMethod GetClassCaption(className As %String = "") As %String
{
  if (className="") quit ""
  set result=$$$comMemberKeyGet(className,$$$cCLASSparameter,"CAPTION",$$$cPARAMdefault)
  if result="" set result=$$$comClassKeyGet(className,$$$cCLASSdescription)
  if result="" set result=className
  quit result
}

ClassMethod GetClassSecureType(className As %String = "") As %String
{
  if (className="") quit ""
  quit $$$comMemberKeyGet(className,$$$cCLASSparameter,"SecureType",$$$cPARAMdefault)
}

ClassMethod GetClassSuper(className As %String = "") As %String
{
  if (className="") quit ""
  quit $$$defClassKeyGet(className,$$$cCLASSsuper)
}

ClassMethod GetParameter(className As %String = "", parameterName As %String = "") As %String
{
  if ((className="") || (parameterName="")) quit ""
  quit $$$comMemberKeyGet(className,$$$cCLASSparameter,parameterName,$$$cPARAMdefault)
}

ClassMethod GetPropertyList(className As %String = "") As %List
{
  if (className="") quit ""

  set Rs=##class(%ResultSet).%New("%Dictionary.CompiledProperty:Summary")
  do Rs.Prepare()
  do Rs.Execute(className)
  
  set plist=""
  while (Rs.Next())
  {
    if Rs.Get("Name")'["%" set plist = plist_$ListBuild(Rs.Get("Name"))
  }

  quit plist
}

ClassMethod GetPropertyType(className As %String = "", propertyName As %String = "") As %String
{
  if ((className="") || (propertyName="")) quit ""

  do ##class(p6.ClassDefinition).CorrectData(.className,.propertyName)

  // если свойство простое, то сразу берем из глобали
  // если составное - то прыгаем по глобали
  if ($length(propertyName,".")=1)
  {
    set propertyType = $$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPtype)
  }
  else
  {
    set propertyType = className
    for i=1:1:$length(propertyName,".")
    {
      set str = $piece(propertyName,".",i)
      if ((propertyType="") || (str="")) quit
      set propertyType = $$$comMemberKeyGet(propertyType,$$$cCLASSproperty,str,$$$cPROPtype)
    }
  }
  quit propertyType
}

ClassMethod GetPropertyCaption(className As %String = "", propertyName As %String = "") As %String
{
  if ((className="") || (propertyName="")) quit ""


  do ##class(p6.ClassDefinition).CorrectData(.className,.propertyName)

  // если свойство простое, то сразу берем из глобали
  // если составное - то прыгаем по глобали
  if ($length(propertyName,".")=1)
  {
	 set propertyCaption = $$$comMemberArrayGet(className,$$$cCLASSproperty,propertyName,$$$cPROPparameter,"CAPTION")
    if propertyCaption="" set propertyCaption = $$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPdescription)
  }
  else
  {
    set propertyType = className, propertyCaption = ""
    for i=1:1:$length(propertyName,".")-1
    {
      set str = $piece(propertyName,".",i)
      if ((propertyType="") || (str="")) quit
      set propertyType = $$$comMemberKeyGet(propertyType,$$$cCLASSproperty,str,$$$cPROPtype)
    }
    set propertyName = $piece(propertyName,".",$length(propertyName,"."))
	 set propertyCaption = $$$comMemberArrayGet(className,$$$cCLASSproperty,propertyName,$$$cPROPparameter,"CAPTION")
    if propertyCaption="" set propertyCaption = $$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPdescription)
  }
  
  if propertyCaption="" quit propertyName
  quit propertyCaption
}

ClassMethod GetPropertyCollection(className As %String = "", propertyName As %String = "") As %String
{
  if ((className="") || (propertyName="")) quit ""
  quit $$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPcollection)
}

ClassMethod GetPropertySequenceNumber(className As %String = "", propertyName As %String = "") As %String
{
  if ((className="") || (propertyName="")) quit ""
  quit $$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPsequencenumber)
}

ClassMethod IsPropertyRequired(className As %String = "", propertyName As %String = "") As p6.dt.Boolean
{
  if ((className="") || (propertyName="")) quit ""
  quit $$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPrequired)
}

ClassMethod IsPropertyCalculated(className As %String = "", propertyName As %String = "") As p6.dt.Boolean
{
  if ((className="") || (propertyName="")) quit ""
  quit $$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPcalculated)
}

ClassMethod IsPropertyTransient(className As %String = "", propertyName As %String = "") As p6.dt.Boolean
{
  if ((className="") || (propertyName="")) quit ""
  quit $$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPtransient)
}

ClassMethod IsPropertyPrivate(className As %String = "", propertyName As %String = "") As p6.dt.Boolean
{
  if ((className="") || (propertyName="")) quit ""
  quit $$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPprivate)
}

ClassMethod IsIntegrityForProperty(className As %String = "", propertyName As %String = "") As p6.dt.Boolean
{
  if ((className="") || (propertyName="")) quit ""
  set str =""
  set str = $$$comMemberKeyGet(className,$$$cCLASSparameter,"NotIntegrityProperties",$$$cPARAMdefault)
  quit $find(","_str_",",","_propertyName_",")=0
}

/// [Previously private]
ClassMethod CorrectData(ByRef className As %String = "", ByRef propertyName As %String = "")
{
  // убираем пробелы в имени свойства и имени класса
  set propertyName = $translate(propertyName," ",""), 
  className = $translate(className," ","")
  // заменяем разделитель "->" на "."
  set propertyName = ##class(p6.Convert).Replace(propertyName,"->",".")
}

ClassMethod GetIndexDescription(className As %String = "", indexName As %String = "") As %String
{
  if ((className="") || (indexName="")) quit ""
  quit $$$comMemberKeyGet(className,$$$cCLASSindex,indexName,$$$cINDEXdescription)
}

}

