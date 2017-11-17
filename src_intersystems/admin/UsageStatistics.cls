/// Статистика использования элементов
Class admin.UsageStatistics Extends %Persistent
{

Property DateUsage As %TimeStamp;

Property UserAka As %String;

Property ClassName As %String;

Property FieldName As %String;

Property FieldAka As %String;

Property FieldValue As %String;

ClassMethod GetUsageStatistics(classname, OREFclassname)
{
	Set cdef = ##class(%Dictionary.ClassDefinition).%OpenId(classname)
	Set userAka = %session.Data("UserSys",$username,"Aka")
	Set count = cdef.Properties.Count()
	Set dateusage = ##class(p6.Date).HToTimeStamp($h)
 	For i = 1:1:count {
     	Set propname = cdef.Properties.GetAt(i).Name 
		Set npropvalue = ##class(%Library.ClassDefinition).%OpenId(classname)
		Set propvalue = $PROPERTY(OREFclassname, propname)
     	If (propvalue '= "") { 
     		if ($ISOBJECT(propvalue))
     		{
	     		Set propvalue = propvalue.%Id()
     		}
     		set fieldAka = ##class(p6.ClassDefinition).GetPropertyCaption(classname,propname)
     		&sql(Insert into admin.UsageStatistics (ClassName, DateUsage, FieldName,FieldAka, UserAka , FieldValue) 
     			values (:classname, :dateusage, :propname, :fieldAka, :userAka, :propvalue)) 
     	}
     }
}

Storage Default
{
<Data name="UsageStatisticsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Date</Value>
</Value>
<Value name="3">
<Value>Login</Value>
</Value>
<Value name="4">
<Value>ClassName</Value>
</Value>
<Value name="5">
<Value>FieldName</Value>
</Value>
<Value name="6">
<Value>DateUsage</Value>
</Value>
<Value name="7">
<Value>BasicDocument</Value>
</Value>
<Value name="8">
<Value>UserAka</Value>
</Value>
<Value name="9">
<Value>FieldAka</Value>
</Value>
<Value name="10">
<Value>FieldValue</Value>
</Value>
</Data>
<DataLocation>^admin.UsageStatisticsD</DataLocation>
<DefaultData>UsageStatisticsDefaultData</DefaultData>
<IdLocation>^admin.UsageStatisticsD</IdLocation>
<IndexLocation>^admin.UsageStatisticsI</IndexLocation>
<StreamLocation>^admin.UsageStatisticsS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

