/// График выручка по месяцам
Class rep.IncomingByMonthReport Extends %RegisteredObject
{

/// Запрос: {"reportName":"incoming-by-month-report","beginDate":"05.12.2017","endDate":"31.12.2017"}
ClassMethod GetData(CriteriaReport, Output result) As %Status
{
	//kill ^a.rep
	kill array
	
	set beginDate =  ##class(p6.Date).DisplayToLogical(CriteriaReport.beginDate)
	set endDate =  ##class(p6.Date).DisplayToLogical(CriteriaReport.endDate)
	kill array
	set balanceTotal = 0, plusPointsTotal = 0, minusPointsTotal = 0
	&sql(declare rep cursor for
		select Id,DocDate, Buyer, Buyer->RegDate, RubSum
		into :qOpId,:qDocDate,:qBuyerId,:qBuyerRegDate, :qRubSum
		from doc.BonusOperation where DocDate>=:beginDate and DocDate<=:endDate)
	&sql(open rep)	
	&sql(fetch rep)	

	while (SQLCODE=0) {
		if qDocDate]"" {
			//set monthDate = $P($zdate(qDocDate,3),"-",1,2)
			set monthDate = $zd(qDocDate,2,",янв,фев,мар,апр,май,июн,июл,авг,сен,окт,ноя,дек",2)
			set monthDate = $tr($p(monthDate,",",2,3),",","`")
					
			if (qBuyerRegDate=qDocDate) {
				set array(monthDate,"first")=+$get(array(monthDate,"first")) + qRubSum
			} else {
				set array(monthDate,"another")=+$get(array(monthDate,"another")) + qRubSum
			}
		}
		&sql(fetch rep)	
	}
	&sql(close rep)	
	
	set result = {}
	set result.labels = []
	set firstData = []
	set anotherData = []
	
	set aa= $o(array(""))
	while aa]"" {
	
		do result.labels.%Push(aa)
		do firstData.%Push(+$get(array(aa,"first")))
		do anotherData.%Push(+$get(array(aa,"another")))
		set aa= $o(array(aa))
	}
	set firstDataSet = {}
	set firstDataSet.label = "Новые клиенты"
	set firstDataSet.backgroundColor = "#42A5F5"
	set firstDataSet.borderColor = "#1E88E5"
	set firstDataSet.data = firstData
	
	set anotherDataSet = {}
	set anotherDataSet.label = "Остальные клиенты"
	set anotherDataSet.backgroundColor = "#9CCC65"
	set anotherDataSet.borderColor = "#7CB342"
	set anotherDataSet.data = anotherData
	
	set datasets = []
	do datasets.%Push(firstDataSet)
	do datasets.%Push(anotherDataSet)
	set result.datasets = datasets
	
	//merge ^a.rep = array
	
	quit $$$OK
}

}

