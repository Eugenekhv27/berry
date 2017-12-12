/// Пользователи системы
Class admin.UserSys Extends p6.Integrity [ ClassType = persistent, ProcedureBlock ]
{

Parameter PAGENAME = "Пользователь системы";

Parameter SecureType = 2;

Index UniqueLoginIndex On Login [ Unique ];

/// ФИО
Property Aka As %String [ Calculated, SqlComputeCode = { set {Aka}=##class(admin.UserSys).GetAka({Id}) }, SqlComputed ];

/// Фамилия
Property LastName As %String(MAXLEN = 15) [ Required ];

/// Имя
Property FirstName As %String(MAXLEN = 15);

/// Отчество
Property MiddleName As %String(MAXLEN = 15);

/// Дата приема
Property BeginDate As p6.dt.Date [ Required ];

/// Дата увольнения
Property EndDate As p6.dt.Date;

/// Телефон
Property Phone As %String(MAXLEN = 20);

/// Сотовый телефон
Property MobilePhone As %String(MAXLEN = 20) [ InitialExpression = "+7" ];

/// Эл.почта
Property MailAddress As %String(MAXLEN = 30);

/// Логин
Property Login As %String(TRUNCATE = 1) [ Required ];

/// Пароль
Property Password As %String(TRUNCATE = 1);

/// Должность
Property Post As %String(TRUNCATE = 1);

/// Новый пароль
Property NewPassword As %String(TRUNCATE = 1) [ Transient ];

/// Админ
Property IsAdmin As p6.dt.Boolean [ InitialExpression = {$$$NO} ];

/// Заблокирован
Property IsBlocked As p6.dt.Boolean [ InitialExpression = {$$$NO} ];

/// Менеджер
Property IsManager As p6.dt.Boolean [ InitialExpression = {$$$NO} ];

/// Разрешено редактировать профили пользователей
Property IsCanEditUser As p6.dt.Boolean [ InitialExpression = {$$$NO} ];

/// Разрешено блокировать рейсы
Property IsCanBlockTrip As p6.dt.Boolean [ InitialExpression = {$$$NO} ];

/// Разрешено частично блокировать рейсы (кроме внесения затрат)
Property IsCanPartBlockTrip As p6.dt.Boolean [ InitialExpression = {$$$NO} ];

/// Разрешено перераспределять стоимость по автоперевозкам
Property IsCanDistributionAutoCost As p6.dt.Boolean [ InitialExpression = {$$$NO} ];

/// Разрешено отменять оплату по ТТН
Property IsCanCancelWaybillPayment As p6.dt.Boolean [ InitialExpression = {$$$NO} ];

/// Разрешено печатать ТТН
Property IsCanPrintWaybill As p6.dt.Boolean [ InitialExpression = {$$$NO} ];

/// Разрешено экспортировать в Excel реестр ТТН
Property IsCanWaybillRegisterToExcel As p6.dt.Boolean [ InitialExpression = {$$$NO} ];

/// Формат отчетов
Property ReportMode As %String(DISPLAYLIST = ",MS Office,Open Office", VALUELIST = ",1,2") [ InitialExpression = 1 ];

/// IP адрес пользователя
Property UserIpAddress As %String(MAXLEN = 200);

/// Доска с рейсами на стартовой странице
Property ShowTripsAtMainPage As %String(DISPLAYLIST = ",Не показывать доску,Показывать по своему филиалу,Показывать по всей компании", VALUELIST = ",1,2,3") [ InitialExpression = 2 ];

/// Разрешено создавать индивидуальные прайсы
Property IsCanMakeIndPrices As p6.dt.Boolean;

/// Разрешено редактировать контакты всех организаций
Property IsCanWatchOrgContacts As p6.dt.Boolean;

/// Зарезервировать лицензию
Property IsReservedLicense As p6.dt.Boolean;

/// Разрешено редактировать ТТН, заблокированные после печати
Property IsCanEditWaybillAfterPrint As p6.dt.Boolean;

/// Разрешено редактировать справочник вагонов
Property IsCanEditCarriage As p6.dt.Boolean;

/// Печатать ТТН в Word
Property IsPrintTtnWord As p6.dt.Boolean;

/// Сбросить пароль
Property IsChangePassword As p6.dt.Boolean [ Transient ];

/// Показывать "директорскую панель"
Property DirectorPanel As p6.dt.Boolean;

/// Меню для отдела продаж
Property IsSalesDivision As p6.dt.Boolean;

/// Меню для финансовой группы
Property IsFinDivision As p6.dt.Boolean;

/// Меню для отдела логистики
Property IsLogisticsDivision As p6.dt.Boolean;

/// Полное меню
Property IsFullMenu As p6.dt.Boolean;

Method %OnNew() As %Status
{
	set ..IsChangePassword=1
	quit $$$OK
}

Method OnAfterSave() As %Status
{
	/// после сохранения обновляем %session пользователя ()
	// подходит для случая, если пользователь редактирует сам себя
	$$$QuitOnError(##class(admin.SessionEvents).OnStartSession())
	
	quit $$$OK
}

Method OnBeforeSave() As %Status [ Private ]
{
	
 if $SYSTEM.SQL.UserExists($NameSpace_"_"_..Login)=0 {	
 	set ns=$NameSpace
 	job ##class(Security.Users).Create($NameSpace_"_"_..Login, "%All", "user1234567890", ..Aka, ns, "", "", $$$YES, '..IsBlocked, ""):("%SYS")

 } 
 elseif (..IsChangePassword)
 {
	set ns=$NameSpace
	ZNSPACE "%SYS"
	set Properties("Enabled")=('..IsBlocked)
	set Properties("Password")="user1234567890"
	set Properties("ChangePassword")=1
	set n = ##class(Security.Users).Modify(ns_"_"_..Login, .Properties) 
	If $$$ISERR(n) {
		set $NameSpace=ns	 
		Quit n
	}
	else
	{
		&js<alert('Пользователю '+ '#(..Login)#' + ' установлен временный пароль \"user1234567890\"\n\rПри первом входе система предложит пользователю сменить пароль.');>
	}
	set $NameSpace=ns	
 } /*
 else {
	 
	set aEnabled=('+..IsBlocked)
	set aChangePassword=+..IsChangePassword
	set login = $NameSpace_"_"_..Login
	set ns=$NameSpace
 	ZNSPACE "%SYS"
 	set err=""
  	SET myquery="update Security.Users set Enabled="_aEnabled
 			_", ChangePassword="_aChangePassword_" where Id='"_login_"'"
 	// не обновляет пароль... надо делать через объект
 	// s User.PasswordExternal=Password<br>
    /// s Status=User.%Save()<br>		
 			
 	Set result=##class(%ResultSet).%New("%DynamicQuery:SQL")
	Set sc=result.Prepare(myquery)
	If $$$ISERR(sc) {
		set $NameSpace=ns	 
		Quit sc
	}
	Set sc=result.Execute() 
	//If $$$ISERR(sc) If $$$ISERR(sc) Quit sc
 			
 			
  	//SET rset=##class(%ResultSet.SQL).%Prepare(myquery,.err,"")	
 	//job ##class(Security.Users).Modify(..Login,Properties):("%SYS")
 	set $NameSpace=ns	 
 	if $$$ISERR(sc) quit sc 
 }*/
 quit $$$OK
}

ClassMethod GetAka(aId) As %String
{
	if aId="" quit ""
	quit ..LastNameGetStored(aId)_" "_$e(..FirstNameGetStored(aId))_". "_$select(..MiddleNameGetStored(aId)]"":$e(..MiddleNameGetStored(aId))_".",1:"")
}

ClassMethod GetDisplayValue(aId As %String) As %String
{
	if aId="" quit ""
	quit ##class(admin.UserSys).GetAka(aId)_" ["_aId_"]"
}

ClassMethod CanUserCreateObject(className As %String = "") As p6.dt.Boolean
{
   quit $$$YES
}

ClassMethod CanUserEditObject(className As %String = "") As p6.dt.Boolean
{
   quit $$$YES
}

ClassMethod CanUserDeleteObject(className As %String = "") As p6.dt.Boolean
{
   quit $$$YES
}

ClassMethod CanUserRunTask(taskId As %String = "") As p6.dt.Boolean
{
   quit $$$YES
}

/* Устарело
ClassMethod GetLoggedInUser(login, password) As admin.UserSys
{
 set userSysId = "",loginUp=" "_$zconvert(login,"U")
 &sql(select id into :userSysId from admin.UserSys where %SQLUPPER(Login)=:loginUp)

 if SQLCODE quit $$$NULLOREF
 set UserSys = ##class(admin.UserSys).%OpenId(userSysId)
 if 'UserSys.IsPasswordCorrect(password) quit $$$NULLOREF
 quit UserSys
}
*/
Method IsPasswordCorrect(password) As admin.UserSys
{
 if ..IsBlocked quit 0
 if $extract(..Password,1,4)="MD5:" {
	 set code=$extract(..Password,5,$l(..Password))
	 if code=$SYSTEM.Encryption.MD5Encode(password) quit 1
	 else  quit 0
 } else {
 	if ..Password=password quit 1
 	else  quit 0
 }
 quit 0
}

ClassMethod GetReservedLicensesNumber() As %Integer
{
	s rsvLicenses = 0
	
	s userAka=""
	
	&sql(declare curUsers cursor for
		 select Aka into :userAka
		 from dtk.admin.UserSys
		 where IsReservedLicense=1)
		 
	&sql(open curUsers)
	&sql(fetch curUsers)
	while (SQLCODE=0) {	
	
		if ('$System.License.ConnectionCount( userAka )) {
			s rsvLicenses = rsvLicenses + 1
		}
		
		&sql(fetch curUsers)
	}
	&sql(close curUsers)
	
	// add one for SOAP service
	quit rsvLicenses + 1
}

/// разрешаем сохранять объект только через метод Save()
Method %OnBeforeSave(Insert As p6.dt.Boolean) As %Status [ Private, PublicList = (NewObject, canSave) ]
{
  if ((..IsReservedLicense) && ((Insert) || ('..IsReservedLicenseGetStored(..%Id())))) {
	  s reservedCount = 0
	  &sql(select count(ID) into :reservedCount
		 from dtk.admin.UserSys
		 where IsReservedLicense=1)
		 
	  // add authorized SOAP service, an anonymous user + pillow for 'Grace'
	  s reservedCount = 3 + reservedCount
	  
	  if ( $System.License.GetUserLimit() < reservedCount) {
	  	quit $$$ERROR(10000, "Слишком много зарезирвированных пользователей")
	  }
  }
	
  set NewObject = $select(Insert:"N",1:"M") // новый или модификация
  if ('$data(canSave)) quit $$$ERROR(10000, "Нельзя сохранить объект класса "_..%ClassName(1)_" напрямую через метод %Save(). Необходимо использовать метод Save().")
  quit $$$OK
}

Storage Default
{
<Data name="UserSysDefaultData">
<Value name="1">
<Value>Aka</Value>
</Value>
<Value name="2">
<Value>Human</Value>
</Value>
<Value name="3">
<Value>Login</Value>
</Value>
<Value name="4">
<Value>Password</Value>
</Value>
<Value name="5">
<Value>IsAdmin</Value>
</Value>
<Value name="6">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="7">
<Value>StoreHouse</Value>
</Value>
<Value name="8">
<Value>CreateFinOperationFromFinDoc</Value>
</Value>
<Value name="9">
<Value>IsBlocked</Value>
</Value>
<Value name="10">
<Value>Post</Value>
</Value>
<Value name="11">
<Value>Forwarder</Value>
</Value>
<Value name="12">
<Value>Operator</Value>
</Value>
<Value name="13">
<Value>Stevedore</Value>
</Value>
<Value name="14">
<Value>IsManager</Value>
</Value>
<Value name="15">
<Value>Filial</Value>
</Value>
<Value name="16">
<Value>IsMSReports</Value>
</Value>
<Value name="17">
<Value>IsNotMSReports</Value>
</Value>
<Value name="18">
<Value>ReportMode</Value>
</Value>
<Value name="19">
<Value>BeginDate</Value>
</Value>
<Value name="20">
<Value>EndDate</Value>
</Value>
<Value name="21">
<Value>FirstName</Value>
</Value>
<Value name="22">
<Value>LastName</Value>
</Value>
<Value name="23">
<Value>MiddleName</Value>
</Value>
<Value name="24">
<Value>Phone</Value>
</Value>
<Value name="25">
<Value>MobilePhone</Value>
</Value>
<Value name="26">
<Value>AddressMail</Value>
</Value>
<Value name="27">
<Value>MailAddress</Value>
</Value>
<Value name="28">
<Value>IsCanEditUser</Value>
</Value>
<Value name="29">
<Value>IsCanBlockTrip</Value>
</Value>
<Value name="30">
<Value>IsCanDistributionAutoCost</Value>
</Value>
<Value name="31">
<Value>IsCanChangeWaybillFilial</Value>
</Value>
<Value name="32">
<Value>Filial2</Value>
</Value>
<Value name="33">
<Value>UserIpAddress</Value>
</Value>
<Value name="34">
<Value>IsUseAllFilials</Value>
</Value>
<Value name="35">
<Value>IsHideBoard</Value>
</Value>
<Value name="36">
<Value>IsCanMakeIndPrices</Value>
</Value>
<Value name="37">
<Value>IsCanCancelWaybillPayment</Value>
</Value>
<Value name="38">
<Value>IsCanPrintWaybill</Value>
</Value>
<Value name="39">
<Value>IsCanwatchOrgContacts</Value>
</Value>
<Value name="40">
<Value>IsCanWatchOrgContacts</Value>
</Value>
<Value name="41">
<Value>IsReservedLicense</Value>
</Value>
<Value name="42">
<Value>IsCanWaybillRegisterToExcel</Value>
</Value>
<Value name="43">
<Value>IsCanEditWaybillAfterPrint</Value>
</Value>
<Value name="44">
<Value>IsCanEditCarriage</Value>
</Value>
<Value name="45">
<Value>IsCanSetOrgFilial</Value>
</Value>
<Value name="46">
<Value>IsPrintTtnWord</Value>
</Value>
<Value name="47">
<Value>MotivationSystem</Value>
</Value>
<Value name="48">
<Value>IsCanPartBlockTrip</Value>
</Value>
<Value name="49">
<Value>DirectorPanel</Value>
</Value>
<Value name="50">
<Value>IsSalesDivision</Value>
</Value>
<Value name="51">
<Value>IsFinDivision</Value>
</Value>
<Value name="52">
<Value>IsLogisticsDivision</Value>
</Value>
<Value name="53">
<Value>IsFullMenu</Value>
</Value>
<Value name="54">
<Value>IsRegWaybillPayByAllManager</Value>
</Value>
<Value name="55">
<Value>IsRegWaybillPayByCurManager</Value>
</Value>
<Value name="56">
<Value>IsChangeOrg</Value>
</Value>
<Value name="57">
<Value>DefaultPayPlace</Value>
</Value>
<Value name="58">
<Value>ShowTripsAtMainPage</Value>
</Value>
<Value name="59">
<Value>NoOnlyCashByFilial</Value>
</Value>
</Data>
<DataLocation>^admin.UserSysD</DataLocation>
<DefaultData>UserSysDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^admin.UserSysD</IdLocation>
<IndexLocation>^admin.UserSysI</IndexLocation>
<Property name="Aka"/>
<Property name="BeginDate"/>
<Property name="EndDate"/>
<Property name="Filial"/>
<Property name="FirstName"/>
<Property name="IsAdmin"/>
<Property name="IsBlocked"/>
<Property name="IsCanBlockTrip"/>
<Property name="IsCanChangeWaybillFilial"/>
<Property name="IsCanDistributionAutoCost"/>
<Property name="IsCanEditUser"/>
<Property name="IsManager"/>
<Property name="LastName"/>
<Property name="Login"/>
<Property name="MailAddress"/>
<Property name="MiddleName"/>
<Property name="MobilePhone"/>
<Property name="Password"/>
<Property name="Phone"/>
<Property name="Post"/>
<Property name="ReportMode"/>
<StreamLocation>^admin.UserSysS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

