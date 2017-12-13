/// Ранг участника на дату
Class ent.BuyerAbcGroup Extends p6.Integrity [ ClassType = persistent ]
{

Index onDateBuyer On (onDate, buyer) [ Unique ];

Property buyer As ent.Buyer [ Required ];

Property onDate As p6.dt.Date [ Required ];

Property groupName As %String;

Storage Default
{
<Data name="BuyerAbcGroupDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>buyer</Value>
</Value>
<Value name="3">
<Value>onDate</Value>
</Value>
<Value name="4">
<Value>groupName</Value>
</Value>
</Data>
<DataLocation>^ent.BuyerAbcGroupD</DataLocation>
<DefaultData>BuyerAbcGroupDefaultData</DefaultData>
<IdLocation>^ent.BuyerAbcGroupD</IdLocation>
<IndexLocation>^ent.BuyerAbcGroupI</IndexLocation>
<StreamLocation>^ent.BuyerAbcGroupS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

