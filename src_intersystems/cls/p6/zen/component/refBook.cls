/// Стандартный справочник. Постороен на основе <class>p6.zen.component.tablePane</class><br>
/// Состоит из таблицы,навиготора и кнопок(создать,изменить,удалить,передать справочник в word,передать в excel)
Class p6.zen.component.refBook Extends %ZEN.Component.composite
{

/// This is the XML namespace for this component.
Parameter NAMESPACE = "http://www.dimas.ru/p6";

/// Класс, экземпляры которого показываем
Property className As %ZEN.Datatype.string;

/// Класс странгицы редактирования
Property editPage As %ZEN.Datatype.string;

/// Тип справочника.<br>
/// Возможные значения:"Open","Modal"<br>
/// Влияет на то будет ли появляться кнопка "выбрать запись"
Property windowType As %ZEN.Datatype.string(VALUELIST = ",Open,Modal") [ InitialExpression = "Open" ];

/// Дополнительное условие where передаваемое в запрос постороения таблицы справочника
Property where As %ZEN.Datatype.string;

/// сортировка Order By
Property orderBy As %ZEN.Datatype.string;

/// Дополнительная строка прикрепляемая к URL страницы редактирования
Property urlParam As %ZEN.Datatype.string;

/// Показывать навигатор
Property showNavigator As %ZEN.Datatype.boolean [ InitialExpression = 1 ];

/// Показывать кнопку "Создать"?
Property btNew As %ZEN.Datatype.string;

/// Показывать кнопку "Создать копированием"?
Property btCopy As %ZEN.Datatype.string;

/// Показывать кнопку "Изменить"?
Property btEdit As %ZEN.Datatype.string;

/// Показывать кнопку "Удалить"?
Property btDelete As %ZEN.Datatype.string;

/// Показывать кнопку "Выбрать запись"?
Property btReturn As %ZEN.Datatype.string;

/// Показывать кнопку "Закрыть"?<br>
/// Если нет то "-"<br>
/// иначе "" - использовать стандартный обработчик кнопки<br>
/// или JS код - выполнить этот код<br>
/// то же верно для остальных кнопок
Property btClose As %ZEN.Datatype.string [ InitialExpression = "-" ];

/// Показывать кнопку "Передать в Word"?
Property btPrintWord As %ZEN.Datatype.string;

/// Показывать кнопку "Передать в Excel"?
Property btPrintExcel As %ZEN.Datatype.string;

Property IsFullRefbookRegister As %ZEN.Datatype.string;

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<composite xmlns="http://www.intersystems.com/zen">
<hgroup id="buttons" align="center" containerStyle="padding-bottom:0.3em;">
</hgroup>
</composite>
}

/// Создание справочника.
Method %OnAfterCreateComposite() As %Status
{
	if ..editPage="" set ..editPage=$zobjclassmethod(..className,"GetDefaultEditPage")

	for n=1:1:..children.Count() {
		set Component = ..children.GetAt(n)
		if Component.%IsA("%ZEN.Component.tablePane") {
			 set Table=Component
		}
	}
	if $get(Table)=$$$NULLOREF {
		set Table=##class(p6.zen.component.tablePane).%New()
	} else {
		do ..%RemoveChild(Table)
		set Table.index=""
	}
	set Table.id="table"
	do ..%AddChild(Table)

	do ..ProcessColumns()
	do ..ProcessWhere()
	//if $$$ZENISIE {
	//	set Table.fixedHeaders=$$$NO // при fixedHeaders=1 сьезжают колонки в IE (надо проработать)
	//} else {
	set Table.fixedHeaders=$$$YES
	//}
	set Table.bodyHeight ="400px"
	set Table.hasFocus=1
	set classDefinition=##class(%Dictionary.CompiledClass).%OpenId(..className)
	set Table.tableName=classDefinition.SqlSchemaName_"."_classDefinition.SqlTableName
	set Table.ondblclick="zenPage.getComponent("_..index_").OnDblClick()"
	set Table.onkeypress="return zenPage.getComponent("_..index_").OnKeypress(evt);"
	
	if ..windowType="Modal" do ..AddButton("btReturn","Выбрать")
	if ..btNew'="-" do ..AddButton("btNew", "Создать")
	if ..btCopy="+" do ..AddButton("btCopy", "Создать копированием")
	if ..btEdit'="-" do ..AddButton("btEdit", "Изменить")
	if ..btDelete'="-" do ..AddButton("btDelete", "Удалить")
 	if ..btPrintWord'="-" do ..AddButton("btPrintWord", "Экспорт в Word")
 	if ..btPrintExcel'="-" do ..AddButton("btPrintExcel", "Экспорт в Excel")
	if ..btClose'="-" do ..AddButton("btClose", "Закрыть")
	
	if ..showNavigator {
		set Navigator=##class(%ZEN.Component.tableNavigatorBar).%New()
		set Navigator.msgFilter = "Фильтр"
		set Navigator.msgPageSize = "Строк на странице"
		set Navigator.msgFound = "Результат"
		set Navigator.msgPage = "Страница"
		set Navigator.msgFirstPage = "Перейти к первой странице"
		set Navigator.msgLastPage = "Перейти к последней странице"
		set Navigator.msgNextPage = "Перейти к следующей странице"
		set Navigator.msgPreviousPage = "Перейти на предыдущую страницу"
		set Navigator.msgMaxRows = "Всего строк" 
		set Navigator.id="navigator"
		set Navigator.containerStyle="padding:0.3em;"
		set Navigator.tablePaneId="table"
		set Navigator.showPageSize=1

		set ButtonsGroup=..%GetChildById("buttons")
		do ButtonsGroup.%AddChild(Navigator)
	}
	//do $system.OBJ.Dump(%page)
	Quit $$$OK
}

/// Подготовка столбцов- заполнение недастающих данных(заголовки итп) из описания классов п6
/// , либо извлечение информации о колонках из описания справочника на странице редактирования
Method ProcessColumns() As %Status
{
	#DIM Table As p6.zen.component.tablePane
	set Table=..%GetChildById("table")
	
	set isIdFound=0

	if Table.columns.Count()>0 {
		for i=1:1:Table.columns.Count() {
			if Table.columns.GetAt(i).colName="ID" || Table.columns.GetAt(i).field="ID" {
				set isIdFound=1
			}
		}
	} else {

		set oldPage=%page
		kill %page
		set newRefBook=..CreateRefBook()
		
		#DIM NewTable As p6.zen.component.tablePane
		set NewTable=newRefBook.children.GetAt(1)
		set ..btNew=newRefBook.btNew
		set ..btCopy=newRefBook.btCopy
		set ..btEdit=newRefBook.btEdit
		set ..btDelete=newRefBook.btDelete
		if newRefBook.btClose'="-" set ..btClose=newRefBook.btClose
	//	set ..btPrintWord=newRefBook.btPrintWord
	//	set ..btPrintExcel=newRefBook.btPrintExcel
		set ..IsFullRefbookRegister = newRefBook.IsFullRefbookRegister
		
		set %page=oldPage
		
		set id=Table.id,index=Table.index,parent=Table.parent
		do ##class(p6.ClassUtils).CopyProperties(Table,NewTable,NewTable.%ClassName(1))
		set Table.id=id,Table.index=index,Table.parent=parent
			
		do Table.columns.Clear(),Table.conditions.Clear()
		
		set Table.filtersDisabled=0
		
		for i=1:1:NewTable.columns.Count() {
			#dim Column As p6.zen.auxiliary.column
			set Column=##class(p6.zen.auxiliary.column).%New()
			do ##class(p6.ClassUtils).CopyProperties(Column,NewTable.columns.GetAt(i),"p6.zen.auxiliary.column")
			do Table.%AddColumn(Column)
			if Column.colName="ID" || Column.field="ID" {
				set isIdFound=1
			}
		}
	
		for i=1:1:NewTable.conditions.Count() {
			#dim Condition As %ZEN.Auxiliary.condition
			set Condition=##class(%ZEN.Auxiliary.condition).%New()
			do ##class(p6.ClassUtils).CopyProperties(Condition,NewTable.conditions.GetAt(i),"%ZEN.Auxiliary.condition")
			do Table.conditions.Insert(Condition)
			do:$IsObject(%page) %page.%AddComponent(Condition)
		}
	}
 	if 'isIdFound {
		set Column=##class(p6.zen.auxiliary.column).%New()
		set Column.colName="ID"
		set Column.field="ID"
		set Column.hidden=1
		do Table.%AddColumn(Column)
	}
 	quit $$$OK
}

/// Обработка where: передача его в таблицу
Method ProcessWhere() As %Status
{
	set ..%GetChildById("table").whereClause=..where
	set:..orderBy]"" ..%GetChildById("table").orderByClause=..orderBy
	quit $$$OK
}

/// Really delete object
ClassMethod ProcessDelete(aClassName, aId) As %Status [ CodeMode = expression, ZenMethod ]
{
$zobjclassmethod(aClassName,"%OnDeleteSource",aId)
}

/// Создание кнопок
Method AddButton(aButtonName As %String, aTitle As %String) As %Status
{
	set ButtonsGroup=..%GetChildById("buttons")
	
	set Button=##class(%ZEN.Component.button).%New()
	set Button.id=aButtonName
	set Button.controlClass=aButtonName
	set Button.onclick="zenPage.getComponent("_..index_")."_aButtonName_"Handler()"
	set Button.containerStyle="padding-right:0.3em;"
	set Button.title=aTitle
	set Button.caption=aTitle
	do ButtonsGroup.%AddChild(Button)
	
	quit $$$OK
}

/// Внутренний метод. Создает справочник на основе описания в XData refBook на странице редактирования
Method CreateRefBook() As p6.zen.component.refBook
{
	set editClass=$piece(..editPage,".cls",1)

	set compiledClass=##class(%Dictionary.CompiledClass).%OpenId(editClass)
	
	if compiledClass]"" {
		#; find XDATA block named Contents
		if ..IsFullRefbookRegister=1 {
			Set tIndex = compiledClass.XDatas.FindObjectId(editClass_"||refBookFull")
		} else {
			Set tIndex = compiledClass.XDatas.FindObjectId(editClass_"||refBook")
		}
	}

	If ($get(tIndex) '= "") {
		#; get XDATA as stream
		Set tStream = compiledClass.XDatas.GetAt(tIndex).Data
		Do tStream.Rewind()

		If (tStream.Size > 0) {

			#; render the stream into composite object (with children)
			Set tReader = ##class(%XML.Reader).%New()
			Set tSC = tReader.OpenStream(tStream) If $$$ISERR(tSC) Quit tSC
			Do tReader.Correlate("composite","%ZEN.Component.composite")
			
			#; there should only be one composite object defined
			Do tReader.Next(.tComposite,.tSC)
			If $$$ISERR(tSC) Quit tSC
			If '$IsObject(tComposite) Quit $$$ERROR($$$GeneralError,"No <composite> element defined in Contents block.")
		}
		Quit tComposite.children.GetAt(1)
	} else {
		if $data(%page) {
			set oldPage=%page
		}
		set %page=""
		set RefBook=##class(p6.zen.component.refBook).%New()
		set RefBook.className=..%ClassName(1)
		set Table=##class(p6.zen.component.tablePane).%New()
		set Table.id="table"
		do RefBook.%AddChild(Table)

		do ..GetColumns(.result)

		set i=""
		for {
			set i=$order(result(i))
			quit:i=""
			set Column=##class(p6.zen.auxiliary.column).%New()
			set Column.field=result(i,"Field")
			set Column.header=result(i,"Caption")
			do Table.%AddColumn(Column)
		}

		if $data(oldPage) {
			set %page=oldPage
		} else {
			kill %page
		}
		quit RefBook
	}
	quit $$$NULLOREF
}

/// В <var>result</var> возвращает информацию обо всех свойствах класса справочника.
/// Нужно если не описан справочник.
Method GetColumns(ByRef result) As %Status [ Internal ]
{
	set propList = ##class(p6.ClassDefinition).GetPropertyList(..className)
	if '$ListFind(propList,"Code") {
		set result(0,"Field")="Id"
		set result(0,"Caption")="Код"
	}

	for i=1:1:$ListLength(propList) {
		set propName = $list(propList,i)
		set propType = ##class(p6.ClassDefinition).GetPropertyType(..className,propName),
			propCaption = ##class(p6.ClassDefinition).GetPropertyCaption(..className,propName),
			propPersistent = ##class(p6.ClassDefinition).IsClassPersistent(propType),
			propTransient = ##class(p6.ClassDefinition).IsPropertyTransient(..className,propName),
			propCalculated = ##class(p6.ClassDefinition).IsPropertyCalculated(..className,propName),
			propSequenceNumber = ##class(p6.ClassDefinition).GetPropertySequenceNumber(..className,propName)
		if propCaption="" set propCaption=propName
		
		if $data(result(propSequenceNumber)) set propSequenceNumber=$order(result(""),-1)+1
		
		if propTransient||propCalculated continue
		if propPersistent &&
			##class(%Dictionary.CompiledProperty).%ExistsId(propType_"||Aka") {
				set result(propSequenceNumber,"Field")=propName_"->Aka"
		} else {
			set result(propSequenceNumber,"Field")=propName
		}
		set result(propSequenceNumber,"Caption")=propCaption
	}
	
	quit $$$OK
}

/// Обработчик сообщений клавиатуры
ClientMethod OnKeypress(evt) [ Language = javascript ]
{
	evt = evt ? evt : window.event;
	if (evt.type!="keydown") return false;
	
	// trap keys
	switch(evt.keyCode) {
	case zenENTER: {

		this.btEditHandler();
		return false;
		break;
	}
	case zenDELETE: {
		this.btDeleteHandler();
		return false;
		break;
	}
	case zenINSERT: {
		this.btNewHandler();
		return false;
		break;
	}
	}
	return true;
}

ClientMethod onloadHandler() [ Language = javascript ]
{
	this.getChildById("table").selectRow(0,false);
	
	document.onload = (function () {
		var refbook = document.getElementById('refbook');
		if (refbook) {
			document.onselectstart = function () {return false;}
		}
	})();
}

/// Обработчик кнопки "Изменить"
ClientMethod btEditHandler() [ Language = javascript ]
{
	var urlHead="";
	if(this.btEdit!='') {
		eval(this.btEdit);
		return
	}
	if(this.getChildById("table").value!='') {
		if (this.editPage.indexOf("?")!=-1) {
			urlHead=this.editPage+"&"
		} else {
			urlHead=this.editPage+"?"
		}
		zenLaunchPopupWindow(urlHead+"Id="+this.getChildById("table").value+"&"+eval(this.urlParam),'edit'+this.index,GetWindowFeatures(),null,this);
	}
}

ClientMethod btCopyHandler() [ Language = javascript ]
{
	var urlHead="";
	if(this.getChildById("table").value!='') {
		if (this.editPage.indexOf("?")!=-1) {
			urlHead=this.editPage+"&"
		} else {
			urlHead=this.editPage+"?"
		}
		zenLaunchPopupWindow(urlHead+"CopyFromId="+this.getChildById("table").value+"&"+eval(this.urlParam),'edit'+this.index,GetWindowFeatures(),null,this);
}
}

/// Обработчик двойного клика
ClientMethod OnDblClick() [ Language = javascript ]
{
	if (this.windowType=="Modal") {
		if(this.getProperty("btReturn")!="-") this.btReturnHandler();
	} else {
		if(this.btEdit!='-')
		{
		this.btEditHandler();
		}else {
			if(this.btReturn!='-') this.btReturnHandler();
		}
	}
}

/// Обработчик кнопки "Изменить"
ClientMethod btNewHandler() [ Language = javascript ]
{
	if(this.btNew!='') {
		eval(this.btNew);
		return
	}
	if (this.editPage.indexOf("?")!=-1) {
			urlHead=this.editPage+"&"
	} else {
			urlHead=this.editPage+"?"
	}
	zenLaunchPopupWindow(urlHead+"Id=&"+eval(this.urlParam),'edit'+this.index,GetWindowFeatures(),null,this);
}

/// Обработчик кнопки "Удалить"
ClientMethod btDeleteHandler() [ Language = javascript ]
{
	if(this.btDelete!='') {
		eval(this.btDelete);
		return
	}
	if (confirm("Вы действительно хотите удалить эту запись?")) {
		sc=this.ProcessDelete(this.className,this.getChildById("table").value);
		if (sc!=1) DisplayError(sc);
		this.getChildById("table").executeQuery(true);
	}
}

/// Обработчик кнопки "Выбрать"
ClientMethod btReturnHandler() [ Language = javascript ]
{
	if(this.btReturn!='') {
		eval(this.btReturn);
		return;
	}
	if (zenPage.isPopup) {
		zenPage.firePopupAction('ok',this.getChildById("table").value);
	} else {
		history.back();
	}
}

/// Обработчик кнопки "Закрыть"
ClientMethod btCloseHandler() [ Language = javascript ]
{
	if(this.btClose!='') {
		eval(this.btClose);
		return
	}
	CloseWindow();
}

/// Обработчик кнопки "Передать в Word"
ClientMethod btPrintWordHandler() [ Language = javascript ]
{
	this.getChildById("table").printIt("1",zenPage.title);
}

/// Обработчик кнопки "Передать в Excel"
ClientMethod btPrintExcelHandler() [ Language = javascript ]
{
	this.getChildById("table").printIt("2",zenPage.title);
}

/// Обработчик события всплывающих окон
ClientMethod onPopupAction(popupName, action, value) [ Language = javascript ]
{
	if(action=="save" || action=="delete") {
		this.getChildById("table").executeQuery(true);
	}
	if(action=="save" && zenPage.isPopup && this.windowType=="Modal") {
		zenPage.firePopupAction('ok',value);
	}
}

}

