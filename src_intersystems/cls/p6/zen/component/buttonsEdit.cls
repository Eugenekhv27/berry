/// Компонент служит для создания стандартных кнопок на форме (следующий,сохранить,удалить,история,закрыть)<br>
/// Должен быть расположен внутри тега form<br>
/// События сохранения и пр. надо ловить или отправлять на форме!!!!
Class p6.zen.component.buttonsEdit Extends %ZEN.Component.control
{

/// This is the XML namespace for this component.
Parameter NAMESPACE = "http://www.dimas.ru/p6";

/// <center><font color=red>НЕ РЕАЛИЗОВАНО</font></center>
/// Отображать кнопку "Следующий"<br>
/// Эта кнопка копирует текущий объект и открывает копию
Property btNext As %ZEN.Datatype.boolean;

/// Функция вызываеться после копирования
Property onbtnext As %ZEN.Datatype.eventHandler;

Property canDelete As %ZEN.Datatype.boolean [ InitialExpression = 1 ];

Property canViewLog As %ZEN.Datatype.boolean [ InitialExpression = 1 ];

Method %DrawHTML() As %Status
{
	set formIndex=..%GetForm().index
	if ..id="" set ..id="buttonsEdit"
	&html<<br><center>>
	if ..btNext {
		if ..%GetForm().%controller.modelId]"" {
		&html<<button id="#(..%MakeId("next"))#" class="btn" onclick="zenPage.getComponent(#(..index)#).btNextFunc(#(formIndex)#)" title="Следующий"><i class="fa fa-ellipsis-h fa-lg"></i> Следующий</button>>
		}
	}
	&html<<button id="#(..%MakeId("save"))#" class="btn" onclick="zenPage.getComponent(#(..index)#).btSave(#(formIndex)#)" title="Сохранить изменения"><i class="fa fa-save fa-lg"></i> Сохранить</button>>
	if ..%GetForm().%controller.modelId]"" {
		if ..canDelete &html<<button id="#(..%MakeId("delete"))#" class="btn" onclick="zenPage.getComponent(#(..index)#).btDelete(#(formIndex)#)" title="Удалить документ"><i class="fa fa-trash fa-lg"></i> Удалить</button>>
		if ..canViewLog &html<<button id="#(..%MakeId("log"))#" class="btn" onclick="zenPage.getComponent(#(..index)#).btHistory(#(formIndex)#)" title="История изменений"><i class="fa fa-history fa-lg"></i> История</button>>
		&html<<button id="#(..%MakeId("help"))#" class="btn" onclick="zenPage.getComponent(#(..index)#).btHelp(#(formIndex)#)" title="Помощь"><i class="fa fa-info fa-lg"></i> Помощь</button>>
	}
	&html<<button id="#(..%MakeId("close"))#" class="btn btn-close" onclick="zenPage.getComponent(#(..index)#).btClose(#(formIndex)#)" title="Закрыть без сохранения"><i class="fa fa-close fa-lg"></i> Закрыть</button>>
	

	&html<</center>>
	Quit $$$OK
}

ClientMethod btSave(formIndex) [ Language = javascript ]
{
	var form = zenPage.getComponent(formIndex);
	if (form.save()) {
		if(zenPage.isPopup) {
			zenPage.firePopupAction('save',form.controller.getModelId());
		}else {
			window.close();
		}
	}
}

ClientMethod btHelp(formIndex) [ Language = javascript ]
{
	var form = zenPage.getComponent(formIndex);
	var n = form.controller.modelClass;
	if (n == 'ent.Station')
	{
		window.open('help/Station.html');
	}
	else if (n == 'ent.ArticleCost')
	{
		window.open('help/ArticleCost.html');
	}
	else if (n == 'dtk.RouteList')
	{
		
		window.open('help/RouteList.html');
	}
	else if (n == 'dtk.PriceExpedite')
	{
		
		window.open('help/PriceExpedite.html');
	}
	else if (n == 'ent.FilialAddService')
	{
		
		window.open('help/FilialAddService.html');
	}
	else if (n == 'dtk.PriceDeliveryAtDoor')
	{
		
		window.open('help/PriceDeliveryAtDoor.html');
	}
	else if (n == 'ent.Org')
	{
		
		window.open('help/Org.html');
	}
}

ClientMethod btDelete(formIndex) [ Language = javascript ]
{
	if (!confirm("Вы действительно желаете удалить эту запись?")) return;
	var form = zenPage.getComponent(formIndex);
	var sc=form.controller.deleteId(form.controller.getModelId());
	if (form.controller.modelId=='') {
		zenPage.firePopupAction('delete');
	}
}

ClientMethod btHistory(formIndex) [ Language = javascript ]
{
	var form = zenPage.getComponent(formIndex);
	zenLaunchPopupWindow("zui.admin.LogObject.cls?ClassName="+form.controller.modelClass+"&Id="+form.controller.getModelId());
}

ClientMethod btClose(formIndex) [ Language = javascript ]
{
	CloseWindow();
}

ClientMethod btNextFunc(formIndex) [ Language = javascript ]
{
	var form = zenPage.getComponent(formIndex);
	this.CopyObj(form.controller);
	zenInvokeCallbackMethod(this.onbtnext);
	form.controller.raiseDataChange();
}

Method CopyObj(Controller As p6.zen.component.dataController) As %Status [ ZenMethod ]
{
	set Form=..%GetForm()
	set Obj=Controller.GetObject()
	set NewObj=Obj.%ConstructClone()
	do Controller.SetObject(NewObj)
	
	quit $$$OK
}

}

