/// Created using the page template: Default
Class zui.admin.UserLoginChange Extends %ZEN.Component.page
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "zui.Application";

/// Displayed name of this page.
Parameter PAGENAME = "Вход в систему";

/// Domain used for localization.
Parameter DOMAIN = "DTK";

Property NameSpace As %ZEN.Datatype.string [ InitialExpression = {$NAMESPACE} ];

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
   <loginForm id="loginForm"  enclosingClass="box" label="Вам необходимо сменить пароль" labelStyle="color: #FF0000;"  >
    
    <text id="userNameText" name="UserName" autocomplete="false" readOnly="true" onfocus="zenPage.DisableAutocompletePassword()" labelStyle="font-weight:bold; color: white;" label="Имя пользователя:"  />
    <text id="cacheUserNameText" name="CacheUserName"  hidden="true" />
    
    <password id="oldpassword" name="CacheOldPassword" autocomplete="false" readOnly="true" onfocus="zenPage.DisableAutocompletePassword()" labelStyle="font-weight:bold; color: white;" label="Временный пароль:"/>
    <password id ="newpassword" name="CachePassword" autocomplete="false" readOnly="true" onfocus="zenPage.DisableAutocompletePassword()" labelStyle="font-weight:bold; color: white;" label="Придумайте новый пароль:" />
    <password id ="repeatnewpassword" name="CacheRepeatPassword" autocomplete="false" readOnly="true" onfocus="zenPage.DisableAutocompletePassword()" labelStyle="font-weight:bold; color: white;" label="Введите новый пароль еще раз:"/>
   	<spacer height="1em" />
    <button onclick="zenPage.Login();" caption="Сменить пароль" controlStyle=" font-weight:bold;" align="center"/>
  </loginForm>
</vgroup>
</page>
}

Method DrawOrgName(seed) As %Status
{
	//write ##class(admin.AppSet).GetCurrent().OrgName
	w "Перевозки"
	quit $$$OK
}

/// This callback is called at the start of the HTML BODY section of the page.<br>
/// (default implementation is a simple expression).
Method %OnDrawHTMLBody() As %Status
{
	 &html<<img style="z-index:-1; position:absolute; top:0; left:0; width:100%; height:100%;" src="/csp/#($NameSpace)#/p6/images/bgLoginGrad.gif" />>
	quit $$$OK
}

/*
ClientMethod keyDown() [ Language = javascript ]
{
	if (!window.sidebar) { // Если не firefox

  var isSingleKey = !((event.ctrlKey) || (event.shiftKey) || (event.altKey));
  if ((event.keyCode == 13) && isSingleKey) {
    if (event.srcElement.name=="UserName") {
	    document.all.CacheOldPassword.focus();
    }else if (event.srcElement.name=="CacheOldPassword") {
	    document.all.CachePassword.focus();
    }else { 
    	zenPage.Login();
    }
    
  }
	}
}
*/
ClientMethod Login() [ Language = javascript ]
{

	login = zenPage.getComponentById("userNameText").value;
	
	zenPage.getComponentById("cacheUserNameText").setProperty("value",zenPage.NameSpace+"_"+login);
	
	zenPage.getComponentById("loginForm").submit();
}

ClientMethod DisableAutocompletePassword() [ Language = javascript ]
{
	zenPage.getComponentById("userNameText").setProperty("readOnly", false)
	zenPage.getComponentById("oldpassword").setProperty("readOnly", false)
	zenPage.getComponentById("newpassword").setProperty("readOnly", false)
	zenPage.getComponentById("repeatnewpassword").setProperty("readOnly", false)
}

}

