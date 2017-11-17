Class p6.ParentClassUtils Extends %RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

ClassMethod OnParentDelete(parentObjectId As %Library.String = "", parentClassName As %String = "", childClassName As %String = "", parentPropertyName As %String = "") As %Status
{
 new lines, i, sc

 set sc = $$$OK
 set lines = ##class(p6.ClassUtils).GetListOfProperty(childClassName, "Id", parentPropertyName_"="_parentObjectId)
 xecute "new isIn"_$translate(parentClassName,".","")_"Delete"
 xecute "set isIn"_$translate(parentClassName,".","")_"Delete = 1"
 for i=1:1:$listlength(lines)
 {
 xecute "set sc = ##class("_childClassName_").DeleteId($list(lines,i))"
 if ($$$ISERR(sc)) quit
 }
 quit sc
}

}

