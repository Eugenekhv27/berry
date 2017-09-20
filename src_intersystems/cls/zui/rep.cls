/// Сводный отчет по бонусам
Class zui.rep Extends %Persistent
{

/*///Ввод\\\*/
/// Дата с
Property BeginDate As p6.dt.Date [ Transient ];

/// по
Property EndDate As p6.dt.Date [ Transient ];

/*///Вывод\\\*/
Property RepDate As p6.dt.Date;

/// Сальдо на начало
Property StartBonus As p6.dt.Money;

/// Начисленно
Property PlusBonus As p6.dt.Money;

/// Оплачено бонусами
Property MinusBonus As p6.dt.Money;

/// Сальдо на конец
Property EndBonus As p6.dt.Money;

Storage Default
{
<Data name="repDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RepDate</Value>
</Value>
<Value name="3">
<Value>StartBonus</Value>
</Value>
<Value name="4">
<Value>PlusBonus</Value>
</Value>
<Value name="5">
<Value>MinusBonus</Value>
</Value>
<Value name="6">
<Value>EndBonus</Value>
</Value>
</Data>
<DataLocation>^zui.repD</DataLocation>
<DefaultData>repDefaultData</DefaultData>
<IdLocation>^zui.repD</IdLocation>
<IndexLocation>^zui.repI</IndexLocation>
<StreamLocation>^zui.repS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

