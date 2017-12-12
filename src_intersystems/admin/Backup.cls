/// Внимание! Для работы утилиты резервного копирования директория, 
/// указанная в методе, уже должна существовать на диске!
Class admin.Backup Extends %RegisteredObject [ ClassType = "", ProcedureBlock ]
{

ClassMethod FullBackup(aDirectory As %String = "c:\d_cache\Archive\") As %Status
{
	set fileName=..GetFileName(aDirectory,"full")
	$$$QuitOnError(..DoBackup(fileName,"F"))
	quit $$$OK
}

ClassMethod CumulativeBackup(aDirectory As %String = "c:\d_cache\Archive\") As %Status
{
	set fileName=..GetFileName(aDirectory,"cuml")
	$$$QuitOnError(..DoBackup(fileName,"C"))
	quit $$$OK
}

ClassMethod IncrementalBackup(aDirectory As %String = "c:\d_cache\Archive\") As %Status
{
	set fileName=..GetFileName(aDirectory,"incr")
	$$$QuitOnError(..DoBackup(fileName,"I"))
	quit $$$OK
}

ClassMethod DoBackup(aFileName As %String = "", aTypeLetter As %String = "") As %Status
{
	if aFileName="" || aTypeLetter="" quit $$$ERROR(10000,"Неверные параметры запуска резервного копирования")
	znspace "%SYS"
	set ^SYS("BACKUP","DIRECTORIES","c:\d_cache\dispuser\")="" 
	do BACKUP^DBACK("",aTypeLetter,"",aFileName_".cbk","",aFileName_".log","NOINPUT") 
	kill ^SYS("BACKUP","DIRECTORIES","c:\d_cache\dispuser\")
	znspace "disp"
	quit $$$OK
}

ClassMethod GetFileName(aDirectory As %String, aType As %String = "") As %String
{
    if $extract($reverse(aDirectory)) '= "\" set aDirectory=aDirectory_"\"
    set datePart=..GetDatePartOfFileName($h)
    quit aDirectory_datePart_"-"_aType_"-duser"
}

ClassMethod GetDatePartOfFileName(aDateH As p6.dt.Date) As %String
{
    set dispDate=$ZD(aDateH)
    set year=$piece(dispDate,"/",3)
    set month=$piece(dispDate,"/",1)
    set day=$piece(dispDate,"/",2)
    set fileDate=$extract(year,3,4)_month_day

    set time=$piece($ZDT(aDateH)," ",2)
    set timeWithoutSeconds=$piece(time,":",1,2)
    set fileTime=$translate(timeWithoutSeconds,":","-")
    quit fileDate_"-"_fileTime
}

}

