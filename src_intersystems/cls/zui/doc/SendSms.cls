/// Отправка SMS и голосовых сообщений клиентам
Class zui.doc.SendSms Extends p6.zen.EditPage
{

Parameter PAGENAME;

XData Style
{
<style type="text/css">
</style>
}

XData editPane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane  xmlns="http://www.intersystems.com/zen" xmlns:p6="http://www.dimas.ru/p6" id="editPane">
<p6:dataController id="source"
 modelClass="doc.SendSms" modelId="#(%page.objectId)#"/>
<form id="myForm" layout="horizontal" labelPosition="left" controllerId="source" width="100%">

<p6:vgroup width="50%" valign="top">
<html OnDrawContent="GetSmscBalance"/>
<spacer height="1pt"/>
<p6:checkbox dataBinding="SendSms" />
<p6:checkbox dataBinding="SendVoice" />

<p6:textarea dataBinding="Message" rows="6" cols="200" />
<spacer height="1pt"/>
<p6:text dataBinding="TestTel" />
<button caption="Протестировать на тел" onclick="zenPage.doIt(1);"/>
<spacer height="1pt"/>
<button caption="Отправить!" onclick="zenPage.doIt(0);"/>
</p6:vgroup>


</form>
</pane>
}

ClientMethod doIt(test = 1) [ Language = javascript ]
{
	alert(zenPage.DoItOnServer(test));
}

Method DoItOnServer(test = 1) As %String [ ZenMethod ]
{
	set Obj=..%GetComponentById("source").GetObject()
	quit Obj.Run(test)
}

Method GetSmscBalance(pSeed As %String) As %Status
{
	
    &html<#(##class(p6.Sms).GetBalance())#>
    Quit $$$OK
}

}

