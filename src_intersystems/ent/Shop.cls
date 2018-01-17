/// Магазин
Class ent.Shop Extends p6.Integrity [ ClassType = persistent ]
{

/// Это наименование уже есть
Index AkaIndex On Aka [ Unique ];

/// Наименование
Property Aka As %String(MAXLEN = 200);

/// Логин для входа в систему
Property Login As %String;

/// Массив логинов с указанием роли: admin или seller
Property Logins As array Of %String;

Property EncriptId As %String(MAXLEN = 350) [ SqlComputeCode = {set {EncriptId}=$system.Encryption.Base32Encode({Id},1)}, SqlComputed, SqlComputeOnChange = (%%UPDATE, %%INSERT) ];

Relationship BonusOperations As doc.BonusOperation [ Cardinality = many, Inverse = Shop ];

Relationship Buyer As ent.Buyer [ Cardinality = many, Inverse = Shop ];

Relationship goodsName As ent.GoodsName [ Cardinality = many, Inverse = shop ];

Relationship bonusOperationGoods As doc.BonusOperationGoods [ Cardinality = many, Inverse = shop ];

/// Примечание
Property Comment As %String(MAXLEN = 2000);

/// Код для доступа в приложение для покупателей
Property AccessCode As %String(MAXLEN = 4, MINLEN = 4);

Property smscLogin As %String;

Property smscPassword As %String;

ClassMethod CreateLogin(shopId, login, role) As %Status
{
	if (role="admin") || (role="seller") {
		set obj = ..%OpenId(shopId)
		set sc = obj.Logins.SetAt(login,role)
		set sc = obj.Save()
	} else {
		set sc = $$$ERROR(1000,"Роль должна быть admin или seller")	
	}
	quit sc
}

Storage Default
{
<Data name="Logins">
<Attribute>Logins</Attribute>
<Structure>subnode</Structure>
<Subscript>"Logins"</Subscript>
</Data>
<Data name="ShopDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Aka</Value>
</Value>
<Value name="3">
<Value>Login</Value>
</Value>
<Value name="4">
<Value>EncriptId</Value>
</Value>
<Value name="5">
<Value>Comment</Value>
</Value>
<Value name="6">
<Value>AccessCode</Value>
</Value>
<Value name="7">
<Value>smscLogin</Value>
</Value>
<Value name="8">
<Value>smscPassword</Value>
</Value>
</Data>
<DataLocation>^ent.ShopD</DataLocation>
<DefaultData>ShopDefaultData</DefaultData>
<IdLocation>^ent.ShopD</IdLocation>
<IndexLocation>^ent.ShopI</IndexLocation>
<StreamLocation>^ent.ShopS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

