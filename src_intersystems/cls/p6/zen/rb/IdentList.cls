/// Created using the page template: Default
Class p6.zen.rb.IdentList Extends p6.zen.EditPage
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "p6.zen.Application";

/// Displayed name of this page.
Parameter PAGENAME = "Перечень имен Cache";

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
 set ident=""
 for  {
	set ident=$o(^p6.rb.Index(ident))
	quit:ident=""
	set Def=##class(p6.rb.Definition).%OpenId(ident)
	if Def=$$$NULLOREF {
		set color="ff7777"
	} else {
		if Def.IsYellow set color="ffff77"
		else  set color="77ff77"
	}
	write "<tr bgcolor='"_color_"'>"
	write "<td><a href='javascript:' onclick='OpenModalWindow("""_p6ApplicationUrl_"/p6/rb/Definition.csp?EditMode=1&Id="_ident_"""); location.reload();'>"_ident_"</a><td>&nbsp;"
	if Def]"" write Def.Description
	write "<td><a href='javascript:' onclick='OpenWindow("""_p6ApplicationUrl_"/p6/rb/IdentLinks.csp?Id="_ident_""");'>"_^p6.rb.Index(ident)_"</a><td>&nbsp;"
}
}

ClientMethod Run() [ Language = javascript ]
{
 //zenPage.OnDrawContent();
}

}

