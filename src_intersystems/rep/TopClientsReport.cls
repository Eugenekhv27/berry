/// Данные для приборной панели
Class rep.TopClientsReport Extends %RegisteredObject
{

/// Запрос: {"reportName":"top-clients-report","beginDate":"05.12.2017","endDate":"31.12.2017"}
ClassMethod GetData(CriteriaReport, Output result) As %Status
{
	kill ^a.rep
	kill array
	
	set beginDate =  ##class(p6.Date).DisplayToLogical(CriteriaReport.beginDate)
	set endDate =  ##class(p6.Date).DisplayToLogical(CriteriaReport.endDate)
	kill array
	
	&sql(declare rep cursor for
			select top 10 (Buyer->Name ||' ' ||Buyer->Aka) as name, sum(RubSum) as groupSubSum
			into :qName,:qRubSum
			from doc.BonusOperation 
		 	where DocDate>=:beginDate and DocDate<=:endDate
			group by Buyer->Aka
			order by groupSubSum desc
		)
	&sql(open rep)	
	&sql(fetch rep)	
	
	set result = {}
	set result.children = []
	set i=1
	while (SQLCODE=0) {
		set line = {}
		set line.no = i
		set line.name = qName
		set line.sum = qRubSum
		do result.children.%Push(line)
		set i=i+1
		&sql(fetch rep)	
	}
	&sql(close rep)	
	//merge ^a.rep = array
	
	quit $$$OK
}

}

