/// Страница редактирования
Class p6.zen.EditPage Extends p6.zen.Page
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "p6.zen.Application";

/// Displayed name of this page.
Parameter PAGENAME;

Parameter DOMAIN = "DIMAS";

Property StdTitle As %ZEN.Datatype.string [ InitialExpression = {..#PAGENAME} ];

Property objectId As %ZEN.Datatype.string(ZENURL = "Id");

Property copyFromId As %ZEN.Datatype.string(ZENURL = "CopyFromId");

Property isEditable As %ZEN.Datatype.boolean [ InitialExpression = {$select($ROLES["BonusClub_Sales":0,1:1)} ];

/// Comma-separated list of User class packages whose HTML class
/// and style definitions are in pre-generated include files.
Parameter USERPACKAGES As STRING = "p6.zen.component,p6.zen.auxiliary";

/// This Style block contains page-specific CSS style definitions.
XData Style2
{
<style type="text/css">
#title {
	background: #CCDDCC;
	color: #444;
	font-family: Verdana;
	font-size: 1.2em;
	font-weight: bold;
	padding: 5px;
	border-bottom: 1px solid #999;
	text-align: center;
}
body {
	background-color: white;
	background-image: url(p6/images/bg_gray.jpg);
}
fieldset {
	background-color: #fafafa;
	background-repeat: repeat-x;
	background-x-position: center;
	background-y-position: top;
	background-image: url(p6/images/bgGrayForm.gif);
	font-size:0.8em;
	font-weight: bold;
	color:#336;
}
label {
	background-color: #fafafa;
	color:#336;
	font-size:0.8em;
}
.vtLabelLeft {
	width:1%;
}
input {
	border: 1px solid #999999;
	font-size: 1em;
}
button, .textRefBookButton {
	background-repeat: repeat-x;
	background-x-position: center;
	background-y-position: bottom;	
	border: 1px solid #999999;
	background-image: url(p6/images/bgGray.gif);
	font-size: 1em;
}
button:hover {
	background-image: url(p6/images/bgGrayForm.gif);
	background-repeat: repeat-x;
	background-x-position: center;
	background-y-position: top;
	color:red;
}
button:focus {
	background-image: url(p6/images/bgGray.gif);
	background-repeat: repeat-x;
	background-x-position: center;
	background-y-position: top;
	color:red;
}
input:active {
	border: 1px solid red;
}
.zenLabel {
	color: #444;
	font-size:0.8em;
}
.tnbrTable {
	background:#9DB9C8;
}
</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" xmlns:p6="http://www.dimas.ru/p6" title="#(%page.StdTitle)#" width="100%"
  align="center" >
<html OnDrawContent="DrawTitle" id="title" />
<pane id="editPane" align="center" paneName="editPane" width="100%" containerStyle="padding:0.5em;" />
</page>
}

/// Draw HTML for the page title
Method DrawTitle(pSeed As %String) As %Status
{
	#; Whatever HTML we render here will be used as the title bar
	&html<#($ZCVT($$$ZENVAL(..StdTitle),"O","HTML"))#>

	Quit $$$OK
}

Method %OnAfterCreatePage() As %Status
{
	set copyFromId = ..copyFromId
	if (copyFromId '="")
	{
		set classname = ..%ClassName(1)
		set classname = $piece(classname, ".",2,3)
		set classnameLine=""
		set propertyLine = ""
		set classmethodname = "%OpenId"
		set oldPage = $CLASSMETHOD(classname, classmethodname, copyFromId)
		set newPage = oldPage.%ConstructClone()
	
		if (classname="ent.Route")
		{
			set classnameLine = "ent.RouteStation"
			set propertyLine = "Route"
			set newPage.Aka = newPage.Aka_" Копия"
		}
		
		if (classname="dtk.Trip")
		{
			set classnameLine = "dtk.rep.TripRegister"
			set propertyLine = "TripId"
			set newPage.Carriage = ""
			set newPage.TripStatus = "Empty"
		}
		
		if (classname = "dtk.Waybill")
		{
			set docno = ##class(dtk.Waybill).GetNewDocNo()
			set docdate = +$H
			set classnameLine = "dtk.Rep.WaybillRegister"
			set propertyLine = "DocNo"
			set newPage.DocNo = docno
			set newPage.DocDate = docdate
		}
		set sc=newPage.Save()
		
		if $$$ISOK(sc) {
		set newId = newPage.%Id()
		
		if (classname '="" && classnameLine '= "" && propertyLine '= "")
		{
			SET myquery="SELECT ID FROM " _ classnameLine _ " where " _ propertyLine _ " = " _ copyFromId
  			SET rset=##class(%ResultSet).%New()
 			SET sc=rset.Prepare(myquery)
  			SET sc=rset.Execute()
     		WHILE rset.Next() 
     		{
	     		set lineId = rset.Data("ID")
	     		set oldLineObject = $CLASSMETHOD(classnameLine, classmethodname, lineId)
	     		set newLineObject = oldLineObject.%ConstructClone()
	     		set $property(newLineObject, propertyLine)= newPage
	     		set cs = newLineObject.Save()
     		}
		}
		
		//set Controller=..%GetComponentById("source")
		set ..%GetComponentById("source").modelId=newId
		set ..objectId=newId
		}
	}
		
		


	// set ..%GetComponentById("editPane").align="center"
	Quit $$$OK
}

}

