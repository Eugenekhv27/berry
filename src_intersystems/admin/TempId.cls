/// таблица для временного хранения поля (например = Id) при владельце (например = процесс + задача)
Class admin.TempId Extends %Persistent [ ClassType = persistent, ProcedureBlock ]
{

Index OwnerIndex On (Owner, TempId);

Property TempId As %String(TRUNCATE = 1);

Property Owner As %String(TRUNCATE = 1);

/// очищает данные по определенному владельцу
ClassMethod ClearTable(owner As %String = "")
{
	if (owner="") quit
	&sql(delete from admin.TempId where Owner=:owner)
}

/// заполняет Id из указанной строки через ,) по определенному владельцу
ClassMethod FillTableFromString(dataString As %String = "", owner As %String = "") As %Status
{
	if ((dataString="") || (owner="")) quit $$$ERROR(10000,"admin.TempId: неверные параметры")
	for i=1:1:$Length(dataString,",") {
		do ..FillData($Piece(dataString,",",i),owner)
	}
	quit $$$OK
}

/// заносит Id по определенному владельцу
ClassMethod FillData(aId As %String = "", aOwner As %String = "") As %Status
{
	if ((aId="") || (aOwner="")) quit $$$ERROR(10000,"admin.TempId: неверные параметры")
	set obj = ..%New()
	set obj.TempId = aId
	set obj.Owner = aOwner
	quit obj.%Save()
	kill obj
}

Storage Default
{
<Data name="TempIdDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Owner</Value>
</Value>
<Value name="3">
<Value>TempId</Value>
</Value>
</Data>
<DataLocation>^CacheTemp.admin.TempIdD</DataLocation>
<DefaultData>TempIdDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^CacheTemp.admin.TempIdD</IdLocation>
<IndexLocation>^CacheTemp.admin.TempIdI</IndexLocation>
<StreamLocation>^CacheTemp.admin.TempIdS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

