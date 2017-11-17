/// абстрактный для порождения всех классов Dimas 
Class p6.Persistent Extends %Library.Persistent [ Abstract, ClassType = "", Inheritance = right, ProcedureBlock, PropertyClass = Utils.JsonParams ]
{

Parameter PROPERTYVALIDATION = 2;

/// Детализация логов по объекту: 1-вести дату и пользователя,
///     0-не вести протокол
Parameter LOGDETALISATION = 1;

/// Детализация логов по объекту: 1- сохранять в логе помимо даты
///  и пользователя состояние объекта после изменения (select * )
/// //     0-не сохранять в логе данное поле
Parameter LOGDETALISATIONWITHSTATE = 0;

ClassMethod GetCaption() As %String
{
 quit ..#CAPTION
}

Method Save() As %Library.Status [ PublicList = (NewObject, canSave) ]
{
   set $ztrap="ExceptionProcessing1"

   set NewObject = "" //признак изменение-M / новый-N
   // начинаем транзакцию
   TSTART
   // проводим валидацию объекта
   set sc = ..%ValidateObject()
   if ($$$ISERR(sc)) { TROLLBACK  quit sc }
   // вызываем свой OnBeforeSave()
   set sc = ..OnBeforeSave()
   if ($$$ISERR(sc)) { TROLLBACK  quit sc }
   // сохраняем объект, автоматом вызовутся %OnBeforeSave() и %OnAfterSave()
   set sc = ..%Save()
   if ($$$ISERR(sc)) { TROLLBACK  quit sc }
   // вызываем свой OnAfterSave()
   set sc = ..OnAfterSave()
   if ($$$ISERR(sc)) { TROLLBACK  quit sc }
   // протокол изменений NewObject = N, M
   if ..#LOGDETALISATION do ##class(admin.LogObject).Put(##this,$get(NewObject))
   // подтверждаем завершение транзакции
   TCOMMIT
   quit $$$OK

ExceptionProcessing1
   set errCode=$ZE
   TROLLBACK
   quit $$$ERROR(10000,##class(p6.ClassUtils).GetTransactionErrorMessage("Save",errCode))
}

Method OnBeforeSave() As %Status [ Private ]
{
 quit $$$OK
}

Method OnAfterSave() As %Status [ Private ]
{
 quit $$$OK
}

Method %OnBeforeSave(Insert As p6.dt.Boolean) As %Status [ Private, PublicList = (NewObject, canSave) ]
{
 set NewObject = $select(Insert:"N",1:"M") // новый или модификация
 // if ('$data(canSave)) quit $$$ERROR(10000, "Нельзя сохранить объект напрямую через метод %Save(). Необходимо использовать метод Save().")
 quit $$$OK
}

Method %OnAfterSave(Insert As p6.dt.Boolean) As %Status [ Private ]
{
 // if ('$data(canSave)) quit $$$ERROR(10000, "Нельзя сохранить объект напрямую через метод %Save(). Необходимо использовать метод Save().")
 quit $$$OK
}

ClassMethod DeleteId(id As %Library.String) As %Library.Status [ PublicList = (NewObject, canSave) ]
{
 set $ztrap="ExceptionProcessing2"
 // начинаем транзакцию
 TSTART

 // узнаем имя класса удаляемого объекта
 set tempObj = ..%New()
 set className = tempObj.%ClassName(1)
 do tempObj.%Close()
 // вызываем свой OnBeforeDelete()
 set sc = ..OnBeforeDelete(id)
 if ($$$ISERR(sc)) { TROLLBACK  quit sc }
 // удаляем объект, автоматом вызовется %OnDelete()
 set sc = ..%DeleteId(id)
 if ($$$ISERR(sc)) { TROLLBACK  quit sc }
 // вызываем свой OnAfterDelete()
 set sc = ..OnAfterDelete(id)
 if ($$$ISERR(sc)) { TROLLBACK  quit sc }
 // протокол удаления объекта
 do ##class(admin.LogObject).PutId(className,id,"D")
 // подтверждаем завершение транзакции
 TCOMMIT
 quit $$$OK


ExceptionProcessing2
 set errCode=$ZE
 TROLLBACK
 quit $$$ERROR(10000,##class(p6.ClassUtils).GetTransactionErrorMessage("DeleteId",errCode))
}

/// [Previously private]
ClassMethod OnBeforeDelete(id As %String) As %Status
{
 quit $$$OK
}

/// [Previously private]
ClassMethod OnAfterDelete(id As %String) As %Status
{
 quit $$$OK
}

Method %OnValidateObject() As %Status [ Private ]
{
 quit $$$OK
}

Method %OnNew(Param As %CacheString = "") As %Status [ Private ]
{
 quit $$$OK
}

Method %OnOpen() As %Status [ Private ]
{
 quit $$$OK
}

/// SQL-фильтр, возвращающий ограничение на выбираемые записи по абоненту
ClassMethod GetModelFilter() As %String
{
	quit ""
}

// 

// Новые методы для работы по REST

// 

ClassMethod GetForGrid(query = "", accountId = "") As %Status
{
    set st = $$$OK
    set propertyType = $$$comMemberKeyGet(..%ClassName(1),$$$cCLASSproperty,"Aka",$$$cPROPtype)
    set aAka=""
    if propertyType]"" { 
    	set aAka = ",Aka"
    }
    set sql = "select Id"_aAka_" from "_ ..%ClassName(1)
    	_ " where Shop="_accountId 
    
    if query]"" {
	 set sql = sql _" and "_query  
    }
	set:aAka]"" sql = sql _ " order by Aka"
    do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,sql,,1000)
    quit st
}

ClassMethod SaveTargetObject(json, className) As %Status
{
	kill ^a.line
	set sc = $$$OK
	
	
	do ##class(Utils.JsonProvider).%ConvertJSONToObject(json,"",.clientObj,1)
	
	
	/// Данные по объекту находятся в свойстве "object"
	set obj= clientObj.object
	set ^a.line("LinesForDel","00")=obj.LinesForDel
	if obj.id="" {
		set cacheObj = ..%New()	
	} else {
		set cacheObj = ..%OpenId(obj.id)	
	}
	set aClassName=$classname($this)
	set property="&"
	set i=1
	SET tStatement = ##class(%SQL.Statement).%New()
	for {
		set property=$$$comMemberNext(aClassName,$$$cCLASSproperty,property)
		if property="" quit
		if ($$$comMemberDefined(aClassName,$$$cCLASSproperty,property)
			&&'##class(p6.ClassDefinition).IsPropertyCalculated(aClassName,property)
			&&'##class(p6.ClassDefinition).IsPropertyTransient(aClassName,property)
			&&'(property="renderFlag")
			) { 
			set ^a.prop(i,cacheObj,obj,property)=$Property(obj,property)
			
			set propertyClassName = ##class(p6.ClassDefinition).GetPropertyType(aClassName,property)
			set ^a.prop(i,cacheObj,obj,property,"propertyClassName")=propertyClassName
			if (propertyClassName="p6.dt.Date") {
				set objValue = $Property(obj,property)
				set value = $ZCONVERT(objValue,"I","UTF8")
				set ^a.prop(i,cacheObj,obj,property,"value")=value
				set:value]"" ^a.prop(i,cacheObj,obj,property,"value2")=$p($zdh(value,15),"T")
				set:value]"" $Property(cacheObj,property) = $p($zdh(value,15),"T")
			}
			/*
			elseif propertyClassName="ent.Org" {
				set objValue = $Property(obj,property)
				if $IsObject(objValue) {
					set ogrn = objValue.data.ogrn
					set aka = $e($ZCONVERT(objValue.value,"I","UTF8"),1,50)
					set address = $ZCONVERT(objValue.data.address.value,"I","UTF8")
					&sql(insert or update ent.Org set Aka=:aka,Ogrn=:ogrn,AddressString=:address)
					if %ROWID]"" {
						set $Property(cacheObj,property) = $CLASSMETHOD(propertyClassName,"%OpenId",%ROWID)
					}
				}
			} elseif propertyClassName="ent.Station" {
				
				set objValue = $Property(obj,property)
				if $IsObject(objValue) {
					set aka = $ZCONVERT(objValue.value,"I","UTF8")
					&sql(insert or update ent.Station set Aka=:aka,FullName=:aka)
					if %ROWID]"" {
						set $Property(cacheObj,property) = $CLASSMETHOD(propertyClassName,"%OpenId",%ROWID)
					}
				}
			
			}
			*/
			elseif (propertyClassName["ent.") || (propertyClassName["dtk.") || (propertyClassName["admin.") {
				set propId=""
				
				
				
				set objValue = $Property(obj,property)
				set ^a.prop(i,cacheObj,obj,property,"objValue")=objValue
				if $IsObject(objValue) {
					set objValueAka = $Property(objValue,"Aka")
					set ^a.prop(i,cacheObj,obj,property,"objValueAka")=objValueAka
				
					set sql = "select Id from "_ propertyClassName _ " where Aka='"
						_$ZCONVERT(objValueAka,"I","UTF8")
						_"'"
				
					SET qStatus = tStatement.%Prepare(sql)
					set ^a.prop(i,cacheObj,obj,property,"qStatus")=qStatus
					if (qStatus=1) {
						SET rset = tStatement.%Execute()
						if rset.%Next() {
							set propId = rset.%GetData(1)	
						}
						set ^a.prop(i,cacheObj,obj,property,"propId")=rset.%GetData(1)
					}
					if propId]"" {	
						set $Property(cacheObj,property) = $CLASSMETHOD(propertyClassName,"%OpenId",propId)
						set ^a.prop(i,cacheObj,obj,property,"valueObj") = $Property(cacheObj,property)
					}
				}
			} elseif $Property(cacheObj,property)["%Collection.ListOfDT" {
				set propCollection =  $Property(cacheObj,property)
				do propCollection.Clear()
				
				set ^a.prop(i,cacheObj,obj,property,"obj property") = $Property(obj,property)
				
				if ($Property(obj,property))["%Library.ListOfDataTypes" {
					for i=1:1:$Property(obj,property).Count() { 
						do propCollection.Insert($ZCONVERT($Property(obj,property).GetAt(i),"I","UTF8") )
					}
				}
				
				//set $Property(cacheObj,property)  =$Property(obj,property)
				
			} else {
				set $Property(cacheObj,property)  =$ZCONVERT($Property(obj,property),"I","UTF8")
			}
			set i=i+1
		}
	}
	
	//set cacheObj.UserAccount = ##class(admin.UserAccount).%OpenId(accountId)
	set sc = cacheObj.Save()
	if $$$ISERR(sc) quit sc
	/// Работа с табличной частью
	set ^a.line("LinesForDel")=obj.LinesForDel
	set delData = obj.LinesForDel
	if delData]"" {
		set ^a.line("LinesForDel",1)=1
		set classNameGrid1 = clientObj.grid1.className
		set ^a.line("LinesForDel","classNameGrid1")=classNameGrid1
		set (key,val)=""
		set line = delData.GetNext(.key)
		set ^a.line("LinesForDel","key1")=key
		set ^a.line("LinesForDel","line")=line
   		while (key]"") {
	   		set ^a.line("LinesForDel","key",key)=1
	   		set ^a.line("LinesForDel","line.ID",key)=line.ID
	   		if line.ID]"" {
		   		
				set sc = $CLASSMETHOD(classNameGrid1,"DeleteId",line.ID)		   
				set ^a.line("LinesForDel","sc",key)=sc
				if $$$ISERR(sc) quit		
	   		} 
   			set line = delData.GetNext(.key)
   		}
   		quit sc
	}
	
	
	if clientObj.grid1]"" {
		set classNameGrid1 = clientObj.grid1.className
		set lineData = clientObj.grid1.data
		if (classNameGrid1]"") && (lineData]"") {
			// lineData здесь объект %ListOfObject
			
			set (key,val)=""
			set line = lineData.GetNext(.key)
   			while (key]"") { 
   				set ^a.line(key)=line
   				If line.ID]"" {
	   				set lineObj = $CLASSMETHOD(classNameGrid1,"%OpenId",line.ID)
   				} else {
   					set lineObj = $CLASSMETHOD(classNameGrid1,"%New")
   				}
   				set ^a.line(key,"lineObj")=lineObj
   				set property="&"
				set i=1
				SET tStatement = ##class(%SQL.Statement).%New()
				for {
					set property=$$$comMemberNext(classNameGrid1,$$$cCLASSproperty,property)
					if property="" quit
					set ^a.line(key,i,"property")=property
					if ($$$comMemberDefined(classNameGrid1,$$$cCLASSproperty,property)
						&&'##class(p6.ClassDefinition).IsPropertyCalculated(classNameGrid1,property)
						&&'##class(p6.ClassDefinition).IsPropertyTransient(classNameGrid1,property)
						&&'(property="renderFlag")
					) { 
						set ^a.line(key,i,"property- next")=property
						set propertyClassName = ##class(p6.ClassDefinition).GetPropertyType(classNameGrid1,property)
						set ^a.line(key,i,"propertyClassName")=propertyClassName
						if propertyClassName="admin.UserAccount" {
							//set $Property(lineObj,property)  = ##class(admin.UserAccount).%OpenId(^||CacheTemp.UserAccountId)
						} elseif (propertyClassName["ent.") || (propertyClassName["dtk.") || (propertyClassName["admin.") {
							set propId=""
				
							set objValue = $Property(line,property)
						
						set ^a.line(key,i,"objValue")=objValue
							
							
									
				
							set sql = "select Id from "_ propertyClassName _ " where Aka='"
									_$ZCONVERT(objValue,"I","UTF8")
									_"' and UserAccount="_accountId
				
								SET qStatus = tStatement.%Prepare(sql)
					
								if (qStatus=1) {
									SET rset = tStatement.%Execute()
									if rset.%Next() {
										set propId = rset.%GetData(1)	
									}
						
								}
								if propId]"" {	
									set $Property(lineObj,property) = $CLASSMETHOD(propertyClassName,"%OpenId",propId)
								}
						//	}
						} else {
							//set ^a.line(key,i,"property",property)=$ZCONVERT($Property(line,property),"I","UTF8")
							set $Property(lineObj,property)  = $METHOD(lineObj,property_"DisplayToLogical", $tr($ZCONVERT($Property(line,property),"I","UTF8")," ",""))
						}
						set i=i+1
					}
				}
				
   				// Сохраняем
   				
   				set $Property(lineObj,$piece(aClassName,".",2))  = cacheObj
   				//set cacheObj.UserAccount = ##class(admin.UserAccount).%OpenId(accountId)
				set sc = lineObj.Save()
				set ^a.line(key,"sc")=sc
				if $$$ISERR(sc) quit
   				set line = lineData.GetNext(.key)
   			}		
		}
		
	}
	
	quit sc
}

ClassMethod SaveObject(json) As %Status
{
	kill ^a.line
	set sc = $$$OK
	
	do ##class(Utils.JsonProvider).%ConvertJSONToObject(json,"",.clientObj,1)
	
	//set ^a.line("_json")=clientObj.%ToJSON()
	
	/// Данные по объекту находятся в свойстве "object"
	set obj= clientObj.object
	set ^a.line("LinesForDel","00")=obj.LinesForDel
	if obj.id="" {
		set cacheObj = ..%New()	
	} else {
		set cacheObj = ..%OpenId(obj.id)	
	}
	set aClassName=$classname($this)
	set property="&"
	set i=1
	SET tStatement = ##class(%SQL.Statement).%New()
	for {
		set property=$$$comMemberNext(aClassName,$$$cCLASSproperty,property)
		if property="" quit
		if ($$$comMemberDefined(aClassName,$$$cCLASSproperty,property)
			&&'##class(p6.ClassDefinition).IsPropertyCalculated(aClassName,property)
			&&'##class(p6.ClassDefinition).IsPropertyTransient(aClassName,property)
			&&'(property="renderFlag")
			) { 
			set ^a.prop(i,cacheObj,obj,property)=$Property(obj,property)
			
			set propertyClassName = ##class(p6.ClassDefinition).GetPropertyType(aClassName,property)
			set ^a.prop(i,cacheObj,obj,property,"propertyClassName")=propertyClassName
			if (propertyClassName="p6.dt.Date") {
				set objValue = $Property(obj,property)
				set value = $ZCONVERT(objValue,"I","UTF8")
				set ^a.prop(i,cacheObj,obj,property,"value")=value
				set:value]"" ^a.prop(i,cacheObj,obj,property,"value2")=$p($zdh(value,15),"T")
				set:value]"" $Property(cacheObj,property) = $p($zdh(value,15),"T")
			}
			/*
			elseif propertyClassName="ent.Org" {
				set objValue = $Property(obj,property)
				if $IsObject(objValue) {
					set ogrn = objValue.data.ogrn
					set aka = $e($ZCONVERT(objValue.value,"I","UTF8"),1,50)
					set address = $ZCONVERT(objValue.data.address.value,"I","UTF8")
					&sql(insert or update ent.Org set Aka=:aka,Ogrn=:ogrn,AddressString=:address)
					if %ROWID]"" {
						set $Property(cacheObj,property) = $CLASSMETHOD(propertyClassName,"%OpenId",%ROWID)
					}
				}
			} elseif propertyClassName="ent.Station" {
				
				set objValue = $Property(obj,property)
				if $IsObject(objValue) {
					set aka = $ZCONVERT(objValue.value,"I","UTF8")
					&sql(insert or update ent.Station set Aka=:aka,FullName=:aka)
					if %ROWID]"" {
						set $Property(cacheObj,property) = $CLASSMETHOD(propertyClassName,"%OpenId",%ROWID)
					}
				}
			
			}
			*/
			elseif (propertyClassName["ent.") || (propertyClassName["dtk.") || (propertyClassName["admin.") {
				set propId=""
				
				
				
				set objValue = $Property(obj,property)
				set ^a.prop(i,cacheObj,obj,property,"objValue")=objValue
				if $IsObject(objValue) {
					set objValueAka = $Property(objValue,"Aka")
					set ^a.prop(i,cacheObj,obj,property,"objValueAka")=objValueAka
				
					set sql = "select Id from "_ propertyClassName _ " where Aka='"
						_$ZCONVERT(objValueAka,"I","UTF8")
						_"'"
				
					SET qStatus = tStatement.%Prepare(sql)
					set ^a.prop(i,cacheObj,obj,property,"qStatus")=qStatus
					if (qStatus=1) {
						SET rset = tStatement.%Execute()
						if rset.%Next() {
							set propId = rset.%GetData(1)	
						}
						set ^a.prop(i,cacheObj,obj,property,"propId")=rset.%GetData(1)
					}
					if propId]"" {	
						set $Property(cacheObj,property) = $CLASSMETHOD(propertyClassName,"%OpenId",propId)
						set ^a.prop(i,cacheObj,obj,property,"valueObj") = $Property(cacheObj,property)
					}
				}
			} elseif $Property(cacheObj,property)["%Collection.ListOfDT" {
				set propCollection =  $Property(cacheObj,property)
				do propCollection.Clear()
				
				set ^a.prop(i,cacheObj,obj,property,"obj property") = $Property(obj,property)
				
				if ($Property(obj,property))["%Library.ListOfDataTypes" {
					for i=1:1:$Property(obj,property).Count() { 
						do propCollection.Insert($ZCONVERT($Property(obj,property).GetAt(i),"I","UTF8") )
					}
				}
				
				//set $Property(cacheObj,property)  =$Property(obj,property)
				
			} else {
				set $Property(cacheObj,property)  =$ZCONVERT($Property(obj,property),"I","UTF8")
			}
			set i=i+1
		}
	}
	
	//set cacheObj.UserAccount = ##class(admin.UserAccount).%OpenId(accountId)
	set sc = cacheObj.Save()
	if $$$ISERR(sc) quit sc
	/// Работа с табличной частью
	set ^a.line("LinesForDel")=obj.LinesForDel
	set delData = obj.LinesForDel
	if delData]"" {
		set ^a.line("LinesForDel",1)=1
		set classNameGrid1 = clientObj.grid1.className
		set ^a.line("LinesForDel","classNameGrid1")=classNameGrid1
		set (key,val)=""
		set line = delData.GetNext(.key)
		set ^a.line("LinesForDel","key1")=key
		set ^a.line("LinesForDel","line")=line
   		while (key]"") {
	   		set ^a.line("LinesForDel","key",key)=1
	   		set ^a.line("LinesForDel","line.ID",key)=line.ID
	   		if line.ID]"" {
		   		
				set sc = $CLASSMETHOD(classNameGrid1,"DeleteId",line.ID)		   
				set ^a.line("LinesForDel","sc",key)=sc
				if $$$ISERR(sc) quit		
	   		} 
   			set line = delData.GetNext(.key)
   		}
   		quit sc
	}
	
	
	if clientObj.grid1]"" {
		set classNameGrid1 = clientObj.grid1.className
		set lineData = clientObj.grid1.data
		if (classNameGrid1]"") && (lineData]"") {
			// lineData здесь объект %ListOfObject
			
			set (key,val)=""
			set line = lineData.GetNext(.key)
   			while (key]"") { 
   				set ^a.line(key)=line
   				If line.ID]"" {
	   				set lineObj = $CLASSMETHOD(classNameGrid1,"%OpenId",line.ID)
   				} else {
   					set lineObj = $CLASSMETHOD(classNameGrid1,"%New")
   				}
   				set ^a.line(key,"lineObj")=lineObj
   				set property="&"
				set i=1
				SET tStatement = ##class(%SQL.Statement).%New()
				for {
					set property=$$$comMemberNext(classNameGrid1,$$$cCLASSproperty,property)
					if property="" quit
					set ^a.line(key,i,"property")=property
					if ($$$comMemberDefined(classNameGrid1,$$$cCLASSproperty,property)
						&&'##class(p6.ClassDefinition).IsPropertyCalculated(classNameGrid1,property)
						&&'##class(p6.ClassDefinition).IsPropertyTransient(classNameGrid1,property)
						&&'(property="renderFlag")
					) { 
						set ^a.line(key,i,"property- next")=property
						set propertyClassName = ##class(p6.ClassDefinition).GetPropertyType(classNameGrid1,property)
						set ^a.line(key,i,"propertyClassName")=propertyClassName
						if propertyClassName="admin.UserAccount" {
							//set $Property(lineObj,property)  = ##class(admin.UserAccount).%OpenId(^||CacheTemp.UserAccountId)
						} elseif (propertyClassName["ent.") || (propertyClassName["dtk.") || (propertyClassName["admin.") {
							set propId=""
				
							set objValue = $Property(line,property)
						
						set ^a.line(key,i,"objValue")=objValue
							
							
									
				
							set sql = "select Id from "_ propertyClassName _ " where Aka='"
									_$ZCONVERT(objValue,"I","UTF8")
									_"' and UserAccount="_accountId
				
								SET qStatus = tStatement.%Prepare(sql)
					
								if (qStatus=1) {
									SET rset = tStatement.%Execute()
									if rset.%Next() {
										set propId = rset.%GetData(1)	
									}
						
								}
								if propId]"" {	
									set $Property(lineObj,property) = $CLASSMETHOD(propertyClassName,"%OpenId",propId)
								}
						//	}
						} else {
							//set ^a.line(key,i,"property",property)=$ZCONVERT($Property(line,property),"I","UTF8")
							set $Property(lineObj,property)  = $METHOD(lineObj,property_"DisplayToLogical", $tr($ZCONVERT($Property(line,property),"I","UTF8")," ",""))
						}
						set i=i+1
					}
				}
				
   				// Сохраняем
   				
   				set $Property(lineObj,$piece(aClassName,".",2))  = cacheObj
   				//set cacheObj.UserAccount = ##class(admin.UserAccount).%OpenId(accountId)
				set sc = lineObj.Save()
				set ^a.line(key,"sc")=sc
				if $$$ISERR(sc) quit
   				set line = lineData.GetNext(.key)
   			}		
		}
		
	}
	
	quit sc
}

ClassMethod GetObject(ByRef pParameters, Output pObject As %RegisteredObject) As %Status
{
  set objectId=	$get(pParameters("Id"))
  Set pObject = ..%OpenId(objectId)
  Quit $$$OK
}

}

