/// Created using the page template: Default
Class p6.zen.FileUpload Extends p6.zen.Page
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "p6.zen.Application";

/// Displayed name of this page.
Parameter PAGENAME;

/// Domain used for localization.
Parameter DOMAIN = "DIMAS";

/// Unique name for file upload description
Property Anchor As %ZEN.Datatype.string(ZENURL = "anchor");

/// Uploded file OID
Property FileDesc As %ZEN.Datatype.string(ZENURL = "desc");

// /// Cleanup

//Property Cleanup As %ZEN.Datatype.bool(ZENURL = "cleanup");

XData Style
{
<style type="text/css">
</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" xmlns:p6="http://www.dimas.ru/p6" width="100%" align="center">
	<form id="frmScan" enctype="multipart/form-data" width="100%" target="_self">
		<fileUpload name="ScanFile" id="scanFile" size="100%" onchange="zenPage.submitScanFile()" containerStyle="padding: 5px 0px"/>
		<text name="Filename" id="filename" hidden="true" />
		<text name="FileDesc" id="fileDesc" hidden="true" value="#(%page.FileDesc)#"/>
		<text name="Anchor" id="anchor" hidden="true" value="#(%page.Anchor)#"/>
	</form>
</page>
}

ClientMethod submitScanFile() [ Language = javascript ]
{
	var filename = zenPage.getComponentById("filename");	
	filename.setValue( zenPage.getComponentById("scanFile").getValue() );
	
	var form=zenPage.getComponentById("frmScan");
		
	form.submit();
}

ClassMethod %OnSubmit(pSubmit As %ZEN.Submit) As %Status
{
	s desc = $g(pSubmit.%Data("FileDesc"))
	d ..CleanupTmpFile( desc )
	
	s mimeData = %request.NextMimeData("")
	
	if ((mimeData'="")) {
	
		s fileExt = $p(pSubmit.%Data("Filename"),".",$l(pSubmit.%Data("Filename"),"."))
		
		s file = ##class(%FileBinaryStream).%New()
		s file.Filename = ##class(%File).TempFilename(fileExt)
		
		d file.CopyFromAndSave(%request.GetMimeData(mimeData))
		
		s %response.Context("desc") = ..Encrypt(file.%Oid())
		s %response.Context("anchor") = $g(pSubmit.%Data("Anchor"))
		
	} else {
		s %response.Context("desc") = ""
		s %response.Context("anchor") = $g(pSubmit.%Data("Anchor"))
	}
		
	quit $$$OK
}

ClassMethod CleanupTmpFile(desc As %String) As %Status
{
	if (desc = "") quit $$$OK
	
	s oid = ..Decrypt( desc ) 
	
	quit ##class(%FileBinaryStream).%Delete(oid)
}

ClassMethod GetFilename(desc As %String) As %String
{
	s oid = ##class(%CSP.Page).Decrypt( desc )
	
	s file = ##class(%FileBinaryStream).%Open( oid )
 	s tmpFilename = file.Filename
 	d file.%Close()
 	
 	quit tmpFilename
}

ClientMethod onloadHandler() [ Language = javascript ]
{
	if( zenPage.FileDesc != "") {
		var anchor = parent.document.getElementById(zenPage.Anchor).firstChild;
		anchor.value = zenPage.FileDesc;
		anchor.onchange();
	}
			
	return this.invokeSuper('onloadHandler',arguments);
}

}

