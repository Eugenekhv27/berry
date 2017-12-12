Class p6.UrlUtils Extends %RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

ClassMethod ConvertString(str As %String = "") As %String
{
 quit str
}

/// замена служебных символов на коды c #
ClassMethod ConvertStringToExcel(str As %String = "") As %String
{
 if str["[" set str=..Replace(str,"[","#lsc")
 if str["]" set str=..Replace(str,"]","#rsc")
 quit str
}

/// замена подстроки на подстроку
ClassMethod Replace(sourceString As %String = "", findString As %String = "", replaceString As %String = "") As %String
{
 if findString="" quit sourceString //#
 new result, i, iLength
 set result = "", iLength = $Length(sourceString,findString)
 for i=1:1:iLength {
 	if (i'=1) set result = result_replaceString
 	set result = result_$Piece(sourceString,findString,i)
 }
 quit result
}

/// преобразует сумму
/// commaSign - знак-разделитель между целой и дробной частью
/// separateSign - знак-разделитель между тысячами
ClassMethod ConvertCurrency(currency As %Currency = "", commaSign As %String = ",", separateSign As %String = " ") As %String
{
   if ((currency="") || (currency=0) || (+currency=0)) { quit "" } //#
   new result
   set result = $translate($fnumber(currency,",",2),",",separateSign)
   if (+result=0) { quit "" } //#
   if (commaSign'=".") { quit $translate(result,".",commaSign) } //#
   quit result
}

/// если после запятой не больше 2 знаков - то будет 2
/// если больше 2 знаков - то будет столько сколько есть
ClassMethod ConvertCurrency2(currency As %Currency = "", commaSign As %String = ",", separateSign As %String = " ") As %String
{
   if ((currency="") || (currency=0) || (+currency=0)) { quit "" } //#
   new result, count
   set count = $Length($Piece(+currency,".",2))
   if (count<2) { set count = 2 }
   set result = $translate($fnumber(currency,",",count),",",separateSign)
   if (+result=0) { quit "" } //#
   if (commaSign'=".") { quit $translate(result,".",commaSign) } //#
   quit result
}

/// для печати платежки замена 00 копеек на =
ClassMethod ConvertCurrencyForPp(currency As %Currency = "") As %String
{
 if (currency="") { quit "" } //#
 new sum
 set sum = ..ConvertCurrency(currency)
 if (sum?.E1"."2"0") { set sum = $extract(sum,1,$find(sum,".")-2)_"=" }
 else { set sum = $extract(sum,1,$find(sum,".")-2)_"-"_$extract(sum,$find(sum,"."),$length(sum)) }
 quit sum
}

/// дата через точку с двумя либо четырьмя знаками в году
ClassMethod ConvertDate(date As p6.dt.Date = "", is4 As p6.dt.Boolean = 0) As %String
{
 if (date="") { quit "" } //#
 new str
 set str = $translate($zdate(date,4,,4),"/",".")
 if (is4=0) { set str = $extract(str,1,6)_$extract(str,9,10) }
 quit str
}

/// добавляет ноль перед точкой, если меньше единицы
/// если ноль - то пусто
ClassMethod ConvertFloat(float As p6.dt.Float = "") As %String
{
 if (+float=0) { quit "" } //#
 if ((float>0) && (float<1)) { set float = "0"_float }
 if ((float<0) && (float>-1)) { set float = "-0"_(float*-1) }
 quit float
}

/// Собирает строку из имен переменных и их значений для подстановки в URL
ClassMethod GetUrlSearch(propertyList As %Library.String = "") As %Library.String
{
 if propertyList="" { quit "" } //#
 set propertyList=$translate(propertyList," ","")
 new result, plength, f, name
 set plength=$length(propertyList,",")
 set result=""
 for f=1:1:plength {
 	set name=$piece(propertyList,",",f)
 	if name]"" { set result = result_"&"_name_"="_$get(@name) }
 }
 set result = $extract(result,2,999999)
 quit result
}

}

