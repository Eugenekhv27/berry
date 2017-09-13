/// Сводный отчет по бонусам
Class rep.BonusReport Extends p6.Persistent [ ClassType = persistent, LegacyInstanceContext ]
{

Parameter LOGDETALISATION = 0;

/*///Ввод\\\*/
/// Дата с
Property BeginDate As p6.dt.Date [ InitialExpression = {+$H}, Transient ];

/// по
Property EndDate As p6.dt.Date [ InitialExpression = {+$H}, Transient ];

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
	set qStartBonus = 0
	
	&sql(select sum(PointsSum) into :qStartBonus from doc.BonusOperation
		where DocDate<:beginDate)
		
		
	&sql(declare line cursor for
		select sum(PointsSum),sum(PlusPointsSum),sum(MinusPointsSum),DocDate 
		into :qBonus,:qPlusBonus,:qMinusBonus,:qDocDate from doc.BonusOperation
		where (DocDate>=:beginDate) and (DocDate<=:endDate)
		group by DocDate
		order by DocDate)	
	&sql(open line)	
	&sql(fetch line)
	set curBonus = 0
	while SQLCODE=0 {
		set startBonus = qStartBonus + curBonus
		set curBonus = curBonus + qBonus
		
		
		&sql(insert into rep.BonusReport 
			set RepDate=:qDocDate,StartBonus= :startBonus,EndBonus=(:curBonus+:qStartBonus),
			PlusBonus=:qPlusBonus,MinusBonus=:qMinusBonus)
	
		&sql(fetch line)	
	}
	&sql(close line)
	
		
	
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
</Data>
<DataLocation>^rep.BonusReportD</DataLocation>
<DefaultData>BonusReportDefaultData</DefaultData>
<IdLocation>^rep.BonusReportD</IdLocation>
<IndexLocation>^rep.BonusReportI</IndexLocation>
<StreamLocation>^rep.BonusReportS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

