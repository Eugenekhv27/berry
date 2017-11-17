/// обеспечение ссылочной целостности
Class p6.IntegrityUtils Extends %Library.RegisteredObject [ ClassType = "", ProcedureBlock ]
{

/// удаление всех child-объектов для объекта с именем класса=className и Id=Id
ClassMethod DeleteChildObjects(aClassName As %String, aId As %String) As %Status
{
	if ((aClassName="") || (aId="")) quit $$$OK
	
	set childClasses = ##class(p6.ClassDefinition).GetParameter(aClassName,"ChildClasses")
	if childClasses="" quit $$$OK
	
	set sc = $$$OK
	
	// пробегаем по всем child-классам и удаляем все объекты
	for i=1:1:$Length(childClasses,",") {
		set classData = $Piece(childClasses,",",i)
		set childClassName = $Piece(classData,":",1)
		set parentPropertyName = $Piece(classData,":",2)
		
		set Rs = ##class(%ResultSet).%New("%DynamicQuery.SQL")

		set sc=Rs.Prepare("select id from "_childClassName_" where "_parentPropertyName_"="_aId,0,"RUNTIME")
		if ($$$ISERR(sc)) quit

		set sc=Rs.Execute("")
		if ($$$ISERR(sc)) quit

		while Rs.Next() {
			set sc = $zobjclassmethod(childClassName,"DeleteId",Rs.GetData(1))
			if ($$$ISERR(sc)) quit
		}

		if ($$$ISERR(sc)) quit
	}
	quit sc
}

/// Обновляет данные по ссылкам для объекта obj.
///  Данный метод вызывается при сохранении объекта в Save().
ClassMethod UpdateDataByObject(AObj As %ObjectHandle) As %Status
{
 if (AObj=$$$NULLOREF) quit $$$ERROR(10000,"Ошибка целостности: не найден объект")
 $$$QuitOnError(..RemoveDataById(AObj.%ClassName(1),AObj.%Id()))
 $$$QuitOnError(..AddDataById(AObj.%ClassName(1),AObj.%Id()))
 quit $$$OK
}

ClassMethod UpdateDataById(aClassName As %String, aId As %String) As %Status
{
 $$$QuitOnError(..RemoveDataById(aClassName,aId))
 $$$QuitOnError(..AddDataById(aClassName,aId))
 quit $$$OK
}

/// удаляет данные по ссылкам для объекта типа className c Id=ID
ClassMethod RemoveDataById(aClassName As %String, aId As %String)
{
 if ((aClassName="") || (aId="")) quit $$$ERROR(10000,"Неверный вызов функции RemoveDataById")

 set keyRefClassName = $order(^admin.Integrity("S",aClassName,aId,""))
 while (keyRefClassName]"")
 {
 	set keyRefId = $order(^admin.Integrity("S",aClassName,aId,keyRefClassName,""))
 	while (keyRefId]"")
 	{
 		kill ^admin.Integrity("S",aClassName,aId,keyRefClassName,keyRefId)
 		kill ^admin.Integrity("D",keyRefClassName,keyRefId,aClassName,aId)
 		set keyRefId = $order(^admin.Integrity("S",aClassName,aId,keyRefClassName,keyRefId))
 	}
 	set keyRefClassName = $order(^admin.Integrity("S",aClassName,aId,keyRefClassName))
 }
 quit $$$OK
}

/// добавляет данные по ссылкам для объекта obj
/// [Previously private]
ClassMethod AddDataById(aClassName As %String, aId As %String) [ PublicList = collection ]
{
 new collection
 do $zobjclassmethod(aClassName,"%OnDetermineClass",$lb(aId),.aClassName)
 set propList = ##class(p6.ClassDefinition).GetPropertyList(aClassName)
 // пробегаем по всем свойствам класса
 for i=1:1:$ListLength(propList)
 {
 	set propName = $List(propList,i)
 	set propType = ##class(p6.ClassDefinition).GetPropertyType(aClassName,propName),
 		propCaption = ##class(p6.ClassDefinition).GetPropertyCaption(aClassName,propName),
 		propPersistent = ##class(p6.ClassDefinition).IsClassPersistent(propType),
 		propCollection = ##class(p6.ClassDefinition).GetPropertyCollection(aClassName,propName),
 		propIntegrity = ##class(p6.ClassDefinition).IsIntegrityForProperty(aClassName,propName),
 		propTransient = ##class(p6.ClassDefinition).IsPropertyTransient(aClassName,propName),
 		propCalculated = ##class(p6.ClassDefinition).IsPropertyCalculated(aClassName,propName)

 	if ((propPersistent) && ($e(propType,1)'="%") && (propIntegrity) && ('propTransient) && ('propCalculated)) {
 		if (propCollection = "") {

 			set propValueId=$zobjclassmethod(aClassName,propName_"GetStored",aId)

 			// если есть ссылка на какой-то объект - добавляем данные о ссылке в глобаль
 			if (propValueId '= "") {

				// определили точное название класса
				do $zobjclassmethod(propType,"%OnDetermineClass",$lb(propValueId),.propType)

 				set str = $get(^admin.Integrity("S",aClassName,aId,propType,propValueId))
 				if ('$find(","_str_",",","_propName_",")) {
 					if (str]"") set str = str_","
 					set ^admin.Integrity("S",aClassName,aId,propType,propValueId) = str_propName
 					set ^admin.Integrity("D",propType,propValueId,aClassName,aId) = str_propName
 				}
 			}
 		}
 		elseif (propCollection = "array")
 		{
 			// определяем значение коллекции
 			xecute "set collection = ##class("_aClassName_").%OpenId("""_aId_""")."_propName
 			set key = collection.Next("")
 			while (key'="") {
 				set oref = collection.GetAt(key)
 				// если есть ссылка на какой-то объект - добавляем данные о ссылке в глобаль
 				if (oref '= $$$NULLOREF) {
 					set str = $get(^admin.Integrity("S",aClassName,aId,oref.%ClassName(1),oref.%Id()))
 					if ('$find(","_str_",",","_propName_",")) {
 						if (str]"") { set str = str_"," }
 						set ^admin.Integrity("S",aClassName,aId,oref.%ClassName(1),oref.%Id()) = str_propName
 						set ^admin.Integrity("D",oref.%ClassName(1),oref.%Id(),aClassName,aId) = str_propName
 					}
 				}
 				set key = collection.Next(key)
 			}
 		}
 	}
 }
 quit $$$OK
}

///  Проверяет наличие ссылок на объект класса refClassName с Id=aId.
///   Данный метод вызывается при удалении объекта в DeleteId().
///    В случае обнаружения ссылок - кидается ошибка.
ClassMethod CheckDataById(aClassName As %String = "", aId As %String = "") As %Status
{
 if (aClassName="") quit $$$ERROR(10000,"Ошибка целостности при проверке наличия ссылок: не задано имя класса для объекта")
 if (aId="") quit $$$ERROR(10000,"Ошибка целостности при проверке наличия ссылок: не задано имя Id объекта")

 set keyClassName = $order(^admin.Integrity("D",aClassName,aId,""))
 while (keyClassName'="")
 {
 	set keyID = $order(^admin.Integrity("D",aClassName,aId,keyClassName,""))
 	while (keyID'="")
 	{
	 	set classCaption = ##class(p6.ClassDefinition).GetClassCaption(keyClassName)
	 	set refClassCaption = ##class(p6.ClassDefinition).GetClassCaption(aClassName)
 		if (classCaption = "") set classCaption = keyClassName
 		// выдаем ошибку о невозможности удаления из-за наличия ссылок
 		set addString=$zobjclassmethod(keyClassName,"GetDisplayValue",keyID)
 		set err=$$$ERROR(10000, "Нельзя удалить объект класса """_refClassCaption_""", т.к. на него есть ссылка в объекте класса """_classCaption_""" с Id = "_keyID_": "_$g(addString)) quit
 		
 		set keyID = $order(^admin.Integrity("D",aClassName,aId,keyClassName,keyID))
 	}
 	if $g(err)]"" quit
 	set keyClassName = $order(^admin.Integrity("D",aClassName,aId,keyClassName))
 }
 if $g(err)]"" quit err
 quit $$$OK
}

// Методы утилиты для "администрирования" ссылочной целостности

/// добавляем данные по ссылкам для всех объектов класса className
ClassMethod AddDataByClass(className As %String)
{
 do ..doUpdateDataByClass(className, $$$NO)
 quit $$$OK
}

/// обновляем данные по ссылкам для всех объектов класса className
ClassMethod UpdateDataByClass(className As %String)
{
 do ..doUpdateDataByClass(className, $$$YES)
 quit $$$OK
}

/// добавляем данные по ссылкам для всех объектов классов classNameList
ClassMethod AddDataByClassList(classNameList As %String)
{
 for i=1:1:$Length(classNameList,",")
 {
 	do ..AddDataByClass($Piece(classNameList,",",i))
 }
 quit $$$OK
}

/// обновляем данные по ссылкам для всех объектов классов classNameList
ClassMethod UpdateDataByClassList(classNameList As %String)
{
 for i=1:1:$Length(classNameList,",")
 {
 	do ..UpdateDataByClass($Piece(classNameList,",",i))
 }
 quit $$$OK
}

/// добавляем либо обновляем данные по ссылкам для всех объектов класса className
/// [Previously private]
ClassMethod doUpdateDataByClass(aClassName As %String, doDelete As p6.dt.Boolean = {$$$YES})
{
 if (aClassName="") { quit } //#
 set rs = ##class(%ResultSet).%New(aClassName_".Extent")
 do rs.Execute()
 while (rs.Next()) {
 	set id = rs.GetData(1)
 	// обновляем либо добавляем данные по ссылкам по данному объекту
 	if (doDelete) { do ..UpdateDataById(aClassName,id) }
 	else { do ..AddDataById(aClassName,id) }
 	kill obj
 }
 kill rs
 quit $$$OK
}

/// добавляем данные по ссылкам для всех классов
ClassMethod UpdateData()
{
 kill ^admin.Integrity

 set beginH = $horolog
 set rs=##class(%ResultSet).%New()
 set rs.ClassName="%ClassDefinition"
 set rs.QueryName="ClassInfo"
 do rs.Execute()
 while (rs.Next()) {
 	set className = rs.GetData(1)
 	set isPersistent=##class(p6.ClassDefinition).IsClassPersistent(className)
 	set superClass=##class(p6.ClassDefinition).GetClassSuper(className)

 	// если имя пакета не начинается с % (пользовательский тип)
 	// и класс хранимый

 	if (($extract(className,1,1)'="%") && (isPersistent)) {
	 	write !,$piece(##class(p6.Horolog).LogicalToTimeStamp($horolog)," ",2),
	 		"   ",className
 		if (..IsIntegrityForClass(className))&&(superClass["p6.Integrity") {
	 		do ..AddDataByClass(className)
	 		write " --done"
 		} else {
	 		write " --skipped"
 		}
 	}
 	kill cd
 }
 kill rs
 set endH = $horolog
 write !,"Общее время: ",
 	##class(p6.Horolog).DifferenceOfLogicals(beginH,endH,"")," сек."
 quit $$$OK
}

//  Методы получения списка суперклассов для определенного класса

ClassMethod GetSuperClasses(className As %String) As %String
{
 set result = ""
 do ..AddSuperClasses(className, .result, $$$NO)
 quit result
}

/// [Previously private]
ClassMethod AddSuperClasses(className As %String, result As %String, withSystem As p6.dt.Boolean)
{
 if (className="") quit

 if (result '= "") set result = result_","
 set result = result_className
 set superClass=##class(p6.ClassDefinition).GetClassSuper(className)


 if (($extract(superClass,1)'="%") || (withSystem))
 {
 	for i=1:1:$Length(superClass,",") do ..AddSuperClasses($Piece(superClass,",",i),.result, withSystem)
 }
 kill cd
 quit $$$OK
}

ClassMethod IsIntegrityForClass(className As %String) As p6.dt.Boolean
{
 set result = ""
 do ..AddSuperClasses(className, .result, $$$YES)
 set index = $find(result,"p6.Integrity")
 if (index=0) quit $$$NO
 quit $$$YES
}

//  Методы для работы с ссылками (выдает списка ссылок, замена ссылок)

/// ищет ссылки на объект типа ClassName с Id = Id в других объектах системы
/// посредством пробега по всем объектам системы
/// результат ложится в массив references(ClassName,Id)=PropertyNameN
///                            references(ClassName,Id,PropertyNameI)=""
ClassMethod GetReferences(findClassName As %String = "", findId As %String = "", references As %CacheString = "") [ PublicList = (findObj, obj, objId) ]
{
 if ((findClassName="") || (findId="")) quit ""

 new findObj,obj,objId
 xecute "set findObj = ##class("_findClassName_").%OpenId("_findId_")"
 if (findObj=$$$NULLOREF) quit ""

 set findClassNameList = ","_##class(p6.IntegrityUtils).GetSuperClasses(findClassName)_","

 // пробегаем по всем классам в системе
 set rsClassInfo=##class(%ResultSet).%New()
 set rsClassInfo.ClassName="%ClassDefinition"
 set rsClassInfo.QueryName="ClassInfo"
 do rsClassInfo.Execute()
 while (rsClassInfo.Next())
 {
 	set className = rsClassInfo.GetData(1)
 	set cd = ##class(%ClassDefinition).%OpenId(className)
 	set isClassPersistent = cd.Persistent
 	kill cd
 	// если класс не системный и хранимый
 	if (($extract(className,1,1)'="%") && (isClassPersistent))
 	{
 		set classNameList = ##class(p6.IntegrityUtils).GetSuperClasses(className)
 		set propertyList = ""
 		// пробегаем по всем свойствам класса
 		for i=1:1:$Length(classNameList,",")
 		{
 			set cd = ##class(%ClassDefinition).%OpenId($Piece(classNameList,",",i))
 			for j=1:1:cd.Properties.Count()
 			{
 				if ($find(findClassNameList,","_cd.Properties.GetAt(j).Type_","))
 				{
 					if (propertyList]"") set propertyList = propertyList_","
 					set propertyList = propertyList_cd.Properties.GetAt(j).Name
 				}
 			}
 			kill cd
 		}

 		// propertyList - список (через ,) имен свойств с искомым типом (findClassName) в классе className
 		// если есть такие свойства
 		if (propertyList'="")
 		{
 			// пробегаем по всем экземплярам класса
 			set rs = ##class(%ResultSet).%New("%DynamicQuery.SQL")
 			do rs.Prepare("select id from "_className,0,"RUNTIME")
 			do rs.Execute("")
 			while (rs.Next())
 			{
 				xecute "set obj = ##class("_className_").%OpenId("_rs.GetData(1)_")"
 				if (obj)
 				{
 					for i=1:1:$Length(propertyList,",")
 					{
 						set objId = ""
 						xecute "if (obj."_$piece(propertyList,",",i)_"=findObj) set objId = obj.%Id()"
 						if (objId]"")
 						{
 							set references(obj.%ClassName(1),objId) = $piece(propertyList,",",i)
 							set references(obj.%ClassName(1),objId,$piece(propertyList,",",i)) = ""
 						}
 					}
 					kill obj
 				}
 			}
 			do rs.Close()
 			kill rs
 		}
 	}
 }
 do rsClassInfo.Close()
 kill rsClassInfo
 kill findObj
 quit $$$OK
}

/// меняем все ссылки на fromObj на ссылки на toObj
/// с ппомощью данных p6.Integrity (то есть меняем олько в тех объектах для которых ведется integrity)
ClassMethod ChangeReferencesByIntegrity(fromClassName As %String = "", fromId As %String = "", toClassName As %String = "", toId As %String = "", statusArray As %CacheString = "") [ PublicList = (fromObj, obj, toObj) ]
{
 if ((fromClassName="") || (fromId="") || (toClassName="") || (toId="")) quit ""

 new fromObj,obj,toObj
 xecute "set fromObj = ##class("_fromClassName_").%OpenId("_fromId_")"
 xecute "set toObj = ##class("_toClassName_").%OpenId("_toId_")"
 if ((fromObj=$$$NULLOREF) || (toObj=$$$NULLOREF)) quit ""

 set keyClassName = $order(^admin.Integrity("D",fromClassName,fromId,""))
 while (keyClassName]"")
 {
 	set keyID = $order(^admin.Integrity("D",fromClassName,fromId,keyClassName,""))
 	while (keyID]"")
 	{
 		xecute "set obj = ##class("_keyClassName_").%OpenId("_keyID_")"
 		if (obj)
 		{
 			set propertyList = ^admin.Integrity("D",fromClassName,fromId,keyClassName,keyID)
 			for i=1:1:$Length(propertyList,",")
 			{
 				xecute "set obj."_$Piece(propertyList,",",i)_" = toObj"
 			}
 			if (..IsIntegrityForClass(obj.%ClassName(1))) set sc = obj.Save()
 			else  set sc = obj.%Save()
 			set statusArray(keyClassName,keyID,propertyList) = ##class(p6.CspMethods).StatusForAlert(sc)
 			kill obj
 		}
 		set keyID = $order(^admin.Integrity("D",fromClassName,fromId,keyClassName,keyID))
 	}
 	set keyClassName = $order(^admin.Integrity("D",fromClassName,fromId,keyClassName))
 }
 quit $$$OK
}

ClassMethod CopyObject(fromObj, toObj) As %Status
{
	if (fromObj.%ClassName(1)'=toObj.%ClassName(1)) quit //$$$ERROR(10000,"Нельзя копировать объекты разных классов")
	
	set className = fromObj.%ClassName(1)
	
	set propertyList = ##class(p6.ClassDefinition).GetPropertyList(className)
	for i=1:1:$ListLength(propertyList)
	{
		set property = $List(propertyList,i)
		if '(##class(p6.ClassDefinition).IsPropertyCalculated(className, property) || ##class(p6.ClassDefinition).IsPropertyPrivate(className, property))
		{
		   set $zobjproperty(toObj,property)=$zobjproperty(fromObj,property)
		}
	}
	quit $$$OK
}

}

