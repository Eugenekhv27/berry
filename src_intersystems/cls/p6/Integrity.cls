/// Класс предназначен для обеспечения ссылочной целостности
Class p6.Integrity Extends p6.Persistent [ Abstract, ProcedureBlock ]
{

// Информация о ссылках хранится в глобали вида:

//      ^admin.Integrity("S", className, ID, refClassName, refID)

//      ^admin.Integrity("D", refClassName, refID, ClassName, ID)

// где, "S" - ветвь, работа с которой ведется через метод Save()

//      "D" - ветвь, работа с которой ведется через метод DeleteId()

// Суть: в объекте класса=className с Id=ID есть ссылка на 

//         объект класса=refClassName c Id=refID

// 

// От данного класса должны наследоваться все хранимые классы,

// для которых необходимо отслеживать ссылочную целостность.

// При этом работа с объектами должна вестись не через 

// стандартные методы %Save() и %DeleteId(), а через

// методы Save() и DeleteId(), которые определены в данном классе

// shu 040130 TCOMMIT заменен на if ($TLEVEL>0) { TCOMMIT }

// 

// Параметры классов, используемые p6.Integrity:

// * NotIntegrityProperties - через запятую список свойств, по которым не строится Integrity

// * ChildClasses - через запятую список дочерних классов в формате <полное имя класса>:<поле-ссылка>

//     эти классы удалятся вместе с родительским классом.

///  Сохранение объектов
Method Save() As %Library.Status [ PublicList = (NewObject, canSave) ]
{

  new canSave, NewObject

  if ('$data(^CacheTemp.IsNotExceptionInIntegrity))
  {
     set $ztrap="ExceptionProcessing1"
  }
  

  set NewObject = "" //признак изменение-M / новый-N
  // флаг разрешения сохранения
  set canSave = $$$YES
  
  // начинаем транзакцию
  TSTART

  set ^CacheTemp.CurrentSavedObjectClassName($job) = ..%ClassName(1)
  // проводим валидацию объекта
  set sc = ..%ValidateObject()

  if ($$$ISERR(sc))
  {
    TROLLBACK
    quit sc
  }

  // вызываем свой OnBeforeSave()
  set sc = ..OnBeforeSave()
  if ($$$ISERR(sc))
  {
    TROLLBACK
    quit sc
  }
  // сохраняем объект, автоматом вызовутся %OnBeforeSave() и %OnAfterSave()
  set sc = ..%Save()
  //set ^a(..%ClassName())= $get(^a(..%ClassName()))_":"_NewObject
  if ($$$ISERR(sc))
  {
    TROLLBACK
    quit sc
  }

  // вызываем свой OnAfterSave()
  set sc = ..OnAfterSave()
  if ($$$ISERR(sc))
  {
    TROLLBACK
    quit sc
  }

  // протокол изменений NewObject = N, M
  if ..#LOGDETALISATION do ##class(admin.LogObject).Put(##this,$get(NewObject))

  // подтверждаем завершение транзакции
  kill ^CacheTemp.CurrentSavedObjectClassName($job)
  if ($TLEVEL>0) { TCOMMIT }
  quit $$$OK

ExceptionProcessing1
  set errCode=$ZE
  TROLLBACK
  quit $$$ERROR(10000,##class(p6.ClassUtils).GetTransactionErrorMessage("Save",errCode))
}

/// свой OnBeforeSave
Method OnBeforeSave() As %Status [ Private ]
{
  quit $$$OK
}

/// свой OnAftersave
Method OnAfterSave() As %Status [ Private ]
{
  quit $$$OK
}

/// разрешаем сохранять объект только через метод Save()
Method %OnBeforeSave(Insert As p6.dt.Boolean) As %Status [ Private, PublicList = (NewObject, canSave) ]
{
  set NewObject = $select(Insert:"N",1:"M") // новый или модификация
  if ('$data(canSave)) quit $$$ERROR(10000, "Нельзя сохранить объект класса "_..%ClassName(1)_" напрямую через метод %Save(). Необходимо использовать метод Save().")
  quit $$$OK
}

/// разрешаем сохранять объект только через метод Save()
Method %OnAfterSave(Insert As p6.dt.Boolean) As %Status [ Private, PublicList = canSave ]
{
  if ('$data(canSave)) quit $$$ERROR(10000, "Нельзя сохранить объект класса "_..%ClassName(1)_" напрямую через метод %Save(). Необходимо использовать метод Save().")
  // обновляем для объекта информацию по ссылкам
  do ##class(p6.IntegrityUtils).UpdateDataByObject(##this)
  quit $$$OK
}

///  Удаление объектов
ClassMethod DeleteId(id As %Library.String) As %Library.Status [ PublicList = canDelete ]
{

  if ('$data(^CacheTemp.IsNotExceptionInIntegrity))
  {
     set $ztrap="ExceptionProcessing2"
  }

  // узнаем имя класса удаляемого объекта
  set sc = $zobjclassmethod(..%ClassName(1),"%OnDetermineClass",$lb(id),.className)

  // флаг разрешения удаления
  new canDelete set canDelete = $$$YES

  // начинаем транзакцию
  TSTART

  // перед непосредственным удалением объекта - удаляем все объекты в child-классах
  //set sc = ##class(p6.IntegrityUtils).DeleteChildObjects(className, id)
  //if ($$$ISERR(sc))
  //{
   // TROLLBACK
    //quit sc
  //}

  // вызываем свой OnBeforeDelete()
  set sc = $zobjclassmethod(className,"OnBeforeDelete",id)
  if ($$$ISERR(sc))
  {
    TROLLBACK
    quit sc
  }

  // проверяем наличие ссылок на объект этого класса с Id=id
  //set sc = ##class(p6.IntegrityUtils).CheckDataById(className, id)
  //if ($$$ISERR(sc))
  //{
  //  TROLLBACK
  //  quit sc
  //}

  // удаляем объект, автоматом вызовется %OnDelete()
  set sc = $zobjclassmethod(className,"%DeleteId",id)
  if ($$$ISERR(sc))
  {
    TROLLBACK
    quit sc
  }

  // вызываем свой OnAfterDelete()
  set sc = $zobjclassmethod(className,"OnAfterDelete",id)
  if ($$$ISERR(sc))
  {
    TROLLBACK
    quit sc
  }

  // после удаления объекта, удаляем инфу о тех ссылках которые были в нем
  //do ##class(p6.IntegrityUtils).RemoveDataById(className, id)

  // протокол удаления объекта
  do ##class(admin.LogObject).PutId(className,id,"D")

  // подтверждаем завершение транзакции
  if ($TLEVEL>0) { TCOMMIT }
  quit $$$OK


ExceptionProcessing2
 set errCode=$ZE 
  TROLLBACK
  quit $$$ERROR(10000,##class(p6.ClassUtils).GetTransactionErrorMessage("DeleteId",errCode))
}

/// свой OnBeforeDelete
/// [Previously private]
ClassMethod OnBeforeDelete(id As %String) As %Status
{
  quit $$$OK
}

/// свой OnAfterDelete
/// [Previously private]
ClassMethod OnAfterDelete(id As %String) As %Status
{
  quit $$$OK
}

/// [Previously private]
ClassMethod %OnDelete(oid As %ObjectIdentity) As %Status [ PublicList = canDelete ]
{
  if ('$data(canDelete)) quit $$$ERROR(10000, "Нельзя удалить объект напрямую через метод %DeleteId(). Необходимо использовать метод DeleteId().")
  quit $$$OK
}

// Прочие методы обратного вызова,

// чтобы можно было наследовать

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

}

