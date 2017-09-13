Class p6.zen.component.ReportPageTopElement Extends %ZEN.Report.CustomAggregate
{

Parameter XMLNAME = "topelement";

Property topField As %ZEN.Report.Datatype.string;

Property Result As %String;

// Property expression As %ZEN.Report.Datatype.string(MAXLEN = 200);

Method ProcessValue(ByRef pValue As %String) As %Status
{
   if ..topField="" quit $$$OK  
   if (..topField="FactDate") {	 
	  set ..Result=##class(p6.dt.Date).LogicalToDisplay(pValue(..topField))	   
   }else{
	    set ..Result=pValue(..topField)
   }	 
   Quit $$$OK
}

Method GetResult() As %String [ ProcedureBlock = 0 ]
{
	
   if ..expression]"" {
		XECUTE "set res="_..expression   
		quit res
   }
   	
   quit ..Result
}

}

