Class zui.ent.Buyer Extends p6.zen.EditPage
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
 modelClass="ent.Buyer" modelId="#(%page.objectId)#"/>
<form id="myForm" layout="vertical" labelPosition="left" controllerId="source">
<p6:hgroup>
<p6:vgroup>
<p6:text dataBinding="Aka" />
<p6:text dataBinding="Name" />
<p6:textarea dataBinding="Comment"  cols="40" rows="4" height="10"  />
<p6:textRefBook dataBinding="SuperBuyer"  />
</p6:vgroup>
<p6:vgroup>
<button caption="Отправить SMS с ссылкой в личный кабинет" onclick="zenPage.sendLinkSms(zen('Aka').value)"/>
</p6:vgroup>
</p6:hgroup>
<p6:buttonsEdit id="buttonsEdit" />
<spacer height="1em;" />
<p6:tabGroup showTabBar="true" id="tabgroup">
<tab caption="Операции по бонусам">
<p6:refBook className="doc.BonusOperation" 
urlParam="'Buyer='+zenPage.objectId" 
where="Buyer=#(%page.objectId)#">
<p6:tablePane>
<p6:column field="DocDate"  />
<p6:column field="RubSum" isAggregated="true" />
<p6:column field="PointsSum" isAggregated="true" />
<p6:column field="Comment"  />
</p6:tablePane>
</p6:refBook>
</tab>
</p6:tabGroup>
</form>
</pane>
}

/// This client event, if present, is fired when the page is loaded.
ClientMethod onloadHandler() [ Language = javascript ]
{
	
  $("#control_10").mask("+7(999)9999999");
  if (zenPage.isEditable==false) { 
	zenPage.getComponentById("myForm").setProperty('disabled',true);
  }
}

Method sendLinkSms(tel) [ ZenMethod ]
{
	$$$QuitOnError(##class(ent.Buyer).SendHelloBuyer(tel))
	quit $$$OK
}

Method %OnAfterCreatePage() As %Status
{
	if '(..isEditable) {
		set ..%GetComponentById("buttonsEdit").canDelete=$$$NO
	}
	quit $$$OK
}

}

