/// Служит для ввода текста или времени.
/// Нормализация времени проводится если связанный атрибут типа <class>p6.dt.Time</class>
Class p6.zen.component.text Extends %ZEN.Component.text
{

/// This is the XML namespace for this component
Parameter NAMESPACE = "http://www.dimas.ru/p6";

XData Style
{
<style type="text/css">
input.text {
	margin-top:0.2em;
	margin-bottom:0.2em;
}
</style>
}

Method %OnAddToPageAfter() As %Status
{
	set form=..%GetForm()
	set className=form.%controller.modelClass
	if ..label="" {
		set ..label=##class(p6.ClassDefinition).GetPropertyCaption(className,..dataBinding)
	}
	
	set propType=##class(p6.ClassDefinition).GetPropertyType(className,..dataBinding)
	if propType="p6.dt.Time" {
		set ..clientType="clock"
	}elseif propType="p6.dt.TimeNoLimit" {
		set ..clientType="clockInf"
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
	
	Quit $$$OK
}

Method NormalizeTime(aTime As %String = "") As %String [ CodeMode = expression, ZenMethod ]
{
##class(p6.dt.Time).LogicalToDisplay(##class(p6.dt.Time).DisplayToLogical(aTime))
}

Method NormalizeTimeNoLimit(aTime As %String = "") As %String [ CodeMode = expression, ZenMethod ]
{
##class(p6.dt.TimeNoLimit).LogicalToDisplay(##class(p6.dt.TimeNoLimit).DisplayToLogical(aTime))
}

ClientMethod onchangeHandler() [ Language = javascript ]
{
	// force HTML value into value property
	var value = this.getValue();

	// notify our form of the change
	var form = this.getForm();
	if (form) {
		form.controlChangeHandler(this);
	}

	if(this.clientType=='clock') this.setValue(this.NormalizeTime(value));
	if(this.clientType=='clockInf') this.setValue(this.NormalizeTimeNoLimit(value));
	
	// if we are invalid, see if new value makes us valid
	if (this.invalid && this.validationHandler()) {
		this.setProperty('invalid',false);
	}

	// call user event handler 
	zenInvokeCallbackMethod(this.onchange,this,'onchange');
}

}

