/// Represents a Report within a ZEN application.
/// This is the base class used for all user reports.<br>
/// Note that a report is <em>not</em> a ZEN page; all logic
/// for a report is executed on the server. The client is sent
/// the final output for viewing and printing.
Class p6.zen.ReportPage Extends %ZEN.Report.reportPage [ Abstract, PropertyClass = %ZEN.Report.reportParameters ]
{

Parameter CONTENTTYPE = "text/xml";

/// This is the logical name of this report.
/// If not provided, class name is used.
Parameter REPORTNAME As STRING;

/// If provided, this is the XML namspace that will be used
/// for the generated XML report.
Parameter REPORTXMLNAMESPACE As STRING;

/// Specifies the default display mode used for this report if
/// the URL parameter, <var>$MODE</var>, is not present.
Parameter DEFAULTMODE As STRING [ Constraint = ",odf,html,doc,xls,pdf,xml", Flags = ENUM ] = "xml";

/// If defined, this provides a reference to the external
/// XML data to use in generating the report. If it is
/// not provided, data will be generated from the
/// ReportDefinition XData block.
Parameter DATASOURCE As String;

/// This provides a reference to the external
/// OpenOffice template to use in generating report.
/// Узазываем без url-приложения, пример "/dtk/rep/PrintWaybill.ods"
Parameter TEMPLATE As String;

/// This is the class name of this application this report belongs to.<br>
/// If not defined, this report does not belong to an application.<br>
/// Currently, the application does not bestow any behavior to the report;
/// it serves merely as a way to document that a report is associated with
/// an application.
Parameter APPLICATION As CLASSNAME;

/// See the DATASOURCE parameter for details.
Property Datasource As %String [ InitialExpression = {..#DATASOURCE} ];

/// XML that defines the contents of this report.
XData ReportDefinition
{
}

/// PreHTTP handler.
/// Sets content-type and content-dispositon depending
/// on $MODE and $LOG
ClassMethod OnPreHTTP() As %Boolean [ ServerOnly = 1 ]
{
	If '$IsObject($G(%request)) Quit 1
	
	do %response.SetHeader("PRAGMA","")
	do %response.SetHeader("EXPIRES","")
	do %response.SetHeader("CACHE-CONTROL","")

	Set tMode = $zconvert($G(%request.Data("$MODE",1),..#DEFAULTMODE),"L")
	Set tDisplayLog = $G(%request.Data("$LOG",1),0)
	set reportName=$select(..#REPORTNAME]"":..#REPORTNAME,1:..%ClassName(0))

	if ((tMode '= "html")&&(tMode '= "xml")&&(tMode '= "pdf")&&('tDisplayLog)) {
		if (%session.Data("UserSys",$username,"ReportMode")=2) {
			if ((tMode="odt") || (tMode="doc")){
				set tMode="odt"
			}elseif ((tMode="ods") || (tMode="xls"))
			{
				set tMode="ods"
			}
		}else {
			if ((tMode="odt") || (tMode="doc")){
				set tMode="doc"
			}elseif ((tMode="ods") || (tMode="xls"))
			{
				set tMode="xls"
			}			
		}
	}

	#; set header parameters based on $MODE,$LOG
	If tDisplayLog {
		Set %response.ContentType = "text/plain"
		Do %response.SetHeader("content-disposition","filename="_reportName_"Output.txt")
	} ElseIf (tMode = "html") {
		Do %response.SetHeader("content-disposition","filename="_reportName_".html")
	} ElseIf (tMode = "xml") {
		Set %response.ContentType = "text/xml"
		Do %response.SetHeader("content-disposition","filename="_reportName_".xml")
	} Else {
		Set %response.ContentType = "application/"_tMode
		Do %response.SetHeader("content-disposition","attachment; filename="_reportName_"."_tMode)
	}

	Quit $$$OK
}

/// Render the contents of this ZEN report.
ClassMethod OnPage() As %Status
{
	Set tSC = $$$OK

	Do {
		#; default mode is specified by DEFAULTMODE
		Set tMode = ..#DEFAULTMODE
		Set tDisplayLog = 0
		Set tDatasource=""

		If $IsObject($G(%request)) {
			Set tMode = $zconvert($G(%request.Data("$MODE",1),tMode),"L")
			Set tDisplayLog = $G(%request.Data("$LOG",1),0)
			Set tDatasource=$G(%request.Data("$DATASOURCE",1))
		}
		
		if ((tMode '= "html")&(tMode '= "xml")&('tDisplayLog)) {
			//if (%session.Data("UserSys",$username,"ReportMode")=2) {
			//	if ((tMode="odt") || (tMode="doc")){
			//		set tMode="odt"
			//	}elseif ((tMode="ods") || (tMode="xls"))
			//	{
			//		set tMode="ods"
			//	}
			//}else {
				if ((tMode="odt") || (tMode="doc")){
					set tMode="doc"
				}elseif ((tMode="ods") || (tMode="xls"))
				{
					set tMode="xls"
				}			
			//}
		}
		
		#; create instance of *this* report
		Set tUserReport = ..%New()

		#; handle datasource URL parameter
		If tDatasource'="" {
			Set tUserReport.Datasource=tDatasource
		}

		#; copy URL parameters into specially marked properties.
		Set tSC = tUserReport.%ApplyURLParms()
		If $$$ISERR(tSC) Quit

		#; invoke callback
		Set tSC = tUserReport.%OnBeforeReport()
		If $$$ISERR(tSC) Quit

		#; serve appropriate content based on $MODE query parameter
		If (tMode = "xml") {
			#; serve raw xml report data
			Set tSC = tUserReport.%DrawXML(0,,,"")
		} Else {
			Set tSC = tUserReport.%DisplayReport(tMode,tDisplayLog)
		}
		If $$$ISERR(tSC) Quit

		#; notify that report is complete
		Set tSC = tUserReport.%OnAfterReport()
		If $$$ISERR(tSC) Quit

	} While(0)
	Quit tSC
}

/// Save report template to temporary place in filesystem
Method %DrawTemplate(stripinstructions As %Boolean = 0) As %Status
{
	Set stylesource="/csp/"_$SYSTEM.SYS.NameSpace()_..#TEMPLATE

	#; if no stylesource, generate error
	If stylesource="" {
		Quit $$$ERROR()
	#; if absolute URL
	} ElseIf $case($p(stylesource,":"),"http":1,"https":1,:0) {
		Set HttpResponse=..%GetFileByAbsoluteURL(stylesource)
		If $IsObject(HttpResponse) {
			Do ..%OutputStream(HttpResponse.Data,stripinstructions)
		} Else {
			&html<<error>Could not find absolute URL: #(stylesource)#</error>>
			Quit $$$ERROR($$$GeneralError,"Could not find absolute URL: "_stylesource)
		}
		Quit $$$OK
	} Else {
		Set stream=..%GetFileByRelativeURL(stylesource)
		If $IsObject(stream) {
			Do ..%OutputStream(stream,stripinstructions)
		} Else {
			&html<<error>Could not find relative URL: #(stylesource)#</error>>
			Quit $$$ERROR($$$GeneralError,"Could not find relative URL: "_stylesource)
		}
		Quit $$$OK
	}
}

/// This method performs the callout to the command line that performs an XSLT
/// or XSL-FO to PDF transformation.
Method %PerformTransform(xmlfile As %String, reportfile As %String, outfile As %String, logfile As %String) As %Status
{
	If $d(^%SYS("p6report","transformerpath")) {
		Set exe="java -jar """_$zu(147,^%SYS("p6report","transformerpath"))_""" "
	} Else {
		Quit $$$ERROR($$$GeneralError,"You must set ^%SYS(""p6report"",""transformerpath"") to the location of your jooreports.jar")
	}

	#; set up command line character to pipe output to a file
	If $$$isWINDOWS {
		Set pipechars = "2>>"
	} ElseIf $$$isUNIX {
		Set pipechars = "2>"
	} ElseIF $$$isVMS {
		#; I'm honestly just guessing here
		Set pipechars = ">"
	} Else {
		Set pipechars = ">"
	}
	If $d(^%SYS("p6report","jodreports")) {
		set outfile1=$p(outfile,".",1)_".odt"
	} else {
		set outfile1 = outfile
	}

	s ^Mymy(1)=exe_" """_reportfile_""" """_xmlfile_""" """_outfile1_""" "_pipechars_" """_logfile_""""
	Do $zf(-1,exe_" """_reportfile_""" """_xmlfile_""" """_outfile1_""" "_pipechars_" """_logfile_"""")
	
	If $d(^%SYS("p6report","jodreports")) {
		Set jodreportsExe="java -jar """_$zu(147,^%SYS("p6report","jodreports"))_""" "
		Do $zf(-1,jodreportsExe_" """_outfile1_""" """_outfile_""" "_pipechars_" """_logfile_"""")	
		SET ^Mymy(2)=jodreportsExe_" """_outfile1_""" """_outfile_""" "_pipechars_" """_logfile_""""
		
	}
	

	Quit $$$OK
}

/// This method outputs the contents of the PDF report  
Method %DisplayReport(aMode As %String, DisplayLog As %Boolean = 0) As %Status
{
	Set tSC=$$$OK
	Do {
		#; Generate data file and XSLT stylesheet which transforms data to HTML
		Set tSC = ..%MakeXMLDataFile(.xmlfile) Quit:$$$ISERR(tSC)
		Set tSC = ..%MakeToTemplateFile(.xslfile) Quit:$$$ISERR(tSC)

		#; Generate filenames for log/pdf
		Set tmpdir=##class(%File).NormalizeDirectory(^%SYS("TempDir"))
		Set logfile = tmpdir_##class(%FileBinaryStream).NewFileName("txt",^%SYS("TempDir"))		
		Set outfile = tmpdir_##class(%FileBinaryStream).NewFileName(aMode,^%SYS("TempDir"))

		#; Command line callout to FOP
		Set tSC = ..%PerformTransform(xmlfile, xslfile, outfile, logfile)

		If $$$ISOK(tSC) {
			If DisplayLog {
				Set oid = ##class(%CSP.StreamServer).GetOidForFile(logfile)
			} Else {
				Set oid = ##class(%CSP.StreamServer).GetOidForFile(outfile)
			}

			Set stream=##class(%Stream.Object).%Open(oid)
			Do stream.OutputToDevice()
		}
		Do ##class(%File).Delete(xmlfile)
		Do ##class(%File).Delete(xslfile)
		Do ##class(%File).Delete(outfile)
		Do ##class(%File).Delete(logfile)
		If $d(^%SYS("p6report","jodreports")) {
			Do ##class(%File).Delete($p(outfile,".",1)_".odt")
		}
	} While (0)

	Quit tSC
}

/// This method creates a temporary local file that contains
/// the XML data indicated by the DATASOURCE parameter or 
/// generated by %RunReport if no DATASOURCE is specified.
Method %MakeXMLDataFile(ByRef filename As %String) As %Status
{
	#; Generate XML to HTML stylesheet
	Set oldio=$IO
	Set tmpdir=##class(%File).NormalizeDirectory(^%SYS("TempDir"))
	Set filename = tmpdir_##class(%FileBinaryStream).NewFileName("xml",^%SYS("TempDir"))
	Open filename:("NW")
	Use filename
	Set tSC = ..%DrawXML(0,,,"")
	Close filename
	Use oldio
	Quit tSC
}

/// This method creates a temporary local copy of the XSLT stylesheet
/// used to transform the XML data into XSL-FO.
Method %MakeToTemplateFile(ByRef filename As %String) As %Status
{
	#; Generate XML to HTML stylesheet
	Set oldio=$IO
	Set tmpdir=##class(%File).NormalizeDirectory(^%SYS("TempDir"))
	Set filename = tmpdir_##class(%FileBinaryStream).NewFileName("odt",^%SYS("TempDir"))
	Open filename:("NWK\RAW\")
	Use filename
	Set tSC = ..%DrawTemplate(0)
	Close filename
	Use oldio
	Quit tSC
}

}

