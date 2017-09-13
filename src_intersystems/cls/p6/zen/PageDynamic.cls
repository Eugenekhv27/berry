/// Динамическиая генерация странички для класса
Class p6.zen.PageDynamic Extends p6.zen.EditPage
{

Property objectClass As %ZEN.Datatype.string(ZENURL = "ClassName");

Property paramStr As %ZEN.Datatype.string(ZENURL = "Param");

XData editPane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane  xmlns="http://www.intersystems.com/zen" xmlns:p6="http://www.dimas.ru/p6" id="editPane">
	<p6:dataController id="source"
	 modelClass="#(%page.objectClass)#" modelId="#(%page.objectId)#"/>
	<p6:dynaForm id="myForm" layout="vertical" labelPosition="left" 
	 controllerId="source" />
	</pane>
}

Method %OnAfterCreatePage() As %Status
{
	set ..%GetComponentById("source").modelClass=..objectClass
	quit $$$OK
}

ClientMethod onloadHandler() [ Language = javascript ]
{
	if(zenPage.paramStr!="") {
	 var property = Piece(zenPage.paramStr,":",1)
	 var value = Piece(zenPage.paramStr,":",2)
	 var prop=zenPage.getComponentById("myForm."+property);
	 prop.setProperty("value",value);
	 prop.setProperty("readOnly",true);
	 prop.onchangeHandler();
	}
	
	
	
	return this.invokeSuper('onloadHandler',arguments);
}

}

