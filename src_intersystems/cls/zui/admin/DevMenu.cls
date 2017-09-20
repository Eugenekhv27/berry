/// Created using the page template: Default
Class zui.admin.DevMenu Extends p6.zen.Page
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "zui.Application";

/// Displayed name of this page.
Parameter PAGENAME;

/// Domain used for localization.
Parameter DOMAIN;

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="Разработчик">
	<html align="center"><h1>Разработчик</h1></html>
<vmenu id="devmenu">

<menuItem caption="Перечень свойств и методов классов" onclick="OpenModalWindow('zui.admin.ClassDefinitionTable.cls');" />
<menuItem caption="Перечень имен Cache" onclick="OpenModalWindow('p6.zen.rb.IdentList.cls');" />
</vmenu>


</page>
}

}

