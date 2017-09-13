/// Галочка - да/нет
Class p6.zen.component.checkbox Extends %ZEN.Component.checkbox
{

/// This is the XML namespace for this component
Parameter NAMESPACE = "http://www.dimas.ru/p6";

XData Style
{
<style type="text/css">
input.checkbox {
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
	if ..id="" {
		set ..id=$tr(..dataBinding,"%.()","____")
	}
	if ..name="" {
		set ..name=..id
	}
	Quit $$$OK
}

}

