/// набор методов для преобразования данных при переходе на новую версию
/// 
/// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
/// !!! 
/// !!!  При добавлении методов ставьте дату, чтобы можно было удалять старые.
/// !!!
/// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
/// 
Class admin.Version Extends %RegisteredObject [ ClassType = "", ProcedureBlock ]
{

/// Номер версии, номер сборки из библиотеки Svn
Parameter VERSION = 1.31;

/// Обновление структур, очистка отладочных массивов
ClassMethod Update() As %Library.Status
{
 write !,"Методы обновления ##class(admin.Version).Update()...",!

 
 quit $$$OK
}

ClassMethod fillGeDate() As %Status
{
	&sql(declare b cursor for 
		select id into :id from ent.Buyer)
	&sql(open b)	
	&sql(fetch b)	
	while (SQLCODE=0) {
		set b=##class(ent.Buyer).%OpenId(id)
		set b.RegDate  =  64284 + $R(360)
		d b.Save()
		
		&sql(fetch b)	
	}
	&sql(close b)
}

}

