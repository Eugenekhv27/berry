/// Утилиты обслуживания классов
Class p6.ClassUtils Extends %Library.RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

Parameter CAPTION = "Утилиты обслуживания классов";

/// Возвращает значение свойства открытого объекта orefPropertyName или пусто
ClassMethod DisplayValue(orefPropertyName As %Library.String = "", delimiter As %Library.String = "") As %Library.String
{
 if orefPropertyName="" quit ""
 if delimiter="" set delimiter="-"
 set $ztrap="ErrorDisplayName"
 new value, value1, numdel,ff, name
 set numdel=$length(orefPropertyName,",")
 set value1=""
 for ff=1:1:numdel {
 set name=$piece(orefPropertyName,",",ff),value=""
 if (name[".") && ($extract(name,$l(name))'=")") {
	 xecute "set value="_name_"LogicalToDisplay("_name_")"
 } elseif name]"" {
	 xecute "set value="_name
 }
 set value1=value1_delimiter_value
 }
 set value=$extract(value1,2,99999)
 quit value
ErrorDisplayName //
 set value=""
 quit ""
}

/// Получение Id (или следующего) по указанному индексу
ClassMethod IdByIndexEquelNext(index As %Library.String = "", string As %Library.String = "") As %Library.String
{
 if index="" quit ""
 if '$find(index,"(") quit "" ;ошибка в индексе
 new id, indexFind
 if $extract(index,$length(index))=")" set index=$extract(index,1,$length(index)-1) // убрали скобку
 set indexFind=index_","" "_$ZCONVERT(string,"U")_"""" // индекс с пробелом и большие буквы
 if $data(@(indexFind_")")) set id=$order(@(indexFind_","""")")) quit id // equel
 set indexString=$order(@(indexFind_")"))
 if indexString="" quit "" //нет больше индексов
 set id=$order(@(index_",indexString,"""")"))
 quit id
 //#shu 020208
}

/// Загрузка и компиляция всех файлов типа Cdl из указанной директории с поддиректориями
ClassMethod LoadCompileDir(dir As %Library.String = "")
{
 quit dir=""  //#
}

/// Присваивает в открытом объекте свойству типа класс значение Id
ClassMethod SetPropertyId(aName As %Library.String = "", aId As %Library.String = "") As %Library.Status
{
	set $ztrap="ErrorSetPropertyId"
	if (aName="") quit $$$ERROR(10000,"p6.ClassUtils.SetPropertyId: не указано имя свойства")
	
	// если в имени свойства нет "." - значит это просто переменная
	// и делаем ее значение равным id (а открытие объекта определенного класса на совести ...)
	if ($length(aName,".")=1) {
		if (aId]"") xecute "set "_aName_"="_aId
		else  xecute "set "_aName_"="""""
		quit $$$OK
	}
	
	new orefName, propertyName, className, propertyOref, p6find, classNameList, i, cd, j, type
	set objectName=$piece(aName,".",1,$length(aName,".")-1)
	set propertyName=$piece(aName,".",$length(aName,"."))
	
	
	// ищем свойство propertyName в ClassDefinition у orefName
	xecute "set className = "_objectName_".%ClassName(1)"

	set type=##class(p6.ClassDefinition).GetPropertyType(className,propertyName)
	
	// если не нашли, то ошибка
	if (type="") quit $$$ERROR(10000,"p6.ClassUtils.SetPropertyId: В классе ["_className_"] нет такого свойства ["_propertyName_"]")
	// если нашли, но это системный тип, то тоже ошибка
	if ($extract(type)="%") quit $$$ERROR(10000,"p6.ClassUtils.SetPropertyId: Свойство ["_aName_"] имеет неверный тип с % ["_type_"]")
	
	// иначе присваиваем объектному свойству новое значение
	if (aId]"") {
		xecute "set propertyOref = ##class("_type_").%OpenId(aId)"
		xecute "set "_aName_" = propertyOref"
		if (propertyOref) kill propertyOref
	} else {
		xecute "set "_aName_" = """""
	}
	
	quit $$$OK
ErrorSetPropertyId //
	quit $$$OK
	//#shu 020116
}

/// Обновляет индексы во всех хранимых классах в текущей области
/// Логи индексируются в последнюю очередь
ClassMethod UpdateIndices(silent As %Library.String = "", html As %Library.String = "")
{
 new classname
 // список всех классов в области
 Set result=##class(%Library.ResultSet).%New("%Library.ClassDefinition:ClassInfo")
 Do result.Execute()
 while (result.Next()) {
    if ( result.Get("Persistent") && ('result.Get("System")) ) {
       if ('silent) { write !,result.Get("Name"),":",result.Get("Persistent"),":",
          result.Get("System")      //,":",result.Get("Super")
       }
       set classname = result.Get("Name")
       if classname'="admin.LogObject" {
       	xecute "do ##class("_classname_").%PurgeIndices()" 
       	xecute "do ##class("_classname_").%BuildIndices()" 
       }
       if ('silent) { write $j("",30-$length(classname)),"Indices updated..." }
       if (html) { write "<br>" }
    }       
 }
 do result.Close()
 kill result
 xecute "do ##class(admin.LogObject).%PurgeIndices()" 
 xecute "do ##class(admin.LogObject).%BuildIndices()" 
 quit
}

/// Присваивает переменной name значение value,
/// возвращает статус, если ошибка при присвоении (проверка по типу в классе)
ClassMethod SetValue(name As %Library.String = "", value As %Library.String = "") As %Library.Status
{
	set $zt="SetValueError"
 if (name="") quit $$$OK //#
 if $find(value,"""") set value = ##class(p6.Convert).Quote(value) // удвоение кавычек
 set value = $zstrip(value,"<>'e"," ") //удаление пробелов
 //удаление прошлой ошибки
 kill %objlasterror
 if name["." {
	 xecute "set "_name_"="_name_"DisplayToLogical("""_value_""")"
 }
 else  {
	 xecute "set "_name_"="""_value_""""
 }
 if $data(%objlasterror)=1 quit %objlasterror //#
 quit $$$OK
SetValueError
 set $zt=""
 quit $$$ERROR(10000,$ze)
}

ClassMethod GetQueryString(select As %String = "", from As %String = "", where As %String = "", orderBy As %String = "") As %String
{
 new queryString
 if (select="") || (from="") quit ""
 set queryString = "select "_select_" from "_from
 if (where]"") set queryString = queryString_" where ("_where_")"
 if (orderBy]"") set queryString = queryString_" order by "_orderBy
 quit queryString
}

ClassMethod GetListOfProperty(className As %String = "", propertyName As %String = "Id", where As %String = "", orderBy As %String = "") As %List
{
 new result, rs, sc, queryString

 set queryString = ..GetQueryString(propertyName,className,where,orderBy)

 set rs = ##class(%ResultSet).%New("%DynamicQuery.SQL")
 set sc = rs.Prepare(queryString)
 set ^CacheTemp.GetListOfProperty("Prepare") = sc
 if ($$$ISERR(sc)) quit ""
 set sc = rs.Execute("")
 set ^CacheTemp.GetListOfProperty("Execute") = sc
 if ($$$ISERR(sc)) quit ""

 set result = ""
 while (rs.Next())
 {
 set result = result_$ListBuild(rs.GetData(1))
 }
 do rs.%Close()
 quit result
}

ClassMethod GetResultSetOfProperty(className As %String = "", propertyName As %String = "Id", where As %String = "", orderBy As %String = "") As %ResultSet
{
 new rs, queryString
 set queryString = ..GetQueryString(propertyName,className,where,orderBy)
 quit ..GetResultSet(queryString)
}

ClassMethod GetResultSet(queryString As %String = "") As %ResultSet
{
 new rs, sc
 set rs = ##class(%ResultSet).%New("%DynamicQuery.SQL")

 set sc = rs.Prepare(queryString)
 set ^CacheTemp.GetResultSetOfProperty("Prepare") = sc
 if ($$$ISERR(sc)) d rs.%Close() quit $$$NULLOREF

 set sc = rs.Execute("")
 set ^CacheTemp.GetResultSetOfProperty("Execute") = sc
 if ($$$ISERR(sc)) d rs.%Close() quit $$$NULLOREF

 quit rs
}

ClassMethod GetMaxPropertyValue(className As %String = "", propertyName As %String = "Id", where As %String = "") As %String
{
 new result, rs, queryString

 set queryString = ..GetQueryString("max("_propertyName_")",className,where)

 set rs = ..GetResultSet(queryString)
 if rs=$$$NULLOREF quit ""

 do rs.Next()
 set result = rs.GetData(1)
 do rs.%Close()
 quit result
}

ClassMethod IsIdExist(orefName As %String = "", id As %String = "") As p6.dt.Boolean
{
	new result,className,orefClassName,rs,queryString
	
	if orefName'["." quit 1
	xecute "set orefClassName="_$p(orefName,".",1,$l(orefName,".")-1)_".%ClassName(1)"
	set className=##class(%Dictionary.CompiledProperty).%OpenId(orefClassName_"||"_$p(orefName,".",$l(orefName,"."))).Type
	
	if ##class(p6.csp.ClassInterface).IsOpenByIdForClass(className)=0 quit 0
	
	set result=$zobjclassmethod(className,"%ExistsId",id)
	quit result
}

ClassMethod GetRefBookId(className As %String = "", orderBy As %String = "", where As %String = "", value As %String = "") As %String
{
 new resultId, rs, queryString, filter,i

	if ##class(%Dictionary.CompiledProperty).%ExistsId(className_"||Code") {
		set queryString = ..GetQueryString("ID",className,##class(p6.FilterUtils).Add("Code='"_value_"'",where))
		set rs = ..GetResultSet(queryString)
		if rs=$$$NULLOREF quit 0
		do rs.Next()
		if rs.GetData(1)]"" quit rs.GetData(1)
		kill rs
	}


 set field=$piece(orderBy,",",1)
 if field="" quit ""
 
 set addWhere="%SQLUPPER("_field_") LIKE '%"_$zcvt(value,"U")_"%'"
 set filter=##class(p6.FilterUtils).Add(where,addWhere)
 set queryString = ..GetQueryString("ID,"_field,className,filter)
 set queryString = queryString_" order by "_field

 set rs = ..GetResultSet(queryString)

 if rs=$$$NULLOREF quit ""

 set resultId="",i=0
 while rs.Next() {
	 set i=i+1
	 set resultId = rs.GetData(1)
	 if rs.GetData(2)=value quit
 }
 if rs.GetData(2)=value quit resultId
 if i=1 quit resultId
 if (i=0) && (##class(p6.csp.ClassInterface).IsQuickCreate(className)) quit "new"
 if i=0 quit ""
 quit "many"
}

ClassMethod GetLastPropertyValue(className As %String = "", propertyName As %String = "Id", where As %String = "", orderBy As %String = "") As %String
{
 new result, rs, sc, queryString

 set queryString = ..GetQueryString(propertyName,className,where,orderBy)

 set rs = ..GetResultSet(queryString)
 if rs=$$$NULLOREF quit ""

 set result = ""
 while( rs.Next() ) {
 if (rs.GetData(1)]"") set result = rs.GetData(1)
 }
 do rs.%Close()
 quit result
}

ClassMethod GetSumOfProperty(className As %String = "", propertyName As %String = "Id", where As %String = "") As %String
{
 new result, rs, sc, queryString

 set queryString = ..GetQueryString("sum("_propertyName_")",className,where)

 set rs = ..GetResultSet(queryString)
 if rs=$$$NULLOREF quit ""

 do rs.Next()
 set result = rs.GetData(1)
 do rs.%Close()
 quit result
}

ClassMethod GetRecordCount(className As %String = "", propertyName As %String = "Id", where As %String = "") As %Integer
{
 new result, rs, sc, queryString

 set queryString = ..GetQueryString("count("_propertyName_")",className,where)

 set rs = ..GetResultSet(queryString)
 if rs=$$$NULLOREF quit 0

 do rs.Next()
 set result = rs.GetData(1)
 do rs.%Close()
 quit result
}

ClassMethod GetTransactionErrorMessage(methodName As %String = "", errCode As %String = "") As %String
{
 if $get(debug) break
 if errCode="" set errCode=$ZE
 quit "Ошибка в исходном коде метода: "_methodName_". Можно продолжать работать, но необходимо сообщить об этой ошибке разработчикам. Код ошибки:"_errCode
}

ClassMethod CopyProperties(ATo As %RegisteredObject, AFrom As %RegisteredObject, aClassName As %String = "") As %Status
{
	if aClassName="" set aClassName=$classname(AFrom)
	set property="&"
	for {
		set property=$$$comMemberNext(aClassName,$$$cCLASSproperty,property)
		if property="" quit
		if ( $$$comMemberDefined(ATo.%ClassName(1),$$$cCLASSproperty,property)
			&&'##class(p6.ClassDefinition).IsPropertyCalculated($classname(ATo),property)
			&&'(property="renderFlag") //shu12 Internal Class %ZEN.Component.object
			) { set $property(ATo,property)=$property(AFrom,property)
		}
	}
	quit $$$OK
}

ClassMethod Update(aClassName, aField, aId, aValue) As %Status [ ProcedureBlock = 1 ]
{
	set Obj=$zobjclassmethod(aClassName,"%OpenId",aId)
	set $zobjproperty(Obj,aField)=$zobjmethod(Obj,aField_"DisplayToLogical",aValue)
	$$$QuitOnError(Obj.Save())
	quit $$$OK
}

ClassMethod GetOld(aClassName, aField, aId) As %String [ ProcedureBlock = 1 ]
{
	set Obj=$zobjclassmethod(aClassName,"%OpenId",aId)
	set value=$zobjmethod(Obj,aField_"LogicalToDisplay",$zobjproperty(Obj,aField))
	quit value
}

}

