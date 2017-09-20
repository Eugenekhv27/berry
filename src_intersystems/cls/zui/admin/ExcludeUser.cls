Class zui.admin.ExcludeUser Extends p6.zen.EditPage
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
 modelClass="admin.ExcludeUser" modelId="#(%page.objectId)#"/>
<form id="myForm" layout="vertical" labelPosition="left" controllerId="source">
<p6:textRefBook dataBinding="UserSys" />
<p6:calendar dataBinding="BudgetBeginDate" />
<p6:calendar dataBinding="TripBeginDate" />
<p6:calendar dataBinding="EndEditDate" />
<p6:buttonsEdit />
</form>
</pane>
}

}

