/// Данные для приборной панели
Class rep.SexChart Extends %RegisteredObject
{

/// Запрос: {"reportName":"sex-chart"}
ClassMethod GetData(CriteriaReport, Output result) As %Status
{
	kill ^a.rep
	kill array
	
	set beginDate =  ##class(p6.Date).DisplayToLogical(CriteriaReport.beginDate)
	set endDate =  ##class(p6.Date).DisplayToLogical(CriteriaReport.endDate)
	kill array
	
	set result = {
            "labels": ["Женщины","Мужчины","Не указано"]
		}
	set data = []	
            
	
	&sql(declare rep cursor for
			select count(c1),c2 into :c1,:c2 from 
			(select Id as c1, nvl(Sex,'НЕИЗВЕСТНО') as c2 from ent.Buyer)
 		group by c2		
 		order by c2)
	&sql(open rep)	
	&sql(fetch rep)	
	
	while (SQLCODE=0) {
		do data.%Push(c1)
		&sql(fetch rep)	
	}
	&sql(close rep)	
	//merge ^a.rep = array
	
	set data1 = {}
	set data1.data = data
	set data1.backgroundColor = [
                        "#FF6384",
                        "#36A2EB",
                        "#FFCE56"
                    ]
    set data1.hoverBackgroundColor = [
                        "#FF6384",
                        "#36A2EB",
                        "#FFCE56"
                    ]       
	
	set datasets = [].%Push(data1)
    set result.datasets = datasets             
	
	quit $$$OK
}

}

