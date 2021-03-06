/// Данные для приборной панели
Class rep.ABCAnalysisReport Extends %RegisteredObject
{

/// Запрос: {"reportName":"abc-analysis-report","beginDate":"05.12.2017","endDate":"31.12.2017","aPrecent":80,"bPrecent":15,"cPrecent":15}
ClassMethod GetData(CriteriaReport, Output result) As %Status
{
	kill ^a.rep
	
	set beginDate =  ##class(p6.Date).DisplayToLogical(CriteriaReport.beginDate)
	set endDate =  ##class(p6.Date).DisplayToLogical(CriteriaReport.endDate)
	kill array
	set balanceTotal = 0, plusPointsTotal = 0, minusPointsTotal = 0
	&sql(declare rep cursor for
		select Id,Aka,Name,BonusSum into :qBuyerId,:qAka,:qName,:qBalance from ent.Buyer order by BonusSum desc)
	&sql(open rep)	
	&sql(fetch rep)	
	while (SQLCODE=0) {
		if qBalance="" set qBalance=0
		set array("balance",qBalance,"buyerId",qBuyerId)=qBuyerId
		set array("report",qBuyerId,"balance")=qBalance
		set (plusPointsSum,minusPointsSum)=0
		&sql(select sum(PlusPointsSum),sum(MinusPointsSum) 
				into :plusPointsSum,:minusPointsSum 
				from doc.BonusOperation where Buyer=:qBuyerId
				and (DocDate>=:beginDate) and (DocDate<=:endDate))
		
		if plusPointsSum="" set plusPointsSum=0
		if minusPointsSum="" set minusPointsSum=0
		
		
		set array("plusPoints",plusPointsSum,"buyerId",qBuyerId)=qBuyerId
		set array("report",qBuyerId,"plusPoints")=plusPointsSum
		set array("minusPoints",minusPointsSum,"buyerId",qBuyerId)=qBuyerId
		set array("report",qBuyerId,"minusPoints")=minusPointsSum
		
		set array("report",qBuyerId,"name")=qName_" "_qAka
		
		set balanceTotal = balanceTotal + qBalance
		set plusPointsTotal = plusPointsTotal + plusPointsSum
		set minusPointsTotal = minusPointsTotal + minusPointsSum
		&sql(fetch rep)	
	}
	&sql(close rep)	
	
	/// определяем границы отсечек 
	set balanceTotalA =balanceTotal * CriteriaReport.aPrecent/100
	set balanceTotalB =balanceTotal * CriteriaReport.bPrecent/100
	
	set plusPointsTotalA =plusPointsTotal * CriteriaReport.aPrecent/100
	set plusPointsTotalB =plusPointsTotal * CriteriaReport.bPrecent/100
	
	set minusPointsTotalA =minusPointsTotal * CriteriaReport.aPrecent/100
	set minusPointsTotalB =minusPointsTotal * CriteriaReport.bPrecent/100
	
	set key = $order(array("balance",""),-1)
	set keyTotal = 0
	while (key]""){
		set buyerId = $order(array("balance",key,"buyerId",""),-1)
		while (buyerId]""){
			
			set keyTotal = keyTotal + key
			set array("report",buyerId,"balanceTotal")=keyTotal
		
			if keyTotal<balanceTotalA {
				set array("report",buyerId,"balanceCaregory")="A"
			} elseif keyTotal<(balanceTotalB + balanceTotalA) {
				set array("report",buyerId,"balanceCaregory")="B"
			} else {
				set array("report",buyerId,"balanceCaregory")="C"
			}
			set buyerId = $order(array("balance",key,"buyerId",buyerId),-1)
		}
		set key = $order(array("balance",key),-1)
	}
	
	set key = $order(array("plusPoints",""),-1)
	set keyTotal = 0
	while (key]""){
		set buyerId = $order(array("plusPoints",key,"buyerId",""),-1)
		while (buyerId]""){
			set keyTotal = keyTotal + key
			set array("report",buyerId,"plusPointsTotal")=keyTotal
			if keyTotal<plusPointsTotalA {
				set array("report",buyerId,"plusPointsCaregory")="A"
				set array("order","A"_buyerId,$get(array("plusPoints",key),0))=buyerId
			} elseif keyTotal<(plusPointsTotalB + plusPointsTotalA) {
				set array("report",buyerId,"plusPointsCaregory")="B"
				set array("order","B"_buyerId,$get(array("plusPoints",key),0))=buyerId
			} else {
				set array("report",buyerId,"plusPointsCaregory")="C"
				set array("order","C"_buyerId,$get(array("plusPoints",key),0))=buyerId
			}
			set buyerId = $order(array("plusPoints",key,"buyerId",buyerId),-1)
		}
		set key = $order(array("plusPoints",key),-1)
	}
	
	set key = $order(array("minusPoints",""),-1)
	set keyTotal = 0
	while (key]""){
		set buyerId = $order(array("minusPoints",key,"buyerId",""),-1)
		while (buyerId]""){
			set keyTotal = keyTotal + key
			set array("report",buyerId,"minusPointsTotal")=keyTotal
			if keyTotal<minusPointsTotalA {
				set array("report",buyerId,"minusPointsCaregory")="A"	
			} elseif keyTotal<(minusPointsTotalB + minusPointsTotalA) {
				set array("report",buyerId,"minusPointsCaregory")="B"	
			} else {
				set array("report",buyerId,"minusPointsCaregory")="C"
			}
			set buyerId = $order(array("minusPoints",key,"buyerId",buyerId),-1)
		}
		set key = $order(array("minusPoints",key),-1)
	}
	
	//m ^a.rep = array
	set onDate = +$H
	set result = {}
	set result.children = []
	//set buyerId = $order(array("report",""))
	set key = $order(array("order",""))
	while (key]"") {
		set key2 = ""
		for {
			set key2 = $order(array("order",key,key2))
			quit:(key2 = "")
			set buyerId = array("order",key,key2)
			// Фиксируем группу начислений, если необходимо
			if (CriteriaReport.saveInBuyer) {
				&sql(insert or update into ent.BuyerAbcGroup (buyer,onDate,groupName)
				values (:buyerId,:onDate,:array("report",:buyerId,"plusPointsCaregory")))	
			}
			/// подключаем дополнительные фильтры для отображения
			set buyerObject = ##class(ent.Buyer).%OpenId(buyerId)
			if (CriteriaReport.sex]"") { // Пол
    			set aSex = $zconvert(CriteriaReport.sex,"I","UTF8")
    			if aSex="Неизвестно" {
	    			if '((buyerObject.Sex="") || (buyerObject.Sex="Неизвестно")) {
		    			continue	
	    			}
    			} else {
    				if buyerObject.Sex'=aSex continue
    			}
    			
    		}
    		if (CriteriaReport.beginAge]"") { // Возраст с 
    			if CriteriaReport.beginAge>buyerObject.age continue
    		}
    		if (CriteriaReport.endAge]"") { // Возраст по
    			if CriteriaReport.endAge<buyerObject.age continue
    		}
    		if (CriteriaReport.abcPlus]"") { // Группа накопления
    			if CriteriaReport.abcPlus '= array("report",buyerId,"plusPointsCaregory") continue
    		}
    		if (CriteriaReport.abcBalance]"") { // Группа 
    			if CriteriaReport.abcBalance '= array("report",buyerId,"balanceCaregory") continue
    		}
    		if (CriteriaReport.abcMinus]"") { // Группа 
    			if CriteriaReport.abcMinus '= array("report",buyerId,"minusPointsCaregory") continue
    		}
    		kill buyerObject
			set line= {}
			set line.id = buyerId
			set line.name = array("report",buyerId,"name")
			set line.balance = array("report",buyerId,"balance")
			set line.balanceCaregory = array("report",buyerId,"balanceCaregory")
		
			set line.plusPoints = array("report",buyerId,"plusPoints")
			set line.plusPointsCaregory = array("report",buyerId,"plusPointsCaregory")
		
			set line.minusPoints = array("report",buyerId,"minusPoints")
			set line.minusPointsCaregory = array("report",buyerId,"minusPointsCaregory")
			
			do result.children.%Push(line)
		
		}
		
		set key = $order(array("order",key))
	}
	
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

