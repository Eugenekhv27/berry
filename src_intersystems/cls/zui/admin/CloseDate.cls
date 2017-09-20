Class zui.admin.CloseDate Extends p6.zen.EditPage
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
 modelClass="admin.CloseDate" modelId="#(%page.objectId)#"/>
<form id="myForm" layout="vertical" labelPosition="left" controllerId="source">
<vgroup>
<p6:calendar dataBinding="BudgetCloseDate" />
<p6:calendar dataBinding="TripCloseDate" />
<p6:buttonsEdit />
</vgroup>
<spacer height="1em"/>
<p6:tabGroup showTabBar="true" id="TabGroup"  width="100%">
<tab caption="Исключение пользователя" id="tab1" width="100%">
<p6:refBook 
className="admin.ExcludeUser" where="" id="refbook"
urlParam="" width="100%">
<p6:tablePane width="100%">
<p6:column field="UserSys->Aka" />
<p6:column field="BudgetBeginDate" />
<p6:column field="TripBeginDate" />
<p6:column field="EndEditDate" />
</p6:tablePane>
</p6:refBook>
</tab>
<!--
<tab caption="Исключение организации" id="tab2" width="100%">
<p6:refBook 
className="admin.ExcludeOrg" where="" 
urlParam="" width="100%">
<p6:tablePane width="100%">
<p6:column field="Org->Aka" />
<p6:column field="TripBeginDate" />
</p6:tablePane>
</p6:refBook>
</tab>
-->
<tab caption="Принудительно разблокированные рейсы" id="tab3" width="100%">
<p6:refBook btClose="-" btDelete="-" btEdit="zenPage.toTripReport();" btNew="-"  
className="dtk.Trip" where="IsUnLocked=1"  id="refbook3"
urlParam="" width="100%" >
<p6:tablePane width="100%" >
<p6:column field="Id" hidden="true" />
<p6:column field="TransportType" header="Тип" style="white-space:nowrap" />
<p6:column colName="TsNum" colExpression="case when (TransportType='авиа') or (TransportType='контейнерный') then WaybillNumber else Ts->Aka end" header="№ вагона / ТС / Конт" style="text-align:right;white-space:nowrap"/>
<p6:column colName="CarriageOrg" colExpression="case when Carriage->IsControl=1 then Carriage->Org->Aka end" header="Принадлежность" style="white-space:nowrap"/>
<p6:column field="StartDate" header="Отправление (план.)"/>
<p6:column field="BeginFactDate" header="Отправление (факт.)"/>
<p6:column field="TripFeature" header="Особенности рейса" />
</p6:tablePane>
</p6:refBook>
</tab>
</p6:tabGroup>
</form>
</pane>
}

ClientMethod toTripReport() [ Language = javascript ]
{
	var table=zenPage.getComponentById("refbook3").getChildById("table");
	//var waybillExpediteId=zenPage.GetWaybillExpediteIdByRouteListLineId(table.value)
	OpenModalWindow("zui.dtk.rep.TripReport.cls?TripId="+table.value);
}

ClientMethod onPopupAction(popupName, action, value) [ Language = javascript ]
{
	var table=zenPage.getComponentById("refbook3").getChildById("table");
	table.executeQuery();
}

}

