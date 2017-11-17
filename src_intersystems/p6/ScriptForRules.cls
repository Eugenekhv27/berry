Include (%occInclude, %cspInclude)

/// методы для генератора правил Csp
/// dimas 2002, shu, shu 031018
Class p6.ScriptForRules Extends %Library.RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

/// формирование кнопки refbook
ClassMethod btRefbook(refbook As %Library.String = "", btText As %Library.String = "") As %Library.String
{
 new sourse,p6refbookRule,btTextRule
 set sourse=""
 if refbook="" quit "" //#
 if btText="" quit "" //#
 set p6refbookRule = $this.GetAttribute(refbook)
 if ('$this.IsDefined(btText)) {
 set btTextRule="..."
 if $extract(btText,7)]"" set btTextRule="."_$extract(btText,7)_"."
 }
 else  {set btTextRule = $this.GetAttribute(btText)}
 set sourse=sourse_" <INPUT "_$$$EOL
 if ($this.IsDefined("readonly")||$this.IsDefined("disabled")) {
	  set sourse=sourse_" disabled "
 }
 set sourse=sourse_" onclick=""p6return="_p6refbookRule_"; "
 set sourse=sourse_idRule_".focus(); "
 set sourse=sourse_"if (p6return != '') {"_idRule_".valueId = p6return; ObjectSetId("_idRule_".name,"_idRule_".valueId); "
 // не работает почему-то: _idRule_".value = #server(p6.ClassUtils.DisplayValue('"_displayNameRule_"'))#; "
 set sourse=sourse_idRule_".refresh(); "
 set sourse=sourse_onchangeRule_" } "" "_$$$EOL
 // $extract(refbook,10) - делает в id кнопки (пусто, 2, 3)
 set sourse=sourse_"     id=""bt_"_idRule_$extract(refbook,10)_""" type=button value="""_btTextRule_""">"_$$$EOL  
 quit sourse
 //#shu 020208
}

/// формирование name и id из localName
ClassMethod localNameRule()
{
	set localNameRule = $this.GetAttribute("localname")
	Do $this.SetAttribute("name",localNameRule)
	set idRule=$translate(localNameRule,".()^","_____")
	Do $this.SetAttribute("id",$translate(localNameRule,".()^","_____"))
	
	/// Формирование желтеньких переходов
	do $this.SetAttribute("onfocus",$this.GetAttribute("onfocus")_"; this.className='selected'; this.select();")
	do $this.SetAttribute("onblur",$this.GetAttribute("onblur")_"; this.className='';")
	quit
}

/// формирование onchange
ClassMethod onchangeRule(string As %Library.String = "")
{
 set onchangeRule = $this.GetAttribute("onchange")
 //перевод кавычек #server(...)# так требует ???
 set onchangeRule = $translate(onchangeRule,"""","'")
 set string = $translate(string,"""","'")
 Do $this.SetAttribute("onchange",string_" "_onchangeRule_";")
 quit
 //#shu 020208
}

/// разборка для присвоения переменной js литерала или функции
/// если указан префикс "javascript:", то остальная часть считается функцией
///      в остальных случаях - литерал заключается в кавычки
ClassMethod JsValue(str As %Library.String = "") As %Library.String
{
 if ($extract(str,1,11)="javascript:") {
	 set str = $extract(str,12,999)
	 if ($extract(str,$length(str))'=";") {set str = str_";"}
 } else {
	 set str = """"_str_""";"
 }
 quit str
}

}

