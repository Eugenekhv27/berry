/// Расширение стандартного контроллера
Class p6.zen.component.dataController Extends %ZEN.Auxiliary.dataController
{

/// This is the XML namespace for this component.
Parameter NAMESPACE = "http://www.dimas.ru/p6";

/// Получить объект связанный с контроллером
Method GetObject() As %RegisteredObject
{
	Set tSC = $$$OK
	Set tModelId = $$$ZENVAL(..modelId)
	
	if $IsObject(..%model) quit ..%model

	#; open instance of model
	Set tModel = ..%CreateModelInstance($$$ZENVAL(..modelClass),tModelId,.tSC,$this)
	If $$$ISERR(tSC) Quit

	#; copy data to model
	If $IsObject(tModel)&&..dataLoaded {
		Set tSC = ..dataBag.%CopyToModel(tModel)
		If $$$ISERR(tSC) Quit
	}

	quit tModel
}

/// Выставить состояние контролера в соответствии с объектом
Method SetObject(aObject As %RegisteredObject) As %Status
{
	Set tSC = $$$OK

	#; copy data to model
	If $IsObject(aObject) {
		set ..%model=aObject
		if aObject.%IsA("%Library.Persistent") set ..modelId=aObject.%Id()
		Set tSC = ..dataBag.%CopyFromModel(aObject)
		If $$$ISERR(tSC) Quit
	}

	quit tSC
}

Method DumpBag() As %Status
{
	d $system.OBJ.Dump(..dataBag)
	quit $$$OK
}

/// Delete an instance of a DataModel object.
ClassMethod %DeleteModelInstance(pClass As %String, pID As %String) As %Status
{
	Set tModel = ""
	Set tSC = $$$OK
	Set $ZT="Trap"
	If (pClass '= "") {
		Set tSC = $zobjclassmethod(pClass,"%DeleteModel",pID)
	}
Done
	Quit tSC
Trap
	Set $ZT=""
	If $ZE["<METHOD DOES NOT EXIST>" {
		Set tSC=$$$ERROR($$$GeneralError,"Class "_ pClass _ " is not a DataModel")
	}
	Else {
		Set tSC=$$$ERROR($$$CacheError,"%DeleteModelInstance: " _ $ZE)
	}
	Goto Done
}

/// Ask our associated dataModel to delete the item with the given id.
ClientMethod deleteId(id) [ Language = javascript ]
{
	// call server to delete data
	var ok = this.DeleteFromServer(id);
	if (ok) {
		// test for delete of this object
		if (this.modelId == id) {
			this.modelId = '';
			this.sendEventToViews('dataChange');
		}

		zenInvokeCallbackMethod(this.ondelete,this,'ondelete','id',id);
	}
	return ok;
}

/// Internal method.<br>
/// Ask the associated DataModel object to delete the given item.
Method DeleteFromServer(pID As %String) As %Boolean [ Internal, ZenMethod ]
{
	Set tSC = $$$OK
	Set tOK = 1

	Do {
		#; delete instance of model
		Set tSC = ..%DeleteModelInstance($$$ZENVAL(..modelClass),pID)
		If $$$ISERR(tSC) { Set tOK = 0 Quit }
	} While(0)

	If $$$ISERR(tSC) {
		Do ##class(p6.CspMethods).DisplayErrorJS($this,tSC)
	}
	
	Quit tOK
}

/// Internal method.<br>
/// Save data back to the associated DataModel object.
/// Returns the id of the saved object (which could have changed
/// in the case of an insert).
Method SaveToServer() As %String [ Internal, ZenMethod ]
{
	Set tSC = $$$OK
	Set tModelId = $$$ZENVAL(..modelId)
	Set tRet = tModelId

	Do {
		#; open instance of model
		Set tModel = ..%CreateModelInstance($$$ZENVAL(..modelClass),tModelId,.tSC,$this)
		If $$$ISERR(tSC) Quit

		#; copy data to model and save model
		If $IsObject(tModel) {
			Set tSC = ..dataBag.%CopyToModel(tModel)
			If $$$ISERR(tSC) Quit

			#; save the model
			Set tSC = tModel.%SaveModel()
			If $$$ISERR(tSC) Quit

			#; model may have been modified by the save
			#; so copy new values back to client
			Set tSC = ..dataBag.%CopyFromModel(tModel)
			If $$$ISERR(tSC) Quit

			#; return the modelId (it could have changed)
			Set tRet = tModel.%id
		}
	} While(0)

	If $$$ISERR(tSC) {
		Do ##class(p6.CspMethods).DisplayErrorJS($this,tSC)
		s tRet=""
	}
	Quit tRet
}

/// Save data from this dataController back to the DataModel on the server.
/// Return the id with which the model was saved or '' if it was not saved.
ClientMethod save() [ Language = javascript ]
{
	var id = '';
	if (this.dataLoaded && !this.dataReadOnly) {
		// call server to save data
		id = this.SaveToServer();
		if(id!="") this.modelId=id;
		this.sendEventToViews('dataChange');

		zenInvokeCallbackMethod(this.onsave,this,'onsave','id',this.modelId);
	}
	
	return id;
}

}

