/// Страница оставлена чтобы программа работала по старой ссылке
Class zui.admin.Login Extends p6.zen.Page
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "zui.Application";

/// Displayed name of this page.
Parameter PAGENAME = "Вход в систему";

/// Domain used for localization.
Parameter DOMAIN = "DTK";

Property isFinishSession As %ZEN.Datatype.string(ZENURL = "IsFinishSession");

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">

.box {
	background-color: #194b8c;
	border: 1px solid #07346f;
	padding:0.4em;
}

.errorMsg {
	color:red;
	font-weight:bold;
	font: 0.8em;
}
</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="Система Login">


</page>
}

ClassMethod %OnBeforeCreatePage() As %Status
{
	set %response.Redirect="zui.Menu.cls"
	Quit $$$OK
}

}

