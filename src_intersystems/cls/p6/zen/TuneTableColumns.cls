/// Created using the page template: Default
Class p6.zen.TuneTableColumns Extends p6.zen.EditPage
{

/// Имя приложения, которому принадлежит эта страница.
Parameter APPLICATION = "p6.zen.Application";

/// Отображаемое имя для нового приложения.
Parameter PAGENAME;

/// Домен, используемый для локализации.
Parameter DOMAIN;

Property SetColimns As %String(MAXLEN = 1000, ZENURL = "SetColumns");

/// Этот блок Style содержит определение CSS стиля страницы.
XData Style
{
<style type="text/css">
</style>
}

/// Этот XML блок описывает содержимое этой страницы.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="Настройка колонок таблицы" dragAndDrop="true">
<html>Перетащите мышкой названия колонок из левого поля в правое. Расположите их в нужном порядке.</html>
<hgroup>
<vgroup valign="top">
<titleBox title="Все колонки"/>
<listBox id="listBox1" listWidth="200px" listHeight="341px"
	dragEnabled="true" dropEnabled="true"
	 onafterdrag="zenPage.afterDrag(zenThis,dragData);">
</listBox>
</vgroup>
<spacer width="50"/>
<vgroup>
<titleBox title="Колонки в отчете"/>
<listBox id="listBox2"  listWidth="200px" listHeight="341px"
	dragEnabled="true" dropEnabled="true"
	onafterdrag="zenPage.afterDrag(zenThis,dragData);">
</listBox>
</vgroup>
</hgroup>
  <hgroup>
  	<button id="mgOk" caption="Сохранить и закрыть" onclick="zenPage.firePopupAction('SetColimns',zenPage.SetColimns,true);"/>
 </hgroup>
</page>
}

/// This method is called after a drag operation is completed.
/// <var>comp</var> is the component on which the drag started.
/// <var>dragData</var> is an object containing details about the 
/// drag operation.<br/>
/// <var>dragData</var> has the following properties:<br/>
/// <br/>
/// <var>dragData.value</var> - logical value of the drag data.<br/>
/// <var>dragData.text</var> - display value of the drag data.<br/>
/// <var>dragData.sourceComponent</var> - Zen component in which the drag started.<br/>
/// <var>dragData.targetComponent</var> - Zen component in which the drop occurred.<br/>
/// <var>dragData.sourceItem</var> - Component-specific value indicating where the drag started within the source.<br/>
/// <var>dragData.targetItem</var> - Component-specific value indicating where the drop occurred within the target.<br/>
/// <var>dragData.sourceMeta</var> - Arbitrary value set by the drag source.<br/>
/// <var>dragData.targetMeta</var> - Arbitrary value set by the drop target.<br/>
/// 
ClientMethod afterDrag(listBox, dragData) [ Language = javascript ]
{
	// override default behavior:
	// if this is a drag and drop between the 2 list boxes,
	// then remove the item from the drag source.
	
	// make sure target is a list box
	if (dragData.targetComponent.isOfType('listBox')) {
		// ignore drag onto ourselves
		if (dragData.targetComponent != listBox) {
			if (dragData.sourceItem >= 0) {
				listBox.removeOption(dragData.sourceItem);
	//			zenPage.updatePriorities();
			}
		}
	}
	zenPage.UpdateSetColimns();
}

ClientMethod UpdateSetColimns() [ Language = javascript ]
{
	listBox = zenPage.getComponentById("listBox2");
	p = listBox.getOptionCount();
	i=0;
	var result="";
	while (i<p) {
		/// формат строки  
		///					    (field)			(1)	
		/// Название колонки ! Имя поля ! признак подсуммировки ;
		///
		/// или					(colName:colExpression)                  (1)
		/// Название колонки ! имя столбца : вычисляемое выражение ! признак подсуммировки ;
		result = result +listBox.getOptionText(i)+ "!" + listBox.getOptionValue(i) + ";";
		i=i+1;
	}
	zenPage.SetColimns = result;
}

ClientMethod onloadHandler() [ Language = javascript ]
{
	var listBox2arr=[];
	if (zenPage.SetColimns!="") {
		listBox2 = zenPage.getComponentById("listBox2");
		var len = Length(zenPage.SetColimns, ";");	
		var i=1;
		while (i<=len) {
			colString=Piece(zenPage.SetColimns,";",i);
			if (colString!="") { 
				listBox2.appendOption(Piece(colString,"!",2), Piece(colString,"!",1));
				listBox2arr.push(colString)
			}
			i=i+1;
		}
	}
	var mainlistbox = 
		"Общий срок доставки на дату формирования отчета!DeliveryPeriod;"+
		"Организация-плательщик!Payment->Aka;"+
		"Грузоотправитель!FromOrg->Aka;"+
		"Грузоотправитель (полное)!FromOrg->FullName;"+
		"Грузополучатель!ToOrg->Aka;"+
		"Грузополучатель (полное)!ToOrg->FullName;"+
		"Номер ТТН!DocNo;"+
		"Номер ТТН клиента!DocNoClient;"+
		"Адрес доставки!ToExpediteAddress;"+
		"Дата ТТН / Дата сдачи груза!DocDate;"+
		"Пин-код ТТН!PinCode;"+
		"Состояние груза!NoteGoods;"+
		"Дата выдачи!DateGiveToClient;"+
		"ПО!FromStation->Aka;"+
		"ПП!CrossStation->Aka;"+
		"ПН!ToStation->Aka;"+
		"Номер ТС!TsAka:(select nvl(TripStation->Trip->Ts->Aka,'')||nvl(TripStation->Trip->WaybillNumber,'') from dtk.WaybillSection where Waybill=dtk.Waybill.ID and TripStation is not null);"+
		"Дата выхода ТС!TsDate:(select TripStation->Trip->StartDate from dtk.WaybillSection where Waybill=dtk.Waybill.ID and TripStation is not null);"+
		"Статус рейса!TripStatus2:TripStatus;"+
		"Количество мест!GoodsQty!1;"+
		"Вес!GoodsWeight!1;"+
		"Объем!GoodsVolume!1;"+
		"Температурный режим!GoodsTemperature;"+
		"Негабаритный груз!IsGoodsOversized;"+
		"Номер счета!AccountNum;"+
		"Дата счета!AccountDate;"+
		"Наличие оплаты!IsPayed;"+
		"Общая стоимость!StoimTotal!1;"+
		"�?нформацию принял!InfoTakkenBy;"+
		"Ожидаемая дата прибытия!FinishEstimatedDate;"+
		"Цена за единицу!PriceAtOne;";
	listBox1 = zenPage.getComponentById("listBox1");
	var len2 = Length(mainlistbox, ";");
	var i=1;
	while (i<=len2) {
			colString2=Piece(mainlistbox,";",i);
			if ((listBox2arr.indexOf(colString2) != -1)||(colString2==""))
			{
				
			}
			else
			{
				listBox1.appendOption(Piece(colString2,"!",2), Piece(colString2,"!",1));
			}
			i=i+1;
		}
}

}

