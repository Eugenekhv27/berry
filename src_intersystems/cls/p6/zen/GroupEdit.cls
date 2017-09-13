Class p6.zen.GroupEdit Extends p6.zen.EditPage
{

Parameter PAGENAME = "Редактирование группы";

/// Класс линков
Property linkClass As %ZEN.Datatype.string(ZENURL = "LinkClass");

/// Свойства через "_"  которые показываются в таблице
Property propertys As %ZEN.Datatype.string(ZENURL = "Props") [ InitialExpression = "Aka" ];

/// Подписи свойств через "_", если нужно подпись свойство по умолчанию то просто 2 символа "_" на том месте
Property propertysDef As %ZEN.Datatype.string(ZENURL = "PropsDef");

/// Класс объектов в группе
Property objInGroup As %ZEN.Datatype.string;

/// Класс групп
Property groupClass As %ZEN.Datatype.cssClass(ZENURL = "GroupClass");

XData Style
{
<style type="text/css">
</style>
}

XData editPane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane width="100%" xmlns="http://www.intersystems.com/zen" xmlns:p6="http://www.dimas.ru/p6" id="editPane">
<p6:dataController id="source"
 modelClass="ent.EntityGroup" modelId="#(%url.Id)#"/>
<form  width="100%" id="myForm" layout="vertical" controllerId="source">
<p6:text dataBinding="Aka" size="20" />
<p6:textRefBook dataBinding="ParentGroup" size="20" />

<hgroup condition="%page.objectId" valign="top">
<vgroup>
<tableNavigatorBar tablePaneId="notInGroup" />
 <p6:tablePane id="notInGroup" valign="top"
	caption="Объекты не входящие в группы" 
	useSnapshot="true"
	showRowSelector="false"
	width="50%" nowrap="false"
	valueColumn="ID"
	height="100"
	dataSource="query"
	orderByClause="Aka" ondblclick="zenPage.add()">
<p6:column colName="ID" hidden="true" filterOp="[NOCASE" filterType="text" />
</p6:tablePane>
</vgroup>
<vgroup cellStyle="padding:0.2em;" valign="top">
<button caption="&gt;" onclick="zenPage.add()"></button>
<button caption="&lt;" onclick="zenPage.remove()"></button>
</vgroup>
<vgroup valign="top" >
<tableNavigatorBar tablePaneId="inGroup" />
<p6:tablePane width="50%" valign="top"
	id="inGroup"
    caption="Объекты входящие в группы"
	showRowSelector="false"
	valueColumn="ID"
	height="100"
	dataSource="query" ondblclick="zenPage.remove()">
  <p6:column colName="ID" hidden="true" />
</p6:tablePane>
</vgroup>
</hgroup>
<p6:buttonsEdit />
</form>
</pane>
}

ClientMethod add() [ Language = javascript ]
{
	var linkId=zenPage.getComponentById('notInGroup').getValue();
	if(linkId!="")
	{
		zenPage.AddObjToGroup(linkId);
		zenPage.getComponentById('notInGroup').executeQuery();
		zenPage.getComponentById('inGroup').executeQuery();
	}else
	{
		alert("Выберите объект!");
	}
}

Method AddObjToGroup(aObjId As %String) As %Status [ ZenMethod ]
{
	set class=..linkClass
	quit $zobjclassmethod(class,"Create",..objectId,aObjId)
}

ClientMethod remove() [ Language = javascript ]
{
	var linkId=zenPage.getComponentById('inGroup').getValue();
	if(linkId!="")
	{
		zenPage.RemoveObjFromGroup(linkId);
		zenPage.getComponentById('notInGroup').executeQuery();
		zenPage.getComponentById('inGroup').executeQuery();
	}else
	{
		alert("Выберите объект!");
	}
}

Method RemoveObjFromGroup(aObjId As %String) As %Status [ ZenMethod ]
{
	set class=..linkClass
	quit $zobjclassmethod(class,"%OnDeleteSource",aObjId)
}

Method %OnAfterCreatePage() As %Status
{
	set controller=..%GetComponentById("source")
	set controller.modelClass=..groupClass

	
	set ..%GetComponentById("editPane").align="center"
	set ..objInGroup=##class(p6.ClassDefinition).GetPropertyType(..linkClass,"Entity")
	set ..groupClass=##class(p6.ClassDefinition).GetPropertyType(..linkClass,"EntityGroup")	
	
	if ..objectId {
		set notInGroupRefBook=..%GetComponentById("notInGroup")
		set inGroupRefBook=..%GetComponentById("inGroup")
	
		set notInGroupRefBook.tableName  =..objInGroup
		set notInGroupRefBook.whereClause="Id not in (select Entity from "_..linkClass_" where (EntityGroup->ID='"_..objectId_"' or ('"_..objectId_"' is null)))"
	
		set inGroupRefBook.tableName  =..linkClass
		set inGroupRefBook.whereClause="(EntityGroup->ID='"_..objectId_"' or ('"_..objectId_"' is null))"
	
		for i=1:1:$LENGTH(..propertys,"_")
		{
			set prop=$PIECE(..propertys,"_",i)
			set col=##class(p6.zen.auxiliary.column).%New()
			set col.field=prop
			if ($PIECE(..propertysDef,"_",i)="") {
				set col.header=##class(p6.ClassDefinition).GetPropertyCaption(..objInGroup,prop)
			}else {
				set col.header=$PIECE(..propertysDef,"_",i)
			}
			do ..%AddComponent(col)
			do notInGroupRefBook.columns.Insert(col)
		
			set col=##class(p6.zen.auxiliary.column).%New()
			set col.field="Entity->"_prop
			if ($PIECE(..propertysDef,"_",i)="") {
				set col.header=##class(p6.ClassDefinition).GetPropertyCaption(..objInGroup,prop)
			}else {
				set col.header=$PIECE(..propertysDef,"_",i)
			}
			do ..%AddComponent(col)
			do inGroupRefBook.columns.Insert(col)
		}
	}
	quit $$$OK
}

}

