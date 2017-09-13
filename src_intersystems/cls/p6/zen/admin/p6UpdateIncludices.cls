/// Created using the page template: Default
Class p6.zen.admin.p6UpdateIncludices Extends p6.zen.EditPage
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "p6.zen.Application";

/// Displayed name of this page.
Parameter PAGENAME = "Пересчет индексов во всех классах и очистка кэша SQL запросов";

/// Domain used for localization.
Parameter DOMAIN;

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

<html align="center" OnDrawContent="Update" ></html>
<button id="btClose"  align="center" caption="Закрыть окно" onclick="CloseWindow()" />
</pane>
}

Method Update(seed) As %Status [ ZenMethod ]
{
 write !,"<br> очистка кэшированных запросов - $system.SQL.Purge(0)<br>",!
 kill ^mcq,^mqh  ; Purge all Cached Queries
 do ##class(p6.ClassUtils).UpdateIndices(0,1) //для html перевод строки
 write !,"<br> очистка ненужных глобалей - admin.Version.PurgeUnnecessary()<br>",!
 do ##class(admin.Version).PurgeUnnecessary()
 quit $$$OK
}

ClientMethod Run() [ Language = javascript ]
{
 //zenPage.OnDrawContent();
}

}

