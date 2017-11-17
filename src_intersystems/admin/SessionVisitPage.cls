Class admin.SessionVisitPage Extends p6.Persistent [ ClassType = persistent, ProcedureBlock ]
{

/// Страница на которую зашёл пользователь
Property Page As %String [ Required ];

/// Дата время
Property DateTime As %TimeStamp;

// Property Session As admin.Session [ Required ];

/// Сессия
Property Params As %String(MAXLEN = 1024);

Storage Default
{
<Data name="SessionVisitPageDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Page</Value>
</Value>
<Value name="3">
<Value>DateTime</Value>
</Value>
<Value name="4">
<Value>Session</Value>
</Value>
<Value name="5">
<Value>Params</Value>
</Value>
</Data>
<DataLocation>^admin.SessionVisitPageD</DataLocation>
<DefaultData>SessionVisitPageDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^admin.SessionVisitPageD</IdLocation>
<IndexLocation>^admin.SessionVisitPageI</IndexLocation>
<Property name="DateTime"/>
<Property name="Page"/>
<Property name="Params"/>
<Property name="Session"/>
<StreamLocation>^admin.SessionVisitPageS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

