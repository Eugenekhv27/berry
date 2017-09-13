/// Created using the page template: Default
Class p6.zen.admin.p6AllClassesValidate Extends p6.zen.EditPage
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "zui.Application";

/// Displayed name of this page.
Parameter PAGENAME = "Проверка данных во всех классах";

/// Domain used for localization.
Parameter DOMAIN;

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
</style>
}

/// This XML block defines the contents of this page.
XData editPane [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane  xmlns="http://www.intersystems.com/zen" xmlns:p6="http://www.dimas.ru/p6" id="editPane">
<html align="center" OnDrawContent="Test" ></html>
<button id="btClose" align="center" caption="Закрыть окно" onclick="CloseWindow()" />
</pane>
}

Method Test(seed) As %Status [ ZenMethod ]
{
   
   do ##class(p6.ClassValidate).AllClasses(.temp) 
   write "<p>"
	set tempI = $order(temp(""))
	while (tempI) {
		set a0= temp(tempI), aClass=$li(a0,1), aId=$li(a0,2), aSc=$li(a0,3)
		write aClass
  		set classAka=##class(p6.ClassDefinition).GetClassCaption(aClass)
		if (classAka]"") {write " ("_classAka_")"}
		write ": [", aId
		xecute "set obj=##class("_aClass_").%OpenId("""_aId_""")"

		set idAka=""
		if (obj]"") {
  			if (obj.%IsA("fd.FinDoc")) {
	  			set idAka=obj.Aka
  			}
  			if (obj.%IsA("fin.Operation")) {
	  			set idAka=obj.OperationNo_" от "_obj.OperationDateLogicalToDisplay(obj.OperationDate)
  			}
  			if (obj.%IsA("fin.OperationTemplate")) {
	  			set idAka=obj.Aka
  			}
		}
		kill obj
		if (idAka]"") {write " ("_idAka_")"}

		write "] - ", ##class(p6.CspMethods).StatusForAlert(aSc), "<br>"
		set tempI = $order(temp(tempI))
    } 
	 kill temp    
	 quit $$$OK
}

}

