/// Многострочное текстовое поле
Class p6.zen.component.textarea Extends %ZEN.Component.textarea
{

/// This is the XML namespace for this component.
Parameter NAMESPACE = "http://www.dimas.ru/p6";

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

}

