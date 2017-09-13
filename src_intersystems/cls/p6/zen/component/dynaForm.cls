/// Динамическое создание формы: для кождого свойства создается свой компонент редактирование.
/// Это расширение только добовляет <class>p6.zen.component.buttonsEdit</class> в конец формы
Class p6.zen.component.dynaForm Extends %ZEN.Component.dynaForm
{

/// This is the XML namespace for this component
Parameter NAMESPACE = "http://www.dimas.ru/p6";

/// Добавили кнопки редактирования
Method %InjectControls() As %Status [ Internal ]
{
	$$$QuitOnError(##super())
	set buttonsEdit=##class(p6.zen.component.buttonsEdit).%New()
	do ..%AddChild(buttonsEdit)
	quit $$$OK
}

}

