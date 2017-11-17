Class p6.ParamFilter Extends %RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

Property DataSet As %CacheString [ Private ];

Property Filter As %String(TRUNCATE = 1) [ Private ];

Property ParamCount As %Integer [ InitialExpression = 0, Private ];

Property ParamNames As list Of %String(TRUNCATE = 1);

Property ParamVals As list Of %String(TRUNCATE = 1);

Method CommaParamNames() As %String
{
 new i,Result
 if ..ParamCount=0 quit ""
 set Result=..ParamNames.GetAt(1)
 for i=2:1:..ParamCount set Result=Result_","_..ParamNames.GetAt(i)
 quit Result
 ;#
}

Method CommaParamVals() As %String
{
 new i,Result
 if ..ParamCount=0 quit ""
 set Result=""""_..ParamVals.GetAt(1)_""""
 for i=2:1:..ParamCount set Result=Result_","""_..ParamVals.GetAt(i)_""""
 quit Result
 ;#
}

Method GetFilter() As %String
{
 quit ..Filter
 ;#
}

Method ParamCount() As %Integer
{
 quit ..ParamCount
 ;#
}

Method SetFilter(filter As %String = "") As %Status
{
 new i,ParamName,chr
 do ..ParamNames.Clear()

 for i=1:1:$length(filter) do  ;
 . set chr=$extract(filter,i)
 . new found set found=0
 . //пропускаем значение между двойных кавычек
 . set found=(chr="""")
 . if found do  ;
 .. for j=i:1:$length(filter) set i=i+1 quit:$extract(filter,i)=""""
 .. quit
 . if found quit
 . //пропускаем значение между апострофов
 . set found=(chr="'")
 . if found do  ;
 .. for j=i:1:$length(filter) set i=i+1 quit:$extract(filter,i)="'"
 .. quit
 . if found quit
 . //выделяем имя параметра
 . set found=(chr=":")
 . if found do  ;
 .. set ParamName="" set i=i+1
 .. for j=i:1:$length(filter) do  quit:'((chr?1A)!(chr?1N))
 ... set chr=$extract(filter,i)
 ... if (chr?1A)!(chr?1N) set ParamName=ParamName_chr
 ... set i=i+1
 ... quit
 .. set ParamName=$zconvert(ParamName,"U")
 .. if ..ParamNames.Find(ParamName)="" do ..ParamNames.Insert(ParamName)
 .. quit
 . if found quit 
 .quit

 set ..Filter=$zconvert(filter,"U")
 set ..ParamCount=..ParamNames.Count()

 //устанавливаем значения параметров по умолчанию
 do ..ParamVals.Clear()
 for i=1:1:..ParamCount do ..ParamVals.Insert("")
 quit ..DataSet.OnFilterChange()
 ;#
}

Method SetParamAt(paramVal As %String = "", paramIdx As %Integer = "") As %Status
{
 do ..ParamVals.Clear()
 if ..ParamCount>paramIdx quit $$$ERROR(10,"Индекс параметра больше чем их количество")
 do ..ParamVals.SetAt(paramVal,paramIdx)
 quit ..DataSet.OnFilterParamsChange()
}

Method SetParams(params As %String = "") As %Status
{
 new i,val
 do ..ParamVals.Clear()
 for i=1:1:..ParamCount do ..ParamVals.Insert($piece(params,",",i))
 if ..ParamCount>0 quit ..DataSet.OnFilterParamsChange()
 quit $$$OK
}

ClassMethod Test()
{
 new x
 set x=##class(p6.ParamFilter).%New() 
 do x.SetFilter("(id>:param12) and (pd=""df:df""""dfdf"") or (x='kl:jh') and (id2<=:nparam34) or z=""hfhfhfhf""")
 do x.SetParams(1,2,3)
}

}

