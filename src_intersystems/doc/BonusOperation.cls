/// Операции по бонусам
Class doc.BonusOperation Extends p6.Integrity [ ClassType = persistent ]
{

/// Дата операции
Property DocDate As p6.dt.Date [ InitialExpression = {+$H} ];

/// Номер чека
Property DocNo As %String;

/// Сумма покупок
Property RubSum As %Decimal;

/// Сумма бонусов
Property PointsSum As %Decimal;

/// Начисление бонусов
Property PlusPointsSum As %Decimal [ Calculated, SqlComputeCode = { set {PlusPointsSum} = $select({PointsSum}>0:{PointsSum},1:"")}, SqlComputed ];

/// Списание бонусов
Property MinusPointsSum As %Decimal [ Calculated, SqlComputeCode = { set {MinusPointsSum} = $select({PointsSum}<0:-{PointsSum},1:"")}, SqlComputed ];

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
    set st = $$$OK

    set sql = "select top 1000 Id as id,DocDate as docDate,Buyer->Aka as participantName,DocNo as docNo,"
    	_" RubSum as money, PlusPointsSum as plusPoints, MinusPointsSum as minusPoints,Buyer as participantId"
    	_" from doc.BonusOperation b"
    	_ " where Shop="_accountId 
    
    set filter = " "	
    if (citeriaObject.beginRegDate]"") {
	 	set beginRegDate = ##class(p6.Date).DisplayToLogical(citeriaObject.beginRegDate)
	 	set beginRegDate = $ZD(beginRegDate,3)
	 	set filter = filter _" and DocDate>='"_beginRegDate_"'"
    }
    if (citeriaObject.endRegDate]"") {
	 	set beginRegDate = ##class(p6.Date).DisplayToLogical(citeriaObject.endRegDate)
	 	set beginRegDate = $ZD(beginRegDate,3)
	 	set filter = filter _" and DocDate<='"_beginRegDate_"'"
    }
    if (citeriaObject.beginBonusSum]"") {
	 	set filter = filter _" and PointsSum>="_citeriaObject.beginBonusSum
    }
    if (citeriaObject.endBonusSum]"") {
	 	set filter = filter _" and PointsSum<="_citeriaObject.endBonusSum
    }
    if (citeriaObject.tel]"") {
	 	set filter = filter _" and Buyer->Aka='"_citeriaObject.tel_"'"
    }
    
    //if query]"" {
	// set sql = sql _" and "_query  
    //}
	// set sql = sql _ " order by DocDate"
	set ^a.sql = sql
    set ^a.sql(1) = citeriaObject.abcGroup
    write "["
    do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,sql_filter_" order by DocDate",,1000)
	write ","
	set provider = ##class(%ZEN.Auxiliary.jsonSQLProvider).%New()
	set provider.arrayName="totals"
	set provider.sql="select"
    	_" sum(RubSum) as rubSum, sum(PlusPointsSum) as plusPointsSum, sum(MinusPointsSum) as minusPointsSum"
    	_" from doc.BonusOperation"
    	_" where Shop="_accountId _ filter
	set provider.maxRows = 1000
	do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,,,,,provider)
	write "]"
    
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

