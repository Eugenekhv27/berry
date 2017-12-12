/// Тип данных - ДАТА
Class p6.dt.Date Extends %Date
{

/// The format specification for the data type's display value.
/// The value of the <var>FORMAT</var> parameter corresponds to the
/// available parameters of the <code>$ZDATE</code> and <code>$ZDATEH</code> functions,
/// which are used to perform the formatting.
Parameter FORMAT = 4;

/// Converts the input value <var>%val</var>, which represents a date, into <code>$H</code> format.
/// <p>Returns the logical (<code>$H</code>) value of the input string <var>%val</var>.
ClassMethod DisplayToLogical(dateExt As %String) As p6.dt.Date
{
 if (dateExt="") { quit "" } //#
 if ($extract(dateExt)="=") { quit +$horolog } //# текущая дата
 if "-+"[$extract(dateExt) {
	 set date=$horolog+dateExt
	 quit date //# смещение от текущей даты
 }
 
 //# дата без разделителя (6 или 8 цифр)
 if ($tr(dateExt,"1234567890")="") && (($length(dateExt)=6) || ($length(dateExt)=8)) {
	 set dateExt=""_$extract(dateExt,1,2)_"/"_$extract(dateExt,3,4)_"/"_$extract(dateExt,5,8)
 }
 
 //# дата в формате Timestamp (yyyy-mm-dd)
 if (dateExt?4n1"-"2n1"-"2n) {
	 quit $zdateh(dateExt,3,,,,,,,"")
 }

 set dateExt=$translate(dateExt," -/,*+","......")
 set dd=+$piece(dateExt,".",1)
 set mm=$piece(dateExt,".",2)
 set yy=$piece(dateExt,".",3)
 // если год или месяц пустые - то взять текущие
 if (yy="") { set date=$zdate(+$h),yy=$piece(date,"/",3) }
 if (mm="") { set mm=$piece(date,"/",1) }
 set mm=+mm,yy=+yy
 // если год 1 или 2 цифры, то до 49 2000 (2000-2049), иначе 1900 (1950-1999)
 if ($length(yy)<3) { if (yy<50) { set yy=yy+2000 } else  { set yy=yy+1900 } }
 set date=mm_"/"_dd_"/"_yy
 set ret=$zdateh(date,,,,,,,,"err")
 if ret="err" set %objlasterror=$system.Status.Error(10000,"Дата введена неверно") 
 if +ret=0 quit ""
 quit ret
}

/// Converts the value of <var>%val</var>, which is in logical <code>$H</code> format, into a display string.
/// The formatting is based on the value of the <a href="#FORMAT">FORMAT</a> parameter.
/// <p>Returns the formatted value of <var>%val</var>.
ClassMethod LogicalToDisplay(%val As p6.dt.Date) As %String [ CodeMode = expression ]
{
$tr($s(+%val=0:"",1:$zd(%val,4,,4,50,49,,,"")),"/",".")
}

}

