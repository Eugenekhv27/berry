Include %occErrors

/// This is the default CSP error page. When writing any error pages you should make this your superclass.
/// If an error occurs while running a hyperevent then the response is controled from the <METHOD>HyperEventError</METHOD>.
/// If it is an error on a standard page then you writing normal HTML output.<p>
/// This error information is designed to make debugging an application easier, if you deploy a CSP application
/// then you should define your own error page that logs the information needed on the server and displays an
/// error message suitable for an end user rather than providing them with a lot of debug information.<p>
/// Two particularly interesting errors are the session timeout and the decryption failure errors are both
/// of these can be the result of attempting to go to a page when the users session has timed out or been ended.
/// Commonly you would redirect them to the login page so they can re-enter the application for example in OnPreHTTP
/// method you can write:
/// <EXAMPLE>
/// New errorcode
/// Set errorcode=%request.Get("Error:ErrorNumber")
/// If errorcode=$$$CSPSessionTimeout!(errorcode=$$$InvalidDecrypt) Do  Quit 1
/// . Set %response.Redirect="/application/login.csp"
/// </EXAMPLE>
/// When an error occurs several variables are set in the %request object because these may be overwritten in
/// generating the error page itself. These variables are all prefixed by 'Error:' and the list is:
/// <ul>
/// <li><b>Error:ErrorCode</b> - The <class>%Status</class> code for this error</li>
/// <li><b>Error:ErrorNumber</b> - The error number assocaited with the ErrorCode</li>
/// <li><b>Error:Namespace</b> - The namespace the page was running in when the error occurred</li>
/// <li><b>Error:URL</b> - The URL of the page in which the error occurred.</li>
/// <li><b>Error:PageName</b> - The name of the page in which the error occurred.</li>
/// <li><b>Error:ResponseContentType</b> - The %response.ContentType at the time of the error.</li>
/// <li><b>Error:ResponseStatus</b> - The %response.Status at the time of the error.</li>
/// </ul>
/// The error page will automatically set the %response.Status for some of the standard errors, such as
/// not being able to find the CSP page . If you wish to override this setting do so in the OnPreHTTP
/// method.
Class admin.Error Extends %CSP.Error [ ClassType = "", Not ProcedureBlock, System = 3 ]
{

/// If an error occurs while processing a HyperEvent then this method is called.
/// This method will write out javascript code that will be executed on the browser.
/// Note that the variable 'CSPPage' refers to the 'self' of the page on which the
/// Hyperevent was called  as this may be different to the current 'self'.<p>
/// You could use this javascript to redirect the browser to another page:
/// <EXAMPLE>
/// Write "CSPPage.window.location='/csp/samples/menu.csp';",!
/// </EXAMPLE>
/// Or you could popup an alert box with the error message in it:
/// <EXAMPLE>
/// Write "alert('An error occurred');",!
/// </EXAMPLE>
ClassMethod HyperEventError()
{
	New ErrorInfo,message,i,j
	Do ..DecomposeError(%request.Get("Error:ErrorCode"),.ErrorInfo)
	Set message=..GetErrorString(.ErrorInfo)
	Write "alert(",$ZCVT(..QuoteJS(message),"O","UTF8"),");",!

	set $ztrap="LogMeHyper"
	set $ECode=message
LogMeHyper	set $ZError=$get(ErrorInfo(1,"Error"),$$$GetSimpleMessage("%CSP","ErrorZE"))
	do BACK^%ETN
}

ClassMethod OnPreHTTP() As %Boolean
{
	set %session.Preserve=1
	quit 1
}

/// Output the error page as HTML. This makes use of the ##class(%CSP.Utils).DisplayAllObjects()
/// call to display as much information as possible about the state of the %request, %response, %server
/// objects when the error occurred.
ClassMethod OnPage() As %Status
{
	New ErrorInfo,errorString,sessionString,message
	Do ..DecomposeError(%request.Get("Error:ErrorCode"),.ErrorInfo)
	set errorString=..GetErrorString(.ErrorInfo)
	//set sessionString=..GetSessionString()

	set message=errorString_sessionString
	set $ztrap="LogMe"
	set $ECode=message
LogMe	set $ZError=$get(ErrorInfo(1,"Error"),$$$GetSimpleMessage("%CSP","ErrorZE"))
	do BACK^%ETN
	set $ztrap="OnPageErr"
	&html<
	<html>
	<head>
	<title> Ошибка </title>
	</head>
	<body bgcolor=#CCCCFF>
	<table bgcolor=#000088 cols=2 width=100% border=1 cellpadding=3>
	<tr>
	<td width=50%>
	<nobr><font face="Verdana,Arial,Helvetica,sans-serif" color=white size="+3">
	<b>Системная ошибка #($znspace)#</b>
	</font></nobr>
	</td>
	</tr>
	</table>
	<br>>

	&html<<font face="Verdana,Arial,Helvetica,sans-serif" color=#FF0000><pre>>
	set errorString=..GetErrorString(.ErrorInfo)
	Write ..EscapeHTML(errorString)
	Write "</pre></font>",!

	&html<<font face="Verdana,Arial,Helvetica,sans-serif" color=#0000FF><pre>>
	//set sessionString=..GetSessionString()
	Write ..EscapeHTML(sessionString)
	Write "</pre></font>",!

	Write "<br>",!

	&html<<table bgcolor=#000088 cols=2 width=100% border=1 cellpadding=3>
	<tr>
	<td width=50%>
	<nobr><font face="Verdana,Arial,Helvetica,sans-serif" color=white size="+3">
	<b>Сообщите об ошибке</b>
	</font></nobr>
	</td>
	</tr>
	</table>
	<br>
	Помимо предоставленной выше информации сообщите, пожалуйста, следующее:
	<ul><li> В каком режиме произошла ошибка
	<li> Какие действия нужно выполнить для воспроизведения ошибки
	<li> Любую другую информацию, имеющую отношение к ошибке
	</ul>
	
	>

	&html<</body>
	</html>>
	Quit $$$OK
OnPageErr
	set $zt=""
	quit $$$OK
}

ClassMethod GetErrorString(ByRef ErrorInfo As %String) As %String
{
 New i,s
 set s=""
 For i=1:1:ErrorInfo Do
 . set s=s_..EscapeHTML(ErrorInfo(i,"Desc"))_$C(13,10)
 . If ErrorInfo(i,"ErrorNo")=$$$FailedToCreateClass Do
 . . set s=s_"Ошибки компиляции:"
 . . New j
 . . Set j="" For  Set j=$O(ErrorInfo(i,"Error",j)) Quit:j=""  Do
 . . . set s=s_"Программа: "_ErrorInfo(i,"Error",j,"Routine")_$C(13,10)
 . . . set s=s_"Смещение: "_ErrorInfo(i,"Error",j,"Offset")_$C(13,10)
 . . . set s=s_"Ошибка: "_(ErrorInfo(i,"Error",j,"Error"))_$C(13,10)
 . . . set s=s_"Описание: "_(ErrorInfo(i,"Error",j,"Desc"))_$C(13,10)
 . . . set s=s_"Строка: "_(ErrorInfo(i,"Error",j,"Line"))_$C(13,10)
 . Else  Do
 . . set s=s_"Ошибка: "_(ErrorInfo(i,"Error"))_$C(13,10)
 . . set s=s_$C(13,10)
 . set s=s_"Номер: "_ErrorInfo(i,"ErrorNo")_$C(13,10)
 . set s=s_"Страница CSP: "_(ErrorInfo(i,"URL"))_$C(13,10)
 . set s=s_"Область: "_(ErrorInfo(i,"Namespace"))_$C(13,10)
 . set s=s_"Класс: "_(ErrorInfo(i,"Class"))_$C(13,10)
 . If $G(ErrorInfo(i,"Routine"))'="" Do
 . . set s=s_"Программа: "_(ErrorInfo(i,"Routine"))_$C(13,10)
 . . set s=s_"Положение: "_(ErrorInfo(i,"Location"))_$C(13,10)
 . . If $G(ErrorInfo(i,"Line"))'="" set s=s_"Строка: "_(ErrorInfo(i,"Line"))_$C(13,10)
 Quit s
}

/*
ClassMethod GetSessionString() As %String
{
 new s set s=""
 set s="Версия: "_##class(admin.Version).GetVersionToString()_$C(13,10)
 if $get(Session)=$$$NULLOREF quit s_"Информация о пользователе недоступна"
 if Session.UserSys'=$$$NULLOREF {
	 set s=s_"Пользователь: "_Session.UserSys.Aka_$C(13,10)
 }
 set s=s_"Начал работать: "_Session.DtStart_$C(13,10)
 quit s
}
*/
}

