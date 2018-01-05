/// График выручка по дням неделям
Class rep.IncomingByWeekDayReport Extends %RegisteredObject
{

/// Запрос: {"reportName":"incoming-by-week-day-report","beginDate":"05.12.2017","endDate":"31.12.2017"}
ClassMethod GetData(CriteriaReport, Output result) As %Status
{
	kill ^a.rep
	kill array
	
	//set beginDate =  ##class(p6.Date).DisplayToLogical(CriteriaReport.beginDate)
	set endDate =  ##class(p6.Date).DisplayToLogical(CriteriaReport.endDate)
	set beginDate =  endDate - 7
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
	set weekDate1 = $zdate(beginDate,10)
	for i=weekDate1:1:(weekDate1+7) {
		set curWeekDateNo = i
		if curWeekDateNo>6 set curWeekDateNo = curWeekDateNo - 7
		set weekDateName = $select(curWeekDateNo=0:"ВС",
			curWeekDateNo=1:"ПН",
			curWeekDateNo=2:"ВТ",
			curWeekDateNo=3:"СР",
			curWeekDateNo=4:"ЧТ",
			curWeekDateNo=5:"ПТ",
			curWeekDateNo=6:"СБ")
		do result.labels.%Push(weekDateName)
		do firstData.%Push(+$get(array(curWeekDateNo,"first")))
		do anotherData.%Push(+$get(array(curWeekDateNo,"another")))
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
	
	merge ^a.rep = array
	
	quit $$$OK
}

}

