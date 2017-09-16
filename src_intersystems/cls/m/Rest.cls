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
<Route Url="/putPoints/:userTel/:uuid/:rubSum/:pointsSum/:fromTel" Method="GET" Call="PutPoints"/>
<Route Url="/getBalance/:userTel/:fromTel" Method="GET" Call="GetBalance"/>
<Route Url="/payByPoints/:userTel/:uuid/:points" Method="GET" Call="PayByPoints"/>
<Route Url="/checkCode/:userTel" Method="GET" Call="CheckCode"/>
<Route Url="/getOperations/:userTel" Method="GET" Call="GetOperations"/>
<Route Url="/genCode/:userTel" Method="GET" Call="GenCode"/>

<Route Method="POST" Url="/:encriptId/save/:className" Call="SaveObject" /> 
<Route Method="GET" Url="/:encriptId/getObject/:className/:ID" Call="GetObjectById" /> 
<Route Method="GET" Url="/:encriptId/getObjectByAka/:className/:Aka" Call="GetObjectByAka" /> 
<Route Method="DELETE" Url="/:encriptId/delObject/:className/:ID" Call="DeleteObject" /> 

<Route Method="GET" Url="/getAE" Call="GetAE" /> 
<Route Method="GET" Url="/:encriptId/grid/:className/" Call="GetForGridByClassName" />

<!-- сервис для DashBoard -->
<Route Method="GET" Url="/:encriptId/dashboard" Call="GetDashboardData" />

</Routes>
}

ClassMethod PutPoints(userTel As %String = "", uuid As %String = "", rubSum As %String = "", pointsSum As %String, fromTel As %String = "") As %Status
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
 set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel,,.sc,fromTel)
 set pointsSum = $tr(pointsSum,",",".")
 
 set ^a.resttest($h,"buyerId")=buyerId
 
 &sql(INSERT OR UPDATE into doc.BonusOperation (RubSum,PointsSum,Buyer,ByDocUUID) 
 				values (:rubSum,:pointsSum*.5,:buyerId,:uuid))
 if SQLCODE<0{
 	set ^a.resttest($h,"SQLCODE")=SQLCODE
 	set ^a.resttest($h,"SQLCODE","%msg")= %msg
 }
 set superBuyerId = ##class(ent.Buyer).SuperBuyerGetStored(buyerId)
 if superBuyerId]"" {
 	set comment = "от "_userTel
 	&sql(INSERT OR UPDATE into doc.BonusOperation (RubSum,PointsSum,Buyer,ByDocUUID,Comment) 
 										values (0,:pointsSum*.3,:superBuyerId,:uuid,:comment))
 	set superSuperBuyerId = ##class(ent.Buyer).SuperBuyerGetStored(superBuyerId)
 	if superSuperBuyerId]"" {
 		set comment = "от "_userTel
 		&sql(INSERT OR UPDATE into doc.BonusOperation (RubSum,PointsSum,Buyer,ByDocUUID,Comment) 
 				values (0,:pointsSum*.2,:superSuperBuyerId,:uuid,:comment))										
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

ClassMethod GetBalance(userTel As %String = "", fromTel As %String = "") As %Status
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
	&sql(select Id into :prentBuyerId from ent.Buyer where Aka[:fromTel)	
	if SQLCODE set prentBuyerId=""
	if prentBuyerId="" {
		write "{""statusFromTel"":""В базе не зарегистрирован 'Кто привлек'""}"
	} else {
		write "{""statusFromTel"":""OK""}"
		
	}
}
	
	set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel,,,,0)
	set ^a.resttest($h,"buyerId")=buyerId
	set balance = 0
	&sql(select sum(PointsSum) into :balance from doc.BonusOperation where Buyer=:buyerId)
 	if SQLCODE set balance = 0									
	
	set ^a.resttest($h,"balance")=balance
	
	
 write "{""balance"":"_$fnumber(balance,"",2)_ "}}"
 quit $$$OK
}

ClassMethod PayByPoints(userTel As %String = "", uuid As %String = "", points As %String = "") As %Status
{
	set ^a.resttest($h,"tel")=userTel
	set ^a.resttest($h,"points")=points
	
 if '(($e(userTel)="8") || ($e(userTel,1,2)="+7")) {
	set userTel = "+7"_userTel
 }
	
	set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel)
 	set points = -$tr(points,",",".")
	
	&sql(INSERT OR UPDATE into doc.BonusOperation (RubSum,PointsSum,Buyer,ByDocUUID) 
 										values (:rubSum,:points,:buyerId,:uuid))
 
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

ClassMethod CheckCode(userTel As %String = "") As %Status
{
	kill ^a.temp
	
 if '(($e(userTel)="8") || ($e(userTel,1,2)="+7")) {
	set userTel = "+7"_userTel
 }

 //if ($get(^smscode(userTel,"code"))=code) {
	 
 //} else {
	// set status = "Неверный код"
 // }	
 
	
 // write "{""data"":["

 
 
 set buyerId = ##class(ent.Buyer).GetBuyerIdByAka(userTel,,,,0)
 
 set ^a.temp("buyerId")=buyerId
 set ^a.temp("userTel")=userTel
 
 /*
 if buyerId] "" {
 	set sql = "SELECT DocDate, PointsSum, Comment FROM doc.BonusOperation where Buyer = " _buyerId
 		_" order by DocDate desc"
 
 	set ^a.temp("sql")=sql
 	do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,sql,,10)
 }
 */
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

		do ##class(Util.JsonProvider).%WriteJSONFromObject("",className,"GetObject",.params)
		
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
		
		do ##class(Util.JsonProvider).%WriteJSONFromObject("",className,"GetObject",.params)
		
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

/*



	
  write "{""data"":["
  set accountId=$system.Encryption.Base32Decode(userCode,1)
  
  // s BinaryText=$ZCONVERT(UnicodeText,"O","UTF8")
  set res = ""
  for i=1:1:$Length(searchString) {
	  if '((i\2*2)=i) {
	  	set res = res_"%"
	  }
	  set res = res_$e(searchString,i)
  }
  set res2= $zconvert(res,"I","URL")
  set res2= $ZCONVERT(res2,"I","UTF8")
  
	
  SET myquery = 2
  SET myquery(1) = " select top 15 JSON_OBJECT('value':ReversFullName) from ent.Station"
  SET myquery(2) = " where (UserAccount = "_accountId_") and (ReversFullName LIKE '%"_res2_"%')"
  SET tStatement = ##class(%SQL.Statement).%New()
  SET qStatus = tStatement.%Prepare(.myquery)
    IF qStatus'=1 { WRITE "%Prepare failed",$System.Status.DisplayError(qStatus) QUIT}
  SET rset = tStatement.%Execute()
  set i=1
  WHILE rset.%Next() {
	  write:i>1 ","
	  DO rset.%Print(" ^ ")
	  set i=i+1
  }
  
  write "]}"
 */
}

