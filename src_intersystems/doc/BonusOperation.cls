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
</Data>
<DataLocation>^doc.BonusOperationD</DataLocation>
<DefaultData>BonusOperationDefaultData</DefaultData>
<IdLocation>^doc.BonusOperationD</IdLocation>
<IndexLocation>^doc.BonusOperationI</IndexLocation>
<StreamLocation>^doc.BonusOperationS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

