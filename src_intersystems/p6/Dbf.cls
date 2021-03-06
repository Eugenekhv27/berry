/// методы для работы с dbf (чтение, запись)
/// dimas 2003, shu 031012, 060620
Class p6.Dbf Extends %RegisteredObject [ ClassType = "", ProcedureBlock ]
{

/// Вывод в dbf файл
/// обращение: set sc=##class(p6.Dbf).WriteFile(file,array)
/// 	sc - сообщение о результате в формате %Status
/// 	file-имя файла
/// 	array - строка со ссылкой на уровень глобального массива,
///          в котором хранятся заголовок и строки
/// 	       для выдачи в файл (на следующем уровне): ^asd("asdf"),
/// 	       ^CacheTemp($job,"dbf")
///          за ссылкой следуют индексы 
///          ...,"header")=<заголовок> 
///             в формате $list($list(var1,length1,type1,dec1),...,$list(varN,lengthN,typeN,decN))
///          ...,"row",<номер записи>)=<запись>
///             в формате $list(var1,...,varN)
ClassMethod WriteFile(file As %String = "", array As %String = "") As %Status [ Final ]
{
	if ( file="" ) { quit $$$ERROR(10000,"неверно имя файла") } //#
	
	// открытие нового файла
	Set fileWrite=##class(%File).%New(file)
	set sc = fileWrite.Open("WSN") if 'sc quit sc //#
	$$$QuitOnError(..WriteStream(.fileWrite,array))
	Do fileWrite.Close()
	kill fileWrite
	quit $$$OK
	;
}

ClassMethod WriteStream(ByRef fileWrite As %Stream = "", array As %String = "") As %Status [ Final ]
{
	if ( fileWrite=$$$NULLOREF ) { quit $$$ERROR(10000,"неверный поток") } //#
	
	if ( $extract(array,$length(array))=")" ) { set array=$extract(array,1,$length(array)-1) }
	if ( $extract(array,$length(array))="," ) { set array=$extract(array,1,$length(array)-1) }
	if ( array="" ) { quit $$$ERROR(10000,"ссылка на массив неверная") } //#
	if ( array'["(" ) { quit $$$ERROR(10000,"ссылка на массив неверная, нет ""(""") } //#
	
	set fldList = @(array_",""header"")")
	set fldQty = $listlength(fldList) //количество полей
	if ( fldQty = 0 ) { quit $$$ERROR(10000,"неверно описание полей") } //#

	// 1 байт заголовок
	do fileWrite.Write($char(3)) //dBASE III PLUS without a memo
	// 3 байта дата последнего обновления YYMMDD
	set date=$zdate(+$horolog,8)
	do fileWrite.Write($char(+$extract(date,3,4))) //год
	do fileWrite.Write($char(+$extract(date,5,6))) //месяц
	do fileWrite.Write($char(+$extract(date,7,8))) //число
	// 32-битное число 4 байта количество записей
	set az=array_",""row"",nzi)", nz=0,nzi="" 
	for  {
		set nzi=$order(@az)
		quit:nzi=""  //#
		set nz=nz+1
	}
	do fileWrite.Write($char((nz#256),(nz\256#256),(nz\256\256#256),(nz\256\256\256#256)))
	
	// структура записей
	do ..WriteStructure(fileWrite, fldList) ;заголовок dbf в файл
		
	// перечень и свойства полей в записи по порядку
	for f=1:1:fldQty {
		set fldProperty=$listget(fldList,f)
		set fldArray(f,"name")=$listget(fldProperty,1)
		set fldArray(f,"type")=$listget(fldProperty,2)
		set fldArray(f,"length")=$listget(fldProperty,3)
		set fldArray(f,"dec")=$listget(fldProperty,4)
	}

	//вывод записей
	set az=array_",""row"",nzi)"
	set nzi="" 
	for  {
		set nzi=$order(@az) quit:nzi=""  //#
		set z=$get(@az) // перечень значений в строке
		
		//добавление записи в dbf
		do fileWrite.Write(" ") // 1 байт - признак удаления записи
		
		//формирование значений полей
		for f=1:1:fldQty {
			set fldValue = $listget(z,f)
			if (fldArray(f,"type")="D") {
				if ( fldValue?5.6n ) { set fldValue = $zdate(fldValue,8) } // перевод dbf формата
				else { set fldValue = "        " }
				do fileWrite.Write(fldValue)
			}
			if (fldArray(f,"type")="N") {
				set fldValue = $j(fldValue,fldArray(f,"length"),fldArray(f,"dec"))
				do fileWrite.Write(fldValue)
			}
			if ((fldArray(f,"type")'="N") && (fldArray(f,"type")'="D")) {
				do fileWrite.Write($extract(fldValue,1,fldArray(f,"length"))) //длина поля
				do fileWrite.Write($j("",(fldArray(f,"length")-$length(fldValue)))) //остаток - пробелами
			}
		}
	}
	//закрытие файла
	do fileWrite.Write($char(26))
	quit $$$OK
	;
}

/// Чтение dbf файла в массив
/// обращение: set sc=##class(p6.Dbf).ReadFile(file,array)
/// 	sc - сообщение о результате в формате %Status
/// 	file-имя файла
/// 	array - строка со ссылкой на уровень глобального массива,
///          в котором хранятся заголовок и строки,
/// 	       прочитанные из файла (на следующем уровне): ^asd("asdf"),
/// 	       ^CacheTemp($job,"dbf")
///          за ссылкой следуют индексы 
///          ...,"header")=<заголовок> 
///             в формате $list($list(var1,length1,type1,dec1),...,$list(varN,lengthN,typeN,decN))
///          ...,"row",<номер записи>)=<запись>
///             в формате $list(var1,...,varN)
///   isReadPerSymbol - читать запись не фиксированной строкой, а посимвольно (в случае,
///          если в записи могут встретиться спецсимволы-разделители. Практически
///          такое не встречается)
///   isDosWin - перекодировать имена полей и значения в данных из кодировки DOS в Windows
ClassMethod ReadFile(file As %String = "", array As %String = "", isReadPerSymbol As p6.dt.Boolean = 0, isDosWin As p6.dt.Boolean = 0) As %Status [ Final ]
{
	if ( file="" ) { quit $$$ERROR(10000,"неверно имя файла") } //#
	
	if ( $e(array,$l(array))=")" ) { set array=$e(array,1,$l(array)-1) }
	if ( $e(array,$l(array))="," ) { set array=$e(array,1,$l(array)-1) }
	if ( array="" ) { quit $$$ERROR(10000,"ссылка на массив неверная") } //#
	if ( array'["(" ) { quit $$$ERROR(10000,"ссылка на массив неверная, нет ""(""") } //#
	if ( $extract(array,$length(array))="(" ) { quit $$$ERROR(10000,"ссылка на массив неверная, нет индексов или заканчивается символом ""(""") } //#
	
	kill @(array_")")
	
	// открытие файла
	Set fileRead=##class(%File).%New(file)
	set sc = fileRead.Open("RSU") if 'sc quit sc //#
	// чтение посимвольное
	// 1 байт заголовок
	do fileRead.Read(1) //dBASE III PLUS without a memo
	for ii=1:1:3 do fileRead.Read(1) // 3 байта дата последнего обновления YYMMDD
	for ii=1:1:4 do fileRead.Read(1) // 32-битное число 4 байта количество записей
	
	// структура записей
	set fldList = ..ReadStructure(fileRead,isDosWin) //получение структуры дбф
	set fldQty=$listlength(fldList) //количество полей
	if ( fldQty=0 ) { quit $$$ERROR(10000,"неверное описание полей") } //#
	set @(array_",""header"")") = fldList
	
	// длина и структура записи
	set rowLength = 1 // первый символ записи - признак удаления
	kill fldArray
	for f=1:1:fldQty {
		set fldProperty=$listget(fldList,f)
		set fldArray(f,"name")=$listget(fldProperty,1)
		set fldArray(f,"type")=$listget(fldProperty,2)
		set fldArray(f,"length")=$listget(fldProperty,3)
		set fldArray(f,"dec")=$listget(fldProperty,4)
		set rowLength = rowLength + fldArray(f,"length")
	}
	
	set arrayRow=array_",""row"",nzi)"
	set nzi=0 

	for  {
		if ( isReadPerSymbol ) { set z = ..ReadPerSymbol(fileRead,rowLength) } //чтение с символами-разделителями
		else { set z = fileRead.Read(rowLength) } //если уверены, что в записи нет символов разделителей
		if ($length(z) < rowLength ) { quit }  //# закончился файл
		
		if ( $extract(z)'=" " ) { quit } //# признак удаленной записи
		//формирование значений полей
		if (isDosWin) { set z = ##class(p6.Convert).KOI8Win1251(z) } //перекодировка
		set zList = "" // строка в массив
		set zBegin = 2
		for f=1:1:fldQty {
			set zEnd = zBegin + fldArray(f,"length") - 1 // позиции поля
			set fldRead = $extract(z,zBegin,zEnd)
			if (fldArray(f,"type")="D") {
				set fldRead = $translate(fldRead," ","")
				if ( fldRead?8n ) { set fldRead = $zdateh(fldRead,8) } // перевод dbf формата
				set zList = zList_$listbuild(fldRead)
			}
			if (fldArray(f,"type")="N") {
				set fldRead = +$translate(fldRead," ","")
				set zList = zList_$listbuild(fldRead)
			}
			if ((fldArray(f,"type")'="N") && (fldArray(f,"type")'="D")) {
				if ( $extract(fldRead,$length(fldRead))=" " ) {
					set fldRead = ..PurgeEndBlanks(fldRead)
				}
				set zList = zList_$listbuild(fldRead)
			}
			set zBegin = zEnd+1
		}
		set nzi = nzi + 1 // номер записи
		set @(array_",""row"","_nzi_")") = zList
	}
	//закрытие файла
	Do fileRead.Close()
	kill fileRead
	quit $$$OK
	;
}

/// Очистка пробелов в конце строки
ClassMethod PurgeEndBlanks(str As %String = "") As %String
{
	if ( str="" ) { quit str } //#
	if ( $extract(str,$length(str))'=" " ) { quit str } //#
	while ( $extract(str,$length(str))=" " ) { 
		set str = $extract(str,1,$length(str)-1) 
	}
	quit str
}

/// создать заголовок структуры dbf
/// [Previously private]
ClassMethod WriteStructure(fileWrite As %File, fldList As %String = "")
{
	// 8-9 16-bit number - number of bytes in the header
	set fldQty=$listlength(fldList) //количество полей
	set headerLength=(fldQty+1)*32+2 //длина заголовка
	do fileWrite.Write($char(headerLength#256,headerLength\256))
	
	// 10-11 16-bit number - number of bytes in the record
	set nbr=0
	for f=1:1:fldQty {
		set fld = $lg(fldList,f)
		set nbr=nbr+$lg(fld,3)
	}
	set nbr = nbr +1 //байт на признак удаления
	do fileWrite.Write($char(nbr#256,nbr\256))
	
	// 12-31 3+13+4 байт зарезервировано
	do fileWrite.Write($char(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
	for f=1:1:fldQty {
		set fld = $lg(fldList,f)
		set fldName = $listget(fld,1) //имя
		set fldName = $translate(fldName,"qwertyuiopasdfghjklzxcvbnm","QWERTYUIOPASDFGHJKLZXCVBNM")
		do fileWrite.Write(fldName)
		for ii=1:1:(11-$length(fldName)) do fileWrite.Write($char(0)) //дополнение имени
		do fileWrite.Write($lg(fld,2)) //тип
		do fileWrite.Write($char(0,0,0,0)) //адрес в памяти
		do fileWrite.Write($c(+$lg(fld,3))) //длина
		do fileWrite.Write($char(+$lg(fld,4))) //длина после точки
		do fileWrite.Write($char(0,0,0,0,0,0,0,0,0,0,0,0,0,0)) //14 байт - резерв
	}
	do fileWrite.Write($char(13,0)) //конец описания структуры
}

/// прочитать заголовок структуры dbf
/// [Previously private]
ClassMethod ReadStructure(fileRead As %File, isDosWin As p6.dt.Boolean = 0) As %String
{
	set fldList = "" //список полей
	// 8-9 16-bit number - number of bytes in the header
	set z1 = fileRead.Read(1), z2 = fileRead.Read(1)
	set headerLength = $ascii(z2)*256 + $ascii(z1) //длина заголовка
	//set fldQty=(headerLength-2)/32 - 1 //количество полей !!!shu 060619
	set fldQty=(headerLength)\32 - 1 //количество полей !!!shu 060619
	
	// 10-11 16-bit number - number of bytes in the record
	set z1 = fileRead.Read(1), z2 = fileRead.Read(1)
	set rowQty = $ascii(z2)*256 + $ascii(z1) //длина записи
	
	// 12-31 3+13+4 байт зарезервировано
	for f=1:1:20 { do fileRead.Read(1) }	

	for f=1:1:fldQty {
		// поле 32 байта
		set fldName = fileRead.Read(11) //имя 11
		set fldName  = $translate(fldName,$char(0),"")
		if (isDosWin) { set fldName = ##class(p6.Convert).KOI8Win1251(fldName) }
		set fldType = fileRead.Read(1) //тип 1
		for ii=1:1:4 do fileRead.Read(1) //адрес в памяти
		set fldLength = $ascii(fileRead.Read(1)) //длина
		set fldDec = $ascii(fileRead.Read(1)) //длина после точки
		do fileRead.Read(14) //14 байт - резерв
		set fldProperty = $listbuild(fldName,fldType,fldLength,fldDec)
		set fldList = fldList_$listbuild(fldProperty) //список полей
	}
	do fileRead.Read(1) //2 байта, конец описания структуры
	//do fileRead.Read(1) 
	// !!! shu 060619 какой-то байт то появляется, то исчезает !!!
	quit fldList
}

/// посимвольное чтение записи из файла, чтобы прочитать запись, даже если в ней 
///    есть спецсимволы-разделители
/// [Previously private]
ClassMethod ReadPerSymbol(fileRead As %File, rowLength As %String = "") As %String
{
	set z=""
	for f=1:1:rowLength { set z = z_fileRead.Read(1) }
	quit z
}

/// Документация
/// [Previously private]
ClassMethod doc()
{
 // Shu 030119, 031012 для кащея
 // структура dbf - http://www.wotsit.org/
 // чтение файла нужно производить по 1 символу, чтобы не попасть на разделитель (12, 13, 26)
 //
 //
 //
 // Проверка:
 // do ##class(p6.Dbf).Prov1ToDbf() - формирование массива и запись в файл
 // do ##class(p6.Dbf).Prov1FromDbf() - чтение файла и формирование массива
 // do ##class(p6.Dbf).Prov1FromDbf(1) - чтение файла и формирование массива
}

/// Проверка формирования dbf
ClassMethod Prov1ToDbf()
{
	kill ^a1.Prov1($job)
	set file = "c:\prov1.dbf"
	set array = "^a1.Prov1("_$job_",""dbf"""
	// описание полей
	set ^a1.Prov1($job,"dbf","header") = $listbuild($listbuild("f1","C",3),$listbuild("f2","N",6),
		$listbuild("f3","N",9,2),$listbuild("f4","C",3),$listbuild("f5","D",8))
	// строки данных в файл
	set ^a1.Prov1($job,"dbf","row",1) = $listbuild("f1",123,1231.23,"f4",58369)
	set ^a1.Prov1($job,"dbf","row",2) = $listbuild(1,2,333.33,4,63445)
	set ^a1.Prov1($job,"dbf","row",3) = $listbuild(11,22,123,44,50000)
	set a = ..WriteFile(file,array)
	write !,"Формирование dbf = ",a,!
	quit
}

/// Проверка чтения dbf (просмотр в проводнике)
ClassMethod Prov1FromDbf(isReadPerSymbol As p6.dt.Boolean = 0)
{
	kill ^a1.Prov1($job)
	set file = "c:\prov1.dbf"
	set array = "^a1.Prov1("_$job_",""prov1"""
	set a = ..ReadFile(file,array,isReadPerSymbol)
	write !,"Чтение dbf = ",a,!
	zwrite ^a1.Prov1($job)
	quit
}

}

