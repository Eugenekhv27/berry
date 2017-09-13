/// Страница редактирования
Class p6.zen.Page Extends %ZEN.Component.page
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "p6.zen.Application";

/// Displayed name of this page.
Parameter PAGENAME;

Parameter DOMAIN = "DIMAS";

Parameter USERPACKAGES = "p6.zen.component";

Property StdTitle As %ZEN.Datatype.string;

/// Comma-separated list of additional CSS include files for the page.
Parameter CSSINCLUDES = "main_style.css, font-awesome-4.5.0/css/font-awesome.min.css";

/// Comma-separated list of additional JS include files for the page.
Parameter JSINCLUDES As STRING = "jquery-1.8.3.min.js,jquery.maskedinput.min.js";

/// If true, then attempt to refresh this page when its session has expired.
Parameter AUTOLOGOUT As BOOLEAN = 0;

/// This Style block contains page-specific CSS style definitions.
XData Style2
{
<style type="text/css">
/* default styles */
body {
	background: #EEEEEE;
	font-family: verdana;
}

</style>
}

/*
ClientMethod onkeydownHandler(e) [ Language = javascript ]
{
	var cancelEvent=false;
	if (zenIsIE){
	     srcElement = event.srcElement;
	} else { // for Mozilla
	   event=e;
	  srcElement = e.target;
	}

	// Change Enter to Tab  
	if ((!event.ctrlKey) && (event.keyCode==13)
	 && (srcElement.tagName!="BUTTON") 
	 && ((srcElement.tagName!="INPUT")
	     ||(srcElement.type!="button")  )
	 && (!event.shiftKey || srcElement.tagName!="TEXTAREA")) {
	     if (zenIsIE) {
	   		event.keyCode=9;
	     } else {
		     cancelEvent=true;
	     }
	}
	// ctrl-enter save form
	if ((event.ctrlKey) && (event.keyCode==13)) {
		srcElement.blur();
		btSave.click();
	}

	// esc закрывает окно
	if ((event.keyCode==27)) {
		if (zenPage.isPopup) {
			zenPage.firePopupAction('close','');
		} else {
			history.back();
		}
	}
	
	// стрелка на tab
	if (((event.keyCode==37) || (event.keyCode==38)) && (srcElement.tagName=="BUTTON") ) {
	    event.keyCode=9;
	    //event.shiftKey=false;  !добавить
	}
	// стрелка на tab
	if (((event.keyCode==39) || (event.keyCode==40)) && (srcElement.tagName=="BUTTON") ) {
	    event.keyCode=9;
	}
	
	if (cancelEvent) {
		if (event.preventDefault) {
			event.preventDefault();
		}
		event.cancelBubble = true;
	}
}
*/
Method %OnAfterCreatePage() As %Status
{
	
	Set titleUserInfo = "Пользователь: "_$username //%session.Data("UserSys",$username,"Aka")
	Set %page.title=..#PAGENAME _"   |    " _ titleUserInfo
	Quit $$$OK
}

Method %OnDrawHTMLHead() As %Status
{
	//Set useAsync = 1 //shu12
	
	Write "<script language=""javascript"">",!
	/*
	Write "function zenClassMethod(object,method,spec,rettype,args)",!
	Write "{",!
	Write $C(9),"var state = new zenSerialState();",!
	Write $C(9),"var arglist = zenBuildArgumentList(state,spec,args);",!
	Write $C(9),"if (zenDEBUGTraceEvents) { zenTRACE('Server Class Method',method,arglist);}",!
	Write $C(9),"var header = state.getHeader();",!
	Write $C(9),"var body = state.getBody();",!
	Write $C(9),"var ns = '",$ZU(5),"';",!
		Write $C(9),"if (''!=rettype) {",!
		Write $C(9,9),"var ret = ",..HyperEventCall("%ZEN.Controller.InvokeClassMethod","object._serverClass,method,rettype,zenSyncFlag,header,body,spec,arglist,ns",0)
	 	Write ";",!
	 	Write $C(9,9),"return zenConvertType(rettype,ret);",!
		Write $C(9),"} else {",!
		Write $C(9,9),"if (!zenSynchronousMode) {",!
		Write $C(9,9,9),..HyperEventCall("%ZEN.Controller.InvokeClassMethod","object._serverClass,method,rettype,zenSyncFlag,header,body,spec,arglist,ns",1)
	 	Write ";",!
		Write $C(9,9),"} else {",!
		Write $C(9,9,9),..HyperEventCall("%ZEN.Controller.InvokeClassMethod","object._serverClass,method,rettype,zenSyncFlag,header,body,spec,arglist,ns",0)
	 	Write ";",!
		Write $C(9,9),"}",!
		Write $C(9),"}",!
	Write "}",!

	#; invokeServerInstanceMethod
	#; JS object, method name, formal spec, arguments
	Write "function zenInstanceMethod(object,method,spec,rettype,args)",!
	Write "{",!
	Write $C(9),"var state = new zenSerialState();",!
	Write $C(9),"state.addObject(object);",!
	Write $C(9),"var arglist = zenBuildArgumentList(state,spec,args);",!
	Write $C(9),"if (zenDEBUGTraceEvents) { zenTRACE('Server Instance Method',method,arglist);}",!
	Write $C(9),"var header = state.getHeader();",!
	Write $C(9),"var body = state.getBody();",!
	Write $C(9),"var ns = '",$ZU(5),"';",!
		Write $C(9),"if (''!=rettype) {",!
		Write $C(9,9),"var ret = ",..HyperEventCall("p6.zen.Controller.InvokeInstanceMethod","object.index,method,rettype,zenSyncFlag,header,body,spec,arglist,ns",0)
	 	Write ";",!
	 	Write $C(9,9),"return zenConvertType(rettype,ret);",!
		Write $C(9),"} else {",!
		Write $C(9,9),"if (!zenSynchronousMode) {",!
		Write $C(9,9,9),..HyperEventCall("p6.zen.Controller.InvokeInstanceMethod","object.index,method,rettype,zenSyncFlag,header,body,spec,arglist,ns",1)
	 	Write ";",!
		Write $C(9,9),"} else {",!
		Write $C(9,9,9),..HyperEventCall("p6.zen.Controller.InvokeInstanceMethod","object.index,method,rettype,zenSyncFlag,header,body,spec,arglist,ns",0)
	 	Write ";",!
		Write $C(9,9),"}",!
		Write $C(9),"}",!
	Write "}",!
	*/ //shu12

	// DisplayError(sc)
	Write "function DisplayError(sc)",!
	Write "{",!
	Write $C(9),"alert(",..HyperEventCall("p6.CspMethods.StatusForAlert","sc",0),");",!
	Write "}",!
	
	Write "p6ApplicationUrl=",..QuoteJS($e(%request.Application,1,$l(%request.Application)-1)),!

	Write "</script>"

	&html<<script language="javascript" src="#(%request.Application)#p6/js/p6Utils.js"></script>>
	// &html<<script language="javascript" src="#(%request.Application)#p6/js/gears_init.js"></script>>
	
	quit $$$OK
}

/// This client event, if present, is fired when the page is loaded.
ClientMethod onloadHandler() [ Language = javascript ]
{
	//return SetFocusOnFirstControl();
}

ClientMethod updateTableBodyHeight(tableComponent) [ Language = javascript ]
{
	
	// Делаем табличные части до низа экрана (не больше, чтобы без добавочного скрола)
	
	try {
       var divTable = tableComponent ? tableComponent.getEnclosingDiv() : null;
       if (divTable) {
	   	var br=divTable.getBoundingClientRect()  ;  
	   	var pageSize = getPageSize();
	   
	   	tableComponent.setProperty("bodyHeight",(pageSize[3]-br.top-70) + "px");
	   	
       }
	} catch(e)
	{}
}

ClassMethod %OnBeforeCreatePage() As %Status
{
	
	quit $$$OK
}

/// This client event, if present, is fired when the page is loaded.
ClientMethod getValue(componentId) [ Language = javascript ]
{
	try {
		return zenPage.getComponentById(componentId).value;
	} catch(e) {
		return ""
	}
}

/// This callback is called at the start of the HTML HEAD section of the page (just after the title).<br/>
/// It allows a page to write out meta tags, if desired.
/// (default implementation is a simple expression).
Method %OnDrawHTMLMeta() As %Status
{
 //if %session.UserAgent["MSIE" {
 	//	write "<meta http-equiv=""X-UA-Compatible"" content=""IE=5""/>"
 //}
 quit $$$OK
}

/// Проверка доступно ли localStore (для хранения временных данных на клиентском компьютере)
ClientMethod isLocalStorageAvailable() [ Language = javascript ]
{
    try {
        return 'localStorage' in window && window['localStorage'] !== null;
    } catch (e) {
        return false;
    }
}

/// Проверяем права на отображение элементов страницы
Method CheckRules(IsSalesDivision = 0, IsFinDivision = 0, IsLogisticsDivision = 0, IsFullMenu = 0, IsAdmin = 0, IsChangeOrg = 0) As p6.dt.Boolean [ ZenMethod ]
{
	//if IsSalesDivision && %session.Data("UserSys",$username,"IsSalesDivision") quit 1
	//if IsFinDivision && %session.Data("UserSys",$username,"IsFinDivision") quit 1
	//if IsLogisticsDivision && %session.Data("UserSys",$username,"IsLogisticsDivision") quit 1
	//if IsFullMenu && %session.Data("UserSys",$username,"IsFullMenu") quit 1
	//if IsAdmin && %session.Data("UserSys",$username,"IsAdmin") quit 1
	//if IsChangeOrg && %session.Data("UserSys",$username,"IsChangeOrg") quit 1
	quit 0
}

}

