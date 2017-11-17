Class admin.UserAccount Extends p6.Integrity [ ClassType = persistent ]
{

Index AkaIndex On Aka [ Unique ];

Property Aka As %String;

Property EncriptId As %String(MAXLEN = 350) [ SqlComputeCode = {set {EncriptId}=$system.Encryption.Base32Encode({Id},1)}, SqlComputed, SqlComputeOnChange = (%%UPDATE, %%INSERT) ];

ClassMethod CreateAccount(userName) As %Status
{
	&sql(insert into admin.UserAccount (Aka) values (:userName))
	quit $$$OK
}

Storage Default
{
<Data name="UserAccountDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Aka</Value>
</Value>
<Value name="3">
<Value>EncriptId</Value>
</Value>
</Data>
<DataLocation>^admin.UserAccountD</DataLocation>
<DefaultData>UserAccountDefaultData</DefaultData>
<IdLocation>^admin.UserAccountD</IdLocation>
<IndexLocation>^admin.UserAccountI</IndexLocation>
<StreamLocation>^admin.UserAccountS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

