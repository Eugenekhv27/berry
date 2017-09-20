/// Сесии пользователей
Class zui.admin.rep.Session Extends p6.zen.EditPage
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
 modelClass="admin.rep.Session" modelId="#(%page.objectId)#"/>
<form id="myForm" layout="vertical" controllerId="source">

<hgroup  cellStyle="padding-right:0.3em;">
<p6:calendar dataBinding="BeginDate" />
<p6:calendar dataBinding="EndDate" />
<p6:textRefBook dataBinding="UserSys" />
</hgroup>
</form>
<hgroup align="center" cellStyle="padding-right:0.3em;">
<button id="btRegister" caption="Реестр"  onclick="zenPage.btRegister()" />
<button id="btClose" caption="Закрыть окно" onclick="CloseWindow()" />
</hgroup>
<p6:refBook id="refbook" className="admin.Session" hidden="true" align="center" >
<p6:tablePane >
 <p6:column field="ID" />
 <p6:column field="DtStart" />
 <p6:column field="DtFinish" />
 <p6:column field="IpAddress" />
 <p6:column field="UserSys->Aka" />
</p6:tablePane>
</p6:refBook>

</pane>
}

ClientMethod btRegister() [ Language = javascript ]
{
	var refbook=zenPage.getComponentById("refbook");
	var table=zenPage.getComponentById("refbook").getChildById("table");
	table.whereClause=zenPage.GetWhere();
	table.executeQuery();
	refbook.setProperty("hidden",false);
}

Method GetWhere() As %String [ ZenMethod ]
{
	set Controller=..%GetComponentById("source")
	set Obj=Controller.GetObject()
	quit Obj.GetFilter()
}

}

