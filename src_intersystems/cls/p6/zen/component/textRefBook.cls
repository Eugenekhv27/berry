/// Компонент для ссылочных полей.<br>
/// Объект можно выбрать как из выподающего списка, так и из открывающегося по кнопке справочника
Class p6.zen.component.textRefBook Extends %ZEN.Component.dataCombo
{

/// This is the XML namespace for this component.
Parameter NAMESPACE = "http://www.dimas.ru/p6";

/// Тип выподающего списка<br>
/// ! ИСПОЛЬЗОВАТЬ ТОЛЬКО ДЛЯ КОМПОНЕНТА <class>%ZEN.Component.dataCombo</class> !
Property comboType As %ZEN.Datatype.string(VALUELIST = ",image,button,timer") [ InitialExpression = "timer" ];

/// Если-истина тогда в поле ввода можно вводить текст, а не только выбирать из списка<br>
/// если ложь- выбирать только из справочника по кнопке<br>
/// !!! НЕ ИСПОЛЬЗОВАТЬ !!!<br>
/// Работает с ошибками=( (если false)<br>
Property editable As %ZEN.Datatype.boolean [ InitialExpression = 1 ];

/// Максимальное количество символов, передаваемых
/// в запрос для выподающего списка.<br>
/// Если ноль то используется вся строка введенныя в поле ввода
Property searchKeyLen As %ZEN.Datatype.integer(MINVAL = 0) [ InitialExpression = 50 ];

/// Масимальное количество строк в выподающем списке
Property maxRows As %ZEN.Datatype.integer [ InitialExpression = 20 ];

/// Колонки которые используются при поиске объектов по введенному пользователем тексту<br>
/// Формат: Колонка1[:Отношени1],Колонка2[:Отношени2],...<br>
/// Отношения могут быть: Exact,StartsWith,Like. По умолчанию: Like.<br>
/// Если пустое, то для получения вызывается метод класса выбираемого объекта GetLookupColumns
Property lookupColumns As %ZEN.Datatype.string;

/// Название класса выбираемого объекта.
/// Нужно, если работаем без модели данных
Property className As %ZEN.Datatype.string;

/// Сколько ждать перед показом "всплывающей подсказки"
Property delay As %ZEN.Datatype.integer [ InitialExpression = 750 ];

/// Если надо задать для выпадающего списка отдельное условие
Property whereClauseBox As %ZEN.Datatype.string;

XData Style
{
<style type="text/css">
input.comboboxInputTimer {
	margin-top:0.2em;
	margin-bottom:0.2em;
}
</style>
}

Method %OnAddToPageAfter() As %Status
{
	 
	if ..label="" {
		set form=..%GetForm()
		set className=form.%controller.modelClass
		set ..label=##class(p6.ClassDefinition).GetPropertyCaption(className,..dataBinding)
	}
	if ..id="" {
		set ..id=$tr(..dataBinding,"%.()","____")
	}
	if ..name="" {
		set ..name=..id
	}
	if (..size="")&&(..width="") {
		set ..width="100%"
	}
	if ..size="" {
		set ..controlStyle="width:100%;"_..controlStyle
	}
	set ..enclosingStyle="width:90%"
	
	Set tModelClass = ..modelClass

	#; if we are not linked to the model, get it via the form
	If ((..dataBinding'="")&&(..modelClass="")) {
		Set tForm = ..%GetForm()
		If ($IsObject(tForm)&&$IsObject(tForm.%controller)) {
			Set tModelClass = tForm.%controller.modelClass
		}
	}
	
	set ..modelClass=tModelClass
	
	if ..className]"" set fieldType=..className
	else  set fieldType=##class(p6.ClassDefinition).GetPropertyType(tModelClass,..dataBinding)
	
	set columns=$zobjclassmethod(fieldType,"GetLookupColumns")
	
	set (select,header)=""
	
	for i=1:1:$length(columns,",") {
		set select=select_", "_$p($p(columns,",",i),":",1)
		set header=header_", "_$p($p(columns,",",i),":",2)
	}
	
	set ($e(select),$e(header))=""
	
	set ..sql="SELECT Id,"_select_" FROM "_fieldType
	set ..columnHeaders=header
	
	Quit $$$OK
}

/// Lookup up the display value for the combobox given
/// a logical value.<br>
/// This is called when the control is initially drawn.
/// A logical value of "", must have a display value of "".
Method %GetDisplayValue(pValue As %String) As %String
{
	if pValue="" quit ""
	set tDisplay = pValue
	Do {
		Set tModelClass = ..modelClass

		#; if we are not linked to the model, get it via the form
		If ((..dataBinding'="")&&(..modelClass="")) {
			Set tForm = ..%GetForm()
			If ($IsObject(tForm)&&$IsObject(tForm.%controller)) {
				Set tModelClass = tForm.%controller.modelClass
			}
		}

		if ..className]"" set fieldType=..className
		else  set fieldType=##class(p6.ClassDefinition).GetPropertyType(tModelClass,..dataBinding)
		try {
		
		set tDisplay=$CLASSMETHOD(fieldType,"GetDisplayValue",pValue)
		}catch {
		}

	} While(0)

	Quit tDisplay
}

/// Internal method.<br>
/// Server-side method to provide contents of the list box.
/// This is called from the client.
/// This method use columns returned by GetLookupColumns() method to query class 
Method %DrawDropDownContents(searchParm As %String, Output pCount As %Integer) As %Status [ Internal ]
{
	set oldColumnHeaders=..columnHeaders
	set oldSql=..sql
	set pCount = 0, sc=$$$OK
	
	if ..className]"" set fieldType=..className
	else  set fieldType=##class(p6.ClassDefinition).GetPropertyType(..modelClass,..dataBinding)
	
	set columns=$zobjclassmethod(fieldType,"GetLookupColumns")

	#; build DHTML table to show results
	&html<<table class="comboboxTable" width="100%" border="0" cellpadding="0" cellspacing="0">>


	for i=1:1:$length(columns,",") {
		set column=$p($p(columns,",",i),":",1)
		set collation=$p($p(columns,",",i),":",3)
		if collation="" set collation="Like"
		set filter="UPPER("_column_")"
		set:collation="Like" filter=filter_" [ UPPER(?)"
		set:collation="Exact" filter=filter_" = UPPER(?)"
		set:collation="StartsWith" filter=filter_" %STARTSWITH UPPER(?)"
		if ..whereClauseBox]"" {
			set filter=##class(p6.FilterUtils).Add(filter,$$$ZENVAL(..whereClauseBox))
		} elseif ..whereClause]"" {
			set filter=##class(p6.FilterUtils).Add(filter,$$$ZENVAL(..whereClause))
		}
		if ##class(%Dictionary.CompiledMethod).%ExistsId(fieldType_"||GetModelFilter") {
			set filter = ##class(p6.FilterUtils).Add(filter,$zobjclassmethod(fieldType,"GetModelFilter"))
		}
		
		set ..sql=oldSql_" where "_filter

		set sc=..%DrawSingleQuery(searchParm,.pCount,.idList)
		set ..columnHeaders=""
	}

	If $$$ISOK(sc) {
		If (pCount = 0) {
			// endModal
			Set tNoMatches = $$$TextHTML("No matches")
			&html<<tr><td onmousedown="zenPage.endModal();"><i>#(tNoMatches)#</i></td></tr>>
		}
	}

	&html<</table>>

	set ..columnHeaders=oldColumnHeaders
	set ..sql=oldSql

	quit sc
}

Method %DrawSingleQuery(searchParm As %String, Output pCount As %Integer, Output pIdList As %String) As %Status [ Internal ]
{
	Set tSC = $$$OK
	Set $ZT="Trap"
	Set tRS = ""
	Set tHasDisplay = 0
	Set tMaxRows = ..maxRows
	Set tCount = pCount

	#; create result set
	#; For query parameters use the values that come from 
	#; the *parameters* property.
	#; If searchKeyLen is non-zero, then ignore parameter(1)
	#; and use the searchParm instead.
	#; Special case: if you set a parameter (other than parameter(1))
	#; to "?", then searchParm will be used for this parameter as well.
	#; This is for special cases where the searchParm needs to occur multiple
	#; times within a query 

	#; create QueryInfo object to hold query info
	Set tInfo = ##class(%ZEN.Auxiliary.QueryInfo).%New()

	#; additional query parms
	Set tInfo.tableName = $$$ZENVAL(..tableName)
	Set tInfo.columnName = $$$ZENVAL(..columnName)
	Set tInfo.whereClause = $$$ZENVAL(..whereClause)
	Set tInfo.orderByClause = $$$ZENVAL(..orderByClause)
	Set tInfo.groupByClause = $$$ZENVAL(..groupByClause)

	#; do we have a searchParm
	Set p = 1
	If (..searchKeyLen > 0) {
		Set tInfo.parms(1) = searchParm
		Set p = 2 // skip first parameter
	}
	
	#; look at parameters for additional parms
	Set tParmCount = ..parameters.Count()
	For n=p:1:tParmCount {
		Set tParam = ..parameters.GetAt(n)
		Set tVal = $$$ZENVAL(tParam.value)
		Set tInfo.parms(n) = $S(tVal="?":searchParm,1:tVal)
	}

	#; remember original query, so we can restore it
	Set tSQL = ..sql
	If ((tSQL="")&&(..dataBinding'="")&&(..modelClass'="")) {
		#; find query from model
		Set tSC = $zobjclassmethod($$$ZENVAL(..modelClass),"%GetLookupSQL",..dataBinding,.sql,.sqllk)
		If $$$ISERR(tSC) Quit tSC
		Set ..sql = $G(sql)
	}
	
	/*Ошибка при задании whereClause выподающий список его не учитывает,
	  открывающийся рефбук учитывает. Проблема в %CreateResultSet или даже в tInfo.%CreateSQL()
	  Решение топорное, но должно работать=(  
	  grender 080305                       */
	set temp=$$$ZENVAL(..whereClause)
	if temp'=""	s ..sql=..sql_" AND ( "_temp_" )"
	// Иногда список учитывает но не проводит $$$ZENVAL   (grender 20080513)
	set ..sql=$$$ZENVAL(..sql)
	if ('($ZCVT(..sql,"U")["ORDER BY")) set ..sql=..sql_$S(..orderByClause="":"",1:" ORDER BY "_..orderByClause)

	Set tRS = ..%CreateResultSet(.tSC,tInfo)
	Set ..sql = tSQL  // restore original SQL
	If $$$ISERR(tSC) Quit tSC
	If (..showQuery) {
		&html<<tr><td>query:<br/><pre>#(tInfo.queryText)#</pre><hr/>>
	}

	Set tInfo = ""

	If ($IsObject(tRS)) {
		Set tStyle=""
		Set tColCount = tRS.GetColumnCount()
		Set tColCount = $S(..multiColumn:tColCount,tColCount=1:1,1:2)
		Set tValueCol = $S(tColCount=1:1,..valueColumn<=tColCount:..valueColumn,1:1)
		Set tChoiceCol = $S(tColCount=1:1,..choiceColumn<=tColCount:..choiceColumn,1:2)
		Set tAuxCol = $S((..auxColumn>0)&&(..auxColumn<=tColCount):..auxColumn,1:0)

		If (tColCount >= 1) {
			#; index of columns to show
			If (..displayColumns '= "") {
				set p4displayColumns = ..displayColumns //shu12
				For n = 1:1:$L(..displayColumns,",") {
					Set tColIdx(n) = +$P(p4displayColumns,",",n)
					If (tColIdx(n)=0) {
						Set tSC = $$$ERROR($$$GeneralError,"displayColumns must contain integer values")
						Quit
					}
				}
				Set tColCount = n
			}
			Else {
				Set n = 1
				For c=1:1:tColCount {
					If (c '= tValueCol) {
						Set tColIdx(n) = c
						Set n = n + 1
					}
				}
			}
		}
		If $$$ISERR(tSC) Quit tSC


		If ((..columnHeaders '= "") && (..columnHeaders '= $C(0))) {
			#; column headers
			set p4columnHeaders = ..columnHeaders //shu12
			&html<<tr>>
			If (tColCount = 1) {
				Set tHeader = $P(p4columnHeaders,",",1)
				&html<<th>#($ZCVT(tHeader,"O","HTML"))#&nbsp;</th>>
			}
			Else {
				Set n = 1
				Set c = $O(tColIdx(""))
				While (c '= "") {
					Set tHeader = $P(p4columnHeaders,",",n)
					&html<<th>#($ZCVT(tHeader,"O","HTML"))#&nbsp;</th>>
					Set n = n + 1
					Set c = $O(tColIdx(c))
				}
			}
			&html<</tr>>
		}

		#; iterate over rows
		Set tSC = $$$OK
		While (tRS.%Next(.tSC) && ((tMaxRows = 0) || (tCount < tMaxRows))) {
			If $$$ISERR(tSC) Quit
			Set tValue = tRS.GetData(1)
			Set:tValue=$C(0) tValue=""
			#; !!! Change here
			;#Set tText = tRS.GetData(tChoiceCol)
			;+++
			if $data(pIdList(tValue)) continue
			set pIdList(tValue)=""
			Set tText = ..%GetDisplayValue(tRS.GetData(tValueCol))
			
			;===
			Set:tText=$C(0) tText=""

			If (tAuxCol '= 0) {
				Set tAuxValue = tRS.GetData(tAuxCol)
				Set:tAuxValue=$C(0) tAuxValue=""
				Set tAuxValue = $ZCVT(tAuxValue,"O","HTML")
				Set tAuxAttr = "zenAux="""_tAuxValue_""""
			}

			Set tValue = $ZCVT(tValue,"O","HTML")
			Set tText = $ZCVT(tText,"O","HTML")
		
			Set tValAttr = "zenValue="""_tValue_""""
			Set tTextAttr = "zenText="""_tText_""""
			Set tCls = "comboboxItem"
			Do DrawRow()
			Set tCount = tCount + 1
		}
	

	}

	Set pCount = tCount
Done
	Quit tSC
Trap
	Set $ZT=""
	Set tSC = $$$ERROR($$$GeneralError,"Error running query: " _ $ZE)
	Goto Done

	#; common code to draw row of the dropdown
DrawRow() 
	&html<<tr id="#(..%MakeId("item_"_tCount))#" class="#(tCls)#" onmousedown="zenPage.getComponent(#(..index)#).itemMouseDown(event,#(tCount)#);" onmouseup="this.style.color='';zenPage.getComponent(#(..index)#).itemMouseUp(event,#(tCount)#);" #(tValAttr)# #(tTextAttr)# #($G(tAuxAttr))# onmouseover="this.style.color='red';" onmouseout="this.style.color='';">>
	If (tColCount = 1) {
		&html<<td>#($S(tText="":"&nbsp;",1:tText))#</td>>
	}
	Else {
		Set c = $O(tColIdx(""))
		While (c '= "") {
			Set tData = tRS.GetData(tColIdx(c))
			Set:tData=$C(0) tData=""
			&html<<td>#($S(tData="":"&nbsp;",1:$ZCVT(tData,"O","HTML")))#</td>>
			Set c = $O(tColIdx(c))
		}
	}
	&html<</tr>>
	Quit
}

/// Keydown within input control.
ClientMethod inputKeyHandler(evt) [ Language = javascript ]
{
	evt = evt ? evt : window.event;
	var idx = parseInt(this.selectedIndex,10);

	// trap keys
	if (this.isDropdownVisible) {
		switch(evt.keyCode) {
		case zenUP:
			this.clearTimer();
			this.keyMode = true;
			if (evt.preventDefault) {
				evt.preventDefault();
			}
			if (idx > 0) {
				this.selectItem(idx - 1,true,false);
			}
			return false;
		case zenDOWN:
			this.clearTimer();
			this.keyMode = true;
			if (evt.preventDefault) {
				evt.preventDefault();
			}
			if (idx < (this.getOptionCount()-1)) {
				this.selectItem(idx + 1,true,false);
			}
			return false;
		case zenPAGEUP:
			this.clearTimer();
			this.keyMode = true;
			if (evt.preventDefault) {
				evt.preventDefault();
			}
			if (idx > 0) {
				this.selectItem((idx > 10) ? idx - 10 : 0,true,false);
			}
			return false;
		case zenPAGEDN:
			this.clearTimer();
			this.keyMode = true;
			if (evt.preventDefault) {
				evt.preventDefault();
			}
			var count = this.getOptionCount();
			if (idx < (count-1)) {
				this.selectItem((idx < count - 10) ? idx + 10 : count - 1,true,false);
			}
			return false;
		case zenESC:
			if (evt.preventDefault) {
				evt.preventDefault();
			}
			zenPage.endModal();
			return false;

		case zenENTER:
			this.clearTimer();
			if (idx!=-1) {
				// choose selected item!
				this.selectItem(idx,false,true);
				zenPage.endModal();
			}
			else {
				// choose first item!
				this.selectItem(0,false,true);
				zenPage.endModal();
			}
			return true;
		default:
			this.startTimer();
			this.keyMode = null;
			break;
		}
	}
	else {
		switch(evt.keyCode) {
		case zenENTER:
			break;
		case zenDOWN:
			// show drop down
			if (!this.isChanged) return true;
			this.clearTimer();
			this.keyMode = true;
			this.showDropdown();
			return false;
		default:
			if (String.fromCharCode(event.keyCode)!='') {
				this.startTimer();
				this.isChanged = true;
			}
			break;
		}
	}

	// invoke callback, if present
	return zenInvokeCallbackMethod(this.onkeydown,this,'onkeydown');
}

/// Draw the input box and button for this combobox.<br>
/// Note that the actual value is placed in a hidden control as the
/// contents of the input box may not be the actual value.
Method %DrawHTML()
{
	#; find displayValue
	Set tDisplay = ..%GetDisplayValue($$$ZENVAL(..value))

	#; do not add this to set of events
	Set tIgnore("onkeypress")=""
	Set tIgnore("onchange")=""
	Set tIgnore("onblur")=""

	Set ..onchange=$$$ZENVALJS(..onchange)
	Set ..onkeypress=$$$ZENVALJS(..onkeypress)
	Set ..onblur=$$$ZENVALJS(..onblur)

	&html<<input type="hidden" id="#(..%MakeId("hidden"))#" #(..%Name())# #(..%Attr("value",..value))#  autocomplete="off"/>>
	
	
	&html<<table border="0" cellspacing="0" cellpadding="0">>
	


	
	Set ..controlClass = "comboboxInputTimer"
	&html<<tr><td style="white-space: nowrap" #($S(..size="":"width=""100%""",1:""))#><input class="#(..controlClass)#" #(..%Attr("style",..controlStyle))# type="text" autocomplete="off" #($S(..disabled:"disabled=""1""",1:""))# #(..%Attr("title",..title))# #(..%Attr("tabindex",..tabIndex))# #($S(..editable:$S(..readOnly:"readonly=""1""",1:""),1:"readonly=""1"""))# id="#(..%MakeId("input"))#" #(..%Attr("size",..size))# #(..%Attr("value",tDisplay))# #(..%Attr("maxlength",..maxlength))# #(..%GetEventHandlers(.tIgnore))# onkeydown="zenPage.getComponent(#(..index)#).inputKeyHandler(event);" onblur="zenPage.getComponent(#(..index)#).inputBlurHandler(event);"  onchange="zenPage.getComponent(#(..index)#).inputChangeHandler();"/></td>>
		;# here we add additional button
	if ..className]"" set fieldType=..className
	else  set fieldType=##class(p6.ClassDefinition).GetPropertyType(..modelClass,..dataBinding)
	&html<<td style="white-space: nowrap; padding-left:0.3em;width:40px;"><input type="button" value="..." class="textRefBookButton" tabIndex=-1 #($S(..disabled:"disabled",1:""))# #($S(..readOnly:"disabled",1:""))#
		 id="#(..%MakeId("btn"))#" onclick="zenPage.getComponent(#(..index)#).showRefBook('#(fieldType)#')" /> </td></tr>>
		 
	

	
		&html<</table>>
	

	If (+..#USECACHEDIV) {
		#; extra div to cache dropdown contents
		&html<<div style="display: none;" id="#(..%MakeId("cache"))#">>
		Do ..%OnDrawCacheDiv()
		&html<</div>>
	}
}

Method DoZenEval(aString As %String) As %String [ ZenMethod ]
{
	set eval=$$$ZENVAL(aString)
	quit eval
}

ClientMethod showRefBook(className) [ Language = javascript ]
{
	zenLaunchPopupWindow("p6.zen.RefBook.cls?WindowType=Modal&ClassName="+className+"&Where="+this.DoZenEval(this.whereClause),'select'+this.index,GetWindowFeatures(),null,this);
}

ClientMethod onPopupAction(popupName, action, value) [ Language = javascript ]
{
	if(action=="close") return;
	this.setProperty('value',value);
	this.onchangeHandler();
}

/*
/// Change handler for input control.
/// Users should not call this method.
ClientMethod inputChangeHandler() [ Internal, Language = javascript ]
{
	
	
	// apply user edit to control
	//var input = this.findElement('input');
	//this.value = input.value;
	// неправильно
	//setTimeout("zenPage.getComponent("+this.index+").findElement('input').value = zenPage.getComponent("+this.index+").findDisplayValue('"+this.value+"');",10);
	//this.onchangeHandler();
}
*/
/// Change handler for input control.
/// Users should not call this method.
ClientMethod inputChangeHandler() [ Internal, Language = javascript ]
{
	var input = this.findElement('input');
	var hidden = this.findElement('hidden');
	if (input.value=='') {
		
		this.value = '';

		this.text = '';

		hidden.value = '';

		input.value = '';
		this.setProperty('value','');	
		this.onchangeHandler();
	}
	
	if (this.unrestricted) {
		if (this.editable) {
			
			// apply user edit to control
			var hidden = this.findElement('hidden');
			var input = this.findElement('input');
			this.value = input.value;
			hidden.value = input.value;
		}

		// notify
		this.onchangeHandler();
	}
}

}

