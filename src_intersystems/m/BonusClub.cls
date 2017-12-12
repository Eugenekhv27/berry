/// Created using the page template: Default
Class m.BonusClub Extends %ZEN.Mojo.basePage
{

/// Class name of application this page belongs to.
Parameter APPLICATION;

/// Displayed name of this page.
Parameter PAGENAME = "Бонус-клуб";

/// Domain used for localization.
Parameter DOMAIN;

/// List of JSON providers created for this page.
/// Used by contentProvider.
Parameter PROVIDERLIST = "data,layout";

/// Starting template class for this page
/// Used by contentProvider.
/// This is overriden by application settings, of provided.
Parameter TEMPLATECLASS = "m.Template";

/// Comma-separated list of additional CSS3 include files for the page.
/// If this is defined *and* this page is using CSS3, then the CSSINCLUDES parameter is ignored.
/// If this is not defined *and* this page is using CSS3, then the CSSINCLUDES parameter is used.
Parameter CSSINCLUDES As STRING = "jquery.mobile-1.4.5.min.css";

/// Comma-separated list of additional JS include files for the page.
Parameter JSINCLUDES As STRING = "jquery-1.10.2.min.js,jquery.mobile-1.4.5.min.js,jquery.maskedinput.min.js";

Property Data As %ZEN.proxyObject;

Property AtArray As %ZEN.Datatype.string [ InitialExpression = {"^CacheTemp("_$j_",""AtCalcArray"")"} ];

Property FinishContent As %ZEN.Datatype.string(MAXLEN = 3250);

Property AccountCode As %ZEN.Datatype.string(ZENURL = "acc");

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
	.ui-title {
		margin: 0 0%;
   		margin-top: 0px;
    	margin-right: 0%;
    	margin-bottom: 0px;
    	margin-left: 0%;	
	}
	.ui-listview-filter {
		margin: 0px;
	}
	 .ui-header {
		background-color: #FFD700;
		color:#000000;
		text-shadow: 0 0.5px 0 #059;
	}
	
	.ui-page-theme-a .ui-btn.ui-btn-active, html .ui-bar-a .ui-btn.ui-btn-active, html .ui-body-a .ui-btn.ui-btn-active, html body .ui-group-theme-a .ui-btn.ui-btn-active, html head+body .ui-btn.ui-btn-a.ui-btn-active, .ui-page-theme-a .ui-checkbox-on:after, html .ui-bar-a .ui-checkbox-on:after, html .ui-body-a .ui-checkbox-on:after, html body .ui-group-theme-a .ui-checkbox-on:after, .ui-btn.ui-checkbox-on.ui-btn-a:after, .ui-page-theme-a .ui-flipswitch-active, html .ui-bar-a .ui-flipswitch-active, html .ui-body-a .ui-flipswitch-active, html body .ui-group-theme-a .ui-flipswitch-active, html body .ui-flipswitch.ui-bar-a.ui-flipswitch-active, .ui-page-theme-a .ui-slider-track .ui-btn-active, html .ui-bar-a .ui-slider-track .ui-btn-active, html .ui-body-a .ui-slider-track .ui-btn-active, html body .ui-group-theme-a .ui-slider-track .ui-btn-active, html body div.ui-slider-track.ui-body-a .ui-btn-active {
    	background-color: #FFD700;
    	border-color: #38c;
    	color: #fff;
    	text-shadow: 0 1px 0 #059;
	}

	#dv_19_0_13_13 {
		background-color: #FFD700;
		
	}
	.calcHeader {
		background-color: #FFD700;
		color:#000000;
		font-size: small;
		font-weight: bold;
		text-shadow: 0 0.5px 0 #059;
	}
	.calcStyle  {
		font-size: x-small;	
		font-weight: bold;
		opacity:1;
		
	}
	.ui-controlgroup-label  {
		font-size: x-small;
		font-weight: bold;	
		opacity:1;
		
	}
	
	.ui-btn,label.ui-btn {
		font-weight:300;
		border-width:1px;
		border-style:solid
	}
	#dv_19_0_13_13 {
		font-weight:700 !important;

	}
   .btnNext div {
		font-weight:700 !important;
	}

	 
</style>
}

// background-color: #FFD700

/// This XML block defines the contents of this pane.
XData pageContents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane xmlns="http://www.intersystems.com/zen"
xmlns:mojo="http://www.intersystems.com/zen/mojo"
layout="none">

<mojo:documentView id="mainView" 
developerMode="false" 
initialDocumentKey="home"
initialLayoutKey="home"
maxPanels="15"
ongetlayout = "return zenPage.getContent('layout',key,criteria,true);"
ongetdata = "return zenPage.getContent('data',key,criteria,true);"
onresolvepluginconflicts="zenPage.onResolvePluginConflicts(zenThis, conflicts);"
>

<mojo:jQM-1.4.5-PageManager jQueryAnimation="" onPageShow="zenPage.onPageShow(layoutkey,documentkey);">
<mojo:jQM-1.4.5-Helper/>
<mojo:mojoDefaultHelper/>
<mojo:HTML5Helper/>
</mojo:jQM-1.4.5-PageManager>
</mojo:documentView>



</pane>
}

ClientMethod onResolvePluginConflicts(docView, conflicts) [ Language = javascript ]
{
	/*
    for (prop in conflicts) {
	    console.log('prop ='+prop);
        if (conflicts[prop].indexOf('$input') > -1) {
            docView.setPluginMapping(prop, 'HTML5');
        } else  {
            docView.setPluginMapping(prop, 'jQM');
        }
    }
    */
}

ClientMethod onPageShow(layoutkey, documentkey) [ Language = javascript ]
{
	if (layoutkey=='home') {
		$("#dv_19_0_8_8").mask("+7(999)9999999");
	}
}

/// This callback is called just after the server-side page 
/// object is created but before its children are created.
Method %OnCreatePage() As %Status
{
	//do ..Services.SetAt(0,"null") //инициируем массив, чтобы был доступен на клиенте
	Quit $$$OK
}

/// Draw the footer group.
/// This method will be removed in a future release,
/// in which it will not be necessary to override this method.
Method ZMojoDrawFooterGroup(pSeed As %String) As %Status [ ZenMethod ]
{
	write "Подождите, идет загрузка..."
	do ##super()
	Quit $$$OK
}

ClassMethod OnPreHTTP() As %Boolean
{
    //do %response.SetHeader("Access-Control-Allow-Origin", "vtkkhv.ru")
    do %response.SetHeader("Access-Control-Allow-Origin", "http://base.progrepublic.ru")
    do %response.SetHeader("P3P", "CP='IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT'")
    quit ##super()
}

/// 
/// This callback is called at the end of the HTML HEAD section of the page.<br/>
/// 
/// (default implementation is a simple expression).
Method %OnDrawHTMLHead() As %Status
{
	do ##super()
	
	
	&html<<link rel="stylesheet" type="text/css" href="frame_style.css">>
	
	Quit $$$OK
}

ClientMethod fixedEncodeURIComponent(str) [ Language = javascript ]
{

  return encodeURIComponent(str).replace(/[!'()*]/g, function(c) {
    return '%' + c.charCodeAt(0).toString(16);
  });
}

}

