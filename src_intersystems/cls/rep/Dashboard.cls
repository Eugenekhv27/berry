/// Данные для приборной панели
Class rep.Dashboard Extends %RegisteredObject
{

ClassMethod GetData(accountId, Output result) As %Status
{
	set result = {}
	set result.summary = {}
	
	set buyerCount=0
	&sql(select count(Id) into :buyerCount from ent.Buyer where Shop=:accountId)
	
	set bonusOperationCount=0,rubSum =0
	&sql(select count(Id),sum(RubSum) 
		into :bonusOperationCount,:rubSum 
		from doc.BonusOperation where Buyer->Shop=:accountId and PointsSum>0)
	
	set result.summary.participantCount = buyerCount
 	set result.summary.purchaseCount = bonusOperationCount
 	set result.summary.purchaseAmount = rubSum
 	set:bonusOperationCount>0 result.summary.averagePurchaseAmount = $number(rubSum/bonusOperationCount,0)
 	
 	/// График количество участников за последние 30 дней
 	&sql(select count(Id)
 		into :startCount
 		from ent.Buyer where RegDate<DATEADD('day',-30,{fn CURDATE()}))
 	&sql(declare cb cursor for
 		SELECT count(ID), RegDate
 		into :addCount,:addDate
 			FROM ent.Buyer
			where RegDate>=DATEADD('day',-30,{fn CURDATE()}) 
			group by RegDate
			order by RegDate)
	&sql(open cb)		
	&sql(fetch cb)		
	set curCount = startCount
	set array(+$H-30)=curCount
	
	while (SQLCODE=0) {
		set curCount = curCount + addCount
		set array(addDate)=curCount
		&sql(fetch cb)		
	}
 	&sql(close cb)
 	kill ^a.array
	m ^a.array = array
 	set result.summary.chart = {}
 	set result.summary.chart.dates = []
 	set result.summary.chart.participantCount = []
 	set curCount = startCount
 	for curDate = +$H-30:1:+$H {
	 	if ($data(array(curDate))) set curCount = array(curDate)
	 	do result.summary.chart.dates.%Push(##class(p6.Date).LogicalToDisplay(curDate))
	 	do result.summary.chart.participantCount.%Push(curCount)
 	}
	quit $$$OK
	
	/* пример возврата
	{
  "summary": {
    "date": "01.01.1888", // string - дата, за которую получены данные

    // данные для индикаторов, тип значений - number
    "participantCount": 123,  //"Количество участников"
    "purchaseCount": 345,     // "Количество покупок"
    "purchaseAmount": 2344,    // "Сумма покупок"
    "averagePurchaseAmount": 12, // "Cумма всех покупок / кол-во чеков"

    // данные для графика
    "chart": {
      "dates": ["date1", "date2", ...], // ряд значений дат для оси X
      // далее идут один или несколько рядов значенй для графиков (массивы чисел),
      // размер каждого массива должен быть точно равен размеру массива "dates"
      // ключ = имя ряда значений, тип элементов массива - number
      "participantCount": ["value1", "value2", ...]
    }
  }
}
*/
}

}

