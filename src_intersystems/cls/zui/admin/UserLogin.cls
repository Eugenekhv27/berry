/// Created using the page template: Default
Class zui.admin.UserLogin Extends %ZEN.Component.page
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "zui.Application";

/// Displayed name of this page.
Parameter PAGENAME = "Вход в систему";

/// Domain used for localization.
Parameter DOMAIN = "DTK";

Property NameSpace As %ZEN.Datatype.string [ InitialExpression = {$NAMESPACE} ];

/// Current control when event is triggerd
Property currControl As %ZEN.Datatype.string;

/// Comma-separated list of additional JS include files for the page.
Parameter JSINCLUDES As STRING = "jquery-1.8.3.min.js,jquery.maskedinput.min.js";

Parameter CSSINCLUDES = "main_style.css";

Property UserNameIsExists(ZENURL = "UserNameIsExists") [ InitialExpression = 0 ];

Property UserLogin(ZENURL = "Login");

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
<page xmlns="http://www.intersystems.com/zen" xmlns:p6="http://www.dimas.ru/p6" title="Система" align="center">

<vgroup align="center" enclosingStyle="width:100%;" height="100%" valign="middle">

    <loginForm id="loginForm" align="center" valign="middle" enclosingClass="box"   >
    <text id="cacheUserNameText" name="CacheUserName" label="Введите номер телефона:" onfocus="zenPage.currControl=zenThis.id;"/>
    <password id="CachePasswordCtrl" hidden="false" name="CachePassword" labelStyle="font-weight:bold; color: white;" label="Пароль:" align="center" onfocus="zenPage.currControl=zenThis.id;" />
    <spacer height="1em" />
  
	<button onclick="zenPage.Login();" caption="ВОЙТИ" controlStyle=" font-weight:bold;"  align="center"/>
	<spacer height="1em" />
	<button onclick="zenPage.Registration();" caption="Зарегистрироваться" controlStyle=" font-weight:bold;"  align="center"/>

  </loginForm>
  <html condition='%page.UserNameIsExists'>Данный номер телефона уже зарегистрирован. Введите пароль.</html>
</vgroup>

</page>
}

// по нажатию на enter - вход в систему

/// This client event, if present, is fired when a keydown event occurs on the page.
ClientMethod onkeydownHandler(event) [ Language = javascript ]
{
	
		if (this.currControl=="") return;
        var ctrl = this.getComponentById(this.currControl);
        switch(ctrl.id) {
        	case 'cacheUserNameText':
                // set background of the enclosing div of the page
                var isSingleKey = !((event.ctrlKey) || (event.shiftKey) || (event.altKey));
                if ((event.keyCode == 13) && isSingleKey) {
	                zen("CachePasswordCtrl").setProperty("hidden",false);
	                document.all.CachePassword.focus();
	                return false;
  				}
                break
            case 'CachePasswordCtrl':
            	var isSingleKey = !((event.ctrlKey) || (event.shiftKey) || (event.altKey));
  				if ((event.keyCode == 13) && isSingleKey) {
	  	   			zenPage.Login();
  				}          	
  				break    
        }
}

ClientMethod Login() [ Language = javascript ]
{
	if (this.currControl=="") return;
    var ctrl = this.getComponentById(this.currControl);
    switch(ctrl.id) {
        	case 'cacheUserNameText':
	            	document.all.CachePassword.focus();
	            	return false;
  				
                break
            case 'CachePasswordCtrl':
      			zenPage.getComponentById("loginForm").submit();      	
  				break    
        }
}

ClientMethod Registration() [ Language = javascript ]
{
	window.location="zui.admin.UserRegistration.cls?CacheUserName=webguest&CachePassword=webguest";
}

/// This callback is called at the start of the HTML BODY section of the page.<br>
/// (default implementation is a simple expression).
Method %OnDrawHTMLBody() As %Status
{
	
	// &html<<img style="z-index:-1; position:absolute; top:0; left:0; width:100%; height:100%;" src="/csp/dtk/p6/images/DTK_main_page.jpg" />>
	 &html<<img style="z-index:-1; position:absolute; top:0; left:0; width:100%; height:100%;" src="/csp/#($NAMESPACE)#/p6/images/bgLoginGrad.gif" />>
	quit $$$OK
}

ClassMethod %OnBeforeCreatePage() As %Status
{
	
	//set ^a.user($H)=$UserName
	if '(($UserName="UnknownUser")||($UserName="webguest")||($UserName="CSPSystem")) {
		set %response.Redirect="zui.Menu.cls"
	}
	Quit $$$OK
}

/// This client event, if present, is fired when the page is loaded.
ClientMethod onloadHandler() [ Language = javascript ]
{
	
  $("#control_4").mask("8(999)999-9999");

	
	if (zenPage.UserLogin!='') {
		zen("cacheUserNameText").setProperty("value",zenPage.UserLogin);
		zenPage.getComponentById("CachePasswordCtrl").focus();
		
	} else {
		zenPage.getComponentById("cacheUserNameText").focus();	
	}
}

}

