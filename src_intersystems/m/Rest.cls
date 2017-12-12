Class m.Rest Extends %CSP.REST
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
<!-- интеграция с кассой (новая версия с анкетой)-->
<Route Url="/:encriptId/getInfo/:userTel" Method="GET" Call="GetInfo"/>
<Route Url="/:encriptId/saveprofile/:userTel" Method="POST" Call="SaveProfile"/>
<Route Url="/:encriptId/postdata" Method="POST" Call="PostData"/>
<Route Url="/:encriptId/putPoints/:userTel/:uuid/:rubSum/:pointsSum" Method="GET" Call="PutPoints2"/>
<!-- интеграция с кассой -->
<Route Url="/:encriptId/putPoints/:userTel/:uuid/:rubSum/:pointsSum/:fromTel" Method="GET" Call="PutPoints"/>
<Route Url="/:encriptId/getBalance/:userTel/:fromTel" Method="GET" Call="GetBalance"/>
<Route Url="/:encriptId/payByPoints/:userTel/:uuid/:points" Method="GET" Call="PayByPoints"/>
<Route Url="/:encriptId/checkCode/:userTel" Method="GET" Call="CheckCode"/>

<!-- интеграция с кассой (старая версия VAPEKO)-->
<Route Url="/putPoints/:userTel/:uuid/:rubSum/:pointsSum/:fromTel" Method="GET" Call="PutPointsVAPEKO"/>
<Route Url="/getBalance/:userTel/:fromTel" Method="GET" Call="GetBalanceVAPEKO"/>
<Route Url="/payByPoints/:userTel/:uuid/:points" Method="GET" Call="PayByPointsVAPEKO"/>

<!-- Проверка баланса для сайта-->
<Route Url="/checkCode/:userTel" Method="GET" Call="CheckCodeVAPEKO"/>




<!-- работа с данными -->
<Route Method="POST" Url="/:encriptId/save/:className" Call="SaveObject" /> 
<Route Method="GET" Url="/:encriptId/getObject/:className/:ID" Call="GetObjectById" /> 
<Route Method="GET" Url="/:encriptId/getObjectByAka/:className/:Aka" Call="GetObjectByAka" /> 
<Route Method="DELETE" Url="/:encriptId/delObject/:className/:ID" Call="DeleteObject" /> 

<Route Method="GET" Url="/getAE" Call="GetAE" /> 
<Route Method="GET" Url="/:encriptId/grid/:className/" Call="GetForGridByClassName" />

<!-- сервис для DashBoard -->
<Route Method="GET" Url="/:encriptId/dashboard" Call="GetDashboardData" />

<!-- Отчет по бонусам -->
<Route Method="GET" Url="/:encriptId/bonusReport/:beginDate/:endDate" Call="GetBonusReport" />
<Route Method="GET" Url="/:encriptId/bonusReportDetails/:onDate" Call="GetBonusReportDetails" />

<!-- Сообщение в техподдержку -->
<Route Method="POST" Url="/:encriptId/help-request" Call="SendToSupport" />

<!-- Отправить SMS сообщения -->
<Route Method="POST" Url="/:encriptId/sms-circular" Call="SendSms" />
<!-- Отправить голосовое сообщения -->
<Route Method="POST" Url="/:encriptId/voice-circular" Call="SendVoice" />

<!-- Начислить бонусы -->
<Route Method="POST" Url="/:encriptId/change-bonus" Call="ChangeBonus" />

<!-- Добавить бонусов в карточке клиентов -->
<Route Method="POST" Url="/:encriptId/doplusbonus" Call="DoPlusBonus" />

<!--
<Route Url="/:encriptId/getOperations/:userTel" Method="GET" Call="GetOperations"/>
<Route Url="/getOperations/:userTel" Method="GET" Call="GetOperationsVAPEKO"/>

<Route Url="/genCode/:userTel" Method="GET" Call="GenCodeVAPEKO"/>
<Route Url="/:encriptId/genCode/:userTel" Method="GET" Call="GenCode"/>
-->
</Routes>
}

/// POST json грузим следующего содеражния
/// {
/// 	"buyerTel":"+7(962)5020828",
/// 	"checkNo":"123 АБС",
/// 	"checkDateTime":"2017-10-03T10:23:22",
/// 	"uuid":"123-123-123-123",
/// 	 	"checkAmount":"123.23",
/// 		"bonusAmount":"23.00",
/// 			"payByBonus":"50",
/// 		"seller":"Иванов В.И.",
/// 		"codeWord":"3212",
/// 		"goods": [
/// 			{	
/// 				"goodsName":"молоко",
/// 				"qty":5,
/// 				"unit":"шт.",
/// 				"price":10.00,
/// 				"cost":50.00,
/// 			},
/// 			{	
/// 				"goodsName":"хлеб",
/// 				"qty":5,
/// 				"unit":"шт.",
/// 				"price":10.00,
/// 				"cost":50.00,
/// 			}
/// 		]
/// }
ClassMethod PostData(encriptId As %String = "") As %Status
{
	set sc=$$$OK
   	set accountId=$system.Encryption.Base32Decode(encriptId,1)
    do ##class(Utils.JsonProvider).%ConvertJSONToObject(%request.Content,"",.clientObj,1)
    
    
    
    set ^a.resttest($h,"buyerTel1")=clientObj.buyerTel
	set ^a.resttest($h,"checkDateTime")=clientObj.checkDateTime
	set ^a.resttest($h,"uuid")=clientObj.uuid
	set ^a.resttest($h,"checkAmount")=clientObj.checkAmount
	set ^a.resttest($h,"bonusAmount")=clientObj.bonusAmount
	set ^a.resttest($h,"payByBonus")=clientObj.payByBonus
	set ^a.resttest($h,"seller")=$ZCONVERT(clientObj.seller,"I","UTF8")
	set ^a.resttest($h,"codeWord")=$ZCONVERT(clientObj.codeWord,"I","UTF8")
	
	set userTel = clientObj.buyerTel
	if ($p(userTel,"(",1)="8") || ($p(userTel,"(",1)="7") || ($p(userTel,"(",1)="") {
		set $p(userTel,"(",1) = "+7"
 	}
 	set userTel = $tr(userTel," ","")
 	set userTel = $tr(userTel,"-","")
 	
 	set checkAmount = $tr(clientObj.checkAmount,",",".")
 	set bonusAmount = $tr(clientObj.bonusAmount,",",".")
 	set payByBonus = $tr(clientObj.payByBonus,",",".")
 	set codeWord = $ZCONVERT(clientObj.codeWord,"I","UTF8")
 	set checkNo = $ZCONVERT(clientObj.checkNo,"I","UTF8")
 	set uuid = clientObj.uuid

	set ^a.resttest($h,"buyerTel2")=userTel
   
   /// 3х ступенчатая система (50%, 30%, 20%)
 	set sc=$$$OK
 	set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel,,.sc,,,accountId)
 	
 	set ^a.resttest($h,"buyerId")=buyerId
 	
 	if (+payByBonus>0) { // списание бонусов
	 	
		&sql(INSERT OR UPDATE into doc.BonusOperation (RubSum,PointsSum,Buyer,ByDocUUID,Shop,CodeWord,DocNo) 
 										values (:checkAmount,-(:payByBonus),:buyerId,:uuid,:accountId,:codeWord,:checkNo))
 
		set ^a.resttest($h,"SQLCODE")=SQLCODE
 		set ^a.resttest($h,"SQLCODE","%msg")= %msg
 		set ^a.resttest($h,"SQLCODE","%ROWCOUNT")=	%ROWCOUNT
 		set ^a.resttest($h,"SQLCODE","%ROWID")=%ROWID
 	
 
 		if SQLCODE=0 {
	 		
	 		set sc = ##class(doc.BonusOperationGoods).updateGoods(accountId,%ROWID,clientObj.goods)
	 		set ^a.resttest($h,"BonusOperationGoods sc")= $System.Status.GetErrorText(sc)
	 		
			/// Отправляем SMS что списали только один раз в одном документе
			if '$data(^smssend(buyerId,uuid)) {
				set ^smssend(buyerId,uuid)=payByBonus
				do ##class(p6.Sms).SendSms(userTel,"Списано бонусов: "_(payByBonus)_". Баланс на www.vapeko.ru") 
			}
 		}	
	} else { // начисление бонусов
 
 		&sql(INSERT OR UPDATE into doc.BonusOperation (RubSum,PointsSum,Buyer,ByDocUUID,Shop,CodeWord,DocNo) 
 				values (:checkAmount,:bonusAmount*.5,:buyerId,:uuid,:accountId,:codeWord,:checkNo))
 		if SQLCODE<0{
 			set ^a.resttest($h,"SQLCODE")=SQLCODE
 			set ^a.resttest($h,"SQLCODE","%msg")= %msg
 		} else {
	 		set sc = ##class(doc.BonusOperationGoods).updateGoods(accountId,%ROWID,clientObj.goods)	
	 		set ^a.resttest($h,"BonusOperationGoods 2 sc")= $System.Status.GetErrorText(sc)
 		}
 		set superBuyerId = ##class(ent.Buyer).SuperBuyerGetStored(buyerId)
 		if superBuyerId]"" {
 			set comment = "от "_userTel
 			&sql(INSERT OR UPDATE into doc.BonusOperation (RubSum,PointsSum,Buyer,ByDocUUID,Comment,Shop) 
 										values (0,:bonusAmount*.3,:superBuyerId,:uuid,:comment,:accountId))
 			set superSuperBuyerId = ##class(ent.Buyer).SuperBuyerGetStored(superBuyerId)
 			if superSuperBuyerId]"" {
 				set comment = "от "_userTel
 				&sql(INSERT OR UPDATE into doc.BonusOperation (RubSum,PointsSum,Buyer,ByDocUUID,Comment,Shop) 
	 				values (0,:bonusAmount*.2,:superSuperBuyerId,:uuid,:comment,:accountId))										
 			}
 		}
 	}
 	
	set result = {}
	set result.data = {}
	if SQLCODE<0 {
		set result.data.status = "ERROR: "_%msg
	} else {
		set result.data.status = "OK"
	}
	write result.%ToJSON()
	
	quit $$$OK
}

ClassMethod PutPoints(encriptId As %String = "", userTel As %String = "", uuid As %String = "", rubSum As %String = "", pointsSum As %String, fromTel As %String = "") As %Status
{
	set ^a.resttest($h,"tel")=userTel
	set ^a.resttest($h,"rubSum")=rubSum
	set ^a.resttest($h,"pointsSum")=pointsSum
	set ^a.resttest($h,"fromTel")=fromTel
	
 set accountId=$system.Encryption.Base32Decode(encriptId,1)	
 
 if '(($e(userTel)="8") || ($e(userTel,1,2)="+7")) {
	set userTel = "+7"_userTel
 }
 if '(($e(fromTel)="8") || ($e(fromTel,1,2)="+7")) {
	set fromTel = "+7"_fromTel
 }
 
 
 /// 3х ступенчатая система (50%, 30%, 20%)
 set sc=$$$OK
 set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel,,.sc,fromTel,,accountId)
 set pointsSum = $tr(pointsSum,",",".")
 
 set ^a.resttest($h,"buyerId")=buyerId
 
 &sql(INSERT OR UPDATE into doc.BonusOperation (RubSum,PointsSum,Buyer,ByDocUUID,Shop) 
 				values (:rubSum,:pointsSum*.5,:buyerId,:uuid,:accountId))
 if SQLCODE<0{
 	set ^a.resttest($h,"SQLCODE")=SQLCODE
 	set ^a.resttest($h,"SQLCODE","%msg")= %msg
 }
 set superBuyerId = ##class(ent.Buyer).SuperBuyerGetStored(buyerId)
 if superBuyerId]"" {
 	set comment = "от "_userTel
 	&sql(INSERT OR UPDATE into doc.BonusOperation (RubSum,PointsSum,Buyer,ByDocUUID,Comment,Shop) 
 										values (0,:pointsSum*.3,:superBuyerId,:uuid,:comment,:accountId))
 	set superSuperBuyerId = ##class(ent.Buyer).SuperBuyerGetStored(superBuyerId)
 	if superSuperBuyerId]"" {
 		set comment = "от "_userTel
 		&sql(INSERT OR UPDATE into doc.BonusOperation (RubSum,PointsSum,Buyer,ByDocUUID,Comment,Shop) 
 				values (0,:pointsSum*.2,:superSuperBuyerId,:uuid,:comment,:accountId))										
 	}
 }

 
 
 if SQLCODE<0 {
	write "{""data"":{"
 	write """userTel"":"""_userTel_""",""rubSum"":"""_rubSum_""",""pointsSum"":"""_pointsSum_""",""status"":""ERROR: "_%msg_""""
  	write "}}"
	 
 } else {
	
 	write "{""data"":{"
 	write """userTel"":"""_userTel_""",""rubSum"":"""_rubSum_""",""pointsSum"":"""_pointsSum_""",""status"":""OK"""
 	write "}}"
 }
 
 quit $$$OK
}

ClassMethod GetBalance(encriptId As %String = "", userTel As %String = "", fromTel As %String = "") As %Status
{
	set ^a.resttest($h,"tel")=userTel
	set ^a.resttest($h,"fromTel")=fromTel
 set accountId=$system.Encryption.Base32Decode(encriptId,1)	
 write "{""data"":"	
 if '(($e(userTel)="8") || ($e(userTel,1,2)="+7")) {
	set userTel = "+7"_userTel
 }
 if '(($e(fromTel)="8") || ($e(fromTel,1,2)="+7")) {
	set fromTel = "+7"_fromTel
 }
 if fromTel="+7null" set fromTel=""
 if (fromTel]"") {
	&sql(select Id into :prentBuyerId from ent.Buyer where Aka[:fromTel and Shop=:accountId)	
	if SQLCODE set prentBuyerId=""
	if prentBuyerId="" {
		write "{""statusFromTel"":""В базе не зарегистрирован 'Кто привлек'""}"
	} else {
		write "{""statusFromTel"":""OK""}"
		
	}
}
	
	set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel,,,,0,accountId)
	set ^a.resttest($h,"buyerId")=buyerId
	set balance = 0
	&sql(select sum(PointsSum) into :balance from doc.BonusOperation where Buyer=:buyerId)
 	if SQLCODE set balance = 0									
	
	set ^a.resttest($h,"balance")=balance
	
	
 write "{""balance"":"_$fnumber(balance,"",2)_ "}}"
 quit $$$OK
}

ClassMethod PayByPoints(encriptId As %String = "", userTel As %String = "", uuid As %String = "", points As %String = "") As %Status
{
	set ^a.resttest($h,"tel")=userTel
	set ^a.resttest($h,"points")=points
 set accountId=$system.Encryption.Base32Decode(encriptId,1)	
 if '(($e(userTel)="8") || ($e(userTel,1,2)="+7")) {
	set userTel = "+7"_userTel
 }
	
	set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel,,,,,accountId)
 	set points = -$tr(points,",",".")
	
	&sql(INSERT OR UPDATE into doc.BonusOperation (RubSum,PointsSum,Buyer,ByDocUUID,Shop) 
 										values (:rubSum,:points,:buyerId,:uuid,:accountId))
 
	set ^a.resttest($h,"SQLCODE")=SQLCODE
 	set ^a.resttest($h,"SQLCODE","%msg")= %msg
 	set ^a.resttest($h,"SQLCODE","%ROWCOUNT")=	%ROWCOUNT
 	set ^a.resttest($h,"SQLCODE","%ROWID")=%ROWID
 	
 
 if SQLCODE<0 {
	write "{""data"":{"
 	write """userTel"":"""_userTel_""",""points"":"""_points_""",""status"":""ERROR: "_%msg_""""
  	write "}}"
	 
 } else {
	/// Отправляем SMS что списали только один раз в одном документе
	if '$data(^smssend(buyerId,uuid)) {
		set ^smssend(buyerId,uuid)=points
		do ##class(p6.Sms).SendSms(userTel,"Списано бонусов: "_(-points)_". Баланс на www.vapeko.ru") 
	}
 	write "{""data"":{"
 	write """userTel"":"""_userTel_""",""points"":"""_points_""",""status"":""OK"""
 	write "}}"
 }	

 quit $$$OK
}

/*
ClassMethod GenCode(userTel As %String = "") As %Status
{
	
 if '(($e(userTel)="8") || ($e(userTel,1,2)="+7")) {
	set userTel = "+7"_userTel
 }
 
 set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel)
 
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
 
	
 //write "{""data"":["

 write "{""status"":""OK""}"
 } else {
	 write "{""status"":""Вас еще нет в нашей базе""}"
 }
 
 //write "]}"
 quit $$$OK
}
*/
ClassMethod CheckCode(encriptId As %String = "", userTel As %String = "") As %Status
{
	set accountId=$system.Encryption.Base32Decode(encriptId,1)	
	
 if '(($e(userTel)="8") || ($e(userTel,1,2)="+7")) {
	set userTel = "+7"_userTel
 }

 set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel,,,,0,accountId)
 
 if buyerId] "" {
	set status = "OK"
 	set balance=0
 	&sql(SELECT sum(PointsSum) into :balance FROM doc.BonusOperation where Buyer = :buyerId)
 	write "{""status"":"""_status_""""
 	write ",""balance"":"""_balance_""""
 } else {
	 set status = "Скорее всего неверный номер"
	 write "{""status"":"""_status_""""
 }
 
  write "}"
 quit $$$OK
}

/* вроде пока не используется
ClassMethod GetOperations(userTel As %String = "") As %Status
{
	
 if '(($e(userTel)="8") || ($e(userTel,1,2)="+7")) {
	set userTel = "+7"_userTel
 }


 
	
 

 write "{""status"":""OK"", ""operations"":"
 
 set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel)
 
 set ^a.temp("buyerId")=buyerId
 set ^a.temp("userTel")=userTel
 
 if buyerId] "" {
 	set sql = "SELECT DocDate, PointsSum, Comment FROM doc.BonusOperation where Buyer = " _buyerId
 		_" order by DocDate desc"
 
 	set ^a.temp("sql")=sql
 	do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,sql,,10)
 }
 
  set balance=0
 &sql(SELECT sum(PointsSum) into :balance FROM doc.BonusOperation where Buyer = :buyerId)
 write ",""balance"":"""_balance_""""
 
  write "}"
 quit $$$OK
}
*/
/// Сохранения объекта
ClassMethod SaveObject(encriptId As %String, className As %String = "") As %Status
{
   set st=$$$OK
   set sc  = $CLASSMETHOD(className, "SaveObject",%request.Content)
   //set sc  = $CLASSMETHOD(className, "SaveTargetObject",%request.Content.Read(),className)
   if $$$ISOK(sc) {
   	write "{""status"":""OK""}"
   } else {
	   
	 write "{""status"":"""_$tr(##class(p6.CspMethods).StatusForAlert(sc),$c(13,10)," ")_"""}"  
   }
    quit st
}

/// Получить объект и передать клиенту
ClassMethod GetObjectByAka(encriptId As %String, className As %String = "", Aka As %String = "") As %Status
{
    set sc=1
	set params("Id")=""
	set ^a.GetObjectByAka("Aka1")=Aka
		set Aka = $tr(Aka,"~","%")
	set ^a.GetObjectByAka("Aka2")=Aka	
		//set Aka = $ZCONVERT(Aka,"I","URL")
	set ^a.GetObjectByAka("Aka3")=Aka	
		set Aka = $ZCONVERT(Aka,"I","UTF8")
		
	set ^a.GetObjectByAka("Aka4")=Aka	
	
		set accountId=$system.Encryption.Base32Decode(encriptId,1)
	set ^a.GetObjectByAka("Id")=accountId
	
		if accountId?.N {
			
	 set ^a.GetObjectByAka("Id2")=accountId		
		
			set sql = "select Id from "_className_" where Aka['"_Aka_"' and Shop="_accountId
			SET tStatement = ##class(%SQL.Statement).%New()
			set qStatus = tStatement.%Prepare(sql)
			SET rset = tStatement.%Execute()
			WHILE rset.%Next() {
				set params("Id")= rset.%GetData(1)
			}
		}
	
	write "{"
	if params("Id")]"" {
		write """result"":"

		do ##class(Utils.JsonProvider).%WriteJSONFromObject("",className,"GetObject",.params)
		
		if $$$ISOK(sc) {
			write ",""status"":""OK"""
		} else {
			write ",""status"":"""_##class(p6.CspMethods).StatusForAlert(sc)_""""  
		}
	} else {
		write """status"":""Не получилось открыть объект"""  
	}
	write "}"
	quit $$$OK
}

/// Получить объект и передать клиенту
ClassMethod GetObjectById(encriptId As %String, className As %String = "", ID As %String = "") As %Status
{
    set sc=1
	set params("Id")=ID
	
	write "{"
	if ID]"" {
		write """result"":"
		
		do ##class(Utils.JsonProvider).%WriteJSONFromObject("",className,"GetObject",.params)
		
		if $$$ISOK(sc) {
			write ",""status"":""OK"""
		} else {
			write ",""status"":"""_##class(p6.CspMethods).StatusForAlert(sc)_""""  
		}
	} else {
		write """status"":""Не получилось открыть объект"""  
	}
	write "}"
	quit $$$OK
}

ClassMethod DeleteObject(encriptId As %String, className As %String = "", ID As %String = "") As %Status
{
	set sc = $CLASSMETHOD(className, "DeleteId",ID)
	write "{"
		if $$$ISOK(sc) {
			write """status"":""OK"""
		} else {
			write """status"":"""_$tr(##class(p6.CspMethods).StatusForAlert(sc),"""","''")_""""  
		}
	write "}"
	quit $$$OK
}

ClassMethod GetAE() As %Status
{
	set result = ""
	set login = $username
	&sql(select Shop->EncriptId,element_key into :result,:role from ent.Shop_Logins 
		where (Logins = :login))
	if SQLCODE set result = ""
	write "{"
	if result ] "" {
		write """result"":"""_ result _ """,""role"":"""_ role _ """,""status"":""OK"""
	} else {
		write """status"":""Скорее всего не верный логин/пароль"""  
	}
	write "}"
	quit $$$OK
}

ClassMethod GetForGridByClassName(encriptId As %String = "", className As %String = "", query As %String = "") As %Status
{
	
	set query = $tr(query,"~","%")
	set query = $ZCONVERT(query,"I","URL")
	set query = $ZCONVERT(query,"I","UTF8")
		
	set accountId=$system.Encryption.Base32Decode(encriptId,1)
	if accountId?.N {
		do $CLASSMETHOD(className, "GetForGrid",query,accountId)
	}
	quit $$$OK
}

ClassMethod GetDashboardData(encriptId) As %Status
{
	set accountId=$system.Encryption.Base32Decode(encriptId,1)
	set result ={}
	$$$QuitOnError(##class(rep.Dashboard).GetData(accountId,.result))
	write result.%ToJSON()
	quit $$$OK
}

ClassMethod GetBonusReport(encriptId, beginDate, endDate) As %Status
{
	set accountId=$system.Encryption.Base32Decode(encriptId,1)
	
	$$$QuitOnError(##class(rep.BonusReport).JsonReport(accountId,$zdh(beginDate,3),$zdh(endDate,3)))
	
	quit $$$OK
}

ClassMethod GetBonusReportDetails(encriptId, onDate) As %Status
{
	set accountId=$system.Encryption.Base32Decode(encriptId,1)
	
	$$$QuitOnError(##class(rep.BonusReport).JsonReportDetails(accountId,onDate))
	
	quit $$$OK
}

/// Отправить сообщение в тех. поддрежку
ClassMethod SendToSupport(encriptId As %String = "") As %Status
{
	
   set sc=$$$OK
   set accountId=$system.Encryption.Base32Decode(encriptId,1)
   
   set (qAka,qComment)=""
   &sql(select Aka,Comment into :qAka,:qComment from ent.Shop where Id=:accountId)
   
    set sendEmail = "vassil@progrepublic.ru"
   	if sendEmail]"" set sendEmail=$LISTFROMSTRING(sendEmail,",")
	else  set sendEmail=""
	
	
	set message = "Контакт: "_qAka_"<br>"_qComment_"<br>"_$ZCONVERT(%request.Content.Read(),"I","UTF8")
	
	/// логируем на всяк случай
	set ^MessageToSupport($H)=message
	
	set sc =##class(admin.Email).SendEmail(sendEmail,message,"BONUS CLUB! СООБЩЕНИЕ В ТЕХПОДДЕРЖКУ !!!")
	
   
   write "{"
   if $$$ISOK(sc) {
   		write """status"":""OK"""
   		
   		write "}"
   } else {
	 	write "{""status"":"""_$tr(##class(p6.CspMethods).StatusForAlert(sc),$c(13,10)," ")_"""}"  
   }
    quit sc
}

ClassMethod SendSms(encriptId As %String = "") As %Status
{
	$$$QuitOnError(..DoSmsVoice(encriptId,"sms"))
	quit $$$OK
}

ClassMethod SendVoice(encriptId As %String = "") As %Status
{
	$$$QuitOnError(..DoSmsVoice(encriptId,"voice"))
	quit $$$OK
}

/// Отправить SMS - сообщение 
/// {
///   "smsCircular": {
///     "text": "Текст сообщения для рассылки",
///     "phones": ["+7(909)8250066", "+7(909)8523150", "+7(909)8554982"]
///   }
/// }
ClassMethod DoSmsVoice(encriptId As %String = "", type = "sms") As %Status
{
	
   set sc=$$$OK
   set accountId=$system.Encryption.Base32Decode(encriptId,1)
   do ##class(Utils.JsonProvider).%ConvertJSONToObject(%request.Content,"",.clientObj,1)
   
      
	set message = $ZCONVERT(clientObj.smsCircular.text,"I","UTF8")
	
	/// логируем на всяк случай
	set ^MessageToSms($H)=message
	
	if type = "voice" {
		set telArray = clientObj.voiceCircular.phones
		set format = "9"
	} else {
		set telArray = clientObj.smsCircular.phones
		set format = "0"
	}
	
	set coutArray=telArray.Count()
	set telString=""
	
   	for i=1:1:coutArray { 
   		set telString = telString_","_telArray.GetAt(i)
   	}
   	set telString=$e(telString,2,*)
	
	set ^a.sms("telString") = telString
	set ^a.sms("message") = message
	set result = "Тестовая заглушка. Телефоны:"_telString_" Сообщение: "_message
	//set result = ##class(p6.Sms).SendSms(telString,message,format)
	
	
   
   write "{"
   write """status"":"""_result_""""
   write "}"
   
    quit sc
}

/// JSON по начислению
/// {"changeBonus":{"ids":["110","122"],"points":10}}
ClassMethod ChangeBonus(encriptId As %String = "") As %Status
{
	set sc=$$$OK
   	set accountId=$system.Encryption.Base32Decode(encriptId,1)
   	do ##class(Utils.JsonProvider).%ConvertJSONToObject(%request.Content,"",.clientObj,1)
    set buyerIdArray = clientObj.changeBonus.ids
    set pountSum = clientObj.changeBonus.points
    set comment = ""
    set countArray=buyerIdArray.Count()
   	for i=1:1:countArray { 
   		set curId = buyerIdArray.GetAt(i)
   		&sql(insert into doc.BonusOperation (PointsSum,Comment,Buyer) Values (:pountSum,:comment,:curId))
   	}  
	
	quit $$$OK
}

/// JSON по начислению
/// {"onDate":"12.12.2017","bonusSum":"200","comment":"По акции","buyerId":"146"}
ClassMethod DoPlusBonus(encriptId As %String = "") As %Status
{
	set sc=$$$OK
   	set accountId=$system.Encryption.Base32Decode(encriptId,1)
   	do ##class(Utils.JsonProvider).%ConvertJSONToObject(%request.Content,"",.clientObj,1)
    set buyerId = clientObj.buyerId
    set pountSum = clientObj.bonusSum
    set comment = $zconvert(clientObj.comment,"I","UTF8")
    set onDate = ##class(p6.Date).DisplayToLogical(clientObj.onDate)
    if onDate="" set onDate = +$H
   	&sql(insert into doc.BonusOperation (PointsSum,Comment,Buyer,DocDate) Values (:pountSum,:comment,:buyerId,:onDate))
   	
   	
   write "{"
   if SQLCODE=0 {
   		write """status"":""OK"""
   		
   		write "}"
   } else {
	 	write "{""status"":"""_$tr(%msg,$c(13,10)," ")_"""}"  
   }
    quit sc  
	
	quit $$$OK
}

ClassMethod PutPointsVAPEKO(userTel As %String = "", uuid As %String = "", rubSum As %String = "", pointsSum As %String, fromTel As %String = "") As %Status
{
	set ^a.resttest($h,"tel")=userTel
	set ^a.resttest($h,"rubSum")=rubSum
	set ^a.resttest($h,"pointsSum")=pointsSum
	set ^a.resttest($h,"fromTel")=fromTel
	
	
 //&sql(delete from doc.BonusOperation where ByDocUUID=:uuid)	
 
 if '(($e(userTel)="8") || ($e(userTel,1,2)="+7")) {
	set userTel = "+7"_userTel
 }
 if '(($e(fromTel)="8") || ($e(fromTel,1,2)="+7")) {
	set fromTel = "+7"_fromTel
 }
 
 
 /// 3х ступенчатая система (50%, 30%, 20%)
 set sc=$$$OK
 set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel,,.sc,fromTel,,1)
 set pointsSum = $tr(pointsSum,",",".")
 
 set ^a.resttest($h,"buyerId")=buyerId
 
 &sql(INSERT OR UPDATE into doc.BonusOperation (RubSum,PointsSum,Buyer,ByDocUUID,Shop) 
 				values (:rubSum,:pointsSum*.5,:buyerId,:uuid,1))
 if SQLCODE<0{
 	set ^a.resttest($h,"SQLCODE")=SQLCODE
 	set ^a.resttest($h,"SQLCODE","%msg")= %msg
 }
 set superBuyerId = ##class(ent.Buyer).SuperBuyerGetStored(buyerId)
 if superBuyerId]"" {
 	set comment = "от "_userTel
 	&sql(INSERT OR UPDATE into doc.BonusOperation (RubSum,PointsSum,Buyer,ByDocUUID,Comment,Shop) 
 										values (0,:pointsSum*.3,:superBuyerId,:uuid,:comment,1))
 	set superSuperBuyerId = ##class(ent.Buyer).SuperBuyerGetStored(superBuyerId)
 	if superSuperBuyerId]"" {
 		set comment = "от "_userTel
 		&sql(INSERT OR UPDATE into doc.BonusOperation (RubSum,PointsSum,Buyer,ByDocUUID,Comment,Shop) 
 				values (0,:pointsSum*.2,:superSuperBuyerId,:uuid,:comment,1))										
 	}
 }

 
 
 if SQLCODE<0 {
	write "{""data"":{"
 	write """userTel"":"""_userTel_""",""rubSum"":"""_rubSum_""",""pointsSum"":"""_pointsSum_""",""status"":""ERROR: "_%msg_""""
  	write "}}"
	 
 } else {
	
 	write "{""data"":{"
 	write """userTel"":"""_userTel_""",""rubSum"":"""_rubSum_""",""pointsSum"":"""_pointsSum_""",""status"":""OK"""
 	write "}}"
 }
 
 quit $$$OK
}

ClassMethod GetBalanceVAPEKO(userTel As %String = "", fromTel As %String = "") As %Status
{
	set ^a.resttest($h,"tel")=userTel
	set ^a.resttest($h,"fromTel")=fromTel
 
 	write "{""data"":"	
 	if '(($e(userTel)="8") || ($e(userTel,1,2)="+7")) {
		set userTel = "+7"_userTel
 	}
 	if '(($e(fromTel)="8") || ($e(fromTel,1,2)="+7")) {
		set fromTel = "+7"_fromTel
 	}
 	if fromTel="+7null" set fromTel=""
 	if (fromTel]"") {
		&sql(select Id into :prentBuyerId from ent.Buyer where Aka[:fromTel and Shop=1)	
		if SQLCODE set prentBuyerId=""
		if prentBuyerId="" {
			write "{""statusFromTel"":""В базе не зарегистрирован 'Кто привлек'""}"
		} else {
		write "{""statusFromTel"":""OK""}"
		
		}
	}
	
	set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel,,,,0,1)
	set ^a.resttest($h,"buyerId")=buyerId
	set balance = 0
	&sql(select sum(PointsSum) into :balance from doc.BonusOperation where Buyer=:buyerId)
 	if SQLCODE set balance = 0									
	
	set ^a.resttest($h,"balance")=balance
	
	
 write "{""balance"":"_$fnumber(balance,"",2)_ "}}"
 quit $$$OK
}

ClassMethod PayByPointsVAPEKO(userTel As %String = "", uuid As %String = "", points As %String = "") As %Status
{
	set ^a.resttest($h,"tel")=userTel
	set ^a.resttest($h,"points")=points
	
 if '(($e(userTel)="8") || ($e(userTel,1,2)="+7")) {
	set userTel = "+7"_userTel
 }
	
	set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel,,,,,1)
 	set points = -$tr(points,",",".")
	
	&sql(INSERT OR UPDATE into doc.BonusOperation (RubSum,PointsSum,Buyer,ByDocUUID,Shop) 
 										values (:rubSum,:points,:buyerId,:uuid,1))
 
	set ^a.resttest($h,"SQLCODE")=SQLCODE
 	set ^a.resttest($h,"SQLCODE","%msg")= %msg
 	set ^a.resttest($h,"SQLCODE","%ROWCOUNT")=	%ROWCOUNT
 	set ^a.resttest($h,"SQLCODE","%ROWID")=%ROWID
 	
 
 if SQLCODE<0 {
	write "{""data"":{"
 	write """userTel"":"""_userTel_""",""points"":"""_points_""",""status"":""ERROR: "_%msg_""""
  	write "}}"
	 
 } else {
	/// Отправляем SMS что списали только один раз в одном документе
	if '$data(^smssend(buyerId,uuid)) {
		set ^smssend(buyerId,uuid)=points
		do ##class(p6.Sms).SendSms(userTel,"Списано бонусов: "_(-points)_". Баланс на www.vapeko.ru") 
	}
 	write "{""data"":{"
 	write """userTel"":"""_userTel_""",""points"":"""_points_""",""status"":""OK"""
 	write "}}"
 }	

 quit $$$OK
}

ClassMethod CheckCodeVAPEKO(userTel As %String = "") As %Status
{
	
 if '(($e(userTel)="8") || ($e(userTel,1,2)="+7")) {
	set userTel = "+7"_userTel
 }

 set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel,,,,0,1)
 

 if buyerId] "" {
	set status = "OK"
 	set balance=0
 	&sql(SELECT sum(PointsSum) into :balance FROM doc.BonusOperation where Buyer = :buyerId)
 	write "{""status"":"""_status_""""
 	write ",""balance"":"""_balance_""""
 } else {
	 set status = "Скорее всего неверный номер"
	 write "{""status"":"""_status_""""
 }
 
  write "}"
 quit $$$OK
}

/// Получение информации по номеру телефона
ClassMethod GetInfo(encriptId, userTel As %String = "") As %Status
{
	
 if ($p(userTel,"(",1)="8") || ($p(userTel,"(",1)="7") || ($p(userTel,"(",1)="") {
	set $p(userTel,"(",1) = "+7"
 }
 set accountId=$system.Encryption.Base32Decode(encriptId,1)
 set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel,,,,0,accountId)
 
 set result={}
 if buyerId] "" {
 	&sql(select Name,BirthDate,Sex,SuperBuyer->Aka,Comment 
 		into :qName,:qBirthDate,:qSex,:qSuperBuyerAka,:qComment from ent.Buyer where Id=:buyerId)
 	set result.profile={}	
 	set result.profile.name=qName
 	set:qBirthDate]"" result.profile.birthDate=$zd(qBirthDate,3)
 	set result.profile.sex=qSex
 	set:qSuperBuyerAka]"" $p(qSuperBuyerAka,"(",1) = "7"
 	set result.profile.fromSomeone=qSuperBuyerAka
 	set result.profile.comment = qComment
 	
	set result.status = "OK"
 	set balance=0
 	&sql(SELECT sum(PointsSum) into :balance FROM doc.BonusOperation where Buyer = :buyerId)
 	set sc=##class(rep.BuyerInfo).GetHtml(accountId, buyerId, .infoResult)
 	if $$$ISERR(sc) {
	 	set infoResult=$System.Status.GetErrorText(sc)
 	}
 	set result.info = infoResult
 	
 } else {
	 set result.status = "Скорее всего неверный номер"
	 
 }
 
  write result.%ToJSON()
 quit $$$OK
}

/// Записать анкету
ClassMethod SaveProfile(encriptId, userTel As %String = "") As %Status
{
	
 if ($p(userTel,"(",1)="8") || ($p(userTel,"(",1)="7") || ($p(userTel,"(",1)="") {
	set $p(userTel,"(",1) = "+7"
 }
 set userTel = $tr(userTel," ","")
 set userTel = $tr(userTel,"-","")
 
 set accountId=$system.Encryption.Base32Decode(encriptId,1)
 do ##class(Utils.JsonProvider).%ConvertJSONToObject(%request.Content,"",.clientObj,1)
 
 set result={}
 
 
 
 set profile = clientObj.profile
 if (profile.fromSomeone]"") {
 	set superBuyerId = ##class(ent.Buyer).GetBuyerIdByAka(profile.fromSomeone,,,,0,accountId)
 	if superBuyerId="" {
		 set result.status = "Кто привлек нет номера в базе!"
	 	write result.%ToJSON()
 		quit $$$OK
 	}
 }
 if profile.birthDate]"" {
 	set bdate = $zdh(profile.birthDate,3)
 } else {
	set bdate = ""
 }
 set name = $ZCONVERT(profile.name,"I","UTF8")
 set sex = $ZCONVERT(profile.sex,"I","UTF8")
 set comment = $ZCONVERT(profile.comment,"I","UTF8")
 
 

 &sql(insert or update into ent.Buyer(Aka,Name,BirthDate,Sex,Comment,Shop,SuperBuyer) 
 	values(:userTel,:name,:bdate,:sex,:comment,:accountId,:superBuyerId))
 
 IF SQLCODE = 0 {
		set result.status = "OK"
 } else {
	 set result.status = %msg
 }
 
 write result.%ToJSON()
 quit $$$OK
}

}

