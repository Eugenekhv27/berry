/// Настройки приложения
Class admin.AppSet Extends p6.Integrity [ ClassType = persistent ]
{

/// Наименование организации
Property OrgName As %String(MAXLEN = 100);

/// Адрес организации
Property OrgAdress As %String(MAXLEN = 100);

/// Руководитель компании :ФИО 
Property Chef As %String(MAXLEN = 30);

/// Руководитель компании :Должность 
Property ChefPost As %String(MAXLEN = 30);

/// Плотность груза для отчетов
Property Density As p6.dt.Boolean;

/// Сохранять информацию о каждой посещенной странице
Property IsSaveVisitPage As p6.dt.Boolean;

/// Ставка страховки груза,%
Property InsuranceRate As %String;

/// Ставка страховки груза УРАЛСИБ,%
Property InsuranceRateUralsib As %String;

/// Ставка страховки груза ИНГВАР,%
Property InsuranceRateIngvar As %String;

/// Франшиза (безусловная),руб.
Property Franchise As %String;

/// Ссылка на HelpDesk
Property HelpDeskUrl As %String(MAXLEN = 200);

/// Шапка в ТТН (строка 1)
Property Header1 As %String(MAXLEN = 1000);

/// Шапка в ТТН (строка2)
Property Header2 As %String(MAXLEN = 1000);

/// Плотность для авиа
Property AviaDensity As %Integer;

/// Плотность для авто
Property AutoDensity As %Integer;

/// Плотность для ЖД
Property TransDensity As %Integer;

/// Плотность для конт
Property ContDensity As %Integer;

/// логин на www.smsc.ru для отправки SMS
Property SmscLogin As %String;

/// пароль на www.smsc.ru
Property SmscPassword As %String;

/// Печатать счета и акты из программы
Property PrintAccounts As p6.dt.Boolean [ InitialExpression = 0 ];

/// Email для приема заявок от калькулятора
Property CalcEmail As %String(MAXLEN = 200);

/// Файл стилей для калькулятора
Property CssLink As %String(MAXLEN = 200);

ClassMethod GetCurrent() As admin.AppSet
{
        &sql(select Id into :qId from admin.AppSet)
        if 'SQLCODE set Obj=..%OpenId($get(qId))
        else  set Obj=..%New()
        quit Obj
}

Storage Default
{
<Data name="AppSetDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Org</Value>
</Value>
<Value name="3">
<Value>Port</Value>
</Value>
<Value name="4">
<Value>RailwayStation</Value>
</Value>
<Value name="5">
<Value>ChiefEnginerFio</Value>
</Value>
<Value name="6">
<Value>ChiefEnginerPost</Value>
</Value>
<Value name="7">
<Value>ChiefFio</Value>
</Value>
<Value name="8">
<Value>ChiefMechanicFio</Value>
</Value>
<Value name="9">
<Value>ChiefMechanicPost</Value>
</Value>
<Value name="10">
<Value>ChiefPost</Value>
</Value>
<Value name="11">
<Value>ConditionerTimeEual</Value>
</Value>
<Value name="12">
<Value>StoppingTimeEual</Value>
</Value>
<Value name="13">
<Value>OrgAdress</Value>
</Value>
<Value name="14">
<Value>OrgName</Value>
</Value>
<Value name="15">
<Value>Chief</Value>
</Value>
<Value name="16">
<Value>ChiefEnginer</Value>
</Value>
<Value name="17">
<Value>ChiefMechanic</Value>
</Value>
<Value name="18">
<Value>AddCity</Value>
</Value>
<Value name="19">
<Value>Chef</Value>
</Value>
<Value name="20">
<Value>ChefPost</Value>
</Value>
<Value name="21">
<Value>Filial</Value>
</Value>
<Value name="22">
<Value>Density</Value>
</Value>
<Value name="23">
<Value>PercentAccompany</Value>
</Value>
<Value name="24">
<Value>PercentAttract</Value>
</Value>
<Value name="25">
<Value>PercentMaintenance</Value>
</Value>
<Value name="26">
<Value>WaybillScanDir</Value>
</Value>
<Value name="27">
<Value>DemandScanDir</Value>
</Value>
<Value name="28">
<Value>WaybillClaimScanDir</Value>
</Value>
<Value name="29">
<Value>DayAttract</Value>
</Value>
<Value name="30">
<Value>SaveVisitPage</Value>
</Value>
<Value name="31">
<Value>IsSaveVisitPage</Value>
</Value>
<Value name="32">
<Value>TripActScanDir</Value>
</Value>
<Value name="33">
<Value>InsuranceRate</Value>
</Value>
<Value name="34">
<Value>Franchise</Value>
</Value>
<Value name="35">
<Value>InsuranceRateUralsib</Value>
</Value>
<Value name="36">
<Value>InsuranceRateIngvar</Value>
</Value>
<Value name="37">
<Value>HelpDeskUrl</Value>
</Value>
<Value name="38">
<Value>Header1</Value>
</Value>
<Value name="39">
<Value>Header2</Value>
</Value>
<Value name="40">
<Value>AviaDensity</Value>
</Value>
<Value name="41">
<Value>AutoDensity</Value>
</Value>
<Value name="42">
<Value>TransDensity</Value>
</Value>
<Value name="43">
<Value>ContDensity</Value>
</Value>
<Value name="44">
<Value>SmscLogin</Value>
</Value>
<Value name="45">
<Value>SmscPassword</Value>
</Value>
<Value name="46">
<Value>PrintAccounts</Value>
</Value>
<Value name="47">
<Value>CalcEmail</Value>
</Value>
<Value name="48">
<Value>CssLink</Value>
</Value>
</Data>
<DataLocation>^admin.AppSetD</DataLocation>
<DefaultData>AppSetDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^admin.AppSetD</IdLocation>
<IndexLocation>^admin.AppSetI</IndexLocation>
<Property name="Chef"/>
<Property name="ChefPost"/>
<Property name="DemandScanDir"/>
<Property name="Density"/>
<Property name="IsSaveVisitPage"/>
<Property name="OrgAdress"/>
<Property name="OrgName"/>
<Property name="WaybillClaimScanDir"/>
<StreamLocation>^admin.AppSetS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

