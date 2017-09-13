Class p6.csp.Print Extends %CSP.Page [ ClassType = "", ProcedureBlock ]
{

ClassMethod OnPreHTTP() As %Boolean
{
	/*Чтобы IE открывал документы MS не в себе, а запускал Word/Excel
	Проводник->(Menu)Сервис->(Menu)Свойства папки->(Tab)Типы файлов->XLS->(Кнопка)Дополнительно->(CheckBoxOff)Показывать в том же окне*/

	set RepSetting=$GET(%request.Data("ReportSet",1))
	if RepSetting="2" {
		set %response.ContentType = "application/vnd.oasis.opendocument.spreadsheet"
		set mode=$GET(%request.Data("Mode",1),"")
		if mode="1" {
			set %response.ContentType = "application/vnd.oasis.opendocument.text"
			Do %response.SetHeader("content-disposition","attachment; filename=Report.odt")
		}else {
			Do %response.SetHeader("content-disposition","attachment; filename=Report.ods")
		}	
	}else {	
		set mode=$GET(%request.Data("Mode",1),"")
		if mode="1" {
			set %response.ContentType = "application/msword"
			Do %response.SetHeader("content-disposition","attachment; filename=Report.doc")
		}elseif mode="2"
		{
			set %response.ContentType = "application/vnd.ms-excel"
			Do %response.SetHeader("content-disposition","attachment; filename=Report.xls")
		}
	}	
	set %response.Expires = "Thu, 01 Apr 2003 00:00:00 GMT"
	Quit $$$OK
}

ClassMethod OnPage() As %Status [ ServerOnly = 1 ]
{
	w "<html  xmlns:v=""urn:schemas-microsoft-com:vml""xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns=""http://www.w3.org/TR/REC-html40"">"
	w "<head>"
	//w "<meta http-equiv=""Content-Type"" content=""text/html; charset=windows-1251"">"
	
	w "<meta http-equiv=Content-Type content=""text/html; charset=windows-1251"">"
    w "<meta name=ProgId content=Excel.Sheet>"
    w "<meta name=Generator content=""Microsoft Excel 11"">"
	w "<!--[if gte mso 9]><xml>"
	w "<x:ExcelWorkbook>"
	w "<x:ExcelWorksheets>"
 	w "<x:ExcelWorksheet>"
  	w "<x:WorksheetOptions>"
    w "<x:Selected/>"
    w "<x:ProtectContents>False</x:ProtectContents>"
    w "<x:ProtectObjects>False</x:ProtectObjects>"
    w "<x:ProtectScenarios>False</x:ProtectScenarios>"
    w "<x:NoSummaryColumnsRightDetail/>"
    w "<x:NoSummaryRowsBelowDetail/>"
    w "</x:WorksheetOptions>"
  	w "</x:ExcelWorksheet>"
 	w "</x:ExcelWorksheets>"
	w "</x:ExcelWorkbook>"
	w "</xml><![endif]-->"
	w "</head><body>"
	set dataFrom=$GET(%request.Data("DataFrom",1),"")
	set dataFrom=..UnescapeURL(dataFrom)
	
	set File=##class(%FileCharacterStream).%New()
	Set File.Filename=dataFrom

	While 'File.AtEnd {
		Set line=File.ReadLine()
		// Вставка border="1"
		set sub1=$PIECE(line,"border=""",1) 
		w sub1
		set sub2=$PIECE(line,"border=""",2)
		if sub2'="" {
			set $PIECE(sub2,"""",1)=1
			w "border="""_sub2
		}
		write !
	}
	
	w "</body>"
	
	Quit $$$OK
}

Parameter CHARSET = "cp1251";

}

