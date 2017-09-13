/// Компонент- список.
/// Элементы списка беруться из DISPLAYLISY связанного свойства типа <class>%String</class>
Class p6.zen.component.combobox Extends %ZEN.Component.combobox
{

/// This is the XML namespace for this component
Parameter NAMESPACE = "http://www.dimas.ru/p6";

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
	set ..required=##class(%Dictionary.CompiledProperty).%OpenId(className_"||"_..dataBinding).Required
	if '..required {
		set ..valueList=##class(%Dictionary.CompiledProperty).%OpenId(className_"||"_..dataBinding).Parameters.GetAt("DISPLAYLIST")
	} else {
		set ..valueList=$e(##class(%Dictionary.CompiledProperty).%OpenId(className_"||"_..dataBinding).Parameters.GetAt("DISPLAYLIST"),2,9999)
	}
	Quit $$$OK
}

/// Обработчик клавиатуры
ClientMethod inputKeyHandler(evt) [ Language = javascript ]
{
	evt = evt ? evt : window.event;
	if ((!this.isDropdownVisible) && (evt.keyCode==zenENTER)) {
		return false;
	}

	// invoke callback, if present
	return this.invokeSuper('inputKeyHandler',arguments);
}

}

