Class zui.admin.UserSys Extends p6.zen.EditPage
{

Parameter PAGENAME = "Пользователь системы";

// Property isEditable As %String;

/// Можно ли редактировать
XData editPane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane  xmlns="http://www.intersystems.com/zen" xmlns:p6="http://www.dimas.ru/p6" id="editPane"  width="100%">
<p6:dataController id="source"
 modelClass="admin.UserSys" modelId="#(%page.objectId)#"  />
<form  id="myForm" layout="vertical" controllerId="source" labelPosition="left" width="100%">
<p6:hgroup id = "mainAttributes" cellVAlign="top">
<p6:vgroup>
<fieldSet legend = "Учетные данные" >
<p6:hgroup>
<p6:text dataBinding="LastName" slice="2" />
<p6:text dataBinding="Login" slice="2" />
<p6:checkbox dataBinding="IsBlocked" slice="2" />
</p6:hgroup>

<p6:hgroup>
<p6:text dataBinding="FirstName" slice="2" />
<p6:checkbox dataBinding="IsChangePassword" slice="2"
	title = "Будет установлен одноразовый пароль: user1234567890&#13;Сразу после входа система потребует задать другой пароль." />
<p6:checkbox dataBinding="IsAdmin" slice="2" />
</p6:hgroup>

<p6:hgroup>
<p6:text dataBinding="MiddleName" slice="2" />
<p6:text dataBinding="UserIpAddress" slice="2" label="IP адрес" title="IP адрес, с которого разрешена работа пользователя" />
<p6:checkbox dataBinding="IsManager" slice="2" />
</p6:hgroup>
</fieldSet>

<fieldSet legend="Сведения о сотруднике" >
<p6:hgroup>
<p6:calendar dataBinding="BeginDate" size="10" />
<p6:calendar dataBinding="EndDate" size="10" />
<p6:text dataBinding="Phone" size="20" />
</p6:hgroup>

<p6:hgroup>
<spacer/>
<spacer/>
<p6:text dataBinding="MobilePhone" size="20" />
</p6:hgroup>

<p6:hgroup>
<p6:text dataBinding="Post" size="40" />
<spacer/>
<p6:text dataBinding="MailAddress" size="20" />
</p6:hgroup>
</fieldSet>
</p6:vgroup>

<fieldSet legend="Права доступа" id="accessRights"  labelPosition="left" >
<p6:checkbox dataBinding="IsCanEditUser" />
<p6:checkbox dataBinding="IsCanChangeWaybillFilial" />
<p6:checkbox dataBinding="IsCanCancelWaybillPayment" />
<spacer height="6"/>
<p6:checkbox dataBinding="IsCanEditWaybillAfterPrint" />
<p6:checkbox dataBinding="IsCanMakeIndPrices" />
<p6:checkbox dataBinding="IsCanPrintWaybill" />
<spacer height="6"/>
<p6:checkbox dataBinding="IsCanWaybillRegisterToExcel" />
<p6:checkbox dataBinding="IsCanEditCarriage"  />
<spacer height="6"/>
<p6:checkbox dataBinding="IsCanBlockTrip" />
<p6:checkbox dataBinding="IsCanPartBlockTrip"  />
<spacer height="6"/>
<p6:checkbox dataBinding="IsRegWaybillPayByAllManager"  />
<p6:checkbox dataBinding="IsRegWaybillPayByCurManager"  />
<p6:checkbox dataBinding="NoOnlyCashByFilial"  />
</fieldSet>

<fieldSet legend="Настройки" labelPosition="left" >
<p6:checkbox dataBinding="IsFullMenu" />
<p6:checkbox dataBinding="IsSalesDivision" />
<p6:checkbox dataBinding="IsFinDivision" />
<p6:checkbox dataBinding="IsLogisticsDivision" />
<spacer height="6"/>
<p6:combobox dataBinding="ShowTripsAtMainPage" size="30" />
<p6:checkbox dataBinding="DirectorPanel" />
<p6:combobox dataBinding="ReportMode" size="30" />
<p6:textRefBook dataBinding="DefaultPayPlace" size="30" value="5"/>
<p6:textRefBook dataBinding="MotivationSystem" size="30" title="Если значение не заполнено,&#13;то применяется основная система мотивации" />
<p6:textRefBook dataBinding="Filial" size="30" disabled="true"/>
</fieldSet>
</p6:hgroup>

<p6:buttonsEdit/>


</form>
</pane>
}

XData refBook [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<composite xmlns:p6="http://www.dimas.ru/p6" xmlns="http://www.intersystems.com/zen">
<p6:refBook id="refBook">
<p6:tablePane id="table" orderByClause="Aka">
<p6:column field="Aka" />
<p6:column field="Post" />
<p6:column field="Phone"/>
<p6:column field="MobilePhone"/>
<p6:column field="MailAddress"/>
<p6:column field="EndDate" header="Уволен"/>
<p6:column field="IsBlocked" />
<p6:column field="Login" />
</p6:tablePane>
</p6:refBook>
</composite>
}

Method %OnAfterCreatePage() As %Status
{
	if (%session.Data("UserSys",$username,"IsAdmin") 
		|| (%session.Data("UserSys",$username,"IsCanEditUser"))) { set ..isEditable=1 }
	else { set ..isEditable=0 }
	Do ##super()
	quit $$$OK
}

ClientMethod onloadHandler() [ Language = javascript ]
{

	if (zenPage.isEditable==false) { 
		zenPage.getComponentById("myForm").setProperty('disabled',true);
	}
	if (zenPage.isEditable==true) { return SetFocusOnFirstControl(); }
}

ClientMethod onPopupAction(popupName = "", action = "", value = "") [ Language = javascript ]
{
	zenPage.getComponentById("source").update();
}

}

