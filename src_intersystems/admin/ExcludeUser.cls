/// Разрешено редактировать пользователям
Class admin.ExcludeUser Extends p6.Integrity [ ClassType = persistent ]
{

/// Пользователь
Property UserSys As admin.UserSys [ Required ];

/// Бюджет разрешено редактировать с даты
Property BudgetBeginDate As p6.dt.Date [ InitialExpression = {+$H} ];

/// Рейсы разрешено редактировать с даты
Property TripBeginDate As p6.dt.Date [ InitialExpression = {+$H} ];

/// Дата закрытия доступа на редактирование
Property EndEditDate As p6.dt.Date [ InitialExpression = {+$H+1} ];

Storage Default
{
<Data name="ExcludeUserDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>UserSys</Value>
</Value>
<Value name="3">
<Value>BudgetBeginDate</Value>
</Value>
<Value name="4">
<Value>BudgetDays</Value>
</Value>
<Value name="5">
<Value>TurnOff</Value>
</Value>
<Value name="6">
<Value>EndEditDate</Value>
</Value>
<Value name="7">
<Value>TripBeginDate</Value>
</Value>
</Data>
<DataLocation>^admin.ExcludeUserD</DataLocation>
<DefaultData>ExcludeUserDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^admin.ExcludeUserD</IdLocation>
<IndexLocation>^admin.ExcludeUserI</IndexLocation>
<StreamLocation>^admin.ExcludeUserS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

