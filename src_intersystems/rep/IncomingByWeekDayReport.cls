/// График выручка по дням неделям
Class rep.IncomingByWeekDayReport Extends %RegisteredObject
{

/// Запрос: {"reportName":"incoming-by-week-day-report","beginDate":"05.12.2017","endDate":"31.12.2017"}
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
			set weekDate = $zdate(qDocDate,10)
					
			if (qBuyerRegDate=qDocDate) {
				set array(weekDate,"first")=+$get(array(weekDate,"first")) + qRubSum
			} else {
				set array(weekDate,"another")=+$get(array(weekDate,"another")) + qRubSum	
			}
		}
		&sql(fetch rep)	
	}
	&sql(close rep)	
	
	set result = {}
	set result.labels = []
	set firstData = []
	set anotherData = []
	//set weekDate1 = $zdate(beginDate,10)
	for i=1:1:6,0 {
		set weekDateName = $select(i=0:"ВС",
			i=1:"ПН",
			i=2:"ВТ",
			i=3:"СР",
			i=4:"ЧТ",
			i=5:"ПТ",
			i=6:"СБ")
		do result.labels.%Push(weekDateName)
		do firstData.%Push(+$get(array(i,"first")))
		do anotherData.%Push(+$get(array(i,"another")))
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

