/// Распределение затрат по филиалам
Class zui.rep.BonusReport Extends p6.zen.EditPage
{

Parameter PAGENAME = "Сводный отчет по бонусам";

XData Style
{
<style type="text/css">
</style>
}

XData editPane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane  xmlns="http://www.intersystems.com/zen" xmlns:p6="http://www.dimas.ru/p6" id="editPane">
<p6:dataController id="source" modelClass="rep.BonusReport"/>
<form id="myForm" layout="vertical" controllerId="source" width="70%">
<p6:hgroup>
<p6:calendar dataBinding="BeginDate" size="10"/>
<p6:calendar dataBinding="EndDate" size="10"/>
</p6:hgroup>
</form>
<hgroup align="center" cellStyle="padding-right:0.2em;">
<button id="btReport" caption="Отчет" onclick="zenPage.btReport()"/>
<button id="btExcel" caption="Excel" onclick="zenPage.btPrintExcel()"/>
<button id="btClose" caption="Закрыть окно" onclick="CloseWindow()"/>
</hgroup>
<spacer height="0.2em"/>
<p6:tablePane id="table" tableName="rep.BonusReport" initialExecute="false"
 fixedHeaders="true" ondblclick="zenPage.ondblClick(zenThis)" valueColumn="RepDate">
<p6:column field="RepDate" header="Дата"/>
<p6:column field="StartBonus" header="Сальдо на начало"/>
<p6:column field="PlusBonus" header="Начислено" isAggregated="true" />
<p6:column field="MinusBonus" header="Списано" isAggregated="true"/>
<p6:column field="EndBonus" header="Сальдо на конец"/>
</p6:tablePane>

<modalGroup id="Details">
<p6:tablePane id="tableDetails" tableName="doc.BonusOperation" initialExecute="false"
 fixedHeaders="true" >
<p6:column field="Buyer->Aka" header="Покупатель"/>
<p6:column field="PlusPointsSum" header="Начислено" isAggregated="true" />
<p6:column field="MinusPointsSum" header="Списано" isAggregated="true"/>
</p6:tablePane>
<hgroup>
<button caption="Закрыть" onclick="zenPage.endModal();" />
</hgroup>
</modalGroup>

</pane>
}

ClientMethod ondblClick(val) [ Language = javascript ]
{
	
	zenPage.getComponentById('Details').show();
	var tableDetails=zenPage.getComponentById("tableDetails");
	
	tableDetails.setProperty('whereClause',"DocDate='"+val.getValue()+"'");
	tableDetails.executeQuery();
}

ClientMethod btReport() [ Language = javascript ]
{
	zenPage.CreateReport(zenPage.getComponentById('source'));

	var table=zenPage.getComponentById("table");
	table.executeQuery();
}

ClassMethod CreateReport(ASource As p6.zen.component.dataController) As %Status [ ZenMethod ]
{
	set Obj=ASource.GetObject()
	$$$QuitOnError(Obj.Report())
	quit $$$OK
}

Property DataController As p6.zen.component.dataController;

ClientMethod onloadHandler() [ Language = javascript ]
{

	


	try { SetFocusOnFirstControl();} catch(e) {}
}

ClientMethod btPrintExcel() [ Language = javascript ]
{
	this.getComponentById("table").printIt("2",zenPage.title);
}

}

