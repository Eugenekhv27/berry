/// Вертикальная группа
Class p6.zen.component.vgroup Extends %ZEN.Component.vgroup
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

