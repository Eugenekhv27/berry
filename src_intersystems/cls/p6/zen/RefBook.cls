/// RefBook placed on a single page
Class p6.zen.RefBook Extends p6.zen.Page
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "p6.zen.Application";

/// Displayed name of this page.
Parameter PAGENAME;

/// Domain used for localization.
Parameter DOMAIN = "P6";

Parameter DEFAULTHEIGHT = "70%";

Property className As %ZEN.Datatype.string(ZENURL = "ClassName");

Property where As %ZEN.Datatype.string(ZENURL = "Where");

/// Type of generated refbook. Values are "Open","Modal". 
Property windowType As %ZEN.Datatype.string(VALUELIST = ",Open,Modal", ZENURL = "WindowType") [ InitialExpression = "Open" ];

/// Параметры задавать в виде 'GO=1'
Property urlParam As %ZEN.Datatype.string(ZENURL = "UrlParam");

/// Показывать кнопку "Передать в Word"?
Property btPrintWord As %ZEN.Datatype.string(ZENURL = "BtPrintWord");

/// Показывать кнопку "Передать в Excel"?
Property btPrintExcel As %ZEN.Datatype.string(ZENURL = "BtPrintExcel");

/// Отобразить полный вариант реестра.
/// Если =1, то описание берется из "XData refBookFull"
Property IsFullRefbookRegister As %ZEN.Datatype.string(ZENURL = "IsFullRefbookRegister");

Property StdTitle As %ZEN.Datatype.string [ InitialExpression = {..#PAGENAME} ];

/// This client event, if present, is fired when the page is loaded.
ClientMethod onloadHandler() [ Language = javascript ]
{
	
	zenPage.updateTableBodyHeight(zenPage.getComponentById("refbook").getChildById("table"));
}

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
/* @doc="Margins for refbook." */
body {
	margin:0.5em; background-color: #E4E4E4;
}
</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" xmlns:p6="http://www.dimas.ru/p6" title="" height="70%">
<html OnDrawContent="DrawTitle" id="title" />
<p6:refBook id="refbook" width="100%"  />
</page>
}

/// Set some refbook properties 
Method %OnAfterCreatePage() As %Status
{
	set RefBook=..%GetComponentById("refbook")
	set RefBook.urlParam=$$$ZENVAL(..urlParam)
	set RefBook.className=$$$ZENVAL(..className)
	set RefBook.IsFullRefbookRegister = $$$ZENVAL(..IsFullRefbookRegister)
	if ..where]"" {
		set RefBook.where=$$$ZENVAL(..where)
	}
	if ..btPrintWord]"" {
		set RefBook.btPrintWord=$$$ZENVAL(..btPrintWord)
	}
	if ..btPrintExcel]"" {
		set RefBook.btPrintExcel=$$$ZENVAL(..btPrintExcel)
	}
	set RefBook.windowType=$$$ZENVAL(..windowType)
	set RefBook.btClose=""
	set classDescription=##class(p6.ClassDefinition).GetClassDescription($$$ZENVAL(..className))
	set classDescription=$piece(classDescription,$c(13),1)
	if classDescription="" set classDescription="Справочник"
	set ..StdTitle=classDescription
	Set titleUserInfo = "Пользователь: "_$username
	Set %page.title=classDescription _"   |    " _ titleUserInfo
	Quit $$$OK
}

/// Draw HTML for the page title
Method DrawTitle(pSeed As %String) As %Status
{
	#; Whatever HTML we render here will be used as the title bar
	&html<#($ZCVT($$$ZENVAL(..StdTitle),"O","HTML"))#>

	Quit $$$OK
}

ClientMethod onPopupAction(popupName, action, value) [ Language = javascript ]
{
	if (this.windowType=="Modal") {
		zenPage.firePopupAction('ok',value);
	} else {
		zenPage.getComponentById("refbook").getChildById("table").executeQuery(1);
	}
}

}

