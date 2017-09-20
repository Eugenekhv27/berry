/// Created using the page template: Default
Class zui.admin.UpdateVersion Extends p6.zen.EditPage
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "p6.zen.Application";

/// Displayed name of this page.
Parameter PAGENAME = "Обновление версии";

/// This XML block defines the contents of this page.
XData editPane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane  xmlns="http://www.intersystems.com/zen" xmlns:p6="http://www.dimas.ru/p6" id="editPane">

<html OnDrawContent="Update" ></html>
<button id="btClose"  align="center" caption="Закрыть окно" onclick="CloseWindow()" />
</pane>
}

Method Update(seed) As %Status [ ZenMethod ]
{
 write !,"<br> Обновление версии <pre>",!
 do ##class(admin.Version).Update()
 write !,"</pre><br> Обновление завершено",!
 quit $$$OK
}

ClientMethod Run() [ Language = javascript ]
{
 //zenPage.OnDrawContent();
}

}

