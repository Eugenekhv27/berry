/// Created using the page template: Default
Class zui.admin.AdminMenu Extends p6.zen.Page
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
<page xmlns="http://www.intersystems.com/zen" title="Администратор">
<html align="center"><h1>Администратор</h1></html>
<vmenu id="adminmenu">
<menuItem caption="Безопасность, рабочие места и т.п." link="zui.secure.SecureMenu.cls" />
<menuItem caption="Пользователи системы" onclick="OpenModalWindow('p6.zen.RefBook.cls?ClassName=admin.UserSys&amp;Where=' + escape('(nvl(IsBlocked,0)&lt;&gt;1)'))" />
<menuItem caption="Пользователи системы (заблокированные)" onclick="OpenModalWindow('p6.zen.RefBook.cls?ClassName=admin.UserSys&amp;Where=' + escape('(nvl(IsBlocked,0)=1)'))" />
<!--<menuItem caption="Сессии пользователей" onclick="OpenModalWindow('zui.admin.rep.Session.cls');" />-->
<menuSeparator />

<menuItem caption="Объединение организаций" onclick="OpenModalWindow('zui.admin.ChangeOrg.cls');" />
<!--<menuItem caption="Обновление версии" onclick="OpenModalWindow('zui.admin.UpdateVersion.cls');" />-->
<menuSeparator />
<menuItem caption="Обновление индексов, удаление кэша SQL запросов" onclick="OpenModalWindow('p6.zen.admin.p6UpdateIncludices.cls');" />
<menuItem caption="Проверка данных во всех классах" onclick="OpenModalWindow('p6.zen.admin.p6AllClassesValidate.cls');" />
<menuSeparator />
<menuItem caption="Ссылки (обновление по всем классам)" onclick="OpenModalWindow('');" />
<menuItem caption="Ссылочная целостность" onclick="OpenModalWindow('');" />
<menuSeparator />
<menuItem caption="Разработчик" link="zui.admin.DevMenu.cls" />
<menuSeparator />
<menuItem caption="Очистить хранилище Google Gears" onclick="g_removeStore();" />
<menuSeparator />
<menuItem caption="Информация по ТТНкам" onclick="OpenModalWindow('zui.admin.WaybillUtils.cls');" />
</vmenu>

</page>
}

/// This client event, if present, is fired when the page is loaded.
ClientMethod onloadHandler() [ Language = javascript ]
{
	//g_init();
	return SetFocusOnFirstControl();
}

}

