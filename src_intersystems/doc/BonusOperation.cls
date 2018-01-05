/// Операции по бонусам
Class doc.BonusOperation Extends p6.Integrity [ ClassType = persistent ]
{

/// Дата операции
Property DocDate As p6.dt.Date [ InitialExpression = {+$H} ];

/// Номер чека
Property DocNo As %String;

/// Сумма покупок
Property RubSum As p6.dt.Money;

/// Сумма бонусов
Property PointsSum As p6.dt.Money;

/// Начисление бонусов
Property PlusPointsSum As p6.dt.Money [ Calculated, SqlComputeCode = { set {PlusPointsSum} = $select({PointsSum}>0:{PointsSum},1:"")}, SqlComputed ];

/// Списание бонусов
Property MinusPointsSum As p6.dt.Money [ Calculated, SqlComputeCode = { set {MinusPointsSum} = $select({PointsSum}<0:-{PointsSum},1:"")}, SqlComputed ];

/// Коментарий
Property Comment As %String(MAXLEN = 2000);

/// Покупатель
Relationship Buyer As ent.Buyer [ Cardinality = one, Inverse = BonusOperations ];

Index BuyerIndex On Buyer;

/// Уникальный индефикатор внешней системы
Property ByDocUUID As %String(MAXLEN = 100);

Index ByDocUUIDIndex On (Shop, ByDocUUID) [ Unique ];

/// Магазин
Relationship Shop As ent.Shop(JSONIGNORE = 1) [ Cardinality = one, Inverse = BonusOperations ];

Relationship bonusOperationGoods As doc.BonusOperationGoods(JSONIGNORE = 1) [ Cardinality = many, Inverse = bonusOperation ];

/// Кодовое слово
Property CodeWord As %String;

/// Рейтинг к отзыву
Property rating As %Integer;

/// Продавец
Relationship seller As ent.Seller [ Cardinality = one, Inverse = bonusOperations ];

ClassMethod GetForGrid(query = "", accountId = "", citeriaObject = {{}}) As %Status
{
     kill ^a.sql
	//set ^a.citeriaObject = citeriaObject.%ToJSON()

    set st = $$$OK
    //set sql = "select top 1000 Id,DocDate,nvl(Buyer->Name,'') ||' '||Buyer->Aka as name,DocNo,"
    set sql = "select top 1000 Id,DocDate,Buyer->Aka as name,DocNo,"
    	_" RubSum, PlusPointsSum, MinusPointsSum"
    	_" from doc.BonusOperation b"
    	_ " where Shop="_accountId 
    	
    if (citeriaObject.beginRegDate]"") {
	 	set beginRegDate = ##class(p6.Date).DisplayToLogical(citeriaObject.beginRegDate)
	 	set beginRegDate = $ZD(beginRegDate,3)
	 	set sql = sql _" and DocDate>='"_beginRegDate_"'"
    }
    if (citeriaObject.endRegDate]"") {
	 	set beginRegDate = ##class(p6.Date).DisplayToLogical(citeriaObject.endRegDate)
	 	set beginRegDate = $ZD(beginRegDate,3)
	 	set sql = sql _" and DocDate<='"_beginRegDate_"'"
    }
    if (citeriaObject.beginBonusSum]"") {
	 	set sql = sql _" and PointsSum>="_citeriaObject.beginBonusSum
    }
    if (citeriaObject.endBonusSum]"") {
	 	set sql = sql _" and PointsSum<="_citeriaObject.endBonusSum
    }
    if (citeriaObject.tel]"") {
	 	set sql = sql _" and Buyer->Aka='"_citeriaObject.tel_"'"
    }
    
    //if (citeriaObject.abcGroup]"") { // Группа ABC
	//    set sql = sql _" and (abcGroup = '"_citeriaObject.abcGroup_"')"
    //}
    	
    if query]"" {
	 set sql = sql _" and "_query  
    }
	set sql = sql _ " order by DocDate"
	set ^a.sql = sql
    set ^a.sql(1) = citeriaObject.abcGroup
    do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,sql,,1000)
    quit st
}

Storage Default
{
<Data name="BonusOperationDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RubSum</Value>
</Value>
<Value name="3">
<Value>Comment</Value>
</Value>
<Value name="4">
<Value>Buyer</Value>
</Value>
<Value name="5">
<Value>ByDocUUID</Value>
</Value>
<Value name="6">
<Value>PointsSum</Value>
</Value>
<Value name="7">
<Value>DocDate</Value>
</Value>
<Value name="8">
<Value>Shop</Value>
</Value>
<Value name="9">
<Value>CodeWord</Value>
</Value>
<Value name="10">
<Value>DocNo</Value>
</Value>
<Value name="11">
<Value>rating</Value>
</Value>
<Value name="12">
<Value>seller</Value>
</Value>
</Data>
<DataLocation>^doc.BonusOperationD</DataLocation>
<DefaultData>BonusOperationDefaultData</DefaultData>
<IdLocation>^doc.BonusOperationD</IdLocation>
<IndexLocation>^doc.BonusOperationI</IndexLocation>
<StreamLocation>^doc.BonusOperationS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

