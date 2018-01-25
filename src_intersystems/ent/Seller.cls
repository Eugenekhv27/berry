/// Продавец
Class ent.Seller Extends p6.Integrity [ ClassType = persistent ]
{

Property aka As %String(MAXLEN = 300);

Index IndexAka On (shop, aka) [ Data = aka, Unique ];

Relationship bonusOperations As doc.BonusOperation [ Cardinality = many, Inverse = seller ];

Relationship shop As ent.Shop(JSONIGNORE = 1) [ Cardinality = one, Inverse = goodsName ];

ClassMethod getSellerId(accountId, sellerName, Output sc)
{
	set sellerName = $ZCONVERT(sellerName,"I","UTF8")
 	&sql(INSERT OR UPDATE into ent.Seller (shop,aka) values (:accountId,:sellerName))
 	if SQLCODE<0 {
	 set sc = $$$ERROR(10000,%msg)
	 quit 0	
 	} else {
	 	quit %ROWID	
 	}
}

Storage Default
{
<Data name="SellerDefaultData">
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
<DataLocation>^ent.SellerD</DataLocation>
<DefaultData>SellerDefaultData</DefaultData>
<IdLocation>^ent.SellerD</IdLocation>
<IndexLocation>^ent.SellerI</IndexLocation>
<StreamLocation>^ent.SellerS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

