///  Created using the page template: Default
Class zui.Menu Extends p6.zen.Page
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "zui.Application";

/// Displayed name of this page.
Parameter PAGENAME = "Меню";

Property HelpDeskUrl As %String(MAXLEN = 200) [ InitialExpression = {##class(admin.AppSet).GetCurrent().HelpDeskUrl} ];

Property CalcFrameName As %String(MAXLEN = 300) [ InitialExpression = {"m.CalcTrans.cls?acc="_..GetAccountEncrypt()} ];

Property ReadOnly As %ZEN.Datatype.string [ InitialExpression = "-" ];

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
	
	if(event.keyCode==113) {
		if(isGears()) {
			alert("Google Gears установлен!");
		 }else {
			location.href="http://gears.google.com/?action=install";
		 }
	}
	
	if (cancelEvent) {
		if (event.preventDefault) {
			event.preventDefault();
		}
		event.cancelBubble = true;
	}
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" xmlns:p6="http://www.dimas.ru/p6" title="Бонус клуб" height="100%" id="editPage">
<vgroup valign="top" align="center" width="99.7%">
<hgroup id = "logoPane" width="100%">
<html>
<div style = 'font-size: 1.5em; color: rgb(55,85,152);'><span class = "fa fa-cubes"></span><span style = "font-family: Verdana; font-weight: bold; font-size: 1em;" > BONUS CLUB</span></div>
</html>
<html width="100" id="SkypeButton"  OnDrawContent="getSkype" align="center" />
<!--
<html align="right" containerStyle="font-weight: bold; padding: 0 12px;" OnDrawContent="DrawFilial" enclosingClass="head" />
-->
</hgroup>

<hgroup width="100%">
<hmenu valign="top" id="workplaces" enclosingClass="yellowblue">



</hmenu>

<hmenu valign="top" id="exitmenu" enclosingClass="yellowblue">
<menuItem caption="Начислить баллы" onclick="OpenWindow('zui.doc.AddBonus.cls');" />
<menuItem caption="SMS рассылка" onclick="OpenWindow('zui.doc.SendSms.cls');" />
<menuItem caption="Сводный отчет по бонусам" onclick="OpenWindow('zui.rep.BonusReport.cls');" />
<menuItem caption="  Выход  " onclick="zenPage.finishSession()" title="Завершение работы с системой" />
</hmenu>
</hgroup>



<hgroup width="100%" align="center" >
<p6:vgroup valign="top" slice="1" width="20%">
<p6:refBook id="refbook" className="ent.Buyer" align="center" width="100%" btPrintExcel="-" btPrintWord="-" showNavigator="true" >
 <p6:tablePane initialExecute="true" orderByClause="" > 
 <p6:column field="Aka"  filterOp="[NOCASE" filterType="text"/>
 <p6:column field="Name"  filterOp="[NOCASE" filterType="text"/>
 <p6:column field="BonusSum" isAggregated="true" filterOp="[NOCASE" filterType="text" />
 <p6:column field="Comment" filterOp="[NOCASE" filterType="text"/>
</p6:tablePane>
 </p6:refBook>
</p6:vgroup>
<!--
<p6:vgroup width="50%">
<iframe id="calcFrame"  height="420pt" align="center" width="90%"   slice="1" />
</p6:vgroup>
<p6:vgroup valign="top" slice="1" width="30%">
<fieldSet label="Как начать работать">
<html>

</html>

</fieldSet>


</p6:vgroup>
-->
</hgroup>



</vgroup>
<spacer height="1" />

</page>
}

Method getSkype(slice) As %Status
{
	 &html<
	 <a href="skype:doroga_katya">Техподдержка</a>
	<a data-config="commands=chat,call,videocall,add;size=14;status=on;theme=logo;language=ru;bgcolor=#163582" id="skaip-buttons" href="http://www.skaip.su/"></a><script src="http://apps.skaip.su/buttons/widget/core.min.js" defer="defer"></script>
	 >
 quit $$$OK
}

Method getName() As %String [ ZenMethod ]
{
	set pName = $username //%session.Data("UserSys",$username,"Aka")
	quit pName
}

ClientMethod finishSession() [ Language = javascript ]
{
	window.location="zui.admin.RejectedConnection.cls?PageName=logout.html";
}

Method %OnAfterCreatePage() As %Status
{
	
	Set titleUserInfo = " Пользователь: "_$username //%session.Data("UserSys",$username,"Aka")
	Set %page.title=..#PAGENAME _"   |    " _ titleUserInfo
	//set ..%GetComponentById("calcFrame").src=..CalcFrameName
	if ($ROLES["BonusClub_Sales") {
		set ..%GetComponentById("refbook").btNew="-"
		set ..%GetComponentById("refbook").btDelete="-"
		set ..%GetComponentById("refbook").btEdit=""
	}
	quit $$$OK
}

ClientMethod onloadHandler() As %Status [ Language = javascript ]
{
	this.invokeSuper('onloadHandler',arguments);
	//var pageSize = getPageSize();
	//zenPage.getComponentById("calcFrame").setProperty("height",(pageSize[3]-100) + "px");
}

/// Takes the serialized state of a set of client components and
/// recreates the set of server-side objects.<br>
/// On return, <var>pObjects</var> is array of objects subscripted by
/// component index.<br>
/// As a side-effect it will set <var>%page</var>.
ClassMethod %DeserializePage(pHeader As %String, pBody As %String, Output pObjects) As %Status
{
	Set $ZT = "Trap"
	Set tSC = $$$OK

	Do {
		#; this should not happen
		If ((pHeader = "")||(pBody="")) Quit

		If ($IsObject(pHeader)) {
			#; header is a stream, not currently supported
			Set tSC = $$$ERROR($$$GeneralError,"Serial State Header is too large")
			Quit
		}
		
		#; first process header
		#; first record is list of class names
		Set tClassList = $P(pHeader,$C(4),1)
		For c = 1:1:$L(tClassList,$C(1)) {
			#; class # to class name
			Set tClasses(c) = $P(tClassList,$C(1),c)
		}

		#; now walk down list of objects in header
		#; instantiate, and add to local, indexed list
		For o = 2:1:$L(pHeader,$C(4)) {
			Set tObjInst = $P(pHeader,$C(4),o)
			
			#; first 2 pieces are class # and obj index
			Set tClassNo = $P(tObjInst,$C(1),1)
			Set tIndex = $P(tObjInst,$C(1),2)

			#; dereference class #
			Set tClass = tClasses(tClassNo)

			Set pObjects(tIndex) = $zobjclassmethod(tClass,"%New")
			If (tIndex = 1) {
				#; this must be the page
				Set %page = pObjects(tIndex)
			}
		}

		#; now walk down body and apply property values
		#; test if body is provided as a stream or string

		If ($IsObject(pBody)) {
			#; process stream in chunks
			Set tExtra = ""
			While (pBody.AtEnd = 0) {
				If ($L(tExtra) < 26000) {
					Set tChunk = tExtra _ pBody.Read(4000)
				}
				Else {
					#; node too big
					Set tSC = $$$ERROR($$$GeneralError,"Node in Serial State is too large")
					Quit
				}
				#; process chunk
				Set p = 1
				While (p > 0) {
					#; get next item
					Set next = $F(tChunk,$C(4),p),tObjState = $S(next>0:$E(tChunk,p,next-2),1:$E(tChunk,p,*))
					#; test for end of chunk v. end of stream
					If ((next=0)&&('pBody.AtEnd)) {
						Set tExtra = tObjState
						Quit
					}
					#; pull index out of 2nd piece and look up oref
					Set tObj = pObjects($P(tObjState,$C(1),2))
					Set tSC = tObj.%ZENDeserialize(tObjState,.pObjects)
					If $$$ISERR(tSC) Quit
					Set p = next
					Set tExtra = ""
				}
			}
		}
		Else {
			#; process string
			Set p = 1
			While (p > 0) {
				#; get next item
				Set next = $F(pBody,$C(4),p), tObjState = $S(next>0:$E(pBody,p,next-2),1:$E(pBody,p,*))
				#; pull index out of 2nd piece and look up oref
				Set tObj = pObjects($P(tObjState,$C(1),2))
				Set tSC = tObj.%ZENDeserialize(tObjState,.pObjects)
				If $$$ISERR(tSC) Quit
				Set p = next
			}
		}

		If $$$ISERR(tSC) Quit
	} While (0)
Done
	Quit tSC
Trap
	Set $ZT=""
	$$$ZENLOGERROR($ZE)
	&js<alert('Error deserializing page: #($ZCVT($ZE,"O","JS"))#\nProperty: #($G(tProp))#\nValue: #($G(tValue))#');>
	Goto Done
}

/// This client event, if present, is fired when a popup page has specified
/// this component as its parent and fires an action.<br>
/// <var>popupName</var> is the name of the popup window sending the action.<br>
/// <var>action</var> is the name of the action.<br>
/// <var>value</var> is the value associated with the action.<br>
ClientMethod onPopupAction(popupName, action, value) [ Language = javascript ]
{
	
	//zen("calcFrame").refreshContents();
}

ClassMethod GetAccountEncrypt() As %String
{

	quit $system.Encryption.Base32Encode($get(%session.Data("UserAccountId")),1)
}

}

