Class zui.admin.AppSet Extends p6.zen.EditPage
{

Parameter PAGENAME = "Настройки системы";

XData Style
{
<style type="text/css">
</style>
}

XData editPane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane  xmlns="http://www.intersystems.com/zen" xmlns:p6="http://www.dimas.ru/p6" id="editPane">
<p6:dataController id="source"
 modelClass="admin.AppSet" modelId="#(%page.objectId)#"/>
<form id="myForm" layout="vertical" controllerId="source" width="100%">
<p6:hgroup>
<p6:vgroup width="40%">
<p6:text dataBinding="OrgName" />
<p6:text dataBinding="OrgAdress" />
<p6:text dataBinding="Chef" />
<p6:text dataBinding="ChefPost" />
<!--<p6:checkbox dataBinding="IsSaveVisitPage" />-->
<!--
<p6:hgroup>
<p6:text dataBinding="InsuranceRateUralsib" />
<p6:text dataBinding="InsuranceRateIngvar" />
</p6:hgroup>
<p6:text dataBinding="Franchise" />
-->
<p6:text dataBinding="HelpDeskUrl" />
<p6:text dataBinding="Header1" />
<p6:text dataBinding="Header2" />
<p6:text dataBinding="CalcEmail" hint="если несколько - через запятую" />
<p6:text dataBinding="CssLink"  />
</p6:vgroup>
<p6:vgroup width="40%">
<p6:text dataBinding="SmscLogin"  autocomplete="false"  />
<p6:text inputtype="password" dataBinding="SmscPassword" autocomplete="false" />
<html OnDrawContent="GetSmscBalance"/>
</p6:vgroup>
</p6:hgroup>
<p6:vgroup>
<p6:checkbox dataBinding="PrintAccounts" />
</p6:vgroup>
<fieldSet legend="Сколько килограмм в одном кубическом метре (для отчетов)" layout="" width="100%">
<p6:hgroup>
<p6:text dataBinding="AviaDensity" slice="1" />
<p6:text dataBinding="AutoDensity" slice="1"/>
<p6:text dataBinding="TransDensity" slice="1"/>
<p6:text dataBinding="ContDensity" slice="1"/>
</p6:hgroup>
<html>*Если не заполнено, то определяется по тому, какая стоимость дороже. </html>
</fieldSet>

<p6:buttonsEdit />
<spacer height="0.1em"/>
</form>
</pane>
}

/// This callback is called after the server-side page 
/// object and all of its children are created.<br>
/// Subclasses can override this to add, remove, or modify 
/// items within the page object model, or to provide values
/// for controls.
Method %OnAfterCreatePage() As %Status
{
	set appSetId=##class(admin.AppSet).GetCurrent().%Id()
	set Controller=..%GetComponentById("source")
	set Controller.modelId=appSetId
	Do ##super()
	Quit $$$OK
}

Method GetSmscBalance(pSeed As %String) As %Status
{
	
    &html<#(##class(p6.Sms).GetBalance())#>
    Quit $$$OK
}

}

