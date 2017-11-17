Class admin.Log Extends %Persistent [ ClassType = persistent, Not ProcedureBlock ]
{

Property DtLog As %TimeStamp;

// Property Session As admin.Session;

Property UserSys As admin.UserSys;

Property Comment As %String(MAXLEN = 200, TRUNCATE = 1);

Method %OnBeforeSave(Insert As p6.dt.Boolean) As %Status [ Private ]
{
 /*	
 set ..DtLog = ##class(p6.Date).HToTimeStamp($h)

 if ($data(Session)) {
    set ..Session = Session
    set ..UserSys = Session.UserSys
    &js<alert("b=#(..UserSys.Aka)#")>
 }
 */
 quit $$$OK
}

Method Save() As %Library.Status [ PublicList = NewObject ]
{
   set ..DtLog = ##class(p6.Date).HToTimeStamp($h)
   //set ..UserSys = ##class(admin.UserSys).%OpenId(%session.Data("UserSys",$username,"UserSysId"))
   set sc = ..%Save()
   if ($$$ISERR(sc)) { quit sc }
   quit $$$OK
}

Storage Default
{
<Data name="LogDefaultData">
<Value name="1">
<Value>DtLog</Value>
</Value>
<Value name="2">
<Value>Session</Value>
</Value>
<Value name="3">
<Value>UserSys</Value>
</Value>
<Value name="4">
<Value>Comment</Value>
</Value>
<Value name="5">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^admin.LogD</DataLocation>
<DefaultData>LogDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^admin.LogD</IdLocation>
<IndexLocation>^admin.LogI</IndexLocation>
<Property name="Comment"/>
<Property name="DtLog"/>
<Property name="Session"/>
<Property name="UserSys"/>
<StreamLocation>^admin.LogS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

