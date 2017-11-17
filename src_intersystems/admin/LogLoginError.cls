Class admin.LogLoginError Extends admin.Log [ ClassType = persistent, Not ProcedureBlock ]
{

Property Login As %String(TRUNCATE = 1);

Property Password As %String(TRUNCATE = 1);

ClassMethod Put(login As %String, password As %String, comment As %String)
{
 new log
 set log = ..%New()
 set log.Login = login
 set log.Password = password
 set log.Comment = comment
 do log.%Save()
 do log.%Close()
}

Storage Default
{
<Data name="LogLoginErrorDefaultData">
<Subscript>"LogLoginError"</Subscript>
<Value name="1">
<Value>Login</Value>
</Value>
<Value name="2">
<Value>Password</Value>
</Value>
</Data>
<DefaultData>LogLoginErrorDefaultData</DefaultData>
<Type>%CacheStorage</Type>
}

}

