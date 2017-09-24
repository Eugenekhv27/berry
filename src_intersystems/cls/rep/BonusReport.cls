/// Сводный отчет по бонусам
Class rep.BonusReport Extends p6.Persistent [ ClassType = persistent, LegacyInstanceContext ]
{

Parameter LOGDETALISATION = 0;

/*///Ввод\\\*/
/// Дата с
Property BeginDate As p6.dt.Date [ InitialExpression = {+$H}, Transient ];

/// по
Property EndDate As p6.dt.Date [ InitialExpression = {+$H}, Transient ];

/// В разрезе по организации
Property Shop As ent.Shop;

/*///Вывод\\\*/
Property RepDate As p6.dt.Date;

/// Сальдо на начало
Property StartBonus As p6.dt.Money;

/// Начисленно
Property PlusBonus As p6.dt.Money;

/// Оплачено бонусами
Property MinusBonus As p6.dt.Money;

/// Сальдо на конец
Property EndBonus As p6.dt.Money;

Method Report() As %Status
{
	
	$$$QuitOnError(..%KillExtent())
	
	set beginDate = ..BeginDate
	set endDate = ..EndDate
	if ..Shop]"" {
		set shopId=..Shop.%Id()
	} else {
		set shopId=1
	}
	set qStartBonus = 0
	
	&sql(select sum(PointsSum) into :qStartBonus from doc.BonusOperation
		where DocDate<:beginDate and Buyer->Shop=:shopId)
		
		
	&sql(declare line cursor for
		select sum(PointsSum),sum(PlusPointsSum),sum(MinusPointsSum),DocDate 
		into :qBonus,:qPlusBonus,:qMinusBonus,:qDocDate from doc.BonusOperation
		where (DocDate>=:beginDate) and (DocDate<=:endDate) and Buyer->Shop=:shopId
		group by DocDate
		order by DocDate)	
	&sql(open line)	
	&sql(fetch line)
	set curBonus = 0
	while SQLCODE=0 {
		set startBonus = qStartBonus + curBonus
		set curBonus = curBonus + qBonus
		
		
		&sql(insert into rep.BonusReport 
			set RepDate=:qDocDate,StartBonus= :startBonus,EndBonus=(:curBonus+:startBonus),
			PlusBonus=:qPlusBonus,MinusBonus=:qMinusBonus)
	
		&sql(fetch line)	
	}
	&sql(close line)
	
		
	
	quit $$$OK
}

ClassMethod JsonReport(accountId, beginDate, endDate) As %Status
{
	set Rep = ..%New()
	set Rep.BeginDate = beginDate
	set Rep.EndDate = endDate
	set Rep.Shop = ##class(ent.Shop).%OpenId(accountId)
	$$$QuitOnError(Rep.Report())
	
	write "["
	set sql="select RepDate,StartBonus,EndBonus,PlusBonus,MinusBonus from rep.BonusReport"
	do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,sql,,1000)
	write ","
	set provider = ##class(%ZEN.Auxiliary.jsonSQLProvider).%New()
	set provider.arrayName="totals"
	set provider.sql="select sum(PlusBonus) as PlusBonus,sum(MinusBonus) as MinusBonus from rep.BonusReport"
	set provider.maxRows = 1000
	do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,,,,,provider)
	write "]"
	
	quit $$$OK
}

ClassMethod JsonReportDetails(accountId, onDate) As %Status
{
	if accountId="" quit $$$ERROR(10000,"Не указан индентификатор")
	
	write "["
	set sql="select Buyer->Aka, PlusPointsSum,MinusPointsSum from doc.BonusOperation where Buyer->Shop="
		_accountId_" and DocDate='"_onDate_"'"
	do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,sql,,1000)
	write ","
	set provider = ##class(%ZEN.Auxiliary.jsonSQLProvider).%New()
	set provider.arrayName="totals"
	set provider.sql="select sum(PlusPointsSum) as PlusPointsSum,sum(MinusPointsSum) as MinusPointsSum from doc.BonusOperation where Buyer->Shop="
		_accountId_" and DocDate='"_onDate_"'"
	set provider.maxRows = 1000
	do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,,,,,provider)
	write "]"
	
	quit $$$OK
}

Storage Default
{
<Data name="BonusReportDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RepDate</Value>
</Value>
<Value name="3">
<Value>StartBonus</Value>
</Value>
<Value name="4">
<Value>PlusBonus</Value>
</Value>
<Value name="5">
<Value>MinusBonus</Value>
</Value>
<Value name="6">
<Value>EndBonus</Value>
</Value>
<Value name="7">
<Value>Shop</Value>
</Value>
</Data>
<DataLocation>^||rep.BonusReportD</DataLocation>
<DefaultData>BonusReportDefaultData</DefaultData>
<IdLocation>^||rep.BonusReportD</IdLocation>
<IndexLocation>^||rep.BonusReportI</IndexLocation>
<StreamLocation>^||rep.BonusReportS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

