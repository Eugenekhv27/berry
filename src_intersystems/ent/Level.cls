/// Ранг участника на дату
Class ent.Level Extends p6.Integrity [ ClassType = persistent ]
{

Property name As %String [ Required ];

Property shop As ent.Shop [ Required ];

Storage Default
{
<Data name="LevelDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>name</Value>
</Value>
<Value name="3">
<Value>shop</Value>
</Value>
</Data>
<DataLocation>^ent.LevelD</DataLocation>
<DefaultData>LevelDefaultData</DefaultData>
<IdLocation>^ent.LevelD</IdLocation>
<IndexLocation>^ent.LevelI</IndexLocation>
<StreamLocation>^ent.LevelS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

