Class admin.UserSysStore Extends %Persistent
{

Property Usersys As admin.UserSys;

Property Field As %String;

Property Value As %String;

ClassMethod Get(field As %String = "") As %String
{
	if field = "" quit
	Set qUserSysId = %session.Data("UserSys",$username,"UserSysId")
	&sql(select Value into :nValue from admin.UserSysStore where Usersys = :qUserSysId and Field = :field)
	if (SQLCODE'=0) set nValue = ""
	
	Quit nValue
}

ClassMethod Set(field As %String = "", value As %String = "") As %Status
{
	if field = "" quit
	Set qUserSysId = %session.Data("UserSys",$username,"UserSysId")
	Set welldone = 0
	&sql(select Usersys, Field into :nUserSys, :nField  from admin.UserSysStore where Usersys = :qUserSysId and Field = :field)
	if (SQLCODE'=0)
		{
			&sql(insert into admin.UserSysStore (Usersys, Field, Value) values (:qUserSysId, :field, :value))
		}
	else 
		{
			&sql(update admin.UserSysStore set Value = :value where Usersys = :qUserSysId and Field = :field)
		}
	quit $$$OK
}

Storage Default
{
<Data name="UserSysStoreDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Usersys</Value>
</Value>
<Value name="3">
<Value>DefaultReportType</Value>
</Value>
<Value name="4">
<Value>Field</Value>
</Value>
<Value name="5">
<Value>Value</Value>
</Value>
</Data>
<DataLocation>^admin.UserSysStoreD</DataLocation>
<DefaultData>UserSysStoreDefaultData</DefaultData>
<IdLocation>^admin.UserSysStoreD</IdLocation>
<IndexLocation>^admin.UserSysStoreI</IndexLocation>
<StreamLocation>^admin.UserSysStoreS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

