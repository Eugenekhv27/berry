/// Соводный отчет по покупателю
/// Выводим:
/// 1. Остаток бонусов
/// 2. К какой группе относится по отчету ABC за последние 30 дней
/// 3. Последние 3 покупки
/// 4. Отчет ABC товаров (стоимость) по данному покупателю за все время жизни. 
Class rep.BuyerInfo Extends %RegisteredObject
{

ClassMethod GetHtml(accountId, buyerId, htmlResult) As %Status
{
	set sc = ..GetData(accountId, buyerId,.result)
	if $$$ISERR(sc) {
	 	set htmlResult=$System.Status.GetErrorText(sc)
 	}
 	set htmlResult = ""
 	
 	_"<h2>Баланс:<b>"_result.balance_"</b></h2>    "
 	_"Статус:<b>"_result.status_"</b>     "
 	_"Средний чек:<b>"_result.averagePurchaseAmount_"</b><br>"
 	_"<br><b>Последние покупки</b><br>"
 	_"02.04.2017  Жижа - 560 руб.<br>"
 	
 	_"<br><b>Товары из группы А</b><br>"
 	_"Кукуруза<br>"
 	_"Морковка<br>"
 	_"Капуста<br>"
 	
 set htmlResult = ""
 	_"<html><head>"
 	_"<meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"" />"
	_"<meta http-equiv=""X-UA-Compatible"" content=""IE=Edge"" />"
	_"<meta name=""format-detection"" content=""telephone=no"" />"
	
	_"<style type=""text/css"">"
	_"body{margin:0;padding:8px;}"
	_"p{line-height:1.15;margin:0;white-space:pre-wrap;}"
	_"ol,ul{margin-top:0;margin-bottom:0;}"
	_"img{border:none;}"
	_"li>p{display:inline;}"
	_"</style>"
	_"</head><body>"
	
	_"<p style=""text-align: center;""><span style=""font-size: 16pt;font-weight: bold;"">Баланс: </span><span style=""font-size: 16pt;font-weight: bold;"">"_result.balance_" бонусов</span></p>"
	_"<p style=""text-align: center;""><br></p><ul><li style=""text-align: left;"">"
	_"<p style=""text-align: left;display:inline;""><span style=""font-weight: bold;"">Частота покупок: 0 в месяц </span><span style=""font-weight: bold;""> </span></p>"
	_"</li><li style=""text-align: left;""><p style=""text-align: left;display:inline;""><span style=""font-weight: bold;"">Средний чек:		 		</span><span style=""font-weight: bold;"">0 руб.</span></p>"
	_"</li><li style=""text-align: left;""><p style=""text-align: left;display:inline;""><span style=""font-weight: bold;"">Общая сумма покупок: 	0 руб.</span></p>"
	_"</li><li style=""text-align: left;"">"
	_"<p style=""text-align: left;display:inline;""><span style=""font-weight: bold;"">Ранг покупателя:			</span></p>"
	_"</li><li style=""text-align: left;"">"
	_"<p style=""text-align: left;display:inline;""><span style=""font-weight: bold;"">Возраст: 				0 лет</span></p>"
	_"</li><li style=""text-align: left;"">"
	_"<p style=""text-align: left;display:inline;""><span style=""font-weight: bold;"">Статус:					</span><span style=""font-weight: bold;"">Из группы А</span><span style=""font-weight: bold;""> </span><span style=""font-weight: bold;"">  </span></p>"
	_"</li>"
	_"</ul>"
	_"<p style=""text-align: center;""><br></p>"
	_"<p style=""text-align: center;""><span style=""font-family: Arial;font-size: 16pt;font-style: normal;font-weight: bold;text-decoration: none;"">Последние покупки:</span></p>"

	// _"<p style=""text-align: left;margin-left: 20pt;""><span style=""font-weight: bold;"">	1) 10.02.2017  на сумму 1000 руб.</span></p>"
	// _"<p style=""text-align: left;margin-left: 20pt;""><span style=""font-weight: normal;"">		Сигареты, жижа, кальян</span><span style=""font-weight: bold;""><br></span>"
	
	// _"<span style=""font-weight: bold;"">	2) 15.01.2017  на сумму 1200 руб.</span></p>"
	// _"<p style=""text-align: left;margin-left: 20pt;""><span style=""font-weight: normal;"">		Сигареты, жижа, кальян</span><span style=""font-weight: bold;"">	</span></p>"
	
	_"<p style=""text-align: center;""><br></p>"
	_"<p style=""text-align: center;margin-left: 0pt;""><span style=""font-family: Arial;font-size: 16pt;font-style: normal;font-weight: bold;text-decoration: none;"">Товары группы А</span></p>"
	_"<p style=""text-align: center;""><br></p>"
	_"<p style=""text-align: center;""><span style=""font-family: Arial;font-size: 16pt;font-style: normal;font-weight: bold;text-decoration: none;"">Товары группы B</span><span style=""font-family: Arial;font-size: 16pt;font-style: normal;font-weight: bold;text-decoration: none;""><br></span></p>"
	_"</body></html>"
 	
 	
	quit $$$OK
	
	
	/*  образец вывода информации по покупателю
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
<meta name="format-detection" content="telephone=no" />
<style type="text/css">
body{margin:0;padding:8px;}
p{line-height:1.15;margin:0;white-space:pre-wrap;}
ol,ul{margin-top:0;margin-bottom:0;}
img{border:none;}
li>p{display:inline;}
</style>
</head>
<body>
<p style="text-align: center;"><span style="font-size: 16pt;font-weight: bold;">Баланс: </span><span style="font-size: 16pt;font-weight: bold;">438 бонусов</span></p>
<p style="text-align: center;"><br></p>
<ul>
<li style="text-align: left;">
<p style="text-align: left;display:inline;"><span style="font-weight: bold;">Частота покупок: 			0 в месяц </span><span style="font-weight: bold;"> </span></p>
</li>
<li style="text-align: left;">
<p style="text-align: left;display:inline;"><span style="font-weight: bold;">Средний чек:		 		</span><span style="font-weight: bold;">1895 руб.</span></p>
</li>
<li style="text-align: left;">
<p style="text-align: left;display:inline;"><span style="font-weight: bold;">Общая сумма покупок: 	0 руб.</span></p>
</li>
<li style="text-align: left;">
<p style="text-align: left;display:inline;"><span style="font-weight: bold;">Ранг покупателя:			</span></p>
</li>
<li style="text-align: left;">
<p style="text-align: left;display:inline;"><span style="font-weight: bold;">Возраст: 				0 лет</span></p>
</li>
<li style="text-align: left;">
<p style="text-align: left;display:inline;"><span style="font-weight: bold;">Статус:					</span><span style="font-weight: bold;">Из группы А</span><span style="font-weight: bold;"> </span><span style="font-weight: bold;">  </span></p>
</li>
</ul>
<p style="text-align: center;"><br></p>
<p style="text-align: center;"><span style="font-family: Arial;font-size: 16pt;font-style: normal;font-weight: bold;text-decoration: none;">Последние покупки:</span></p>
<p style="text-align: left;margin-left: 20pt;"><span style="font-weight: bold;">	1) 10.02.2017  на сумму 1000 руб.</span></p>
<p style="text-align: left;margin-left: 20pt;"><span style="font-weight: normal;">		Сигареты, жижа, кальян</span><span style="font-weight: bold;"><br></span><span style="font-weight: bold;">	2) 15.01.2017  на сумму 1200 руб.</span></p>
<p style="text-align: left;margin-left: 20pt;"><span style="font-weight: normal;">		Сигареты, жижа, кальян</span><span style="font-weight: bold;">	</span></p>
<p style="text-align: center;margin-left: 40pt;"><span style="font-weight: bold;"><br></span><span style="font-weight: bold;">		</span></p>
<p style="text-align: center;margin-left: 0pt;"><span style="font-family: Arial;font-size: 16pt;font-style: normal;font-weight: bold;text-decoration: none;">Товары группы А</span></p>
<p style="text-align: center;"><br></p>
<p style="text-align: center;"><span style="font-family: Arial;font-size: 16pt;font-style: normal;font-weight: bold;text-decoration: none;">Товары группы B</span><span style="font-family: Arial;font-size: 16pt;font-style: normal;font-weight: bold;text-decoration: none;"><br></span></p>
</body>
</html>
*/
}

ClassMethod GetData(accountId, buyerId, Output result) As %Status
{
	set result = {}
	
	// остаток баллов
	set balance = 0
	&sql(select sum(PointsSum) into :balance from doc.BonusOperation where Buyer=:buyerId and Shop=:accountId)
 	if SQLCODE set balance = 0									
	set result.balance = balance
	
	// средний чек	
	set bonusOperationCount=0,rubSum =0
	&sql(select count(Id),sum(RubSum) 
		into :bonusOperationCount,:rubSum 
		from doc.BonusOperation where Buyer->Shop=:accountId and PointsSum>0 and Buyer=:buyerId)
	
 	set:bonusOperationCount>0 result.averagePurchaseAmount = $number(rubSum/bonusOperationCount,0)
 	
 	// статус
 	set result.status = "Из группы А"  // пока не реализовано
 	
 	// посление 3 покупки
 	set result.lastPurchase = [
		{
			"date":"2017-04-05",
			"detail": [
				{"goods":"Кукуруза","qty":1,"price":100.00},
				{"goods":"Морковка","qty":1,"price":100.00},
				{"goods":"Капуста","qty":1,"price":100.00}
			]
		},
 
		{
			"date":"2017-03-05",
			"detail": [
				{"goods":"Кукуруза","qty":1,"price":100.00},
				{"goods":"Морковка","qty":1,"price":100.00},
				{"goods":"Капуста","qty":1,"price":100.00}
			]
		},
		{
			"date":"2017-02-05",
			"detail": [
				{"goods":"Кукуруза","qty":1,"price":100.00},
				{"goods":"Морковка","qty":1,"price":100.00},
				{"goods":"Капуста","qty":1,"price":100.00}
			]
		}
	]
	
	set result.abcReport = [
		{"goods":"Кукуруза","sum":100.00,"group":"A"},
		{"goods":"Морковка","sum":100.00,"group":"B"},
		{"goods":"Капуста","sum":100.00,"group":"C"}
	]
 	
 	
	quit $$$OK
	
	/* пример возврата
 {
    "balance": 100, // остаток бонусов
    "status": "Из группы А", // группа из отчета ABC за последние 30 дней
    "averagePurchaseAmount":20, // средний чек
	"lastPurchase": [
		{
			"date":"2017-04-05",
			"detail": [
				{"goods":"Кукуруза","qty":1,"price":100.00},
				{"goods":"Морковка","qty":1,"price":100.00},
				{"goods":"Капуста","qty":1,"price":100.00}
			]
		},
		{
			"date":"2017-03-05",
			"detail": [
				{"goods":"Кукуруза","qty":1,"price":100.00},
				{"goods":"Морковка","qty":1,"price":100.00},
				{"goods":"Капуста","qty":1,"price":100.00}
			]
		},
		{
			"date":"2017-02-05",
			"detail": [
				{"goods":"Кукуруза","qty":1,"price":100.00},
				{"goods":"Морковка","qty":1,"price":100.00},
				{"goods":"Капуста","qty":1,"price":100.00}
			]
		}
	],
	"abcReport": [
		{"goods":"Кукуруза","sum":100.00,"group":"A"},
		{"goods":"Морковка","sum":100.00,"group":"B"},
		{"goods":"Капуста","sum":100.00,"group":"C"},
	]
 }
*/
}

}

