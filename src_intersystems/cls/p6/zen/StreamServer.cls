/// Created using the page template: Default
Class p6.zen.StreamServer Extends (%ZEN.Component.page, %CSP.StreamServer) [ Inheritance = right ]
{

Property ObjectId As %ZEN.Datatype.string(ZENURL = "STREAMOID");

ClassMethod OnPreHTTP() As %Boolean
{
  s oid=$get(%request.Data("STREAMOID",1))
  if oid="" quit $$$OK
  
  s %stream = ##class(%FileBinaryStream).%Open(..Decrypt(oid))

  if (%stream '= $$$NULLOREF) {
        s mode = $get(%request.Data("Mode",1))
        s aka = $get(%request.Data("Aka",1))
        
        if ( mode = "view" ) {
	        s %response.ContentType = %stream.GetAttribute("ContentType")
	        s %response.CharSet=%stream.GetAttribute("CharSet")
			if %stream.GetAttribute("ContentDisposition")'="" d %response.SetHeader("Content-Disposition",%stream.GetAttribute("ContentDisposition"))
			if %stream.IsDefinedAttribute("Expires") s %response.Expires=%stream.GetAttribute("Expires")
	    } else {
		    s %response.ContentType = "application/download"
		    s %response.Expires= 600
        	s %response.ContentLength=%stream.Size
        
		    s ext = $p(%stream.Filename,".",$l(%stream.Filename,"."))
		    if (aka '= "") s aka = "_"_aka
		    s filename = "ClaimScan"_aka_"."_ext
		    d %response.SetHeader("content-disposition","attachment; filename="""_filename_"""" )
		    
		   // s %response.ServerSideRedirect=..Link("p6.zen.StreamServer?File="_filename)
       }
   } else {
        set %response.Status="404 File in Storage Not Found"
        quit 0
    }

    quit $$$OK
}

ClassMethod OnPage() As %Status
{
   If %stream'=$$$NULLOREF Do %stream.OutputToDevice()
   Quit $$$OK
}

/// Displayed name of this page.
Parameter PAGENAME;

}

