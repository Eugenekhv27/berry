/// Горизантальная группа<br>
/// Отличие от классической: по умолчанию растягивается на всю возможную ширину,
/// а не собирается уменьшая компоненты до минимума
Class p6.zen.component.hgroup Extends %ZEN.Component.hgroup
{

/// This is the XML namespace for this component
Parameter NAMESPACE = "http://www.dimas.ru/p6";

Parameter DEFAULTWIDTH = "100%";

Parameter DEFAULTCELLSIZE = "stretch";

Method %DrawHTML()
{
	for i=1:1:..children.Count() {
		set Child = ..children.GetAt(i)
		if (+Child.slice=0) {
			set Child.slice =  1
		}
	}


	Do ..%LayoutChildren(..tuple)
}

}

