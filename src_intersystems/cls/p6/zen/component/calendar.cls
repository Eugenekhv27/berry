/// Компонент- поле ввода для даты, с возможность выбора её из появляющегося календаря.
Class p6.zen.component.calendar Extends %ZEN.Component.dateText
{

/// This is the XML namespace for this component.
Parameter NAMESPACE = "http://www.dimas.ru/p6";

/// Optional. Specifies the display format used for this component.
/// (Note that the internal value of this control is always YYYY-MM-DD).
/// Possible values are:<br/>
/// <ul>
/// <li>"YMD" - Year,Month,Day</li>
/// <li>"MDY" - Month,Day,Year</li>
/// <li>"DMY" - Day,Month,Year</li>
/// </ul>
Property format As %ZEN.Datatype.string(MAXLEN = 3, VALUELIST = ",MDY,DMY,YMD", ZENEXPRESSION = 1) [ InitialExpression = "DMY" ];

/// Optional. Specifies the separator character used between date segments.
/// Note, if time is also displayed, the time separator is <em>always</em> ":".
Property separator As %ZEN.Datatype.string(MAXLEN = 1, VALUELIST = ",-,/,., ", ZENEXPRESSION = 1) [ InitialExpression = "." ];

/// Specified which day of the week (Sunday=0, Saturday = 6) is displayed as
/// the starting day of the week.<br>
/// This allows for customizing the calendar for locales where weeks start with
/// other days of the week.
/// This is passed on the popup calendar.
Property firstDayOfWeek As %ZEN.Datatype.integer(MAXVAL = 6, MINVAL = 0) [ InitialExpression = 1 ];

XData Style
{
<style type="text/css">
input.comboboxInput, .comboboxImgButton {
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
	Quit $$$OK
}

Method %DrawHTML()
{
	#; do not add this to set of events
	Set tIgnore("onchange")=""
	Set tIgnore("onkeydown")=""

	Set disabled = $S(..disabled:"disabled=""1""",1:"")
	Set ro = $S(..readOnly:"readonly=""1""",1:"")
	Set bflag = $S(..readOnly:"readonly=""1""",1:"")
	
	#; if localized properties have not been set, set them
	Set:..dayList="" ..dayList = $$$Text("S,M,T,W,T,F,S")
	Set:..monthList="" ..monthList = $$$Text("January,February,March,April,May,June,July,August,September,October,November,December")
	Set:..timeCaption="" ..timeCaption = $$$Text("Time:")

	#; if there are expressions for these props, evaluate
	Set ..minDate = $$$ZENVAL(..minDate)
	Set ..maxDate = $$$ZENVAL(..maxDate)
	Set ..format = $$$ZENVAL(..format)
	Set ..separator = $$$ZENVAL(..separator)

	#; Get value
	Set tValue = $$$ZENVAL(..value)
	Set tDisplayValue = tValue
	
	#; do not let #()# expression go to client
	Set ..value = tValue

	// JMDXXX: use layout from selector control
	/*
	&html<<table border="1" cellspacing="0" cellpadding="0">>
	#; render as one line as CR will mess up the display
	&html<<tr><td style="white-space: nowrap"><input class="#(..controlClass)#" type="text" size="#(+..size)#" id="#(..%MakeId("control"))#" #(..%Attr("title",..title))# #(..%Name())# #(disabled)# #(ro)# #(..%Attr("value",tDisplayValue))# #(..%Attr("tabindex",..tabIndex))# #(..%Attr("style",..controlStyle))# #(..%GetEventHandlers(.tIgnore))# onkeydown="return #(..%Self())#.keydownHandler(event);" onchange="#(..%Self())#.ondatechangeHandler();"/><img src="images/datetext.gif" id="#(..%MakeId("image"))#" onclick="#(..%Self())#.showDateSelector();" class="comboboxImgButton"/></td></tr>>
	&html<</table>>
	*/

	Set tTitle = $$$Text("Display calendar.","%ZEN")
	Set tIcon = ..image
	&html<<div class="dateTextDiv" id="#(..%MakeId("div"))#" style="opacity:0.1;width:#((..size*7)+22)#px;"><nobr>
	<input type="text" class="#(..controlClass)#" #(..%Attr("title",..title))# id="#(..%MakeId("control"))#" #(..%Name())# #(disabled)# #(ro)# #(..%Attr("value",..value))# #(..%Attr("size",..size))# #(..%Attr("style",..controlStyle))# #(..%Attr("tabindex",..tabIndex))# #(..%GetEventHandlers(.tIgnore))# onkeydown="return #(..%Self())#.keydownHandler(event);" onchange="#(..%Self())#.ondatechangeHandler();"/><image class="dateTextIcon" align="top" src="#(tIcon)#" id="#(..%MakeId("icon"))#" title="#(tTitle)#" onclick="#(..%Self())#.showDateSelector();"/>
	</nobr></div>>
}

/// Обработчик изменения значения
ClientMethod ondatechangeHandler() [ Language = javascript ]
{
	var ctrl = this.findElement('control');
	zenASSERT(ctrl,'Unable to find input element',arguments);

	// parse date entered by user:
	var v = this.normalizeDate(ctrl.value);
	ctrl.value = ((ctrl.value!="")&&(v=="")) ? "Неверная дата" : v;
	// notify
	this.onchangeHandler();
}

ClassMethod NormalizeDateOnServer(aDate As %String = "") As %String [ CodeMode = expression, ZenMethod ]
{
##class(p6.dt.Date).LogicalToDisplay(##class(p6.dt.Date).DisplayToLogical(aDate))
}

ClientMethod normalizeDate(aDate) As %String [ Language = javascript ]
{
	if (aDate=="") return ""
	return this.NormalizeDateOnServer(aDate)
}

}

