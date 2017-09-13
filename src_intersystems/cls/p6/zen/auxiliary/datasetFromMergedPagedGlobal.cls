/// Класс обертка чтобы не переписывать 
/// весь код на обращение к глобали для страниц где реализовано страничное листание в редактируемой таблице
/// Пример в регистрации выгрузки
Class p6.zen.auxiliary.datasetFromMergedPagedGlobal Extends %RegisteredObject
{

Property AtAddress As %String;

Property OnOnePage As %Integer;

Method %GetValue(row, col) As %String
{
	set page=row\..OnOnePage
	set rowOnPage=row-(page*..OnOnePage)
	if rowOnPage=0
	{
		set page=page-1
		set rowOnPage=..OnOnePage
	}
	quit $G(@..AtAddress@(page+1,rowOnPage,col))
}

Method %GetDimSize(dim) As %Integer
{
	set numPages=$O(@..AtAddress@(""),-1)
	quit ..OnOnePage*numPages
}

Method %SetValue(value, row, col)
{
	set page=row\..OnOnePage
	set rowOnPage=row-(page*..OnOnePage)
	s @..AtAddress@(page+1,rowOnPage,col)=value
}

}

