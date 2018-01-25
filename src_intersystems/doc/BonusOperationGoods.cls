/// Покупаемые товары
Class doc.BonusOperationGoods Extends p6.Integrity [ ClassType = persistent ]
{

Relationship shop As ent.Shop [ Cardinality = one, Inverse = bonusOperationGoods ];

Index rowIndex On (shop, bonusOperation, goodsName) [ Unique ];

Relationship bonusOperation As doc.BonusOperation [ Cardinality = one, Inverse = bonusOperationGoods ];

Index bonusOperationIndex On bonusOperation;

Relationship goodsName As ent.GoodsName [ Cardinality = one, Inverse = bonusOperationGoods ];

Index goodsNameIndex On goodsName;

Property qty As %Float;

Property unit As %String;

Property price As %Float;

Property cost As %Float;

ClassMethod updateGoods(accountId, bonusOperationId, goods) As %Status
{
	set sc=$$$OK
	set ^a.updateGoods("goods")=goods
	if '(goods.%Extends("%Library.ListOfObjects")) {
		// quit $$$ERROR(1000,"Нет товаров")	
	}
	&sql(delete from doc.BonusOperationGoods where shop=:accountId and  bonusOperation = :bonusOperationId)
	set iter = goods.%GetIterator()
	while iter.%GetNext(.i , .goodsLine) {
   		set goodsNameId = ##class(ent.GoodsName).getGoodsNameId(accountId,goodsLine.goodsName,.sc)
   		set ^a.updateGoods(i)=sc
   		//if $$$ISERR(sc) quit
   		set unit = $ZCONVERT(goodsLine.unit,"I","UTF8")
   		set qty = $tr(goodsLine.qty,",",".")
   		set price = $tr(goodsLine.price,",",".")
   		set cost = $tr(goodsLine.cost,",",".")
   		
   		set ^a.updateGoods(i,"shop")=accountId
   		set ^a.updateGoods(i,"bonusOperationId")=bonusOperationId
   		set ^a.updateGoods(i,"goodsNameId")=goodsNameId
   		
   		set ^a.updateGoods(i,"groupName")=goodsLine.goodsGroup.groupName
   		set ^a.updateGoods(i,"parentGroup")=goodsLine.goodsGroup.goodsGroup
   		set ^a.updateGoods(i,"parentGroup.groupName")=goodsLine.goodsGroup.goodsGroup.groupName
   		
   		&sql(INSERT OR UPDATE into doc.BonusOperationGoods (shop,bonusOperation,goodsName,qty,unit,price,cost) 
 										values (:accountId,:bonusOperationId,:goodsNameId,:qty,:unit,:price,:cost))
 										
 		set ^a.updateGoods(i,"%msg")=%msg								
 		set ^a.updateGoods(i,"SQLCODE")=SQLCODE
 		if SQLCODE<0 {
	 		set sc = $$$ERROR(10000,%msg)
	 		//quit
 		}
   	}
		
	quit sc
}

Storage Default
{
<Data name="BonusOperationGoodsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>bonusOperation</Value>
</Value>
<Value name="3">
<Value>goodsName</Value>
</Value>
<Value name="4">
<Value>qty</Value>
</Value>
<Value name="5">
<Value>unit</Value>
</Value>
<Value name="6">
<Value>price</Value>
</Value>
<Value name="7">
<Value>cost</Value>
</Value>
<Value name="8">
<Value>shop</Value>
</Value>
</Data>
<DataLocation>^doc.BonusOperationGoodsD</DataLocation>
<DefaultData>BonusOperationGoodsDefaultData</DefaultData>
<IdLocation>^doc.BonusOperationGoodsD</IdLocation>
<IndexLocation>^doc.BonusOperationGoodsI</IndexLocation>
<StreamLocation>^doc.BonusOperationGoodsS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

