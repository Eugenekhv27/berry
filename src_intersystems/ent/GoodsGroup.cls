Class ent.GoodsGroup Extends p6.Integrity [ ClassType = persistent ]
{

Property aka As %String(MAXLEN = 300);

Index IndexAka On (shop, aka) [ Data = aka, Unique ];

Index ParentGroupIndex On ParentGroup;

Relationship shop As ent.Shop [ Cardinality = one, Inverse = goodsName ];

Relationship goodsName As ent.GoodsName [ Cardinality = many, Inverse = goodsGroup ];

Relationship ParentGroup As ent.GoodsGroup [ Cardinality = one, Inverse = ChildGroups ];

Relationship ChildGroups As ent.GoodsGroup [ Cardinality = many, Inverse = ParentGroup ];

ClassMethod getGoodsGroupId(accountId, goodsGroup, Output sc)
{
	set goodsGroup = $ZCONVERT(goodsGroup,"I","UTF8")
 	&sql(INSERT OR UPDATE into ent.GoodsName (shop,aka) values (:accountId,:goodsGroup))
 	if SQLCODE<0 {
	 set sc = $$$ERROR(10000,%msg)
	 quit 0	
 	} else {
	 	quit %ROWID	
 	}
}

Storage Default
{
<Data name="GoodsGroupDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>aka</Value>
</Value>
<Value name="3">
<Value>shop</Value>
</Value>
<Value name="4">
<Value>ParentGroup</Value>
</Value>
</Data>
<DataLocation>^ent.GoodsGroupD</DataLocation>
<DefaultData>GoodsGroupDefaultData</DefaultData>
<IdLocation>^ent.GoodsGroupD</IdLocation>
<IndexLocation>^ent.GoodsGroupI</IndexLocation>
<StreamLocation>^ent.GoodsGroupS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

