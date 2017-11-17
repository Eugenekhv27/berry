/// Манифест для google gears
Class p6.GearsManifest Extends %CSP.Page
{

Parameter CONTENTTYPE = "text/plain";

Parameter CHARSET = "UTF-8";

ClassMethod OnPage() As %Status [ ServerOnly = 1 ]
{
	set files=$lb(
		"/csp/broker/zenutils.js",
		"/csp/broker/cspbroker.js",
		"/csp/broker/cspxmlhttp.js",
		"/csp/broker/ZEN_Component.js",
		"/csp/broker/ZEN_Component.css",
		"/csp/broker/ZEN_Auxiliary.js",
		"/csp/broker/ZEN_Auxiliary.css",
		"/csp/broker/ZEN_SVGComponent.js",
		"/csp/dtk/p6/js/gears_init.js",
		"/csp/dtk/p6/js/p6Utils.js",
		"/csp/dtk/p6/styles/p6skinfb1.css",
		"/csp/broker/images/spacer.gif",
		"/csp/dtk/p6/images/DTK_mainpage.jpg"
	)
	set ver=^dimas.Eis("Version","Build")
	w "{",!
		w """betaManifestVersion"": 1,",!
		w """version"": """_ver_""",",!
		w """entries"": [",!
		for i=1:1:$LISTLENGTH(files) {
			w "{""url"":"""_$LIST(files,i)_"""}"_$s(i=$LISTLENGTH(files):"",1:","),!
		}
		w "]",!
		
	w "}"
	Quit $$$OK
}

}

