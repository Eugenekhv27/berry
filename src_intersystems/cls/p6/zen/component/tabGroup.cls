/// Расширение стандартного компонента вкладок.
/// Если объект на форме еще не сохранен то вкладки заменяються на кнопку "Сохранить и показать строки"
/// Обычно на вкладках распологаються таблицы строк объекта и пока объект не сохранен
/// эти таблицы не могут быть показаны
Class p6.zen.component.tabGroup Extends %ZEN.Component.tabGroup
{

/// This is the XML namespace for this component.
Parameter NAMESPACE = "http://www.dimas.ru/p6";

/// Если истина, то даже если форма не сохранена то вкладки показываются
Property isShowTabs As %ZEN.Datatype.boolean;

/// Информация о индексах компонентов таблиц в каждом табе
/// в виде (,;15,26;)
/// 3 таба, на втором 2 таблицы с индексами 15 и 26
Property tableInfo As %ZEN.Datatype.string;

Method %DrawHTML() As %Status
{
	
	do ..FillTableInfo()
	
	set formId=..%GetForm().id
	
	if (..%GetForm().%controller.modelId="")&&('..isShowTabs) {
		&html<<button id="#(..%MakeId("save_and_show"))#" onclick="zenPage.getComponent(#(..index)#).btSaveAndShow('#(..%GetForm().id)#')">Сохранить и показать кнопки</button>>
		quit $$$OK
	}
	
	do ##super()
	Quit $$$OK
}

/// заполнение информации о индексах таблиц находящихся в табах
/// !! не обрабатывает вложенные !!
Method FillTableInfo() As %Status
{
	set tableCompNum=""
	Set tCount = ..children.Count()
	For tabNo=1:1:tCount {
		Set tab = ..children.GetAt(tabNo)
		If tab.%IsA("%ZEN.Component.tab") {
			Set numComp = tab.children.Count()
			For compNo=1:1:numComp {
				Set comp = tab.children.GetAt(compNo)
				If (comp.%IsA("p6.zen.component.refBook") || comp.%IsA("p6.zen.component.tablePane")) {
					set $P(tableCompNum,",",tabNo)=+$L(tableCompNum,",")+1
					set p4tableInfo = ..tableInfo //shu12
					set oldCompList=$P(p4tableInfo,";",tabNo)
					set $P(oldCompList,",",$P(tableCompNum,",",tabNo))=comp.index
					set $P(p4tableInfo,";",tabNo)=oldCompList
					set ..tableInfo = p4tableInfo
				}
			}
		}else {
			quit
		}
	}
	quit $$$OK
}

/// Server-side method.
/// Find the form object that this control belongs to.
/// Return "" if there is no form.
Method %GetForm() As %ZEN.Component.form
{
	Set tForm = ""
	Set tParent = ..parent
	While ($IsObject(tParent)) {
		If (tParent.%IsA("%ZEN.Component.form")) {
			Set tForm = tParent
			Quit
		}
		Set tParent = tParent.parent
	}
	Quit tForm
}

ClientMethod btSaveAndShow(formId) [ Language = javascript ]
{
	var form = zenPage.getComponentById(formId);
	if (form.save()) {
		this.isShowTabs=true;
		zenPage.objectId=form.controller.modelId;
		zenPage.refreshContents(true);
	}
}

/// При переключении таба обновление ширины для всех таблиц в этом табе
ClientMethod onshowTabHandler(tabno) [ Language = javascript ]
{
	var tableList=Piece(this.tableInfo,";",tabno);
	for(i=1;i<=Length(tableList,",");i++) {
		tableId=Piece(tableList,",",i);
		if(tableId=="")continue;
		comp=zenPage.getComponent(tableId);
		if(comp._serverClass=="p6.zen.component.refBook") {
			comp.getChildById("table").resizeHeaders();
		}else {
			comp.resizeHeaders();
		}
	}
}

}

