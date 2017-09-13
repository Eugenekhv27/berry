IncludeGenerator (%occInclude, %occUtility)

Class p6.dt.Time Extends %Time
{

/// Converts the input value <var>%val</var>, which represents a time value,
/// into a logical time value (number of seconds since midnight).
/// <p>Returns the value of the input string <var>%val</var> as a
/// logical time value (number of seconds since midnight).
ClassMethod DisplayToLogical(timeExt As %String) As %Time
{
 if (timeExt="") q ""
 if ($extract(timeExt)="=") { quit $p($h,",",2) } //# текущее время
 if ($l(timeExt)=3)||($l(timeExt)=1) {s timeExt="0"_timeExt}
 if ($tr(timeExt,"1234567890")="") && ($length(timeExt)=6) {
	 //# время без разделителя (6 цифр)
	 s timeExt=""_$extract(timeExt,1,2)_":"_$extract(timeExt,3,4)_":"_$extract(timeExt,5,6)
 }
 set timeExt=$translate(timeExt," -/,*+.|\;бю","::::::::::::")
 set hh=$piece(timeExt,":",1)
 if ($l(hh)=1) {s hh="0"_hh}
 set mm=$piece(timeExt,":",2)
 set ss = $piece(timeExt, ":", 3)
 // если год или месяц пустые - то взять текущие
 if (hh="") { set time=$zt($p($h,",",2)),hh=$p(time,":",1) }
 if (mm="") { set time=$zt($p($h,",",2)),mm=$piece(time,":",2) }
 if (ss="") { set time=$zt($p($h,",",2)),ss=$piece(time,":",3) }
 if $l(timeExt)=2 s mm="00", ss="00"
 s time=hh_":"_mm_":"_ss

 s ret=$zth(time,,"err")
 if ret="err" set %objlasterror=$system.Status.Error(10000,"Дата введена неверно") quit ""
 quit ret
}

/// Converts the value of <var>%val</var>, which is a logical time value
/// (number of seconds since midnight), into a display string. The formatting is based
/// on the value of the <var>FORMAT</var> parameter.
/// Returns the formatted value of <var>%val</var>.
ClassMethod LogicalToDisplay(%val As %Time) As %String [ CodeMode = generator, ProcedureBlock = 0 ]
{
 n i,len,sep
 k %code s %code=0
 s %codemode=$$$cMETHCODEMODEEXPRESSION
 s %code="$s(%val="""":"""",1:$zt(%val,2))"
 QUIT $$$OK
}

}

