/// Столбец для <class>p6.zen.component.tablePane</class>
Class p6.zen.auxiliary.column Extends %ZEN.Auxiliary.column
{

/// This is the XML namespace for this component.
Parameter NAMESPACE = "http://www.dimas.ru/p6";

/// Поле таблицы для данной колонки. Использовать вместо colName и colExpression
/// Поддерживается "стрелочный" синтаксис(table->property)
Property field As %ZEN.Datatype.string;

/// Подсуммировывать эту колонку
Property isAggregated As %ZEN.Datatype.boolean [ InitialExpression = 0 ];

/// Необязательно<br>
/// Название метода сервера который производит HTML наполнение для ячеек этой колонки.
/// Этот метод должен распологаться на странице
/// HTML выводиться либо WRITE, либо &html
Property OnDrawCell As %ZEN.Datatype.delegator(FORMALSPEC = "table:p6.zen.component.tablePane,name:%ZEN.Datatype.string,seed:%ZEN.Datatype.string,row:%ZEN.Datatype.string", RETURNTYPE = "%Status");

/// Если по данной колонке задается фильтр, то это названия операции SQL 
/// которая используется при наложении фильтра<br>
/// Возможные значения:
/// <ul>
///  <li>%STARTSWITH</li>
///  <li>=</li>
///  <li>>=</li>
///  <li><=</li>
///  <li><></li>
///  <li>></li>
///  <li><</li>
///  <li>IN</li>
///  <li>BETWEEN</li>
///  <li>%CONTAINS</li>
///  <li>[ - вхождение с учетом регистра</li>
///  <li>[NOCASE - проверить вхождение без учета регистра</li>
/// </ul>
/// Для "IN", <property>filterValue</property> содержит список значений разделенных запятыми для выражения IN в запросе.<br>
/// Для "%CONTAINS", <property>filterValue</property> содержит список значений разделенных запятыми для выражения %CONTAINS в запросе.<br>
/// Для "BETWEEN", <property>filterValue</property> содержит список из 2х значений разделенных запятыми используемых для выражения BETWEEN в запросе.<br>
Property filterOp As %ZEN.Datatype.string(VALUELIST = ",%STARTSWITH,=,>=,<=,<>,>,<,[,IN,BETWEEN,%CONTAINS,[NOCASE");

}

