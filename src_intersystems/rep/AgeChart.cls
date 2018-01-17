/// Данные для приборной панели
Class rep.AgeChart Extends %RegisteredObject
{

/// Запрос: {"reportName":"age-chart"}
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
	set iter = CriteriaReport.ageSections.%GetIterator()
	while iter.%GetNext(.key , .section) {
		set ^a.rep2(key,"section")=section
	    //set ^a.rep(key,"rangeValues")=rangeValues
	    set beginAge = section.rangeValues.%Get(0)
		set endAge = section.rangeValues.%Get(1)
		
		set ^a.rep2(key,"beginAge")=beginAge
		set ^a.rep2(key,"endAge")=endAge
		set count = 0
		&sql(select count(Id) into :count from ent.Buyer where age>=:beginAge and age<=:endAge)	
		do result.labels.%Push(beginAge _ " - " _ endAge)
		//do data.%Push(count)
		set array(beginAge _ " - " _ endAge,"count")=count
		set array(beginAge _ " - " _ endAge,"backgroundColor")=section.color
		set total = total + count
		//do backgroundColor.%Push(section.color)
	}
	set count = 0
	&sql(select count(Id) into :count from ent.Buyer where age is null)	
	set total = total + count
	do result.labels.%Push("Не указано")
	//do data.%Push(count)
	//do backgroundColor.%Push("#2ca3de")
	set array("Не указано","count")=count
	set array("Не указано","backgroundColor")="#2ca3de"
	
	set key = $order(array(""))
	while (key]"") {
		do data.%Push($fnumber(array(key,"count")*(100/total),"",1))
		do backgroundColor.%Push(array(key,"backgroundColor"))
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

