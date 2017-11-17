IncludeGenerator (%occInclude, %occUtility)

/// The <b>Money</b> data type class represents a maney value.
/// <p><b>Money</b> is essentially the same as the <CLASS>%Numeric</CLASS> data type with
/// <b>clientdatatype</b> of CURRENCY and a fixed SCALE of 2.
Class p6.dt.Money Extends %Currency
{

/// Converts the input value <var>%val</var>, which is a string representing
/// a currency value, into a logical currency value.
/// <p>Returns the value of the input string <var>%val</var> as a currency (fixed point number).
ClassMethod DisplayToLogical(%val As %String) As %Currency [ CodeMode = generator ]
{
 s %code=0
 $$$GENERATE(" if '(%val?.1""-"".N.1""."".1"","".N) set %objlasterror=$system.Status.Error(10000,""Номер введен неверно"")")
 i %parameter("VALUELIST")'="",%parameter("DISPLAYLIST")'="" d  QUIT $$$OK
 . s sep=$e(%parameter("DISPLAYLIST"))
 . s len=$l(%parameter("DISPLAYLIST"),sep)
 . f i=2:1:$l(%parameter("DISPLAYLIST"),sep) $$$GENERATE(" q:%val="_$$quote($p(%parameter("DISPLAYLIST"),sep,i))_" "_$$quote($p(%parameter("VALUELIST"),sep,i)))
 . $$$GENERATE(" q """"")
 $$$GENERATE(" quit $in($tr(%val,"","","".""),"""_%parameter("FORMAT")_""","""")")
 QUIT $$$OK
}

/// Converts the value of <var>%val</var>, which is in currency FORMAT, into a display string.
/// <p>Returns the FORMATted value of <var>%val</var>.
ClassMethod LogicalToDisplay(%val As %Currency) As %String [ CodeMode = generator ]
{
 s %code=0
 i %parameter("VALUELIST")'="",%parameter("DISPLAYLIST")'="" d  QUIT $$$OK
 . s sep=$e(%parameter("VALUELIST"))
 . s len=$l(%parameter("VALUELIST"),sep)
 . f i=2:1:$l(%parameter("VALUELIST"),sep) $$$GENERATE(" q:%val="_$$quote($p(%parameter("VALUELIST"),sep,i))_" "_$$quote($p(%parameter("DISPLAYLIST"),sep,i)))
 . $$$GENERATE(" q """"")
 s %codemode=$$$cMETHCODEMODEEXPRESSION

 s temp=""""_%parameter("FORMAT")_""""
 s temp=temp_",2"
 s %code="$s(%val="""":"""",1:$fn(%val,"_temp_"))"
 QUIT $$$OK
}

}

