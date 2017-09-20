/// Show object log
Class zui.admin.LogObject Extends %ZEN.Component.page
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "zui.Application";

/// Domain used for localization.
Parameter DOMAIN = "P6";

Property className As %ZEN.Datatype.string(ZENURL = "ClassName");

Property objectId As %ZEN.Datatype.string(ZENURL = "Id");

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
	table.tpTable tr.tpSelected { background: #3d80df; color: white; }
</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" xmlns:p6="http://www.dimas.ru/p6" >
<html align="center"><b>Сводка изменений для #(%page.className)# Id=#(%page.objectId)#</b></html>
<p6:tablePane id="table"
	showRowSelector="false"
	width="100%" nowrap="false"
	height="100"
	useSnapshot="true"
	maxRows="0"
	valueColumn="ID"
	showQuery="false"
	showZebra="true"
	showFilters="true"
	useKeys="true"
	headerLayout="headersOnTop"
	dataSource="query"
	tableName="admin.LogObject"
	whereClause="Class='#(%page.className)#' and ObjectId='#(%page.objectId)#'"
>
<p6:column header="Дата, время(по филиалу пользователя)" colName="DtLog" OnDrawCell="ShowTimeWithOffset"  />
<p6:column header="Пользователь" colName="UserSysAka" colExpression="UserSys->Aka"  />

<p6:column header="Метод" colName="Method" />
<p6:column header="Изменения" colName="Changes" />

</p6:tablePane>
</page>
}

Method ShowTimeWithOffset(Table, name, seed, row) As %Status
{
	&html<#(..GetTimeWithOffset(%query("DtLog")))#>
	quit $$$OK
}

ClassMethod GetTimeWithOffset(dtLog As %String) As %String
{
	set date=$p(dtLog," ",1)
	set time=$p(dtLog," ",2)
	
	set dateH=##class(p6.dt.Date).DisplayToLogical(date)
	set timeH=##class(p6.dt.Time).DisplayToLogical(time)
	/*set TimeDiff = ##class(ent.TimeZone).MSKTimeGetStored(##class(ent.Filial).TimeZoneGetStored(%session.Data("UserSys",$username,"FilialId")))
	if TimeDiff = "" set TimeDiff = 0
	set timeH=timeH+(TimeDiff*3600)
	if (timeH>=86400) {
		set timeH=timeH-86400
		set dateH=dateH+1
	}elseif (timeH<0) {
		set timeH=timeH+86400
		set dateH=dateH-1		
	}*/
	Set LocalDateTime = ##class(p6.Horolog).LogicalToTimeStamp(dateH_","_timeH)
	/*if TimeDiff = 0
	{*/
		Set result = LocalDateTime _ " (MSK)"
	/*}
	else
	{
		Set result = LocalDateTime _ " (MSK +" _ TimeDiff _ ")"
	}*/
	quit result
}

ClassMethod GetLastEditStamp(classname, aId) As %String
{
	set user = ""
	set dtLog = ""
	
	&sql(select UserSys->Aka, DtLog
			into :user, :dtLog
			from admin.LogObject 
			where Class=:classname 
			and ObjectId=:aId 
			order by Id desc)
	
	if (dtLog'="") {
		quit user_" [ "_..GetTimeWithOffset( dtLog )_" ]"
	}
	
	quit ""
}

}

