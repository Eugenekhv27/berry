/// Created using the page template: Default
Class zui.admin.ClassDefinitionTable Extends p6.zen.EditPage
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "p6.zen.Application";

/// Displayed name of this page.
Parameter PAGENAME = "Перечень свойств и методов классов";

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

<html align="center" OnDrawContent="Update" ></html>
<button id="btClose"  align="center" caption="Закрыть окно" onclick="CloseWindow()" />
</pane>
}

Method Update(seed) As %Status [ ZenMethod ]
{
 	 Set result=##class(%ResultSet).%New("%ClassDefinition.ClassInfo")
	 Do result.Execute()
 	 &html<<table border="1" cellspacing="0" cellpadding="1">>
 	 &html<<tr><th>ClassName<th>What<th>Name<th>Caption<th>Decription</tr>>

	 While (result.Next()) { 
 		set name=result.GetDataByName("Name") 
 		if $extract(name)'="%",$extract(name,1,3)'="csp",$extract(name,1,3)'="csr" {
 		 set def=##class(%ClassDefinition).%OpenId(name)

 		 // Класс
 			&html<<tr>
 				<td>#(name)#&nbsp;</td>
 				<td>Класс</td>
 				<td>#(name)#&nbsp;</td>
 				<td>&nbsp;</td>
 				<td>#(def.Description)#&nbsp;</td>
 			</tr>>


 		 // Свойства
 		 set count=def.Properties.Count()
 		 for i=1:1:count {
 			set prop=def.Properties.GetAt(i).Name
 			set capt=$get(^oddDEF(name,"a",prop,"P","CAPTION"))
 			set help=$get(^oddDEF(name,"a",prop,4))
 			&html<<tr>
 				<td>#(name)#&nbsp;</td>
 				<td>Свойство</td>
 				<td>#(prop)#&nbsp;</td>
 				<td>#(capt)#&nbsp;</td>
 				<td>#(help)#&nbsp;</td>
 			</tr>>
 		 }
 		 // Методы
 		 Set count=def.Methods.Count()
 		 For i=1:1:count {
 			set prop=def.Methods.GetAt(i).Name
 			set help=$g(^oddDEF(name,"m",prop,4))
 			&html<<tr>
 				<td>#(name)#&nbsp;</td>
 				<td>Метод</td>
 				<td>#(prop)#&nbsp;</td>
 				<td>&nbsp;</td>
 				<td>#(help)#&nbsp;</td>
 			</tr>>
 		 }
 		}
 	 }
 	 &html<</table>>
 	 do result.%Close()
 	 kill result
 	 quit $$$OK
}

ClientMethod Run() [ Language = javascript ]
{
 //zenPage.OnDrawContent();
}

}

