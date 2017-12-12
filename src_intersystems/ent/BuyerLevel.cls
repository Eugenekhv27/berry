/// Ранг участника на дату
Class ent.BuyerLevel Extends p6.Integrity [ ClassType = persistent ]
{

Property buyer As ent.Buyer [ Required ];

Property onDate As p6.dt.Date [ Required ];

Property guestLevel As ent.Level [ Required ];

Storage Default
{
<Data name="BuyerLevelDefaultData">
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
<Value>guestLevel</Value>
</Value>
</Data>
<DataLocation>^ent.BuyerLevelD</DataLocation>
<DefaultData>BuyerLevelDefaultData</DefaultData>
<IdLocation>^ent.BuyerLevelD</IdLocation>
<IndexLocation>^ent.BuyerLevelI</IndexLocation>
<StreamLocation>^ent.BuyerLevelS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

