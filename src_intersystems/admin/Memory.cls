/// Временная память, буфер для подсказок. На систему, на человека
Class admin.Memory Extends %Library.RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

/// Чтение из памяти: 
/// 1 поле - тема, предмет; 
/// 2 поле - владелец, человек; 
/// возвращает - текст
ClassMethod Get(subject As %Library.String = "", owner As %Library.String = "") As %Library.String
{
 if subject="" quit ""
 if owner="" quit $get(^admin.memory(subject))
 quit $get(^admin.memory(subject,owner))
}

/// Запись в память: 
/// 1 поле - текст
/// 2 поле - тема, предмет; 
/// 3 поле - владелец, человек; 
ClassMethod Put(text As %Library.String = "", subject As %Library.String = "", owner As %Library.String = "")
{
 if subject="" quit
 if owner="" set ^admin.memory(subject)=text quit
 set ^admin.memory(subject,owner)=text
 quit
}

}

