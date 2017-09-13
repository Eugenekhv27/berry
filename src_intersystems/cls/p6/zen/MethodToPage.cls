/// Created using the page template: Default
Class p6.zen.MethodToPage Extends p6.zen.EditPage
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "zui.Application";

/// Displayed name of this page.
Parameter PAGENAME;

/// Domain used for localization.
Parameter DOMAIN;

Property methodName As %ZEN.Datatype.string(ZENURL = "MethodName");

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
</style>
}

/// This XML block defines the contents of this page.
XData editPane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane  xmlns="http://www.intersystems.com/zen" xmlns:p6="http://www.dimas.ru/p6" id="editPane">
<html align="center" OnDrawContent="Test" ></html>
<button id="btClose" align="center" caption="Закрыть окно" onclick="CloseWindow()" />
</pane>
}

Method Test(seed) As %Status [ ZenMethod ]
{
   write "<pre>",!
   xecute "do ##class"_..methodName
   write "</pre>",!
   quit $$$OK
}

}

