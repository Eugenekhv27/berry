Class zui.doc.BonusOperation Extends p6.zen.EditPage
{

Parameter PAGENAME;

Property buyerId As %ZEN.Datatype.string(ZENURL = "Buyer");

XData Style
{
<style type="text/css">
</style>
}

XData editPane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane  xmlns="http://www.intersystems.com/zen" xmlns:p6="http://www.dimas.ru/p6" id="editPane">
<p6:dataController id="source"
 modelClass="doc.BonusOperation" modelId="#(%page.objectId)#"/>
<form id="myForm" layout="vertical" labelPosition="left" controllerId="source">
<p6:calendar dataBinding="DocDate" />
<p6:text dataBinding="RubSum" />
<p6:text dataBinding="PointsSum" />
<p6:textarea dataBinding="Comment" />
<p6:textRefBook dataBinding="Buyer" hidden="true" />
<p6:buttonsEdit id="buttonsEdit" />
</form>
</pane>
}

ClientMethod onloadHandler() [ Language = javascript ]
{
	var price=zenPage.getComponentById("Buyer");
	if(zenPage.buyerId!="") {
		
		price.setProperty("value",zenPage.buyerId);
		price.setProperty("disabled",true);
		price.setProperty("hidden",true);
		price.onchangeHandler();
	} else {
		price.setProperty("hidden",false);
	}
	if (zenPage.isEditable==false) { 
	zenPage.getComponentById("myForm").setProperty('disabled',true);
  }
}

Method %OnAfterCreatePage() As %Status
{
	if '(..isEditable) {
		set ..%GetComponentById("buttonsEdit").canDelete=$$$NO
	}
	quit $$$OK
}

}

