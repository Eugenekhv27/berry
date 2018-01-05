/// Данные для приборной панели
Class rep.SellersKpiReport Extends %RegisteredObject
{

/// Запрос: {"reportName":"sellers-kpi-report","beginDate":"05.12.2017","endDate":"31.12.2017"}
ClassMethod GetData(CriteriaReport, Output result) As %Status
{
	kill ^a.rep
	kill array
	
	set beginDate =  ##class(p6.Date).DisplayToLogical(CriteriaReport.beginDate)
	set endDate =  ##class(p6.Date).DisplayToLogical(CriteriaReport.endDate)
	kill array
	set balanceTotal = 0, plusPointsTotal = 0, minusPointsTotal = 0
	&sql(declare rep cursor for
		select Id, seller->aka, Buyer, Buyer->RegDate, RubSum
		into :qOpId,:qsellerAka,:qBuyerId,:qBuyerRegDate, :qRubSum
		from doc.BonusOperation where DocDate>=:beginDate and DocDate<=:endDate)
	&sql(open rep)	
	&sql(fetch rep)	

	while (SQLCODE=0) {
		if (qsellerAka]"") {
			if (qBuyerRegDate>=beginDate) && (qBuyerRegDate<=endDate) {
				set array(qsellerAka,"buyerId",qBuyerId)=1	
			}
			set array(qsellerAka,"saleSum")	= +$get(array(qsellerAka,"saleSum")) + qRubSum
			set array(qsellerAka,"qtyCheck")	= $get(array(qsellerAka,"qtyCheck")) + 1
		
		}
		&sql(fetch rep)	
	}
	&sql(close rep)	
	
	set result = {}
	set result.children = []
	set attractedQtyTotal = 0
	set saleSumTotal = 0
	set qtyCheckTotal = 0
	// Узнаем количество привлеченных и средний чек
	set key = $order(array(""))
	while (key]"") {
		set key2 = $order(array(key,"buyerId",""))
		set attractedQty = 0
		while (key2]"") {
			set attractedQty = attractedQty + 1
			set key2 = $order(array(key,"buyerId",key2))
		}
		set line = {}
		set line.id = ""
		set line.name = key
		set line.attractedClients = attractedQty
		set attractedQtyTotal = attractedQtyTotal + attractedQty
		set line.saleSum = $get(array(key,"saleSum"))
		set saleSumTotal = saleSumTotal + $get(array(key,"saleSum"))
		set line.averageCheck = 0
		if (+$get(array(key,"qtyCheck"))>0) {
			set line.averageCheck = +$get(array(key,"saleSum"))/array(key,"qtyCheck")
		}
		set line.qtyCheck = $get(array(key,"qtyCheck"))
		set qtyCheckTotal = qtyCheckTotal + $get(array(key,"qtyCheck"))
		do result.children.%Push(line) 
		set key = $order(array(key))
	}
	set result.totals = {}
	set result.totals.attractedClients = attractedQtyTotal
	set result.totals.saleSum = saleSumTotal
	set result.totals.qtyCheck = qtyCheckTotal
	
	//merge ^a.rep = array
	
	quit $$$OK
	/* 
	пример возврата:
	set report = 
	{
		"status": "OK",
		"report": {
		  "children":[
			{
				"id":245,
				"name":" +7(000)0000000",
				"balance":120,
				"balanceCaregory":"A",
				"plusPoints":45,
				"plusPointsCaregory":"B",
				"minusPoints":20,
				"minusPointsCaregory":"C"
			},		
			{
				"id":246,
				"name":" +7(000)0000000",
				"balance":120,
				"balanceCaregory":"A",
				"plusPoints":45,
				"plusPointsCaregory":"B",
				"minusPoints":20,
				"minusPointsCaregory":"C"
			},
			{
				"id":247,
				"name":" +7(000)0000000",
				"balance":120,
				"balanceCaregory":"A",
				"plusPoints":45,
				"plusPointsCaregory":"B",
				"minusPoints":20,
				"minusPointsCaregory":"C"
			}
		],
		"totals":{
			"balance":1200,
			"plusPoints":1150,
			"minusPoints":432	
		}
  	  }
  	  */
}

}

