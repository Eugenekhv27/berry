/// Временная таблица для отчетов, сортировок
/// Состоит из полей строковых Selection, Prop1,...,Prop16 по 255 символов
/// Selection надо присваивать уникальное значение, индексируется
/// Хранится в ^CacheTemp.p6.SelectionD(Id)=Section,...
Class p6.TempSelection Extends %Persistent [ ClassType = persistent, ProcedureBlock ]
{

Index SelectionIndex On Selection;

/// Выборка (раздел) - уникальное имя для набора данных
/// Рекомендуется <имя задачи>_" "_$INCREMENT(^CacheTemp.p6.Selection)
Property Selection As %String(MAXLEN = 255, TRUNCATE = 1) [ Required ];

Property Prop1 As %String(MAXLEN = 255, TRUNCATE = 1);

Property Prop2 As %String(MAXLEN = 255, TRUNCATE = 1);

Property Prop3 As %String(MAXLEN = 255, TRUNCATE = 1);

Property Prop4 As %String(MAXLEN = 255, TRUNCATE = 1);

Property Prop5 As %String(MAXLEN = 255, TRUNCATE = 1);

Property Prop6 As %String(MAXLEN = 255, TRUNCATE = 1);

Property Prop7 As %String(MAXLEN = 255, TRUNCATE = 1);

Property Prop8 As %String(MAXLEN = 255, TRUNCATE = 1);

Property Prop9 As %String(MAXLEN = 255, TRUNCATE = 1);

Property Prop10 As %String(MAXLEN = 255, TRUNCATE = 1);

Property Prop11 As %String(MAXLEN = 255, TRUNCATE = 1);

Property Prop12 As %String(MAXLEN = 255, TRUNCATE = 1);

Property Prop13 As %String(MAXLEN = 255, TRUNCATE = 1);

Property Prop14 As %String(MAXLEN = 255, TRUNCATE = 1);

Property Prop15 As %String(MAXLEN = 255, TRUNCATE = 1);

Property Prop16 As %String(MAXLEN = 255, TRUNCATE = 1);

/// Очистка выборки
/// - выполнять перед выборкой и после сортировки
ClassMethod Clear(selection As %String = "")
{
	if (selection="") quit  //#
	&sql(delete from p6.TempSelection where Selection=:selection)
	quit
}

/// возвращает уникальное имя для свойства Session
ClassMethod SelectionName(name As %String = "") As %String
{
	quit name_" "_$INCREMENT(^CacheTemp.p6.Selection)
}

Storage Default
{
<Data name="TempSelectionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Selection</Value>
</Value>
<Value name="3">
<Value>Prop1</Value>
</Value>
<Value name="4">
<Value>Prop2</Value>
</Value>
<Value name="5">
<Value>Prop3</Value>
</Value>
<Value name="6">
<Value>Prop4</Value>
</Value>
<Value name="7">
<Value>Prop6</Value>
</Value>
<Value name="8">
<Value>Prop6</Value>
</Value>
<Value name="9">
<Value>Prop7</Value>
</Value>
<Value name="10">
<Value>Prop8</Value>
</Value>
<Value name="11">
<Value>Prop9</Value>
</Value>
<Value name="12">
<Value>Prop10</Value>
</Value>
<Value name="13">
<Value>Prop11</Value>
</Value>
<Value name="14">
<Value>Prop12</Value>
</Value>
<Value name="15">
<Value>Prop13</Value>
</Value>
<Value name="16">
<Value>Prop14</Value>
</Value>
<Value name="17">
<Value>Prop15</Value>
</Value>
<Value name="18">
<Value>Prop16</Value>
</Value>
<Value name="19">
<Value>Prop5</Value>
</Value>
</Data>
<DataLocation>^CacheTemp.p6.TempSelectionD</DataLocation>
<DefaultData>TempSelectionDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^CacheTemp.p6.TempSelectionD</IdLocation>
<IndexLocation>^CacheTemp.p6.TempSelectionI</IndexLocation>
<StreamLocation>^CacheTemp.p6.TempSelectionS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

