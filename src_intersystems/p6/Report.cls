/// Класс, задающий параметры отчетов. 
/// По каждому пользователю хранятся выбранные ранее значения
/// и потом подсказываются при инициализации объекта
Class p6.Report Extends %RegisteredObject [ ClassType = "", ProcedureBlock ]
{

/// Перечислить поля для сохранения через ~1~2~3~4~. 
Parameter SAVEPROPERTY;

Method %OnNew(param) As %Status
{
	set userSysId=%session.Data("UserSys",$username,"UserSysId")
	set saveProperty=..#SAVEPROPERTY
	set ClassDef=##class(%Dictionary.CompiledClass).%OpenId($this.%ClassName(1))
	for i=1:1:ClassDef.Properties.Count() {
		set Prop=ClassDef.Properties.GetAt(i)
		if Prop.MultiDimensional continue
		if (saveProperty]"")&&(saveProperty'[("~"_Prop.Name_"~")) continue
		set val=##class(admin.Memory).Get($this.%ClassName(1)_"||"_Prop.Name,userSysId)
		if val]"" { 
			set Type=##class(%Dictionary.CompiledClass).%OpenId(Prop.Type)
			if Type.ClassType="datatype" {
				set $zobjproperty($this,Prop.Name)=val
			} elseif Type.ClassType="persistent" {
				set $zobjproperty($this,Prop.Name)=$zobjclassmethod(Type.Name,"%OpenId",val)
			}
		} 
	}
	quit $$$OK
}

Method %OnClose(param) As %Status
{
	set userSysId=%session.Data("UserSys",$username,"UserSysId")
	set ClassDef=##class(%Dictionary.CompiledClass).%OpenId($this.%ClassName(1))
	for i=1:1:ClassDef.Properties.Count() {
		set Prop=ClassDef.Properties.GetAt(i)
		if Prop.MultiDimensional continue
		set Type=##class(%Dictionary.CompiledClass).%OpenId(Prop.Type)
		if Type.ClassType="datatype" {
			set val=$zobjproperty($this,Prop.Name)
			do ##class(admin.Memory).Put(val,$this.%ClassName(1)_"||"_Prop.Name,userSysId)
		} elseif Type.ClassType="persistent" {
			set PropVal=$zobjproperty($this,Prop.Name)
			if PropVal]"" set val=$zobjmethod(PropVal,"%Id")
			else  set val=""
			do ##class(admin.Memory).Put(val,$this.%ClassName(1)_"||"_Prop.Name,userSysId)

		}
	}
	quit $$$OK
}

/// Преобразование строки в формате $horolog в строку DD.MM.YY HH:MM
///   (обычно для печати отчета)
ClassMethod GetHorolog(aHorolog As %String = {$horolog}) As %String
{
 if (aHorolog="") { quit "" } //#
 set date=##class(p6.dt.Date).LogicalToDisplay($piece(aHorolog,",",1))
 set time=##class(p6.dt.Time).LogicalToDisplay($piece(aHorolog,",",2))
 quit (date_" "_time)
}

/// Расшифровка периода в строку для отчета
ClassMethod GetPeriod(aDateBegin As p6.dt.Date = "", aDateEnd As p6.dt.Date = "") As %String
{
	if ((aDateBegin="") && (aDateEnd="")) { quit "Период не задан" } //#
	set str = "Период "
	if (aDateBegin]"") { set str =str_"с "_##class(p6.dt.Date).LogicalToDisplay(aDateBegin)
		if (aDateEnd="") { quit str } //#
		set str = str_" по "_##class(p6.dt.Date).LogicalToDisplay(aDateEnd) quit str //#
	}
	set str =str_"по "_##class(p6.dt.Date).LogicalToDisplay(aDateEnd)
	quit str
}

ClassMethod GetPeriod2(aDateBegin As p6.dt.Date = "", aDateEnd As p6.dt.Date = "") As %String
{
	if ((aDateBegin="") && (aDateEnd="")) { quit "Период не задан" } //#
	set str = ""
	if (aDateBegin]"") { set str =str_"с "_##class(p6.dt.Date).LogicalToDisplay(aDateBegin)
		if (aDateEnd="") { quit str } //#
		set str = str_" по "_##class(p6.dt.Date).LogicalToDisplay(aDateEnd) quit str //#
	}
	set str =str_"по "_##class(p6.dt.Date).LogicalToDisplay(aDateEnd)
	quit str
}

/// Период + время печати в одну строку для отчета
ClassMethod GetPeriodAndHorolog(aDateBegin As p6.dt.Date = "", aDateEnd As p6.dt.Date = "") As %String
{
	set str = ..GetPeriod(aDateBegin,aDateEnd)_"."
	set str = str_"   Напечатано "_..GetHorolog()_"."
	quit str
}

}

