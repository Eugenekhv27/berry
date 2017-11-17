Class admin.TempMemory Extends %Library.RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

ClassMethod Get(subject As %String = "", owner As %String = "") As %String
{
 if (subject="") quit ""
 if (owner="") quit $get(^CacheTemp.TempMemory(subject))
 quit $get(^CacheTemp.TempMemory(subject, owner))
}

ClassMethod Put(text As %String = "", subject As %String = "", owner As %String = "")
{
 if (subject="") quit
 if (owner="") set ^CacheTemp.TempMemory(subject) = text
 else  set ^CacheTemp.TempMemory(subject, owner) = text
 quit
}

}

