Class m.UserRest Extends %CSP.REST
{

/// This parameter controls the CSP session support. By default the CSP session will be
/// ended after each request in accordance with the spirit of REST. However this CAN be
/// overridden by the user. To use a session, it's necessary to manage the CSPSESSION cookie.
/// Browsers do this automatically but command line tools such as CURL require the setting of
/// options.<p>
/// Note that if you choose to use a session then this will use a CSP license until the session
/// is ended or expires and the grace period has been satisfied. If you use the default of no
/// session then this will be the same behavior as SOAP requests of holding a license for ten
/// seconds.
Parameter UseSession As Integer = 0;

/// This parameter influences the CORS support. The default is an empty string meaning 'not specified'.
/// If set to true (1) then CORS processing is ON. If set to false (0) then CORS processing is OFF.
/// If left unset "" then the decision to process CORS is delegated to the setting on the URL map route.
Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<!-- Получение доступа к ЛК-->
<Route Url="/getaccesscode/:encodeUserTel/:shopId" Method="GET" Call="getAccessCode"/>
<Route Url="/confirmcode/:encodeUserTel/:shopId/:code" Method="GET" Call="confirmCode"/>

<!-- Баланс -->
<Route Url="/getbalance" Method="POST" Call="getBalance"/>
<!-- Инфа о покупках -->
<Route Url="/getpurchase" Method="POST" Call="getPurchase"/>
</Routes>
}

ClassMethod getAccessCode(encodeUserTel As %String = "", shopId = "") As %Status
{
 kill ^a.temp	
 set ^a.temp("encodeUserTel") = encodeUserTel
 set userTel=$system.Encryption.Base64Decode($ZCONVERT(encodeUserTel,"I","UTF8"))	
 set ^a.temp("encodeUserTel2") = userTel	
 if '(($e(userTel)="8") || ($e(userTel,1,2)="+7")) {
	set userTel = "+7"_userTel
 }
 set ^a.temp("encodeUserTel3") = userTel
 
 set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel, ,.sc,, 1, shopId)
 
 if buyerId]"" {
	
 	set code=$RANDOM(9999)
 	if $l(code)=3 {
		set code = "0"_code	 
 	} elseif $l(code)=2 {
		set code = "00"_code	 
 	} elseif $l(code)=1 {
		set code = "000"_code	 
 	}
 	set ^a.temp($H,"code",userTel) = code
 	set ^smscode(userTel,"code") = code
 	set ^smscode(userTel,"datetime") = $H
 	
 	do ##class(p6.Sms).SendSms(userTel,"Код для входа: "_code,,,,,,,,"Код отправлен.")
 	
 	set buyer = ##class(ent.Buyer).%OpenId(buyerId)
 	set buyer.accessCode = code
 	set sc = buyer.Save()
	
 	set output = {}
 	set output.status = "OK"
 	set output.result = {}
 	set output.result.accesscode = code
 
 
 
 } 
 if $$$ISERR(sc) {
	 set output = {}
 	 set output.status = $System.Status.GetErrorText(sc)
	 
 }
 
 write output.%ToJSON()
 quit $$$OK
}

ClassMethod confirmCode(encodeUserTel As %String = "", shopId = "", code = "") As %Status
{
 kill ^a.temp	
 set ^a.temp("encodeUserTel") = encodeUserTel
 set ^a.temp("shopId") = shopId
 
 
 set userTel=$system.Encryption.Base64Decode($ZCONVERT(encodeUserTel,"I","UTF8"))	
 set ^a.temp("encodeUserTel2") = userTel
 if '(($e(userTel)="8") || ($e(userTel,1,2)="+7")) {
	set userTel = "+7"_userTel
 }
 set ^a.temp("encodeUserTel3") = userTel
 
 set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel, ,.sc,, 0, shopId)
 set accesscode = ##class(ent.Buyer).accessCodeGetStored(buyerId)
 set output = {}
 if (accesscode=code) {
 	set output.status = "OK"
 } else {
	 set output.status = "Неверный код"
 }
 write output.%ToJSON()
 quit $$$OK
}

/// {'q1': q1}
ClassMethod getBalance() As %Status
{
 kill ^a.temp
 do ##class(Utils.JsonProvider).%ConvertJSONToObject(%request.Content,"",.clientObj,1)
 set aAka = $p(clientObj.q1,":")
 set ^a.temp("tel1") = aAka
 
 if ($p(aAka,"(",1)="8") || ($p(aAka,"(",1)="7") || ($p(aAka,"(",1)="") {
	set $p(aAka,"(",1) = "+7"
 }
 set points = ""
 &sql(select sum(PointsSum) into :points from doc.BonusOperation 
 	where Buyer->Aka[:aAka)	
 set output = {}	
 set output.result = {}	
 set output.result.points = points
 set output.result.details = []	
 	
 &sql(declare bal cursor for 
 	select sum(PointsSum), Shop->Aka
 	into :detailPoints,:qShopAka
 	 from doc.BonusOperation 
 	where Buyer->Aka[:aAka
 	group by Shop)
 &sql(open bal)				
 &sql(fetch bal)			
 while (SQLCODE=0) {

    set line = {}
    set line.shop = qShopAka
    do line.%Set("points",detailPoints,"number")
	do output.result.details.%Push(line) 
	&sql(fetch bal)				 
 }
 &sql(close bal)
 set output.status = "OK"
 write output.%ToJSON()
 quit $$$OK
}

/// {'q1': q1}
/// {
///     id: '123',
///     date: '2017-10-17T15:55:11.000Z',
///     shop: 'Магазин «Клюковка»',
///     points: '+123',
///     money: 1234,
///     rating: 3,
///     detailsSummary: 'на сумму 1234 руб',
///     details: [
///       {
///         article: 'Что-то',
///         money: 123,
///       }, {
///         article: 'Нечто',
///         money: 234,
///       }, {
///         article: 'Что-то с чем-то',
///         money: 345,
///       },
///     ]
///   }
ClassMethod getPurchase() As %Status
{
 kill ^a.temp
 do ##class(Utils.JsonProvider).%ConvertJSONToObject(%request.Content,"",.clientObj,1)
 set aAka = $p(clientObj.q1,":")
 set ^a.temp("tel1") = aAka
 
 if ($p(aAka,"(",1)="8") || ($p(aAka,"(",1)="7") || ($p(aAka,"(",1)="") {
	set $p(aAka,"(",1) = "+7"
 }

 	
 set result = []	
  	
 &sql(declare purchase cursor for 
 	select top 10 Id,DocDate,PointsSum, Shop->Aka,RubSum,rating
 	into :opId,:docDate,:points,:qShopAka,:qRubSum,:qRating
 	 from doc.BonusOperation 
 	where Buyer->Aka[:aAka
 	order by DocDate desc)
 &sql(open purchase)				
 &sql(fetch purchase)			
 while (SQLCODE=0) {

    set purchase = {}
    set purchase.id=opId
    set purchase.docDate = ##class(p6.Date).LogicalToDisplay(docDate)
    set purchase.shop = qShopAka
    set purchase.points = $select(points>0:"+"_points,1:points)
    set purchase.money = qRubSum
    set purchase.rating = qRating
    set purchase.details = []
    &sql(declare purchaseLine cursor for
    	select goodsName->aka,cost
    	into :qGoodsName,:qCost
    	from doc.BonusOperationGoods where bonusOperation=:opId)
    &sql(open purchaseLine)	
    &sql(fetch purchaseLine)	
    while (SQLCODE=0) {
	    set line = {}
	    set line.article = qGoodsName
	    set line.money = qCost
	    do purchase.details.%Push(line) 
	    &sql(fetch purchaseLine)	
    }
    &sql(close purchaseLine)	
	do result.%Push(purchase) 
	&sql(fetch purchase)				 
 }
 &sql(close purchase)
 
 set output = {}
 set output.result = result
 set output.status = "OK"
 write output.%ToJSON()
 quit $$$OK
}

}

