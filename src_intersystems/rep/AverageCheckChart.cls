/// Данные для приборной панели
Class rep.AverageCheckChart Extends %RegisteredObject
{

/// Запрос: {"reportName":"average-check-chart"}
///  ageSections = [
///    {color: '#1976D2', rangeValues : [0, 17]},
///    {color: '#d23819', rangeValues : [18, 22]},
///    {color: '#ff0095', rangeValues : [23, 45]},
///    {color: '#00ff04', rangeValues : [46, 100]}
///  ];
ClassMethod GetData(CriteriaReport, Output result) As %Status
{
	kill ^a.rep2
	kill array
	set result = {
            "labels": []
		}
	set data = []
	set backgroundColor = []
	set total = 0	
	set iter = CriteriaReport.averageCheckSections.%GetIterator()
	while iter.%GetNext(.key , .section) {
		set ^a.rep2(key,"section")=section
	    //set ^a.rep(key,"rangeValues")=rangeValues
	    set beginAge = section.rangeValues.%Get(0)
		set endAge = section.rangeValues.%Get(1)
		
		set ^a.rep2(key,"beginAge")=beginAge
		set ^a.rep2(key,"endAge")=endAge
		set count = 0
		//&sql(select count(Id) into :count from doc.BonusOperation where RubSum>=:beginAge and RubSum<:endAge)	
		&sql( select count(buyerCount) into :count from
			( SELECT count( DISTINCT Buyer) as buyerCount
				FROM doc.BonusOperation where Buyer->shop=1
				group by Buyer having avg(RubSum)>=:beginAge and avg(RubSum)<:endAge
			)
		)
		//do result.labels.%Push(beginAge _ " - " _ endAge _ ", руб.")
		//do data.%Push(count)
		//do backgroundColor.%Push(section.color)
		set array(beginAge,beginAge _ " - " _ endAge _ ", руб.","count")=count
		set array(beginAge,beginAge _ " - " _ endAge _ ", руб.","backgroundColor")=section.color
		set total = total + count
	}
	set count = 0
	//&sql(select count(Id) into :count from doc.BonusOperation where RubSum>=:endAge)	
	&sql( select count(buyerCount) into :count from
			( SELECT count( DISTINCT Buyer) as buyerCount
				FROM doc.BonusOperation where Buyer->shop=1
				group by Buyer having avg(RubSum)>=:endAge
			)
		)
	//do result.labels.%Push(endAge _ " +")
	//do data.%Push(count)
	//do backgroundColor.%Push("#ff0000")
	set array(endAge,endAge _ " +","count")=count
	set array(endAge,endAge _ " +","backgroundColor")="#ff0000"
	set total = total + count
	
	set key = $order(array(""))
	while (key]"") {
		set key1 = $order(array(key,""))
		while (key1]"") {
			//do data.%Push($fnumber(array(key,"count")/(total/100),"",1))
			do result.labels.%Push(key1)
			do data.%Push($fnumber(array(key,key1,"count"),"",1))
			do backgroundColor.%Push(array(key,key1,"backgroundColor"))
			set key1 = $order(array(key,key1))
		}
		set key = $order(array(key))
	}
		
	set data1 = {}
	set data1.data = data
	set data1.backgroundColor = backgroundColor
    set data1.hoverBackgroundColor = backgroundColor
	
	set datasets = [].%Push(data1)
    set result.datasets = datasets             
	
	quit $$$OK
}

}

