IncludeGenerator (%occInclude, %occUtility)

/// The <b>%Float</b> data type class represents a floating point number.
/// <p>The logical value of the <b>%Float</b> data type is a floating point value.
Class p6.dt.Float Extends %Float
{

/// Converts the input value <var>%val</var>, which is a string representing a floating point value,
/// into a logical floating point value.
/// <p>Returns the logical floating point value of the input string <var>%val</var>.
ClassMethod DisplayToLogical(%val As %String) As %Float [ CodeMode = generator ]
{
 s %code=0
 $$$GENERATE(" if '(%val?.1""-"".N.1""."".1"","".N) set %objlasterror=$system.Status.Error(10000,""Номер введен неверно"")")
 i %parameter("VALUELIST")'="",%parameter("DISPLAYLIST")'="" d  QUIT $$$OK
 . s sep=$e(%parameter("DISPLAYLIST"))
 . s len=$l(%parameter("DISPLAYLIST"),sep)
 . f i=2:1:$l(%parameter("DISPLAYLIST"),sep) $$$GENERATE(" q:%val="_$$quote($p(%parameter("DISPLAYLIST"),sep,i))_" "_$$quote($p(%parameter("VALUELIST"),sep,i)))
 . $$$GENERATE(" q """"")
 $$$GENERATE(" quit $in($tr(%val,"", "","".""),"""_%parameter("FORMAT")_""","""")")
 QUIT $$$OK
}

/// Converts the value of <var>%val</var>, which is in logical floating point format, into a display string.
/// The formatting is based on the value of the <a href="#FORMAT">FORMAT</a> parameter.
/// <p>Returns the formatted value of <var>%val</var>.
ClassMethod LogicalToDisplay(%val As %Float) As %String [ CodeMode = expression, ServerOnly = 1 ]
{
$s($e(%val)=".":0_%val,1:%val)
}

}

