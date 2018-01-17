/// Ранг участника на дату
Class ent.City Extends p6.Integrity [ ClassType = persistent ]
{

Index IndexName On (shop, name) [ Data = (name, shop), Unique ];

Property name As %String(MAXLEN = 200) [ Required ];

Property shop As ent.Shop [ Required ];

ClassMethod GetByAka(shop, aAka) As ent.City
{
	if $IsObject(shop) set shopId=shop.%Id()
	else  quit ""
	&sql(insert or update ent.City (name,shop) values (:aAka,:shopId))
	if %ROWID>0 {
		quit ..%OpenId(%ROWID)	
	}
	quit ""
}

Storage Default
{
<Data name="CityDefaultData">
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
<DataLocation>^ent.CityD</DataLocation>
<DefaultData>CityDefaultData</DefaultData>
<IdLocation>^ent.CityD</IdLocation>
<IndexLocation>^ent.CityI</IndexLocation>
<StreamLocation>^ent.CityS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

