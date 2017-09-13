/// Класс для добавления модели данных к хранимым классам Прототипа-5
Class p6.zen.DataModel Extends %ZEN.DataModel.Adaptor [ Abstract ]
{

/// SQL-фильтр, возвращающий ограничение на выбираемые записи
ClassMethod GetModelFilter() As %String
{
	quit ""
}

/// This method return value which is displayed in textRefBook fields
ClassMethod GetDisplayValue(aId As %String) As %String
{
	if '$zobjclassmethod(..%ClassName(1),"%ExistsId",aId) quit ""
	if ##class(%Dictionary.CompiledProperty).%ExistsId(..%ClassName(1)_"||Code") {
		set code=$zobjclassmethod(..%ClassName(1),"CodeGetStored",aId)
	} else {
		set code=aId
	}

	if ##class(%Dictionary.CompiledProperty).%ExistsId(..%ClassName(1)_"||Aka") {
		quit $zobjclassmethod(..%ClassName(1),"AkaGetStored",aId)_" ["_code_"]"
	}
	quit ..%ClassName(1)_" ["_code_"]"
}

/// This return class name of default edit page class for this data model
ClassMethod GetDefaultEditPage() As %String
{
	if ##class(%Dictionary.CompiledClass).%ExistsId("zui."_..%ClassName(1)) {
		quit "zui."_..%ClassName(1)_".cls"
	}
	quit "p6.zen.PageDynamic.cls?ClassName="_..%ClassName(1)
}

/// This method return columns, which are used to find objects while user type in p6:textRefBook
/// Format: Property1[:Collation1],Property2[:Collation2],...
/// Where Collation is one of Exact,StartsWith,Like. Default is Like.
ClassMethod GetLookupColumns() As %String
{
	if ##class(%Dictionary.CompiledProperty).%ExistsId(..%ClassName(1)_"||Code") {
		set result="Code:Код:Exact"
	} else {
		set result="Id:Код:Exact"
	}
	if ##class(%Dictionary.CompiledProperty).%ExistsId(..%ClassName(1)_"||Aka") {
		set result=result_",Aka:Описание:Like"
	}
	quit result
}

/// Custom Save() method
Method %OnSaveSource(pSource As %RegisteredObject) As %Status [ CodeMode = objectgenerator ]
{
	Set tType = $$$getClassType(%compiledclass.Name)
	If (tType = "persistent") {
		Do %code.Write(" Set tSC = ..Save()")
		Do %code.Write(" Set:$$$ISOK(tSC) ..%id = ..%Id()")
		Do %code.Write(" Quit tSC")
	}
	Else {
		Do %code.Write(" Quit $$$OK")
	}
	Quit $$$OK
}

/// Custom DeleteId() method
ClassMethod %OnDeleteSource(pID As %String) As %Status [ CodeMode = objectgenerator ]
{
	Set %code.CodeMode = "expression"
	Set tType = $$$getClassType(%compiledclass.Name)
	If (tType = "persistent") {
		Do %code.Write("..DeleteId(pID)")
	}
	Else {
		Do %code.Write("$$$OK")
	}
	Quit $$$OK
}

/// Custom controls
ClassMethod %OnGetPropertyInfo(pIndex As %Integer, ByRef pInfo As %String, pExtended As %Boolean = 0, pModelId As %String = "", pContainer As %String = "") As %Status
{
	for {
		set prop=$o(pInfo($get(prop)))
		quit:prop=""

		set:$d(pInfo(prop,"%type")) pInfo(prop,"%type")=$case($get(pInfo(prop,"%type")),
			"text":"p6.zen.component.text",
			"textarea":"p6.zen.component.textarea",
			"dataCombo":"p6.zen.component.textRefBook",
			"checkbox":"p6.zen.component.checkbox",
			"combobox":"p6.zen.component.combobox",
			"radioSet":"p6.zen.component.combobox",
			:pInfo(prop,"%type")
		)
		
		if $get(pInfo(prop,"%ptype"))=10 {
			set pInfo(prop,"%type")="p6.zen.component.calendar"
		}
		if $get(pInfo(prop,"%type"))="p6.zen.component.checkbox" {
			kill pInfo(prop,"caption")
		}
		set description=##class(p6.ClassDefinition).GetPropertyCaption(..%ClassName(1),prop)
		set pInfo(prop,"label")=description
	}

	quit $$$OK
}

/// Проверка прав доступа
Method %OnCopyDataFromModel(ByRef pData) As %Status
{
	if ##class(%Dictionary.CompiledMethod).%ExistsId(..%ClassName(1)_"||GetModelFilter") &&
		##class(%Dictionary.CompiledMethod).%ExistsId(..%ClassName(1)_"||%Id") {
		set id=$zobjmethod($this,"%Id")
		if id="" quit $$$OK
		set filter=$zobjclassmethod($this.%ClassName(1),"GetModelFilter")
		if filter] "" {
			set filter=##class(p6.FilterUtils).Add(filter,"Id="_id)
			set Rs=##class(%ResultSet).%New()
			$$$QuitOnError(Rs.Prepare("Select id from "_..%ClassName(1)_" where "_filter))
			$$$QuitOnError(Rs.Execute())
			if 'Rs.Next() kill pData
		}
	}
	
	Quit $$$OK
}

/// If defined, this callback method is invoked just before the dataController
/// copies its values into the properties of this DataModel object.<br>
/// <var>pData</var> is an array containing the values provided by the
/// controller, subscripted by property name.
Method %OnCopyDataToModel(ByRef pData) As %Status
{
	set err=""
	s sno=$ORDER(pData(""))
	while((sno'="") & (err="")) {
		s prop=$ORDER(pData(sno,""))
		while((prop'="") & (err="")) {		
			set className=##class(p6.ClassDefinition).GetPropertyType(..%ClassName(1),prop)
			set persist=##class(p6.ClassDefinition).IsClassPersistent(className)
			set required=##class(p6.ClassDefinition).IsPropertyRequired(..%ClassName(1),prop)
			if (persist & required) {
				if '$zobjclassmethod(className,"%ExistsId",pData(sno,prop)) {
					s pData(sno,prop)=""
				}
			}
			s prop=$ORDER(pData(sno,prop))
		}
		s sno=$ORDER(pData(sno))
	}
	if err'="" quit $$$ERROR(10000,err)
	Quit $$$OK
}

}

