/// Преобразование формата Horolog и TimeStamp
Class p6.Horolog Extends %Library.RegisteredObject [ ClassType = "", ProcedureBlock ]
{

/// Преобразование в формате $horolog в тип данных %TimeStamp
ClassMethod LogicalToTimeStamp(arg As %String = "") As %TimeStamp
{
 if (arg="") { quit "" } //#
 set date=$zdate(arg,3,,,,,,,"error")
 set time=+$piece(arg,",",2)
 if (time=0) { set time="00:00:00" }
 else { 
 	set h=$justify(time#86400\3600,2),m=$justify(time#3600\60,2),
 		s=$justify(time#60,2),time=h_":"_m_":"_s,time=$tr(time," ",0)
 }
 quit (date_" "_time)
}

/// Преобразование в формате $horolog в строку DD.MM.YY HH:MM
///   (обычно для печати отчета)
ClassMethod LogicalToReportTime(arg As %String = {$horolog}) As %String
{
 if (arg="") { quit "" } //#
 set date=##class(p6.Date).LogicalToDisplay($piece(arg,",",1))
 set time=+$piece(arg,",",2)
 if (time=0) { set time="00:00" }
 else {
	 set h=$justify(time#86400\3600,2),m=$justify(time#3600\60,2),
	 	time=h_":"_m,time=$tr(time," ",0)
 }
 quit (date_" "_time)
}

/// Разность между значениями в формате TimeStamp
ClassMethod DifferenceOfTimeStamps(beginTs As %TimeStamp = "", endTs As %TimeStamp = "", format As %String = "hm") As %String
{
 if ((beginTs="") || (endTs="")) { quit "" } //#
 set beginH=$zdatetimeh(beginTs,3,,,,,,,,"error")
 set endH=$zdatetimeh(endTs,3,,,,,,,,"error")
 if ((beginH="error") || (endH="error")) { quit "error" } //#
 set dif=..DifferenceOfLogicals(beginH,endH,format)
 quit dif
}

/// Разность между значениями в формате Horolog
ClassMethod DifferenceOfLogicals(beginH As %String = "", endH As %String = "", format As %String = "hm") As %String
{
 if ((beginH="") || (endH="")) { quit "" } //#
 set days=endH-beginH
 if (days<0) { quit "error" } //#
 set secs = ($piece(endH,",",2)-$piece(beginH,",",2)) + (days*86400)
 if (secs<0) { quit "error" } //#
 set dif=secs
 if (format="hm") {
	 set dif=(secs\3600)_":"_$justify(secs#3600\60,2)
 }
 set dif = $translate(dif," ","0")
 quit dif
}

}

