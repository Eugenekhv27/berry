/// Вторая страница чтобы  не включался GRACE период
Class zui.admin.RejectedConnection2 Extends %ZEN.Component.page
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "zui.Application";

/// Displayed name of this page.
Parameter PAGENAME = "Отказ во входе в систему";

/// Domain used for localization.
Parameter DOMAIN = "XPM";

Property pageName As %String(ZENURL = "PageName") [ InitialExpression = "busy.html" ];

Method CloseSession() As %String [ ZenMethod ]
{
	set %session.EndSession = 1
	quit %request.Application_"p6/" _ %page.pageName
}

/// This client event, if present, is fired when the page is loaded.
ClientMethod onloadHandler() [ Language = javascript ]
{
	setInterval(function(){window.location.replace(zenPage.CloseSession());},1000);
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="Отказ во входе в систему">
	<html align="center" containerStyle="color: white">Отказ во входе в систему</html>
</page>
}

}

