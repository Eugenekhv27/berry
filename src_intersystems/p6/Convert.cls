/// Методы преобразования данных
Class p6.Convert Extends %Library.RegisteredObject [ ClassType = "", Not ProcedureBlock ]
{

/// Строка = Atr [Id] для указанного класса
ClassMethod ClassAtrId(Class As %String = "", Atr As %String = "", Id As %String = "") As %String
{
 n z,a
 x "s z=##class("_Class_").%OpenId(Id)"
 i z="" q "0Нет объекта с номером ["_Id_"]" ;#
 x "s a=z."_Atr
 s a=a_" ["_Id_"]"
 d z.%Close()
 q a
}

/// Замена спецсимволов при выводе строки в Html на &...;
ClassMethod HtmlStr(Str As %String = "") As %String [ Final ]
{
 i Str="" q "" ;#
 n i s Str=$tr(Str,"&",$c(1))
 i $f(Str,$c(1)) f  s i=$f(Str,$c(1)) q:'i  s $e(Str,i-1)="&amp;"
 i $f(Str,"""") f  s i=$f(Str,"""") q:'i  s $e(Str,i-1)="&quot;"
 i $f(Str,"<") f  s i=$f(Str,"<") q:'i  s $e(Str,i-1)="&lt;"
 i $f(Str,">") f  s i=$f(Str,">") q:'i  s $e(Str,i-1)="&gt;"
 q Str
}

/// Преобразование строки из KOI8 в Windows-1251
/// shu 060621-переведено на $char - неверное отображение в редакторе
ClassMethod KOI8Win1251(str As %String = "") As %String
{
 if str="" quit "" ;#
 //quit $tr(str,"‰–“Љ…Ќѓ?™‡•љ”›‚ЂЏђЋ‹„†ќџ—‘Њ€’њЃћ©жгЄҐ­Јий§екдлў Їа®«¤¦нпзб¬ЁвмЎо","ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮйцукенгшщзхъфывапролджэячсмитьбю") ;#
 quit $tr(str,$c(137,150,147,138,133,141,131,152,153,135,149,154,148,155,130,128,143,144,142,139,132,134,157,159,151,145,140,136,146,156,129,158,169,230,227,170,165,173,163,232,233,167,229,234,228,235,162,160,175,224,174,171,164,166,237,239,231,225,172,168,226,236,161,238),"ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮйцукенгшщзхъфывапролджэячсмитьбю") ;#
}

/// Преобразование сроки параметров для страницы Html в массив %KEY()
ClassMethod ParamToKEY(str As %String = "")
{
 new np,npl,p,pData,pVar
 set npl=$length(str,"&") if npl=0 quit  ;#
 for np=1:1:npl do  ;
 . set p=$piece(str,"&",np) if p="" quit
 . set pVar=$piece(p,"=") if pVar="" quit
 . set pData=$piece(p,"=",2,99)
 . set %KEY(pVar)=pData
 . quit
 ;# shu 001114
}

/// Удвоение кавычек в строке
ClassMethod Quote(str As %String = "") As %String
{
 if $find(str,"""")=0 quit str ;#
 new str1,i,s set str1=""
 for i=1:1 set s=$e(str,i) quit:s=""  set str1=str1_s if s="""" set str1=str1_s
 quit str1 ;#
 ;# shu 000425
}

/// Преобразование строки из Windows-1251 в  KOI8
/// shu 060621-переведено на $char - неверное отображение в редакторе
ClassMethod Win1251KOI8(str As %String = "") As %String
{
 if str="" quit "" ;#
 //quit $tr(str,"ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮйцукенгшщзхъфывапролджэячсмитьбю","‰–“Љ…Ќѓ?™‡•љ”›‚ЂЏђЋ‹„†ќџ—‘Њ€’њЃћ©жгЄҐ­Јий§екдлў Їа®«¤¦нпзб¬ЁвмЎо") ;#
 quit $tr(str,"ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮйцукенгшщзхъфывапролджэячсмитьбю",$c(137,150,147,138,133,141,131,152,153,135,149,154,148,155,130,128,143,144,142,139,132,134,157,159,151,145,140,136,146,156,129,158,169,230,227,170,165,173,163,232,233,167,229,234,228,235,162,160,175,224,174,171,164,166,237,239,231,225,172,168,226,236,161,238)) ;#
}

/// Преобразование строки из Windows-1251 в  DOs CP866
ClassMethod Win1251DOs(str As %String = "") As %String
{
 if str="" quit "" ;#
 quit $tr(str,"ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮйцукенгшщзхъфывапролджэячсмитьбю","‰–“Љ…Ќѓ?™‡•љ”›‚ЂЏђЋ‹„†ќџ—‘Њ€’њЃћ©жгЄҐ­Јий§екдлў Їа®«¤¦нпзб¬ЁвмЎо") ;#
}

/// Преобразование суммы для печати в платежном поручении
ClassMethod SummAliPp(str As %String = "", nullKop As p6.dt.Boolean = 0) As %String
{
 if +str'=str quit str // не цифра
 new s1,s2
 set str=+str, s1=$piece(str,".",1), s2=$piece(str,".",2)
 if s2="" { 
 	if nullKop quit (s1_"-00") //#
 	else  quit (s1_"=") //#
 }
 if $length(s2)=1 set s2=s2_"0"
 if s1="" set s1=0
 quit (s1_"-"_s2)
}

/// Преобразование суммы для печати в платежном поручении
ClassMethod DisplaySummaInTable(str As %String = "", digits As %Integer = 2) As %String
{
 if str="" set str="-"_$justify("",digits) quit str //#
 if +str'=str quit str //# не цифра
 if digits="" set digits=2
 new s1,s2
 set str=+str, s1=$piece(str,".",1), s2=$piece(str,".",2)
 if str=0 set str="-"_$justify("",digits) quit str //#
 if $length(s2)>digits quit str //# больше десятичных разрядов, не преобразовывать
 quit $justify(str,0,digits)
}

/// перевод числа в пропись
ClassMethod WriteNumber(summa As %Library.String = "") As %String
{
 new summap
 set summap=..WriteSumma(summa)
 set summap=$piece(summap," руб")
 quit summap
}

/// перевод суммы в пропись
ClassMethod WriteSumma(summa As %Library.String = "") As %String
{
 ; ПЕРЕВОД СУММЫ В ПРОПИСЬ;07:02 PM  14 Jan 1995, L=3598
 ;
 new SUMMA,SUMMAP,%X,%X0,%X1,R0,R1,VV,V2,V3,V
 set SUMMA=summa
 I +SUMMA'<1000000000000 S SUMMAP=SUMMA G END0 ;### 
 I +SUMMA<0 S SUMMA=-SUMMA
 S %X=+$P(SUMMA,".",1),SUMMAP="",VV=0
 ;I %X=0 S SUMMAP="ноль рублей"
 I %X=0 S SUMMAP="ноль "
 I %X>0 D PRUBL
 S V2=$E(%X,$L(%X)-1),V3=$E(%X,$L(%X))  
 I V3=1,V2'=1 S SUMMAP=SUMMAP_" рубль",VV=1
 I ((V3=2)!(V3=3)!(V3=4))&(V2'=1) S SUMMAP=SUMMAP_" рубля",VV=1
 I ((V3=1)!(V3=2)!(V3=3)!(V3=4))&(V2=1) S SUMMAP=SUMMAP_" рублей",VV=1
 I V3>4 S SUMMAP=SUMMAP_" рублей",VV=1
 I VV=0 S SUMMAP=SUMMAP_" рублей"
 S %X=$P(SUMMA,".",2) I %X="" S %X="00"
 I %X?1N S %X=%X_"0",(V1,V)="0"
 I %X?2N S V1=$E(%X,1,1),V=$E(%X,2,2)
R1 I (V="1")&(V1'="1") S SUMMAP=SUMMAP_" "_%X_" копейка"
 I ((V="2")!(V="3")!(V="4"))&(V1'="1") S SUMMAP=SUMMAP_" "_%X_" копейки"
 I ((V'="1")&(V'="2")&(V'="3")&(V'="4"))!(V1="1") S SUMMAP=SUMMAP_" "_%X_" копеек"
 I $E(SUMMAP)=" " S SUMMAP=$E(SUMMAP,2,255)
 S SUMMAP=$TR($E(SUMMAP),"одтчпшсвн","ОДТЧПШСВН")_$E(SUMMAP,2,255)
END0 K %X,%X0,%X1,R0,R1
 Q (SUMMAP) ;1
 ;-
PRUBL ; РУБЛИ   
 D PMILR,PMILE,PtYS,PEDIN
 Q  ;PRUBL
 ;-
PMILR ;МИЛЛИАРД
 S %X0=%X\1000000000 Q:%X0=0  ;###
 D PSoT,PDES
 ;S SUMMAP=SUMMAP_"миллион"_$S(%X0#10=1:"",%X0#10>1&(%X0#10<5):"а",1:"ов")_" "
RRR3 S SUMMAP=SUMMAP_" миллиард"_$S(%X0#100=0:"ов",%X0#100>10&(%X0#100<21):"ов",%X0#10>1&(%X0#10<5):"а",%X0#10=1:"",1:"ов")_" "
 K R3
 Q  ;PMILR
 ;-
PMILE ;МИЛЛИОНЫ
 ;S %X0=%X\1000000 Q:%X0=0  ;###
 S %X0=%X#1000000000\1000000 Q:%X0=0  ;###
 D PSoT,PDES
 ;S SUMMAP=SUMMAP_"миллион"_$S(%X0#10=1:"",%X0#10>1&(%X0#10<5):"а",1:"ов")_" "
R3 S SUMMAP=SUMMAP_" миллион"_$S(%X0#100=0:"ов",%X0#100>10&(%X0#100<21):"ов",%X0#10>1&(%X0#10<5):"а",%X0#10=1:"",1:"ов")_" "
 K R3
 Q  ;PMILE
 ;-
PtYS ;ТЫСЯЧИ
 S %X0=%X#1000000\1000 Q:%X0=0  ;###
 D PSoT,PDES
 S %X1=$E(SUMMAP,$L(SUMMAP)-2,$L(SUMMAP))
 I %X1="ва " S SUMMAP=$E(SUMMAP,1,$L(SUMMAP)-3)_"ве "
 I %X1="ин " S SUMMAP=$E(SUMMAP,1,$L(SUMMAP)-3)_"на "
QQ S SUMMAP=SUMMAP_" тысяч"_$S(%X0#100=11:"",%X0#100=12:"",%X0#100=13:"",%X0#100=14:"",%X0#10=1:"а",%X0#10>1&(%X0#10<5):"и",1:"")_" "
 K R4,R5,R6
 Q  ;PtYS
 ;-
PEDIN ;ЕДИНИЦЫ В ОСТАТКЕ
 S %X0=%X#1000 Q:%X0=0  ;###
 D PSoT,PDES
 Q  ;PtDIN
 ;-
PSoT ;СОТНИ
 S %X1=%X0\100 Q:%X1=0  ;###
R7 S S1="сто"
R8 S S2="двести"
R9 S S3="триста"
R10 S S4="четыреста"
R11 S S5="пятьсот"
R12 S S6="шестьсот"
R13 S S7="семьсот"
R14 S S8="восемьсот"
R15 S S9="девятьсот"
 S SUMMAP=SUMMAP_$S(%X1=1:S1,%X1=2:S2,%X1=3:S3,%X1=4:S4,%X1=5:S5,%X1=6:S6,%X1=7:S7,%X1=8:S8,%X1=9:S9)_" "
 K S1,S2,S3,S4,S5,S6,S7,S8,S9
 Q  ;PSoT
 ;-
PDES ;ДЕСЯТКИ
 S %X1=%X0#100\10 Q:%X=0  ;###
 I %X1=1 D PDC Q  ;###
R17 S D2="двадцать"
R18 S D3="тридцать"
R19 S D4="сорок"
R20 S D5="пятьдесят"
R21 S D6="шестьдесят"
R22 S D7="семьдесят"
R23 S D8="восемьдесят"
R24 S D9="девяносто"
 S SUMMAP=SUMMAP_$S(%X1=2:D2,%X1=3:D3,%X1=4:D4,%X1=5:D5,%X1=6:D6,%X1=7:D7,%X1=8:D8,%X1=9:D9,1:"")_" "
 K D2,D3,D4,D5,D6,D7,D8,D9
 D PoDIN
 Q  ;PDES
 ;-
PDC ;
 S %X1=%X0#10
R25 S F0="десять"
R26 S F1="одиннадцать"
R27 S F2="двенадцать"
R28 S F3="тринадцать"
R29 S F4="четырнадцать"
R30 S F5="пятнадцать"
R31 S F6="шестнадцать"
R32 S F7="семнадцать"
R33 S F8="восемнадцать"
R34 S F9="девятнадцать"
 S SUMMAP=SUMMAP_$S(%X1=0:F0,%X1=1:F1,%X1=2:F2,%X1=3:F3,%X1=4:F4,%X1=5:F5,%X1=6:F6,%X1=7:F7,%X1=8:F8,%X1=9:F9)
 K F0,F1,F2,F3,F4,F5,F6,F7,F8,F9  
 Q  ;PDC
 ;-
PoDIN ;ЕДИНИЦЫ
 S %X1=%X0#10 I %X1=0 Q  ;###
 S SUMMAP=SUMMAP_$S(%X1=1:"один",%X1=2:"два",%X1=3:"три",%X1=4:"четыре",%X1=5:"пять",%X1=6:"шесть",%X1=7:"семь",%X1=8:"восемь",%X1=9:"девять",1:"")_" "
 K E1,E2,E3,E4,E5,E6,E7,E8,E9
 Q  ;PoDIN
 ;-
 ;Стрымбу 28.06.89
 ;ВХОД: СУММА  - ЧИСЛОВАЯ, РУБЛИ, КОПЕЙКИ
 ;ВЫХОД: СУММАП - ПРОПИСЬЮ
 ;#П
}

/// re-make of JScript escape() function (Unicode supported)
ClassMethod escape(str As %String = "") As %String [ Final ]
{
 i str="" q "" ;#
 n i,out,c,a,d s d=$c(0)
 s out="" f i=1:1:$l(str) s c=$e(str,i) d
 . i "+-*/.@0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"[c s out=out_c q
 . s a=$a(c),out=out_d_$s(a<16:"0",a<256:"",a<4096:"u0",1:"u")_$zh(a)
 q out
}

/// re-make of JScript unescape() function (Unicode supported)
ClassMethod unescape(str As %String = "") As %String [ Final ]
{
 i str="" q "" ;#
 n i,out,p,h,d s d="%"
 s str=$tr(str,$c(0),"%")
 s out=$p(str,d) f i=2:1:$l(str,d) s p=$p(str,d,i) d
 . s h=$e(p,1,2) i $l(h)=2,$tr(h,"0123456789abcdefABCDEF")="" s out=out_$c($zh(h))_$e(p,3,$l(p)) q
 . i $e(p)="u" s h=$e(p,2,5) i $l(h)=4,$tr(h,"0123456789abcdefABCDEF")="" s out=out_$c($zh(h))_$e(p,6,$l(p)) q
 . s out=out_d_p
 q out
}

ClassMethod FileToString(file As %Library.String = "") As %Library.String
{
 if file="" quit "" //#
 new prdev, string
 set prdev=$io, string=""
 open file
 set $ztrap="errorFileToString"
 use file for  read *a quit:a<0  set string=string_$char(a)
 use prdev
 close file
 quit string
errorFileToString //
 set $ztrap=""
 use prdev
 close file
 quit string
}

ClassMethod WriteToFile(method As %Library.String = "", file As %Library.String = "")
{
 if method="" quit  //#
 if file="" quit  //#
 new prdev
 set prdev=$io
 set $ztrap="errorWriteToFile"
 open file:"wn"
 use file xecute "do "_method
 use prdev
 close file
 quit
errorWriteToFile //
 set $ztrap=""
 use prdev
 close file
 quit
}

ClassMethod Replace(sourceString As %String = "", findString As %String = "", replaceString As %String = "") As %String
{
 new result, i
 set result = ""
 for i=1:1:$Length(sourceString,findString)
 {
 if (i'=1) set result = result_replaceString
 set result = result_$Piece(sourceString,findString,i)
 }
 quit result
}

ClassMethod StringToExcel(aString As %String = "") As %String
{
   set aString=..Replace(aString,$c(13)," ")
   set aString=..Replace(aString,$c(10),"")
   set aString=..Replace(aString,$c(19)," ")
   quit aString
}

ClassMethod SqlDate(aDate As p6.dt.Date = "") As %String
{
   new ret
   if aDate="" quit ""
   set ret="todate('"_$zdate(aDate,1)_"','MM/DD/YYYY')"
   quit ret
}

ClassMethod SqlTime(aTime As p6.dt.Time = "") As %String
{
   new ret
   if aTime="" quit ""
   set ret="CAST('"_aTime_"' AS TIME)"
   quit ret
}

/// Преобразование кодировки DOS -> Win ("DW")
/// Win -> DOS ("WD")
ClassMethod TranslateFile(fromFile As %Library.String = "", toFile As %Library.String = "", dw As %Library.String = "") As %Library.Status [ ProcedureBlock = 1 ]
{
 if fromFile="" quit $$$ERROR(10000,"неверно имя входного файла") //#
 if toFile="" quit $$$ERROR(10000,"неверно имя выходного файла") //#
 if (dw="") { set dw = "DW" }
 set From = ##class(%File).%New(fromFile)
 do From.Open("RU")
 set To = ##class(%File).%New(toFile)
 do To.Open("WSN")
 while ('From.AtEnd) {
	 set s = From.Read(1)
	 if (dw="WD") {set s = ..Win1251KOI8(s)}
	 else { set s = ..KOI8Win1251(s) }
	 do To.Write(s)
 }
 quit $$$OK
}

/// Удаление символа из файла
ClassMethod EraseSymbolFromFile(fromFile As %Library.String = "", toFile As %Library.String = "", symbol As %Library.String = "") As %Library.Status [ ProcedureBlock = 1 ]
{
 if (fromFile="") {quit $$$ERROR(10000,"неверно имя входного файла")} //#
 if (toFile="") {quit $$$ERROR(10000,"неверно имя выходного файла")} //#
 if (symbol="") { quit $$$ERROR(10000,"не указан символ для удаления") } //#
 set From = ##class(%File).%New(fromFile)
 do From.Open("RU")
 set To = ##class(%File).%New(toFile)
 do To.Open("WSN")
 while ('From.AtEnd) {
	 set s = From.Read(1)
	 if (s'=symbol) {do To.Write(s)}
 }
 quit $$$OK
}

/// Для Экзеля - разделяет значение по буковкам и записывает в разные поля.
/// GetCharDividedString("a","q1w")="&a1=q&a2=1&a3=w"
/// см. класс tax.test.Return
ClassMethod GetCharDividedString(aName As %String, aValue As %String) As %String
{
   set res=""
   for i=1:1:$length(aValue) {
      set res=res_"&"_aName_i_"="_$extract(aValue,i)
   }
   quit res
}

ClassMethod Reverse(str, delimiter = ",") As %String [ SqlProc ]
{
	quit:$LENGTH(str,delimiter)=1 str
	set result = ""
	for i=1:1:$LENGTH(str,delimiter) {
		set result = $piece(str,delimiter,i)_$select(result]"":", ",1:"")_result	
		
	}
	
	quit $e(result,2,999)
}

/*
ClassMethod JsonToProxyObject(json As %Object) As %ZEN.proxyObject [ ProcedureBlock = 1 ]
{
	set result = ##class(%ZEN.proxyObject).%New()
	set result.children = ##class(%ListOfObjects).%New()
	set iterator=json.$getIterator()
    while iterator.$getNext(.key,.value) {
	    if key="children" {
			set value = ..ChildrenJsonToProxyObject(value) 
			do result.children.Insert(value)
	    } else { 
	    	SET $PROPERTY(result,key) = value
	    }
        //write !, "Property name: ",key
        //write !, "Property value: ",value
    }
	quit result
}

ClassMethod ChildrenJsonToProxyObject(arayJson As %Library.Array) As %ListOfObjects [ ProcedureBlock = 1 ]
{
	set result = ##class(%ListOfObjects).%New()
	set iterator0=arayJson.$getIterator()
	while iterator0.$getNext(.index,.json) {
		set proxyObject = ##class(%ZEN.proxyObject).%New()
		set proxyObject.children = ##class(%ListOfObjects).%New()
		set iterator=json.$getIterator()
	    while iterator.$getNext(.key,.value) {
    		if key="children" {
				set value = ..ChildrenJsonToProxyObject(value)    
	    	 	do proxyObject.children.Insert(value)
	    	} else { 
	    		SET $PROPERTY(proxyObject,key) = value
	    	}
    	}
	 	do result.Insert(proxyObject)
	 	
    }
	quit result
}
*/
}

