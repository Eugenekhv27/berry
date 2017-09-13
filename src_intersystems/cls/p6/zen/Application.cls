/// Superclass for prototype 5 application
Class p6.zen.Application Extends %ZEN.application
{

/// This is the name of this application.
Parameter APPLICATIONNAME = "Prototype 6 application";

/// This is the URL of the main starting page of this application.
Parameter HOMEPAGE;

/// Comma-separated list of User class packages whose HTML class
/// and style definitions are in pre-generated include files.
Parameter USERPACKAGES = "p6.zen.component,p6.zen.auxiliary";

/// This Style block contains application-wide CSS style definitions.
XData Style
{
<style type="text/css">
/* @doc="Input box " */
input {
        vertical-align: middle;
        border: 1px solid black;
        padding-left:3px;
}
</style>
}

}

