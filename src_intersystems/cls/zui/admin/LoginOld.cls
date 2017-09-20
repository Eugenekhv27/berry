/// Created using the page template: Default
Class zui.admin.LoginOld Extends p6.zen.Page
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "zui.Application";

/// Displayed name of this page.
Parameter PAGENAME = "Вход в систему";

/// Domain used for localization.
Parameter DOMAIN = "DTK";

Property isFinishSession As %ZEN.Datatype.string(ZENURL = "IsFinishSession");

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">

.box {
	background-color: #194b8c;
	border: 1px solid #07346f;
	padding:0.4em;
}

.errorMsg {
	color:red;
	font-weight:bold;
	font: 0.8em;
}
</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="Система">

<vgroup align="center" enclosingStyle="width:100%;" height="100%" valign="middle">
   <form id="loginForm" nextPage="zui.Menu.cls" enclosingClass="box" >
   <!--
	<html align="center" containerStyle="font-weight:bold; color: white" OnDrawContent="DrawOrgName" />
    <spacer height="1em" containerStyle="border-bottom:3px solid;" />
    
    <spacer height="1em" />
    -->
    <text id="Login" name="Login" labelStyle="font-weight:bold; color: white;" label="Имя пользователя:" />
    <password id="Password" name="Password" labelStyle="font-weight:bold; color: white;" label="Пароль:" />
    <!-- 
    	<spacer height="1em" containerStyle="border-bottom:3px solid;" />
    -->
    	<spacer height="1em" />
    
    <submit id="btLogin" controlStyle=" font-weight:bold;" caption="Вход" align="center" />
    <!-- <spacer height="1em" />
	<html align="center" containerStyle="color: white">(С) Димас 2010</html>
	-->
  </form>
  <html id="warning"><p id="msg" align="right" style="color:red;">Отключение через  30 секунд</p></html>
</vgroup>
</page>
}

Method DrawOrgName(seed) As %Status
{
	//write ##class(admin.AppSet).GetCurrent().OrgName
	w "Перевозки"
	quit $$$OK
}

Method %OnAfterCreatePage() As %Status
{
	if ..isFinishSession $$$QuitOnError(..DoFinishSession())
	Do ##super()
	Quit $$$OK
}

/// Вход в систему
ClassMethod %OnSubmit(ASubmit As %ZEN.Submit) As %Status [ PublicList = Session ]
{
	
	set userSys = ##class(admin.UserSys).GetLoggedInUser(ASubmit.%GetValue("Login"),ASubmit.%GetValue("Password"))
 	/*
 	if ($IsObject(userSys)) {
	 	
	 	if (('userSys.IsReservedLicense) &&
	 		($System.License.LUAvailable() < ##class(admin.UserSys).GetReservedLicensesNumber())) {
				set ASubmit.%NextPage = "zui.admin.RejectedConnection.cls" 
				quit $$$OK
 			}
 	}
 	*/
	set sc=##class(admin.Session).Login(ASubmit.%GetValue("Login"),ASubmit.%GetValue("Password"),%request.CgiEnvs("REMOTE_ADDR"))
	if 'sc do ASubmit.%SetError("Login",##class(p6.CspMethods).StatusForAlert(sc))
	quit $$$OK
}

ClassMethod DoFinishSession() As %Status [ ZenMethod ]
{
	$$$QuitOnError(##class(admin.Session).Finish())
	set %response.Redirect=%request.Application_"p6/logout.html"
	quit $$$OK
}

/// This callback is called at the start of the HTML BODY section of the page.<br>
/// (default implementation is a simple expression).
Method %OnDrawHTMLBody() As %Status
{
	// &html<<img style="z-index:-1; position:absolute; top:0; left:0; width:100%; height:100%;" src="/csp/dtk/p6/images/DTK_main_page.jpg" />>
	 &html<<img style="z-index:-1; position:absolute; top:0; left:0; width:100%; height:100%;" src="/csp/dtk/p6/images/bgLoginGrad.gif" />>
	quit $$$OK
}

/// This client event, if present, is fired when the page is loaded.
ClientMethod onloadHandler() [ Language = javascript ]
{
	try {
		zenPage.timerCount = 30;
		zenPage.timerHandler = setInterval(function(){zenPage.updateTimer()},1000);
		//g_init();
		//g_createStore();
	} catch(e) {};
	return SetFocusOnFirstControl();
}

ClassMethod %OnBeforeCreatePage() As %Status [ PublicList = Session ]
{
	if $data(%session.Data("SessionId")) {
		$$$QuitOnError(##class(admin.Session).Finish())
	}
	
	if ($System.License.LUAvailable() = 0)	{
		set %response.Redirect = "zui.admin.RejectedConnection.cls"
	}
		
	quit $$$OK
}

ClientMethod updateTimer() [ Language = javascript ]
{
	zenPage.timerCount-=1;
	
	if( zenPage.timerCount == 0 )
	{
		clearInterval( zenPage.timerHandler );
		window.location = "zui.admin.RejectedConnection.cls?PageName=logout.html";
	}
	else 
		document.getElementById("msg").innerHTML = "Отключение через "+zenPage.timerCount+" секунд";
}

ClientMethod onunloadHandler() [ Language = javascript ]
{
	zenPage.CloseSession();
	//window.location = "zui.admin.RejectedConnection.cls?PageName=logout.html";
}

Method CloseSession() As %String [ ZenMethod ]
{
	set %session.EndSession = 1
	quit %request.Application_"p6/logout.html"
}

}

