/// Подсказки по полям. Название поля должно быть алфавитно-цифровым, без пробелов и точек.
/// Активируется указанием p6Hint в строке. Если p6Hint="", то в качестве значени Field
/// берется имя поля для подсказки.
Class p6.Hint Extends p6.Integrity [ ClassType = persistent, ProcedureBlock ]
{

Parameter SecureType = 1;

Parameter CAPTION = "Подсказка";

Property Field As %String(CAPTION = "Поле для подсказки", TRUNCATE = 1) [ Required ];

Property Hint As %String(CAPTION = "Подсказкаа", MAXLEN = 1000, TRUNCATE = 1) [ Required ];

Storage Default
{
<Data name="HintDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Field</Value>
</Value>
<Value name="3">
<Value>Hint</Value>
</Value>
</Data>
<DataLocation>^p6.HintD</DataLocation>
<DefaultData>HintDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^p6.HintD</IdLocation>
<IndexLocation>^p6.HintI</IndexLocation>
<StreamLocation>^p6.HintS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

