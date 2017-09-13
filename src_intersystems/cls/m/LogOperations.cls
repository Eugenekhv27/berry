Class m.LogOperations Extends p6.Integrity [ ClassType = persistent ]
{

Property SessionId As %String;

Property OnDate As p6.dt.Date;

Property OnTime As p6.dt.Time;

Property Comment As %String(MAXLEN = 3000);

ClassMethod AddLogLine(operation, comment = "") As %Status [ ProcedureBlock = 0 ]
{
	
	set qSession = %session.SessionId
	set qOnDate = +$H
	set qOnTime = $p($H,",",2)
	&sql(insert into m.LogOperations (SessionId,OnDate,OnTime,Comment)
		Values (:qSession,:qOnDate,:qOnTime,:comment))
	
	quit $$$OK
}

Storage Default
{
<Data name="LogOperationsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SessionId</Value>
</Value>
<Value name="3">
<Value>Operation</Value>
</Value>
<Value name="4">
<Value>OnDate</Value>
</Value>
<Value name="5">
<Value>OnTime</Value>
</Value>
<Value name="6">
<Value>Comment</Value>
</Value>
</Data>
<DataLocation>^m.LogOperationsD</DataLocation>
<DefaultData>LogOperationsDefaultData</DefaultData>
<IdLocation>^m.LogOperationsD</IdLocation>
<IndexLocation>^m.LogOperationsI</IndexLocation>
<StreamLocation>^m.LogOperationsS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

