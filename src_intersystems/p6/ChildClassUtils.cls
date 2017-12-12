Class p6.ChildClassUtils Extends %Persistent [ Abstract, ClassType = "", Not ProcedureBlock ]
{

ClassMethod BeforeChildDelete(childObjectId As %Library.String = "", parentPropertyName As %String = "")
{
 new obj  set obj = ..%OpenId(childObjectId)
 if (obj)
 {
 xecute "set ^CacheTemp.Parent2ChildDelete($job,obj.%ClassName(1))=obj."_parentPropertyName_".%Id()"
 do obj.%Close()
 }
}

ClassMethod AfterChildDelete(childObjectId As %Library.String = "", childClassName As %String = "", parentClassName As %String = "") As %Status
{
 new obj, sc, bool

 set bool=$$$NO
 xecute "if ($data(isIn"_$translate(parentClassName,".","")_"Delete)) set bool=1"
 if (bool) quit $$$OK

 xecute "set obj = ##class("_parentClassName_").%OpenId($get(^CacheTemp.Parent2ChildDelete($job,childClassName)))"
 set sc = $$$OK
 if (obj) set sc = obj.Save()
 kill ^CacheTemp.Parent2ChildDelete($job,childClassName)
 quit sc
}

}

