/// Methods for Csp
Class p6.CspMethods Extends %Library.RegisteredObject
{

/// Выполнение метода класса без возвращаемого значения
ClassMethod Do(method As %Library.String = "") [ ProcedureBlock = 0 ]
{
 if method="" quit "" //#
 xecute "do "_method
 quit
}

/// Выполнение метода класса с возвращаемым значением
ClassMethod Function(method As %Library.String = "") As %Library.String [ ProcedureBlock = 0 ]
{
 if method="" quit "" //#
 xecute "set ret = "_method
 quit ret
}

/// выполнение командной строки
ClassMethod Xecute(command As %Library.String = "") [ ProcedureBlock = 0 ]
{
 if command="" quit  //#
 xecute command 
 quit
}

/// Определение относительной ссылки для приложения в виде
/// "/csp/<application>"
/// работает только внутри csp-страницы, где имеется объект %request
ClassMethod ApplicationUrl() As %Library.String [ ProcedureBlock = 1 ]
{
	quit $extract(%request.Application,1,$l(%request.Application)-1)
 //Проверка работы Commit из SmartSVN
}

/// Сообщение об ошибке
ClassMethod DisplayErrorJS(Oref As %CacheObject, aSc As %Status) As %Status
{
	&js<alert(#(##class(%CSP.Page).QuoteJS(..StatusForAlert(aSc)))#);>
	quit $$$OK
}

/// Расшифровка сообщения %Status для IE
ClassMethod StatusForAlert(sc As %Status = {$$$OK}) As %String
{
 if ($$$ISOK(sc)) quit "" //#

 // первоначально - пустое сообщение об ошибке
 set message = ""
 // в этой глобали сидело имя сохраняемого в данный момент класса (это в Integrity, метод - Save())
 set className = $get(^CacheTemp.CurrentSavedObjectClassName($job))

 // пробегаем по всем составляющим ошибки
 do DecomposeStatus^%apiOBJ(sc,.error)
 for i=1:1:error {
	 set str = error(i)

	 // Проверка завершилась неудачно
	 if (error(i,"code")=5802) continue

	 // Ошибка в самой Каше
	 if (error(i,"code")'=+error(i,"code")) continue

	 // Значение больше MAXLEN
	 if (error(i,"code")=7201) {
		 kill embedError
		 set embedSc=error(i,"embeddederror",1)
		 do DecomposeStatus^%apiOBJ(embedSc,.embedError)
		 set propType=$p(embedError(1,"param",1),":",1)
		 set propName=$p(embedError(1,"param",1),":",2)
		 set propertyCaption=##class(p6.ClassDefinition).GetPropertyCaption(propType,propName)
		 set str="Свойство '"_propertyCaption_"', равное '"_error(i,"param",1)_"', состоит из "_$length(error(i,"param",1))_" знаков при максимально допустимой длине "_error(i,"param",2)
	 }

	 // Значение меньше MINLEN
	 if (error(i,"code")=7202) {
		 kill embedError
		 set embedSc=error(i,"embeddederror",1)
		 do DecomposeStatus^%apiOBJ(embedSc,.embedError)
		 set propType=$p(embedError(1,"param",1),":",1)
		 set propName=$p(embedError(1,"param",1),":",2)
		 set propertyCaption=##class(p6.ClassDefinition).GetPropertyCaption(propType,propName)
		 set str="Свойство '"_propertyCaption_"', равное '"_error(i,"param",1)_"', состоит из "_$length(error(i,"param",1))_" знаков при минимально допустимой длине "_error(i,"param",2)
	 }

	 // Значение больше MAXVAL
	 if (error(i,"code")=7203) {
		 kill embedError
		 set embedSc=error(i,"embeddederror",1)
		 do DecomposeStatus^%apiOBJ(embedSc,.embedError)
		 set propType=$p(embedError(1,"param",1),":",1)
		 set propName=$p(embedError(1,"param",1),":",2)
		 set propertyCaption=##class(p6.ClassDefinition).GetPropertyCaption(propType,propName)
		 set str="Свойство '"_propertyCaption_"', равное '"_error(i,"param",1)_"', превышает максимально допустимое занчение '"_error(i,"param",2)_"'"
	 }

	 // Значение отсутствует в VALUELIST и не является пустым
	 if (error(i,"code")=7205) {
		 kill embedError
		 set embedSc=error(i,"embeddederror",1)
		 do DecomposeStatus^%apiOBJ(embedSc,.embedError)
		 set propType=$p(embedError(1,"param",1),":",1)
		 set propName=$p(embedError(1,"param",1),":",2)
		 set propertyCaption=##class(p6.ClassDefinition).GetPropertyCaption(propType,propName)
		 if (error(i,"param",1)]"") set str="Свойство '"_propertyCaption_"', равное '"_error(i,"param",1)_"', должно быть одно из '"_$e(error(i,"param",2),2,9999)_"'"
		 else  set str=" "
	 }
	 // Значение должно быть числовым
	 if (error(i,"code")=7207) {
		 kill embedError
		 set embedSc=error(i,"embeddederror",1)
		 do DecomposeStatus^%apiOBJ(embedSc,.embedError)
		 set propType=$p(embedError(1,"param",1),":",1)
		 set propName=$p(embedError(1,"param",1),":",2)
		 set propertyCaption=##class(p6.ClassDefinition).GetPropertyCaption(propType,propName)
		 set str="Свойство '"_propertyCaption_"', равное '"_error(i,"param",1)_"', должно быть числовым"
	 }
	 // Значение не соответствует шаблону
	 if (error(i,"code")=7209) {
		 kill embedError
		 set embedSc=error(i,"embeddederror",1)
		 do DecomposeStatus^%apiOBJ(embedSc,.embedError)
		 set propType=$p(embedError(1,"param",1),":",1)
		 set propName=$p(embedError(1,"param",1),":",2)
		 set propertyCaption=##class(p6.ClassDefinition).GetPropertyCaption(propType,propName)
		 set str="Свойство '"_propertyCaption_"', равное '"_error(i,"param",1)_"', не соответствует шаблону "_error(i,"param",2)
	 }

	 // если была нарушена уникальность индекса
	 if (error(i,"code")=5808) {
		set indexName = error(i,"param",1)
		set str = "Данная запись уже существует!"
	 }
	 
	 // если не проставлено обязательное поле, то узнаем описание этого поля и вперед ...
	 if (error(i,"code")=5659) {
		 set propertyName = $piece($piece(error(i,"param",1),"::",2),"(",1)
		 set caption = ##class(p6.ClassDefinition).GetPropertyCaption(className,propertyName)
		 if (caption="") set caption=propertyName
		 set str = "Свойство \'"_caption_"\' является обязательным"
	 }
	 // если встречается она из нижеупомянтух фраз, то меняем ее на фразу на русском языке
	 if (error(i,"code")=10000) set str = "Ошибка: "_$get(error(i,"param",1),"Неизвестная ошибка")
	 set message = message_str
 }
 quit message
}

/// Закрывает указанный объект в памяти
ClassMethod CloseOref(orefName As %Library.String = "") [ ProcedureBlock = 0 ]
{
 if orefName="" quit
 set $ztrap="ErrorCloseOref"
 kill @orefName
ErrorCloseOref //
 quit  // закрыли ошибки
 //#shu 020405, 021112
}

ClassMethod Next(codeString As %String = "") [ ProcedureBlock = 0 ]
{
 merge %request.Data=^CacheTemp.RequestDataForNext($job)
 kill ^CacheTemp.RequestDataForNext($job)

 new OldIO, file, fileName

 set OldIO = $io

 set file = ##class(%File).%New("c:\CacheSys\temp"_$job_".txt")
 do file.Open("WN")
 set fileName = file.Name
 use fileName

 xecute codeString

 use OldIO

 do file.Close()
 do file.%Close()

 do ##class(%File).Delete(fileName)
}

}

