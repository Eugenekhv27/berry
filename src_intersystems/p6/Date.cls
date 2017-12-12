/// Преобразование даты 
Class p6.Date Extends %Library.RegisteredObject [ ClassType = "", ProcedureBlock ]
{

/// возвращает год
ClassMethod GetYear(date As p6.dt.Date = {+$horolog}) As %Numeric
{
	set year = $piece($zdate(date,3),"-",1)
   quit year
}

ClassMethod GetMonth(date As p6.dt.Date = {+$horolog}) As %Numeric
{
	set month = $piece($zdate(date,3),"-",2)
	// убрать нуль, если число
	if (+month>0) {set month = +month}
   quit month
}

ClassMethod GetDay(date As p6.dt.Date = {+$horolog}) As %Numeric
{
	set day = $piece($zdate(date,3),"-",3)
   quit day
}

/// возвращает дату = первое число того месяца который в date
ClassMethod GetFirstDayOfYear(date As p6.dt.Date = "") As p6.dt.Date
{
	if (date="") { set date= +$H } //#
	set dateString = $zdate(date,3)
   set $piece(dateString,"-",2)="01"
   set $piece(dateString,"-",3)="01"
   quit $zdateh(dateString,3)
}

ClassMethod GetLastDigitOfYear(date As p6.dt.Date = "") As %String
{
	if (date="") { quit "" } //#
	set dateString = $zdate(date,4)
   quit $extract(dateString,$length(dateString))
}

/// возвращает дату = первое число того месяца который в date
ClassMethod GetFirstDayOfMonth(date As p6.dt.Date = "") As p6.dt.Date
{
	if (date="") { quit "" } //#
	set dateString = $zdate(date,3)
   set $piece(dateString,"-",3)="01"
   quit $zdateh(dateString,3)
}

/// возвращает дату = первое число того месяца который перед месяцем в date
ClassMethod GetFirstDayOfPreviosMonth(date As p6.dt.Date = "") As p6.dt.Date
{
	if (date="") quit ""
	set dateString = $zdate(date,3)
   set $piece(dateString,"-",3)="01"
	set month = $Piece(dateString,"-",2)
   if (+month=1) {
	   set year = $Piece(dateString,"-",1)
      set $piece(dateString,"-",2)="12"
      set $piece(dateString,"-",1)=year-1
   }
   else { set $piece(dateString,"-",2)=month-1 }
   quit $zdateh(dateString,3)
}

/// возвращает дату = первое число того месяца который после месяца в date
ClassMethod GetFirstDayOfNextMonth(date As p6.dt.Date = "") As p6.dt.Date
{
	if (date="") quit ""
	set dateString = $zdate(date,3)
   set $piece(dateString,"-",3)="01"
	set month = $Piece(dateString,"-",2)
   if (+month=12) {
	   set year = $Piece(dateString,"-",1)
      set $piece(dateString,"-",2)="01"
      set $piece(dateString,"-",1)=year+1
   }
   else { set $piece(dateString,"-",2)=month+1 }
   quit $zdateh(dateString,3)
}

/// УСТАРЕЛО. Пользуйтесь классом p6.dt.Date.
ClassMethod DisplayToLogical(dateExt As %String = "") As p6.dt.Date
{
 //нет диагностики неверного ввода!!!
 if (dateExt="") { quit "" } //#
 if ($extract(dateExt)="=") { quit +$horolog } //# текущая дата
 if "-+"[$extract(dateExt) {
	 set date=$horolog+dateExt
	 quit date //# смещение от текущей даты
 }
 set dateExt=$translate(dateExt," -/,*+","......")
 set dd=+$piece(dateExt,".",1)
 set mm=$piece(dateExt,".",2)
 set yy=$piece(dateExt,".",3)
 // если год или месяц пустые - то взять текущие
 if (yy="") { set date=$zdate(+$h),yy=$piece(date,"/",3) }
 if (mm="") { set mm=$piece(date,"/",1) }
 set mm=+mm,yy=+yy
 // если год 1 или 2 цифры, то до 19 2000 (2000-2019), иначе 1900 (1920-1999)
 if ($length(yy)<3) { if (yy<20) { set yy=yy+2000 } else  { set yy=yy+1900 } }
 set date=mm_"/"_dd_"/"_yy
 quit $zdateh(date,,,,,,,,"")
 //# shu 000704, 001126, 010205, 020102, 020726, 031125
}

/// Преобразование в формате $horolog в тип данных %TimeStamp
///    устаревшее имя - убрать из системы shu 031213
ClassMethod HToTimeStamp(arg As %String = "") As %TimeStamp
{
 quit (..LogicalToTimeStamp(arg))
}

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
///   перенесен в p6.Horolog 031219
ClassMethod LogicalToReportTime(arg As %String = {$horolog}) As %String
{
 quit (##class(p6.Horolog).LogicalToReportTime(arg))
}

/// Преобразование %var в формате $horolog в тип данных DD-MM-YYYY
ClassMethod LogicalTo10Rus(arg As %String = "") As %TimeStamp
{
 if (arg="") { quit "" } //#
 set date=$zdate(arg,3,,,,,,,"error")
 if (date="error") { quit date } //#
 set y=+date, m=$piece(date,"-",2), d=$piece(date,"-",3)
 set date=d_"-"_m_"-"_y
 quit date
}

/// Преобразование %var в формате $horolog в тип данных DD MMMMMMMM YYYY
ClassMethod LogicalToFullRus(arg As %String = "") As %TimeStamp
{
 if (arg="") { quit "" } //#
 set date=$zd(arg,3,,,,,,,"error")
 if (date="error") { quit date } //#
 set y=+date, m=$piece(date,"-",2), d=$piece(date,"-",3)
 set m=$piece("января февраля марта апреля мая июня июля августа сентября октября ноября декабря"," ",m)
 set date=d_" "_m_" "_y
 quit date
}

/// Преобразует значение <var>dateIntl</var> из логического формата <code>$H</code> 
/// в отображаемую строку вида ДД.ММ.ГГ[ГГ]
/// если 2 агумент=1 всегда выдается год в 4 знака.
/// если 2 аргумент=0 (по умолчанию) то с 1920 по 2019 выдается два последних знака
ClassMethod LogicalToDisplay(dateInt As p6.dt.Date = "", is4 As p6.dt.Boolean = 0) As %CacheString
{
 if (dateInt="") { quit "" } //#
 if (dateInt'?5n) { quit "!date: ["_dateInt_"]" } //# неверный внутренний формат (до 2114)
 set dl=$zdate(dateInt) ;mm/dd/yy[yy]
 set yy=$piece(dl,"/",3)
 if (yy<100) { s yy=yy+1900 }
 if (('is4) && (yy>1919) && (yy<2020)) { set yy=$extract(yy,3,4) } //урезать до 2 знаков
 set dd=$piece(dl,"/",2)_"."_$piece(dl,"/")_"."_yy
 quit dd ;#
 ;# shu 000101, 001126, 010206, 031213
}

/// дата начала указанного месяца
ClassMethod GetBeginOfMonth(year As %String = "", month As %String = "") As p6.dt.Date
{
	if (year="") { set year = $piece($zdate(+$horolog,3),"-",1) }
	if (month="") { set month = $piece($zdate(+$horolog,3),"-",2) }
	set year = +year, month = +month
	if (year<100) {
		if (year<20) { set year = 2000 + year }
		else { set year = 1900 + year }
	}
	quit $zdateh(month_"/1/"_year)
}

/// дата окончания указанного месяца
ClassMethod GetEndOfMonth(year As %Integer = "", month As %Integer = "") As p6.dt.Date
{
	if (year="") { set year = $piece($zdate(+$horolog,3),"-",1) }
	if (month="") { set month = $piece($zdate(+$horolog,3),"-",2) }
	set year = +year, month = +month
	if (year<100) {
		if (year<20) { set year = 2000 + year }
		else { set year = 1900 + year }
	}
	if (month<12) { quit ($zdateh((month+1)_"/1/"_year)-1) } //#
	quit $zdateh(month_"/31/"_year)
}

/// Название месяца
ClassMethod GetMonthName(monthNo As %Integer = "") As %String
{
 set month=$piece("январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь",",",monthNo)
 quit month
}

/// Порядковый номер месяца
ClassMethod GetMonthNo(monthName As %String = "") As %String
{
 set monthList=$ListBuild("январь","февраль","март","апрель","май","июнь","июль","август","сентябрь","октябрь","ноябрь","декабрь")
 quit $ListFind(monthList,monthName)
}

/// Название месяца в родительном падеже
ClassMethod GetMonthNameRp(monthNo As %Integer = "") As %String
{
 set month=$piece("января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря",",",monthNo)
 quit month
}

/// Количество месяцев между датами
ClassMethod GetCountOfMonth(date1 As p6.dt.Date = "", date2 As p6.dt.Date = "") As %Integer
{
	if ((date1="") || (date2="")) { quit "" } //#
	set tempDate=date1
	set count=0
	while (tempDate<date2) {
		set tempDate=..GetFirstDayOfNextMonth(tempDate)
		set count=count+1
	}
	quit count
}

}

