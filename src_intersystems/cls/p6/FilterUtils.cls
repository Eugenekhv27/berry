Class p6.FilterUtils Extends %RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

/// возвращает: (toFieldName>=fromDate) and (fromFieldName<=toDate)
ClassMethod FormCrossPeriodsCondition(fromFieldName, toFieldName, fromDate, toDate) As %String
{
 if (fromDate = "") {
 	if (toDate]"") quit fromFieldName_"<="_toDate
 	quit ""
 }
 else  {
 	if (toDate = "") quit toFieldName_">="_fromDate
 	quit "("_toFieldName_">="_fromDate_") and ("_fromFieldName_"<="_toDate_")"
 }
}

/// возвращает: (fromFieldName>=fromDate) and (toFieldName<=toDate)
ClassMethod FormIncludePeriodsCondition(fromFieldName, toFieldName, fromDate, toDate) As %String
{
 if (fromDate = "") {
 	if (toDate]"") quit toFieldName_"<="_toDate
 	quit ""
 }
 else {
 	if (toDate = "") quit fromFieldName_">="_fromDate
 	quit "("_fromFieldName_">="_fromDate_") and ("_toFieldName_"<="_toDate_")"
 }
}

/// возвращает: (FieldName>=fromDate) and (FieldName<=toDate)
ClassMethod FormPeriodCondition(fieldName, fromDate, toDate) As %String
{
 if (fromDate = "") {
 	if (toDate]"") quit fieldName_"<="_toDate
 	quit ""
 }
 else  {
 	if (toDate = "") quit fieldName_">="_fromDate
 	quit "("_fieldName_">="_fromDate_") and ("_fieldName_"<="_toDate_")"
 }
}

/// Возвращает: (FieldName>=todate('04/10/2005','MM/DD/YYYY')) 
///             and (FieldName<=todate('07/19/2005','MM/DD/YYYY'))
ClassMethod FormPeriodConditionSql(fieldName = "", fromDate = "", toDate = "") As %String
{
 
 quit ..FormPeriodCondition(fieldName,##class(p6.Convert).SqlDate(fromDate),##class(p6.Convert).SqlDate(toDate))
}

ClassMethod Add(wholeFilter, newCondition) As %String
{
 if (newCondition = "") quit wholeFilter
 if (wholeFilter]"") set wholeFilter = "("_wholeFilter_") and ("_newCondition_")"
 else  set wholeFilter = newCondition
 quit wholeFilter
}

/// aIdList - разделитель запятая, напр. ",5,15,555,"
ClassMethod IsIdInList(aId, aIdList) As p6.dt.Boolean [ CodeMode = expression, SqlProc ]
{
aIdList[(","_aId_",")
}

/// возвращает: (fromFieldName>=fromDate) and (toFieldName<=toDate)
ClassMethod FormIncludePeriodsConditionByYearMonth(fieldName, year, month) As %String
{
	set fromDate=##class(p6.Date).GetBeginOfMonth(year, month) 
	set toDate=##class(p6.Date).GetEndOfMonth(year, month) 
 	quit ..FormPeriodConditionSql(fieldName, fromDate, toDate)
}

}

