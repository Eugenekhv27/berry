Class ent.GoodsName Extends p6.Integrity [ ClassType = persistent ]
{

Property aka As %String(MAXLEN = 300);

Index IndexAka On (shop, aka) [ Data = aka, Unique ];

Relationship bonusOperationGoods As doc.BonusOperationGoods [ Cardinality = many, Inverse = goodsName ];

Relationship shop As ent.Shop [ Cardinality = one, Inverse = goodsName ];

ClassMethod getGoodsNameId(accountId, goodsName, Output sc)
{
	set goodsName = $ZCONVERT(goodsName,"I","UTF8")
 	&sql(INSERT OR UPDATE into ent.GoodsName (shop,aka) values (:accountId,:goodsName))
 	if SQLCODE<0 {
	 set sc = $$$ERROR(10000,%msg)
	 quit 0	
 	} else {
	 	quit %ROWID	
 	}
}

Storage Default
{
<Data name="GoodsNameDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>aka</Value>
</Value>
<Value name="3">
<Value>shop</Value>
</Value>
</Data>
<DataLocation>^ent.GoodsNameD</DataLocation>
<DefaultData>GoodsNameDefaultData</DefaultData>
<IdLocation>^ent.GoodsNameD</IdLocation>
<IndexLocation>^ent.GoodsNameI</IndexLocation>
<StreamLocation>^ent.GoodsNameS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

