/// Studio Template:<br>
/// Create a new p6 Zen page class.
Class p6.zen.template.PageWizard Extends %ZEN.Template.studioTemplate
{

Parameter TEMPLATENAME = "New p6 Zen Page";

Parameter TEMPLATETITLE = "p6 Zen Page Wizard";

Parameter TEMPLATEDESCRIPTION = "Create a new p6 Zen page class.";

Parameter TEMPLATETYPE = "cls";

/// What type of template.
Parameter TEMPLATEMODE = "new";

/// Domain used for localization.
Parameter DOMAIN = "p6ZEN";

/// If this is true then even if this template is tied to a specific namespace it
/// will be available in any namespace and it will be up to the template to make sure
/// it looks for any specific data in the target namespace.
Parameter GLOBALTEMPLATE As BOOLEAN = 0;

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
</style>
}

/// This XML block defines the contents of the body pane of this Studio Template.
XData templateBody [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane id="body" xmlns="http://www.intersystems.com/zen">

<vgroup labelPosition="left" cellStyle="padding: 2px; padding-left: 5px; padding-right: 5px;">
<html id="desc" OnDrawContent="%GetDescHTML"/>
<dataCombo label="Model Class:"
		id="ctrlModelClass"
		name="ModelClass"
		title="Class name of the model class" 
		editable="true"
		unrestricted="true"
		searchKeyLen="15"
		multiColumn="false"
		displayColumns="1"
		valueColumn="1"
		choiceColumn="1"
		 comboType="timer"
		 delay="10"
		maxRows="500"
		size="40"
		dropdownWidth="20.0em"
		OnCreateResultSet="CreateModelClassRS"
		onchange="zenPage.updateNames();zenPage.updateState();"
/>

<dataCombo label="Package Name:"
		id="ctrlPackage"
		name="Package"
		required="true"
		labelClass="zenRequired"
		title="Package name for the new page"
		editable="true"
		unrestricted="true"
		searchKeyLen="10"
		maxRows="500"
		size="40"
		dropdownWidth="20.0em"
		OnCreateResultSet="CreatePackageRS"
		onchange="zenPage.updateState();"
/>

<text label="Class Name:" 
	id="ctrlClassName"
	name="ClassName"
	size="40"
	required="true"
	labelClass="zenRequired"
	title="Class name for the new component" 
	onchange="zenPage.updateState();"
/>

<dataCombo label="Application:"
		id="ctrlApplication"
		name="Application"
		title="Class name of the application this page belongs to" 
		editable="true"
		unrestricted="true"
		searchKeyLen="0"
		multiColumn="false"
		displayColumns="1"
		valueColumn="1"
		choiceColumn="1"
		maxRows="500"
		size="40"
		dropdownWidth="20.0em"
		OnCreateResultSet="CreateApplicationRS"
		onchange="zenPage.updateState();"
/>


<radioSet label="Type:" 
	id="ctrlType"
	name="Type"
	valueList="staticForm,register"
	labelClass="zenRequired"
	title="Type of component to create" 
	value="staticForm"
/>

<textarea label="Description:" 
	id="ctrlDescription"
	name="Description"
	rows="4"
	cols="50"
	title="Description for the new component" 
	onchange="zenPage.updateState();"
/>
</vgroup>
</pane>
}

/// Provide contents of description component.
Method %GetDescHTML(pSeed As %String) As %Status
{
	Write $$$TextHTML("This wizard creates a new p6 Zen MVC page class."),"<br/>"
	Write $$$TextHTML("Fill in the form below and then press Finish to create a new class.")
	Quit $$$OK
}

Method %OnAfterCreatePage() As %Status
{
	#; plug in default values
	Do %page.%SetValueById("ctrlPackage",##class(%ZEN.Utils).GetDefaultPackage())
	Do %page.%SetValueById("ctrlApplication",##class(%ZEN.Utils).GetDefaultApplication())
	//Do %page.%SetValueById("ctrlDomain",##class(%ZEN.Utils).GetDefaultDomain())
	//Do %page.%SetValueById("ctrlXMLNS",##class(%ZEN.Utils).GetDefault("XMLNamespace"))
	
	Quit $$$OK
}

/// This is called when the template is first displayed;
/// This provides a chance to set focus etc.
ClientMethod onstartHandler() [ Language = javascript ]
{
	// give focus to name
	var ctrl = zenPage.getComponentById('ctrlModelClass');
	if (ctrl) {
		ctrl.focus();
		ctrl.select();
	}
}

ClientMethod updateNames() [ Language = javascript ]
{
	var a=zenPage.getComponentById('ctrlModelClass').getValue().split('.');
	zenPage.getComponentById('ctrlClassName').setValue(a.splice(a.length-1,1));
	zenPage.getComponentById('ctrlPackage').setValue('zui.'+a.join('.'));
}

/// Validation handler for form built-into template.
ClientMethod formValidationHandler() [ Language = javascript ]
{
	// test if class name is valid
	var pkgName = zenPage.getComponentById('ctrlPackage').getValue();
	var clsName = zenPage.getComponentById('ctrlClassName').getValue();

	var msg = this.IsValidClassName(pkgName + "." + clsName);

	if ('' != msg) {
		alert(msg);
		return false;
	}

	return true;
}

ClassMethod %TemplateHeader()
{
	Write "<?xml version=""1.0"" encoding=""Windows-1251""?>",!
	Write "<template><![CDATA[BODY"_..#DELIM
	Kill %session.Data("Template")
	Quit
}

/// This method is called when the template is complete. Any
/// output to the principal device is returned to the Studio.
Method %OnTemplateAction() As %Status
{
	Set tPackage = ..%GetValueByName("Package")
	Set tClassName = ..%GetValueByName("ClassName")
	Set tDescription = ..%GetValueByName("Description")
	Set tApplication = ..%GetValueByName("Application")
	Set tType = ..%GetValueByName("Type")
	Set tModelClass = ..%GetValueByName("ModelClass")
	
	Set cls = tPackage_"."_tClassName
	Set classDescription = ##class(p6.ClassDefinition).GetClassDescription(cls)
	
	#; create content of new class definition
	Do ..%SetClassName(cls)
	
	#; update defaults
	Do ##class(%ZEN.Utils).SetDefaultPackage(tPackage)
	
	#; process description
	If (tDescription '= "") {
		For i = 1:1:$length(tDescription,$char(13,10)) {
			Set line = $piece(tDescription,$char(13,10),i)
			Write "/// ",line,!
		}
	}
	
	Set tSuper = $Case(tType,"dynamicForm":"p6.zen.EditPage",:"p6.zen.EditPage")
	
	Write "Class ",cls," Extends ",tSuper,!
	Write "{",!!

	Write "Parameter PAGENAME = """_classDescription_""";",!!

	
	#; style sheet
	If (tType'="dynamicForm") {
		Write "XData Style",!
		Write "{",!
		Write "<style type=""text/css"">",!
		Write "</style>",!
		Write "}",!!
	}

	If (tType="staticForm") {
		Write "XData editPane"
		Write:$ZV]'"5.2" " [XMLNamespace=""http://www.intersystems.com/zen""]"
		Write !
		Write "{",!
		Write "<pane  xmlns=""http://www.intersystems.com/zen"" xmlns:p6=""http://www.dimas.ru/p6"" id=""editPane"">",!
		Write "<p6:dataController id=""source""",!
		Write " modelClass="""_tModelClass_""" modelId=""#(%page.objectId)#""/>",!
		Write "<form id=""myForm"" layout=""vertical"" labelPosition=""left"" controllerId=""source"">",!
		do ..WriteControls(tModelClass)
		Write "<p6:buttonsEdit />",!
		Write "</form>",!
		Write "</pane>",!
		Write "}",!
	}


	If (tType="register") {
		Write "XData editPane"
		Write:$ZV]'"5.2" " [XMLNamespace=""http://www.intersystems.com/zen""]"
		Write !
		Write "{",!
		Write "<pane  xmlns=""http://www.intersystems.com/zen"" xmlns:p6=""http://www.dimas.ru/p6"" id=""editPane"">",!
		Write "<p6:dataController id=""source""",!
		Write " modelClass="""_tModelClass_""" modelId=""#(%page.objectId)#""/>",!
		Write "<form id=""myForm"" layout=""vertical"" labelPosition=""left"" controllerId=""source"">",!
		do ..WriteControls(tModelClass)
		Write "</form>",!,!
		Write "<hgroup align=""center"" cellStyle=""padding-right:0.3em;"" >",!
		Write "<button id=""btRegister"" caption=""Выбор""  onclick=""zenPage.btRegister()"" />",!
		Write "<button id=""btClose"" caption=""Закрыть окно"" onclick=""CloseWindow()"" />",!
		Write "</hgroup>",!,!,!
		Write "<p6:refBook id=""refbook"" className="""_tModelClass_"""  ",!
		Write " align=""center"" width=""100%"">",!
		Write "<p6:tablePane initialExecute=""false"">",!
		Write "</p6:tablePane>"
		Write "</p6:refBook>"

		Write "</pane>",!
		Write "}",!
		
		
		&html<
Method btRegister() [ Language = javascript ]
{
	var refbook=zenPage.getComponentById("refbook");
	var table=zenPage.getComponentById("refbook").getChildById("table");
	table.whereClause=zenPage.GetWhere();
	table.executeQuery();
}

Method GetWhere() As %String [ ZenMethod ]
{
	set Controller=..%GetComponentById("source")
	set Obj=Controller.GetObject()
	quit Obj.GetFilter()
}
		>
	}

	#; end of class
	Write "}",!

	Quit $$$OK
}

/// Write controls for specific class
Method WriteControls(aClassName As %String) As %Status
{
	do $zobjclassmethod(aClassName,"%GetPropertyInfo",.info,1)
	for {
		set fieldName=$order(info($get(fieldName)))
		quit:fieldName=""
		set type=##class(p6.Convert).Replace(info(fieldName,"%type"),"p6.zen.component.","p6:")
		set sortedFields(info(fieldName))=$lb(fieldName,type)
	}
	for {
		set fieldNumber=$order(sortedFields($get(fieldNumber)))
		quit:fieldNumber=""
		write "<",$lg(sortedFields(fieldNumber),2)
			," dataBinding=""",$lg(sortedFields(fieldNumber),1),""" />",!
	}
	quit $$$OK
}

/// Create the result set used by the Package dataCombo.
Method CreatePackageRS(Output tSC As %Status, pInfo As %ZEN.Auxiliary.QueryInfo) As %ResultSet
{
	Set tRS = ""
	Set tSC = $$$OK

	Set tRS = ##class(%ResultSet).%New()
	Set tRS.ClassName = "%ZEN.Utils"
	Set tRS.QueryName = "EnumeratePackages"
	Quit tRS
}

/// Create the result set used by the Package dataCombo.
Method CreateModelClassRS(Output tSC As %Status, pInfo As %ZEN.Auxiliary.QueryInfo) As %ResultSet
{
	Set tRS = ""
	Set tSC = $$$OK

	Set tRS = ##class(%ResultSet).%New()
	do tRS.Prepare("select ID from %Dictionary.ClassDefinition where ID %STARTSWITH ?")
	//Set tRS.QueryName = "Extent"
	Quit tRS
}

/// Create the result set used by the Application dataCombo.
Method CreateApplicationRS(Output tSC As %Status, pInfo As %ZEN.Auxiliary.QueryInfo) As %ResultSet
{
	Set tRS = ""
	Set tSC = $$$OK

	Set tRS = ##class(%ResultSet).%New()
	Set tRS.ClassName = "%ZEN.Utils"
	Set tRS.QueryName = "EnumerateApplications"
	Quit tRS
}

}

