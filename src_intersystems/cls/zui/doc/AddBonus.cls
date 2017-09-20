Class zui.doc.AddBonus Extends p6.zen.EditPage
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
 modelClass="doc.AddBonus" modelId="#(%page.objectId)#"/>
<form id="myForm" layout="vertical" labelPosition="left" controllerId="source">
<p6:hgroup>
<p6:vgroup>
<p6:text dataBinding="BonusSum" />
<p6:textarea dataBinding="Comment"  cols="40" rows="4" height="10"  />
<button caption="Начислить всем участникам  в базе" onclick="zenPage.addToAll()"/>

</p6:vgroup>
</p6:hgroup>

</form>
</pane>
}

/// This client event, if present, is fired when the page is loaded.
ClientMethod onloadHandler() [ Language = javascript ]
{
}

Method addToAll() [ ZenMethod ]
{
	//$$$QuitOnError(##class(ent.Buyer).SendHelloBuyer(tel))
	set aPointsSum = ..%GetComponentById("BonusSum").value
	set aComment = ..%GetComponentById("Comment").value
	
	&sql(declare addBonus cursor for 
		select Id into :bayerId from ent.Buyer)
		
	&sql(open addBonus)
	&sql(fetch addBonus)
	while SQLCODE=0 {
		&sql(insert into doc.BonusOperation (PointsSum,Comment,Buyer) Values (:aPointsSum,:aComment,:bayerId))
		
		&sql(fetch addBonus)
	}
	&sql(close addBonus)
	&js<alert('Выполнено');>
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

