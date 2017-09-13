/// Стандартная таблица на основе которой созданы все справочники<br>
/// Существует возможность работать в режиме выбора нескольких строк(свойство <property>multiselect</property>-true).
/// Рядом с каждой строкой появляеться галочки при помощи которых отмечаются выбранные.<br><br>
/// Также может работать в режиме "страниц": чтобы большую таблицу полностью не загружать с сервера,
/// загружаем и показываем только одну "страницу".
/// Переключателем "страниц" могут служить следующие компоненты:<br>
/// <class>p6.zen.component.refBook</class><br>
/// <class>%ZEN.Component.tableNavigator</class><br>
/// <class>%ZEN.Component.tableNavigatorBar</class><br>
Class p6.zen.component.tablePane Extends %ZEN.Component.tablePane
{

/// This is the XML namespace for this component
Parameter NAMESPACE = "http://www.dimas.ru/p6";

// Redefine initial values from parent

/// Список в котором содержаться все колонки справочника
Property columns As list Of p6.zen.auxiliary.column(XMLPROJECTION = "ELEMENT", XMLTYPECONSTRAINT = "CHOICE");

/// Принимать сообщения от клавиатуры пользователя
Property useKeys As %ZEN.Datatype.boolean [ InitialExpression = 1 ];

/// Количество строк на одной "странице"<br>
/// 0 - показывать все<br>
/// Использовать только в режиме snapshot
Property pageSize As %ZEN.Datatype.integer [ InitialExpression = 200 ];

/// Показывать зеброй=)<br>
/// Пары строчек разных цветов.
Property showZebra As %ZEN.Datatype.boolean [ InitialExpression = 1 ];

/// Использовать снимок (snapshot)<br>
/// Позволяет организовать страницы и пересортировку без перезапуска запроса
Property useSnapshot As %ZEN.Datatype.boolean [ InitialExpression = 1 ];

/// IE не поддерживает nowrap(не переносит слова на сл. строку) заданный в CSS.<br>
/// Это свойство добовляет другие пути для IE...
Property nowrap As %ZEN.Datatype.boolean [ InitialExpression = 0 ];

/// Максимальное количество строк извлекаемое из <class>%ResultSet</class>.
Property maxRows As %ZEN.Datatype.integer [ InitialExpression = 10000 ];

/// Показывать отдельную колонку с селектором строк
Property showRowSelector As %ZEN.Datatype.boolean [ InitialExpression = 0 ];

/// Название колонки отвечающей за логическое значение выбранной строки
Property valueColumn As %ZEN.Datatype.string [ InitialExpression = "ID" ];

/// Если <property>fixedHeaders</property> - true,
/// задает значение высоты основной части таблицы
Property bodyHeight As %ZEN.Datatype.length [ InitialExpression = "10%" ];

XData Style
{
<style type="text/css">
/* @doc="Style for odd-rows when using zebra styling." */
.tpOdd {
	color: darkblue;
	background-color: #F8F8FF;
}

/* @doc="Style for even-rows when using zebra styling." */
.tpEven {
	color: darkblue;
	background-color: #C0D2DC;
}

/* @doc="Style for bottom row with aggregations" */
.tpBottomRow {
	color: darkblue;
	background-color: #DDDDDD;
}

.tpNum {
	text-align: right;
	white-space: nowrap;
}

TABLE.tpTable {
	TABLE-LAYOUT: auto;
	font-size:0.8em;
}

</style>
}

/// Подготовка столбцов- заполнение недастающих данных(заголовки итп) из описания классов п6
Method PrepareColumns() As %Status
{
	set ..aggCols=""
	for i=1:1:..columns.Count() {
		set Column = ..columns.GetAt(i)
		#DIM Column As p6.zen.auxiliary.column
		if 'Column.%IsA("p6.zen.auxiliary.column") continue
			
		if Column.field]"" {
			if Column.colExpression="" {	
				if Column.field["-" {
					set Column.colExpression=Column.field
				}
				else {
					 set Column.colName=Column.field
				}
			}
			if (..tableName]"") && (Column.header="") {
				
				set className=$tr(..tableName,"_",".")
				set firstFieldName=$tr($piece(Column.field,"-",1)," ")
				set Column.header=##class(p6.ClassDefinition).GetPropertyCaption(className,firstFieldName)
			}
		}
		if Column.isAggregated {
			set ..aggCols=$s(..aggCols="":i,1:..aggCols_","_i)
		}

		if (Column.colExpression]"") && (Column.colName="") {
			set Column.colName=$tr(Column.colExpression,"()->|","")
		}
		if (Column.colName="ID") {
			set Column.header="Код"
		}
		if (Column.title="") {
			
			set Column.title=Column.header
		}
	}
	quit $$$OK
}

/// Отрисовка всего компонента(окружающий div, поле ввода дополнительно к таблицы) в HTML
Method %DrawHTML()
{
	
	do ..PrepareColumns()
	// Here we should write do ##super(), but it doesn't call our %DrawTable
	#; check for invalid property combinations
	Set tSC = $$$OK
	If ('..useSnapshot && (+..pageSize>0)) {
		Set tSC = $$$ERROR($$$GeneralError,"Page size should only be specified in snapshot mode")
	}

	If (..useKeys) {
		#; insert invisible input to catch key events
		Set keyevt = "onkeydown=""zenPage.getComponent("_..index_").tpKeyDownHandler(event);"" onkeypress=""zenPage.getComponent("_..index_").tpKeyPressHandler(event);"""
		
		// чтобы Firefox не прокручивал страницы
		if $$$ZENISIE {
			set style="style=""top:0px;left:0px;position:absolute;border: 0px solid green;width:0;height:0;padding:0;"""
		}else {
			set style="style=""top:0px;left:0px;position:fixed;border: 0px solid green;width:0;height:0;padding:0;"""
		}
		
		&html<<input type="text" id="#(..%MakeId("invisible"))#" #(style)# #(keyevt)# />>
	}
	
	Set tInfo = ""
	Set tRS = ""
	Set tRunQuery = 1
	If ('..clearSnapshot && (%zenContext'="page") && ..useSnapshot && (..snapshotId '= "")) {
		#; test if snapshot exists
		If $D(^CacheTemp.zenData(%session.SessionId,..snapshotId,..index)) {
			Set tRunQuery = 0
		}
		Else {
			#; go back to page 1
			Set ..currPage = 1
		}
	}

	If (tRunQuery) {
		If ((..clearSnapshot || '..useSnapshot) && (..snapshotId'="")) {
			#; kill old snapshot
			Kill ^CacheTemp.zenData(%session.SessionId,..snapshotId,..index)
			Set ..snapshotId=""
		}

		#; create QueryInfo object to hold query info
		;+++++p6
		;Set tInfo = ##class(%ZEN.Auxiliary.QueryInfo).%New()
		Set tInfo = ##class(p6.zen.auxiliary.queryInfo).%New()
		;-----p6
		
		#; convert parameters to array
		For n = 1:1:..parameters.Count() {
			Set value = ..parameters.GetAt(n).value
			Set tInfo.parms(n) = $$$ZENVAL(value)
		}

		#; additional query parms
		Set tInfo.sortColumn = $$$ZENVAL(..currColumn)
		Set tInfo.sortOrder = $$$ZENVAL(..sortOrder)
		Set tInfo.tableName = $$$ZENVAL(..tableName)
		Set tInfo.columnName = $$$ZENVAL(..columnName)
		Set tInfo.whereClause = $$$ZENVAL(..whereClause)
		Set tInfo.orderByClause = $$$ZENVAL(..orderByClause)
		Set tInfo.groupByClause = $$$ZENVAL(..groupByClause)
		
		#; +p6 - проверка GetModelFilter
		set className=$tr(..tableName,"_",".")
		if ##class(%Dictionary.CompiledMethod).%ExistsId(className_"||GetModelFilter") {
			set tInfo.whereClause = ##class(p6.FilterUtils).Add(tInfo.whereClause,$zobjclassmethod(className,"GetModelFilter"))
		}

		#; # of rows to fetch
		If (..useSnapshot) {
			Set tInfo.rows = 0 // fetch all
		}

		#; look at column object to find filters and column info.
		#; these will be passed on to the CreateResultSet callback
		#; so that it can apply filtering etc.
		Set tCount = ..columns.Count()
		For n=1:1:tCount {
			Set tColumn = ..columns.GetAt(n)
			Set tColName = $$$ZENVAL(tColumn.colName)
			If (tColName'="") {
				#; make sure client has resolved client name
				Set:tColName'=tColumn.colName tColumn.actualColName = tColName

				#; column info
	 			Set tInfo.columns(n) = tColName
	 			Set tInfo.columnExpression(tColName) = $$$ZENVAL(tColumn.colExpression)
  
				#; filter info
				Set tInfo.filters(tColName) = $S(tColumn.filterValue=$C(0):"",1:tColumn.filterValue)
				Set tInfo.filterOps(tColName) = $S(tColumn.filterOp=$C(0):"",1:tColumn.filterOp)
				Set tInfo.filterTypes(tColName) = $S(tColumn.filterType=$C(0):"",1:tColumn.filterType)
			}
		}
		

		#; create and execute result set
		Set ..lastUpdate = ""
		Set ..rowCount = "" // clear
		Set tRS = ..%CreateResultSet(.tSC,tInfo,..initialExecute)
		If $$$ISERR(tSC) {
			#; don't show error if no initialExecute
			If (..initialExecute) {
				Do ##class(%ZEN.Utils).%DisplayErrorHTML($this,tSC)
			}
		}

		If $$$ISOK(tSC)&&$IsObject(tRS) {
			#; set lastUpdate time: timestamp plus ms
			Set ..lastUpdate = $ZDT($ZU(188),3,,3)
	
			If (..useSnapshot) {
				#; build the snapshot
				#; create snapshot ID
				Set ..snapshotId = ($ZH*100)\1
				Set tSC = ..%CreateSnapshot(..snapshotId, tRS)
				If $$$ISERR(tSC) {
					Do ##class(%ZEN.Utils).%DisplayErrorHTML($this,tSC)
				}
			}
		}
	}

	#; diagnostic display
	If ($$$ZENVAL(..showQuery)) {
		If $IsObject(tInfo) {
			Set tQueryText = tInfo.queryText
		}
		Else {
			Set tQueryText = "snapshot: (" _ ..snapshotId _ ")"
		}
		&html<<div style="border: 1px solid darkblue; padding:2px; background: white;">#($ZCVT(tQueryText,"O","HTML"))#</div>>
	}

	#; draw the table
	If $$$ISOK(tSC) {
		Set tSC = ..%DrawTable(tRS)
		If $$$ISERR(tSC) {
			Do ##class(%ZEN.Utils).%DisplayErrorHTML($this,tSC)
		}
		Set tRS = ""
	}
	
	#; reset execute flag
	Set ..initialExecute = 1
	quit
}

/// Отрисовка нижней строки- подсуммировок по колонкам.<br>
/// При режиме <property>multiselect</property> отображается 2 строки:<br>
/// -Итого выбрано<br>
/// -Итого
Method DrawBottomRow() As %Status
{
	if '..initialExecute quit $$$OK
	set visualNum=0
	if ..multiSelect set visualNum=1

	set sumList=^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"sumData")
	set isShowSumStr=$S($ListGet(sumList,1,"")="":$$$YES,1:$$$NO)
		
	if ..multiSelect {
		&html<<tr>>
		&html<<td>Итого выбрано:</td>>
		for i=1:1:$listLength(sumList) {
			if (..columns.GetAt(i).hidden) continue
			&html<<td id="#(..%MakeId("tdAggCol"_i))#" style="font-weight:bold;font-size:1.2em;" align="right">&nbsp;</td>>
		}
		&html<</tr>>		

	}
	
	&html<<tr class="tpBottomRow">>
	set firstNonHidden=0
	if ..multiSelect {
		&html<<td>Итого:</td>>
		set firstNonHidden=1
	}
	for i=1:1:$listLength(sumList) {
		if (..columns.GetAt(i).hidden) continue
		if '..multiSelect {
			if (('..columns.GetAt(i).isAggregated) & ('firstNonHidden)) {
				&html<<td>Итого:</td>>
				set firstNonHidden=1
				continue
			}
		}
		
		set firstNonHidden=1
		&html<<td align="right" nowrap>#($s(+$LG(sumList,i,0)'=0:##class(p6.UrlUtils).ConvertCurrency2($LG(sumList,i,0)),1:"&nbsp;"))#</td>>
	}
	&html<</tr>>
	quit $$$OK
}

/// Вывод на печать<br>
/// при значении <var>mode</var>:<br>
/// <ul>
///  <li>1-в Текстовой процессор(Word/Writer)</li>
///  <li>2-в Табличный процессор(Excel/Calc)</li>
/// </ul>
/// В <var>header</var> можно задать заголовок (HTML)
ClientMethod printIt(mode, header) [ Language = javascript ]
{
	if(mode=="") mode="1";
	var data=this.PrintItToFile(mode,header);
	var repSetting=this.GetReportSetting();
	OpenWindow("p6.csp.Print.cls?DataFrom="+escape(data)+"&Mode="+mode+"&ReportSet="+repSetting);
}

/// (Внутренний метод)<br>
/// Вывод таблицы в файл
Method PrintItToFile(mode As %String, header As %String) As %String [ ZenMethod ]
{
	Set oldio=$IO
	Set tmpdir=##class(%File).NormalizeDirectory(^%SYS("TempDir"))
	Set filename = tmpdir_##class(%FileBinaryStream).NewFileName("tmp",^%SYS("TempDir"))
	Open filename:("NW")
	Use filename
	set oldPageSize=..pageSize
	set oldUseKays=..useKeys
	set oldFixedHeaders=..fixedHeaders
	set ..pageSize=..rowCount
	set ..fixedHeaders=$$$NO
	//Чтобы пропал НЕВИДИМЫЙ INPUT
	set ..useKeys=$$$NO
	if header'="" w "<center><font size=+2><b>"_$$$ZENVAL(header)_"</b></font></center>"
	do ..%DrawHTML()
	Close filename
	Use oldio
	set ..pageSize=oldPageSize
	set ..useKeys=oldUseKays
	set ..fixedHeaders=oldFixedHeaders
	Quit filename
}

/// Вернуть настройки печати<br>
/// 1-MS Office<br>
/// 2-Open Office<br>
Method GetReportSetting() As %Integer [ ZenMethod ]
{
	quit 1
	//quit %session.Data("UserSys",$username,"ReportMode")
}

/// Для режима выбора нескольких ячеек позволяет выбрать ячейки с клиента.<br>
/// <var>row</var> - строка<br>
/// <var>flag</var> - выбрана или нет<br>
/// Так же обновляет значение галочки(чекбокса)
ClientMethod selectMultiRow(row, flag) [ Language = javascript ]
{
	    // convert local row # to set of all rows
		var idx = row;
		if (!isNaN(this.pageSize)) {
			idx = row + ((this.currPage-1) * this.pageSize);
		}
			
	    // try to find logical value of selected row
    	// if the given row is not available on the client, do not select.
	    var val = '';
	    var tr = this.findElement("tr_" + row);
	    if (tr) {
	        val = tr.getAttribute('zenValue');
	    }
	
	    var list = this.selectedRows.split(',');
	    list[idx] = flag ? val : '';
	
	    this.selectedRows = list.join(',');
	
	    // find checkbox in this page
	    var rcb = this.findElement('cb_'+row);
	    if (rcb) {
	        rcb.checked = flag;
	    }
	      
		var dummy=this.UpdateSelAggSum(idx,flag);
		this.reshowSelAggSumCols();
}

/// Пересчет и установка <property>selectedRows</property> и колонок подсумировок если aRow="", то всех иначе только для одной строки
Method UpdateSelAggSum(aRow = "", aFlag As %ZEN.Datatype.boolean) As %Status [ ZenMethod ]
{
	set start=0
	set end=..rowCount-1
	
	set valCol=..GetValueColNum()
	
	if aRow="" {
		if ('aFlag) {
			set ..selectedRows=""
		}
		set p4selAggColsSum = ..selAggColsSum //shu12
		for i=1:1:$Length(..aggCols,",") {
			set $p(p4selAggColsSum,",",i)=0
		}
		set ..selAggColsSum = p4selAggColsSum
	}else {
		set start=aRow
		set end  =aRow
	}
	
	for row=start:1:end {	
		set p4selAggColsSum = ..selAggColsSum //shu12
		set p4aggCols = ..aggCols
		set p4selectedRows = ..selectedRows
		for i=1:1:$Length(..aggCols,",") {
			if aRow="" {
				if aFlag {
					if ..aggCols'="" set $p(p4selAggColsSum,",",i)=$p(p4selAggColsSum,",",i)+..FetchCellFromSnapshot(..index,..snapshotId,$p(p4aggCols,",",i),row+1,..currColumn,..sortOrder)
					set $p(p4selectedRows,",",row+1)=..FetchCellFromSnapshot(..index,..snapshotId,valCol,row+1,..currColumn,..sortOrder)
				}
			}else {
				if aFlag {
					if ..aggCols'="" set $p(p4selAggColsSum,",",i)=$p(p4selAggColsSum,",",i)+..FetchCellFromSnapshot(..index,..snapshotId,$p(p4aggCols,",",i),row+1,..currColumn,..sortOrder)
					set $p(p4selectedRows,",",row+1)=..FetchCellFromSnapshot(..index,..snapshotId,valCol,row+1,..currColumn,..sortOrder)
				}else {
					if ..aggCols'="" set $p(p4selAggColsSum,",",i)=$p(p4selAggColsSum,",",i)-..FetchCellFromSnapshot(..index,..snapshotId,$p(p4aggCols,",",i),row+1,..currColumn,..sortOrder)
					set $p(p4selectedRows,",",row+1)=""
				}
			}
		}
		set ..selAggColsSum = p4selAggColsSum
	}
	quit $$$OK
}

/// Пересчет подсуммировок по <property>selectedRows</property>
Method RecalcSelAggSum() As %Status [ ZenMethod ]
{
	set ..selAggColsSum=""
	set valCol=..GetValueColNum()

	for row=0:1:..rowCount-1 {
		set p4selectedRows = ..selectedRows //shu12
		set p4selAggColsSum = ..selAggColsSum
		set p4aggCols = ..aggCols
		for i=1:1:$Length(..aggCols,",") {
			if $p(p4selectedRows,",",row+1)'="" {
				set $p(p4selAggColsSum,",",i)=$p(p4selAggColsSum,",",i)
				+..FetchCellFromSnapshot(..index,..snapshotId,$p(p4aggCols,",",i),row+1,..currColumn,..sortOrder)
			}
		set ..selAggColsSum = p4selAggColsSum
		}
	}
	quit $$$OK
}

/// Перезагрузить значения колонок подсуммировок БЕЗ ПЕРЕСЧЕТА
/// (при переключении страниц)
ClientMethod reshowSelAggSumCols() [ Language = javascript ]
{
	if(this.multiSelect) {
		for(i=1;i<=Length(this.aggCols,",");i++)
		{
			var colNum=Piece(this.aggCols,",",i);
			var sumDiv = this.window.document.getElementById(this.makeId("tdAggCol"+colNum));
			if(sumDiv!=null) {
				var val=parseFloat(Piece(this.selAggColsSum,",",i));
				if(isNaN(val)) {
					sumDiv.innerHTML="0";
				}else {
					sumDiv.innerHTML=val.toFixed(2).toString().replace(/\./g,",");
				}
			}
		}
	}
}

/// Номера аггрегируемые колонок через ","
Property aggCols As %ZEN.Datatype.string;

/// Сумма агрегируемых колонок через ","
Property selAggColsSum As %ZEN.Datatype.string;

/// Для режима выбора нескольких строк:
/// отметить, либо снять отметки со всех зависит от <var>flag</var>.
ClientMethod selectAllMultiRows(flag) [ Language = javascript ]
{
	var dummy=this.UpdateSelAggSum("",flag);
	this.reshowSelAggSumCols();
}

/// Invoke user method to provide contents for a cell
Method %DrawCell(pMethod As %String, pName As %String, pSeed As %String, aRow As %Integer = "") As %Status
{
	Set $ZT="Trap"
	Set tSC = $$$OK

	#; invoke method
	Set tHost = $G(%page)
	If ($IsObject(tHost) && (pMethod '= "")) {
		Set tSC = $zobjmethod(tHost,pMethod,$this,pName,pSeed,aRow)
	}
Done
	Quit tSC
Trap
	Set $ZT=""
	Set tSC = $$$ERROR($$$GeneralError,$ZE)
	Write $ZCVT($ZE,"O","HTML")
	Goto Done
}

/// Определяем номер значещей колонки
/// используеться при работе с aggCols и selAggColsSum
Method GetValueColNum() As %Integer
{
	set valCol=0
	for i=1:1:..columns.Count() {
		set Column = ..columns.GetAt(i)
		if ($zcvt(Column.colName,"l")=$zcvt(..valueColumn,"l")) {
			set valCol=i
			quit
		}
	}
	quit valCol
}

/// Запрос одной ячейки из снимка
ClassMethod FetchCellFromSnapshot(pIndex As %Integer, pID As %String, pCol As %String, pRow As %Integer, pCurrColumn As %String = "", pSortOrder As %String = "") As %String [ ZenMethod ]
{
	    #; if table is sorted, find actual row ID # first
	    If (pCurrColumn = "") {
	        Set tRow = pRow
	    }
	    Else {
	        #; find n-th element in index (as there is no cross-index)
	        Set tSortOrder = $Case(pSortOrder,"asc":1,"desc":-1,:1)
	        Set tRow = ""
	        Set n = 0
	        Set tVal = $O(^CacheTemp.zenData(%session.SessionId,pID,pIndex,"index",pCurrColumn,""),tSortOrder)
	        While (tVal '= "") {
	            Set tKey = $O(^CacheTemp.zenData(%session.SessionId,pID,pIndex,"index",pCurrColumn,tVal,""),tSortOrder)
	            While (tKey '= "") {
	                Set n = n + 1
	                If (n = pRow) {
	                    Set tRow = tKey
	                    Quit
	                }
	                Quit:(n=pRow)
	                Set tKey = $O(^CacheTemp.zenData(%session.SessionId,pID,pIndex,"index",pCurrColumn,tVal,tKey),tSortOrder)
	            }
	            Quit:(tRow'="")
	            Set tVal = $O(^CacheTemp.zenData(%session.SessionId,pID,pIndex,"index",pCurrColumn,tVal),tSortOrder)
	        }
	    }
	
	    #; get data row from snapshot
	    Set tData = ""
	    Set:tRow'="" tData = $G(^CacheTemp.zenData(%session.SessionId,pID,pIndex,"data",tRow))
	
	    If ((tData="")||(+pCol=0)) {
	        Quit ""
	    }
	    quit $LIST(tData,pCol)
}

///  Client-side method to select the given row (0-based) in the table.
///  If <var>scroll</var> is true, scroll the new row into view.
///  If <var>which</var> is present, it is passed along to the user event notification.
ClientMethod selectRow(row, scroll, which) [ Language = javascript ]
{
	if (!this.rowSelect) {
		if (this.multiSelect && !this.ignoreClick) {
			// multi-select only; toggle multiselect for row
			this.selectMultiRow(row,!this.isRowSelected(row));
			zenInvokeCallbackMethod(this.onmultiselect,this,'onmultiselect');
		}
		// do nothing more
		this.ignoreClick = false;
		return;
	}

	this.ignoreClick = false;

	var changed = (row != this.selectedIndex);
	// unhighlight current selected
	if (this.selectedIndex >= 0) {
		var tr = this.findElement("tr_" + this.selectedIndex);
		if (tr) {
			tr.className = this.trClass ? this.trClass : '';
		}

		// selector
		var selector = this.findElement("selector_" + this.selectedIndex);
		if (selector) {
			selector.innerHTML="&nbsp;";
		}
		if (this.enableToggleSelect) {		
			this.selectedIndex = -1;
			this.value = ""; // PFD, 2013/02/04 - Clear the value property
			// invoke callback, if present
			which = ('undefined' == typeof which) ? '' : which;
			zenInvokeCallbackMethod(this.onunselectrow,this,'onunselectrow','which',which);
			if (!changed) return;
		}
	}
	
	this.selectedIndex = row;
	if (changed || !this.enableToggleSelect) {
		this.value = '';

		// update new selection
		if (this.selectedIndex >= 0) {
			var tr = this.findElement("tr_" + this.selectedIndex);
			if (tr) {
				// stash current background
				if (this._rowClassIndex && (this._rowClassIndex[row] != null)) {
					this.trClass = this._rowClassIndex[row];
					delete this._rowClassIndex[row];
				}
				else {
					this.trClass = tr.className;
				}
				tr.className = 'tpSelected';	

				if (scroll) {
					zenScrollIntoView(this.findElement('tpBody'),tr);
				}

				// get logical value of row
				this.value = tr.getAttribute('zenValue');
			}

			// selector
			var selector = this.findElement("selector_" + this.selectedIndex);
			if (selector) {
				selector.innerHTML="&raquo;";
			}
		}

		// invoke callback, if present
		if (this.enableToggleSelect || changed) {
			which = ('undefined' == typeof which) ? '' : which;
			zenInvokeCallbackMethod(this.onselectrow,this,'onselectrow','which',which);
		}
	}
	else if (this.onmouseoverClass && (this.onmouseoverClass != '')) {
		if (!this._rowClassIndex) {
			this._rowClassIndex =  new Object();
		}
		// remember this row's style for when we mouse out
		var thisClass = '';
		if (tr && tr.className) {
			thisClass = tr.className;
		}
		this._rowClassIndex[row] = thisClass;
	}
}

/// Вызывается после <method>refreshContents</method> 
/// Called after refreshContents--call the superclass to make sure row is selected.
/// then call the correctHeaders routine to see if any alignment issue need to be 
/// addressed.
ClientMethod onRefreshContents() [ Internal, Language = javascript ]
{
	this.invokeSuper('onRefreshContents',arguments);
	this.reshowSelAggSumCols();
}

/// Create a temporary snapshot file from a result set.
/// Assumes that result set has been created and executed.
/// Users should not call this method.
Method %CreateSnapshot(pTempID As %String, pRS As %ResultSet) As %Status
{
	Set tSC = $$$OK

	#; clear out temp file
	Kill ^CacheTemp.zenData(%session.SessionId,pTempID,..index)

	Do {
		If ('$IsObject(pRS)) {
			Set tSC = $$$ERROR($$$GeneralError,"Invalid result set object")
			Quit
		}

		#; get column metadata
		Set cols = pRS.GetColumnCount()
		For c = 1:1:cols {
			Set tCols(c) = pRS.GetColumnName(c)
			Set th = pRS.GetColumnHeader(c)
			Set:tCols(c)'=th tCols(c,"th") = th
			;p6+++++
			Set:..columns.GetAt(c).isAggregated tCols(c,"isAgr")=$$$YES
			;p6-----
			#; note: 10 is string and is the default
			Set:pRS.GetColumnType(c)'=10 tCols(c,"type") = pRS.GetColumnType(c)
		}

		#; remember column info
		Merge ^CacheTemp.zenData(%session.SessionId,pTempID,..index,"info") = tCols

		#; do not fetch more than maxRows rows
		Set tMaxRows = ..maxRows		
		Set row = 0
		Set tMore = 0
		;p6++++
		Set sumList = ""
		;p6----
		While (pRS.%Next(.tSC)) {
			If $$$ISERR(tSC) Quit
			If ((tMaxRows>0)&&(row>=tMaxRows)) {
				Set tMore = 1
				Quit
			}
			Set row = row + 1
			Set tValList = ""
			For c = 1:1:cols {
				#; fill in temp file
				#; 3:float,5:integer,10:string,12:binstream,13:charstream
				Set tColType = $G(tCols(c,"type"),10)
				If (tColType=12) {
					Set tVal = "[BinaryStream]"		// BINARYSTREAM
				}
				ElseIf (tColType = 13) {			// CHARACTERSTREAM
					Set tVal = "[CharacterStream]"	
				}
				Else {
					Set tVal = $G(pRS.Data(tCols(c)))
				}
				Set $List(tValList,c) = tVal
				;p6++++
				if $G(tCols(c,"isAgr"),$$$NO) s $List(sumList,c)=$ListGet(sumList,c,0)+tVal
				;p6----
			}
			Set ^CacheTemp.zenData(%session.SessionId,pTempID,..index,"data",row) = tValList
		}
		Set ..rowCount = row _ $S(tMore:"+",1:"")
		
		;p6++++
		Set ^CacheTemp.zenData(%session.SessionId,pTempID,..index,"sumData") = sumList
		;p6----
	} While (0)

	Quit tSC
}

/*
ClientMethod anchorDiv() [ Internal, Language = javascript ]
{
	
	//PL84286
	if (!this.useKeys) return;
	var node = this.getEnclosingDiv();
	var position = null;
	try {
		if (node.currentStyle) // IE Style
			position = node.currentStyle.position;
		else if (window.getComputedStyle) // W3C Style
			position = window.getComputedStyle(node,null).position;
		if (!(position=="absolute" || position=="relative")) {
			node.style.position = "relative";
			node.style.top = "0px";
			node.style.left = "0px";
		}
	 } catch (e) {
	 }
}
*/

/*
/// Handler for clicks within a row.
ClientMethod clickHandler(row) [ Internal, Language = javascript ]
{


		this.selectRow(row,false,'click');
	//	this.focus();
}
*/
/// Отрисовка таблицы в HTML<br>
/// Почти не измененный метод Intersystems'а. Изменения п6 помечены:<br>
/// <pre>
/// ;+++++ P6
/// ;изменения
/// ;----- P6
/// </pre>
///  Draw the table.
Method %DrawTable(pRS As %ResultSet) As %Status
{

	Set tSC = $$$OK
	#; we are forced to be IE-specific for fixed header
	Set tIE = $$$ZENISIE
	//if tIE set ..fixedHeaders=0 // В IE съезжают колонки (пока непонятно как пофиксить)

	#; build array containing column information
	#; first get columns from actual query or snapshot
	#; and place them, by name, into tColNames
	#; and by number, into tColNums
	#; we assume there are no duplicate column names

	#; get columns
	Set tColsFromQuery = (..dataSource="query")
	Set tColNums = 0
	If (..useSnapshot && (..snapshotId'="")) {
		#; use snapshot
		Set c = $O(^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"info",""))
		While (c '= "") {
			Set tName = $G(^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"info",c))
			Set tHeader = $G(^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"info",c,"th"),tName)
			Set tType = $G(^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"info",c,"type"),10)
			Set:$D(tColNames(tName)) tName = "(duplicate) " _ tName // duplicate column name
			Set tColNames(tName) = c
			If (tColsFromQuery) {
				#; add column
				Set tColNums = tColNums + 1
				Set tColNums(c) = tName
				Set:tHeader'=tName tColNums(c,"th") = tHeader
				Set tColTypeByNum(c) = tType
				Set tColNums(c,"type") = tType
			}
			Else {
				Set tColTypes(tName) = tType
				Set tColTypeByNum(c) = tType
				Set tColNums(c,"type") = tType
			}
			Set c = $O(^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"info",c))
		}
		
		#; if a sort is specified, build an index (unless it exists)
		If ((..currColumn '= "") && $D(tColNames(..currColumn)) && (..snapshotId'="")) {
			Set cn = tColNames(..currColumn)

			If ('$D(^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"index",..currColumn))) {
				Set tKey = $O(^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"data",""),1,tSnapData)
				While (tKey '= "") {
					#; collate
					set tCollated = 0
					Set tType = $G(tColTypeByNum(cn),10)
					If (..%IsTypeNumeric(tType)) {
						Set tValue = $LG(tSnapData,cn)
						Set tValue = $S(tValue="":1E-14,1:+tValue)
					}
					elseif tType = 2 {
							// DATE - we assume that if the date is numeric (val=+val) that the form is $h
						Set tRawValue = $LG(tSnapData,cn)
						try {
								// if numeric then just take it
							if tRawValue = +tRawValue { set tValue = tRawValue }
								// Try to convert it using the current locale setting
							else { set tValue = $zdth(tRawValue) }
						}
						catch tException {
								// <ILLEGAL VALUE> means this is some other format than the current locale
								// Odd but it could be ODBC format (type = 3)
							if tException.Name = "<ILLEGAL VALUE>" {
								try { set tValue = $zdth(tRawValue,3) }
									// Note that overridden LogicalToDisplay/LogicalToODBC methods can make this formatting fail
								catch tException2 { set tValue = tRawValue }
							}
						}
					}
					Else {
							// DLP: truncate the value to some arbitrary length to avoid a <SUBSCRIPT> error.
			//			Set tValue = " "_$ZCVT($Extract($LG(tSnapData,cn),1,250),"U")
						Set tValue = " "_$ZCVT($LG(tSnapData,cn),"U")
						set tCollated = 1
					}
					if tValue="" {
						set tValue=$$$nulindex
					}
					try {
						Set ^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"index",..currColumn,tValue,tKey)=""
					}
					catch tException {
							// If this is a subscript error on a collated value then the value is too long. Truncate it.
						if (tException.Name = "<SUBSCRIPT>") && (tCollated) {
							set tFiled = 0
								// First try simple truncation to the arbitrary first truncation limit = 250
							set tStart = $Select($Length(tValue)<512:$Length(tValue)-1,1:511)
							for tTruncation = tStart:-1:1 {
								try {
									set ^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"index",..currColumn,$Extract(tValue,1,tTruncation),tKey)=""
									set tFiled = 1
								}
								catch tInnerException {
									if tException.Name '= "<SUBSCRIPT>" {
											// Re-throw the original exception
										throw tException
									}
								}
								quit:tFiled
							}
							if 'tFiled { throw tException }
						}
						else {
							throw tException
						}
					}
					Set tKey = $O(^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"data",tKey),1,tSnapData)
				}
			}
		}
	}
	ElseIf $IsObject(pRS) {
		#; get columns from result set
		Set tRSCols = pRS.%ResultColumnCount
		if (pRS.%IsA("%Library.ResultSet")) {
			For c = 1:1:tRSCols {
				Set tName = pRS.GetColumnName(c)
				Set:$D(tColNames(tName)) tName = "(duplicate) " _ tName // duplicate column name
				Set tColNames(tName) = c
				If (tColsFromQuery) {
					Set tColNums = tColNums + 1
					#; add column
					Set tColNums(c) = tName
					Set tColNums(c,"th") = pRS.GetColumnHeader(c)
					#; type--> 3:float,5:integer,10:string,12:binstream,13:charstream
					Set:pRS.GetColumnType(c)'=10 tColTypeByNum(c) = pRS.GetColumnType(c)
					Set:pRS.GetColumnType(c)'=10 tColNums(c,"type") = pRS.GetColumnType(c)
				}
				Else {
					#; pick up column type
					Set:pRS.GetColumnType(c)'=10 tColTypes(tName) = c
				}
			}
		}
		else {
			For c = 1:1:tRSCols {
					#dim tColumn as %SQL.StatementColumn
				set tRSMD = pRS.%GetMetadata()
				set tColumn = tRSMD.columns.GetAt(c)
				Set tName = tColumn.colName
				Set:$D(tColNames(tName)) tName = "(duplicate) " _ tName // duplicate column name
				Set tColNames(tName) = c
				If (tColsFromQuery) {
					Set tColNums = tColNums + 1
					#; add column
					Set tColNums(c) = tName
					Set tColNums(c,"th") = tColumn.label
					#; type--> 3:float,5:integer,10:string,12:binstream,13:charstream
					Set:tColumn.clientType'=10 tColTypeByNum(c) = tColumn.clientType
					Set:tColumn.clientType'=10 tColNums(c,"type") = tColumn.clientType
				}
				Else {
					#; pick up column type
					Set:tColumn.clientType'=10 tColTypes(tName) = c
				}
			}
		}
	}

	#; styles for specialty columns
	Set tRowNumberStyle = ""
	Set tRowSelectorStyle = ""
	Set tRowCheckboxStyle = ""

	#; now walk over set of column spec objects 
	Set tCount = ..columns.Count()
	Set tHiddenCols = 0
	For n=1:1:tCount {
		Set tColumn = ..columns.GetAt(n)
		Set tHidden = +$$$ZENVAL(tColumn.hidden)
		Set:(tColumn.hidden'="")&&(tColumn.hidden'=tHidden) tColumn.hidden = tHidden // send resolved value to client
		Set tColName = $$$ZENVAL(tColumn.colName)
		Set tOrigName = tColName
		If ((..OnCreateResultSet="") && (..sql="") && (..queryClass="")) {
			#; for -> references we need to get the final piece of the name
			Set:tColName[">" tColName = $P(tColName,">",$L(tColName,">"))
			Set:tColName[" " tColName = $P(tColName," ",$L(tColName," "))
		}
		If (tColName = "$selector") {
			Set tRowSelectorStyle = tColumn.style
		}
		ElseIf (tColName = "$checkbox") {
			Set tRowCheckboxStyle = tColumn.style
		}
		ElseIf (tColName = "$rownumber") {
			Set tRowNumberStyle = tColumn.style
		}
		ElseIf (tColName '= "") {
			#; find corresponding column in query
			If ($D(tColNames(tColName))) {
				Set c = tColNames(tColName)
				If (tHidden) {
					#; remove/skip column, add to hidden list
					Set tHiddenCols = tHiddenCols + 1
					Set tHiddenCols(tHiddenCols) = tColName
					Kill:tColsFromQuery tColNums(c)
				}
				Else {
					If ('tColsFromQuery) {
						#; add column
						Set tColNums = tColNums + 1
						Set tColNums(tColNums) = tColName
						Set:$D(tColTypes(tColName)) tColTypeByNum(tColNums) = tColTypes(tColName)
						#; add spec to column
						Set tColNums(tColNums,"spec") = tColumn
						Set:tOrigName'=tColName tColNums(tColNums,"orig") = tOrigName
					}
					Else {
						#; add spec to column
						Set tColNums(c,"spec") = tColumn
						Set:tOrigName'=tColName tColNums(c,"orig") = tOrigName
					}
				}
			}
			ElseIf ('tColsFromQuery) {
				#; this is a named column with no data
				Set tColNums = tColNums + 1
				Set tColNums(tColNums) = tColName
				Set tColNums(tColNums,"spec") = tColumn
			}
		}
		Else {
			If ('tHidden) {
				#; this is an unnamed column
				Set tColNums = tColNums + 1
				Set tColNums(tColNums,"spec") = tColumn
			}
		}
	}

	#; now build the list of columns to display
	#; this is held in tColInfo
	#; tColInfo(n)=type  (action,data,dataAction,selector,rownum)
	#; tColInfo(n,"th")=header

	Set tHasFilters = 0
	Set tColCount = 0
	If (..showRowSelector && ..rowSelect) {
		Set tColCount = tColCount + 1
		Set tColInfo(tColCount) = "selector"
	}
	If (..multiSelect) {
		Set tColCount = tColCount + 1
		Set tColInfo(tColCount) = "checkbox"
	}
	If (..showRowNumbers) {
		Set tColCount = tColCount + 1
		Set tColInfo(tColCount) = "rownum"
	}

	#; if no column has width set, then use auto layout for table
	Set tAutoWidth = 1
	Set n = $O(tColNums(""))
	While (n '= "") {
		Set tColCount = tColCount + 1
		Set tColumn = $G(tColNums(n,"spec"))

		If ($G(tColNums(n)) '= "") {
			#; there is data for this column
			If $IsObject(tColumn) {
				If (tColumn.link="") {
					Set tColInfo(tColCount,"cls") = $S(..%IsTypeNumeric($G(tColTypeByNum(n))):"tpNum",1:"tpStr")
					Set tColInfo(tColCount) = "data"
					;p6++++++++
					Set tColInfo(tColCount,"dataType") = $get(tColNums(n,"type"))
					;p6--------
				}
				Else {
					Set tColInfo(tColCount,"cls") = "tpAction"
					Set tColInfo(tColCount) = "dataAction"
					Set tColInfo(tColCount,"link") = tColumn.link
					Set:tColumn.linkConfirm'="" tColInfo(tColCount,"confirm") = tColumn.linkConfirm
				}

				If (tColumn.onclick'="") {
					Set tColInfo(tColCount,"cls") = "tpAction"
					Set tColInfo(tColCount) = "dataAction"
				}

				Set tHeader = $$$ZENVAL(tColumn.header)
				Set tWidth = $$$ZENVAL(tColumn.width)
				Set tStyle = $$$ZENVAL(tColumn.style)
				Set:tWidth'="" tAutoWidth = 0

				Set th = $S(tHeader'="":tHeader,1:$G(tColNums(n,"th"),tColNums(n)))
				Set:tStyle'="" tColInfo(tColCount,"style") = tStyle
				Set:tWidth'="" tColInfo(tColCount,"wid") = tWidth

				Set:tColumn.title'="" tColInfo(tColCount,"title") = tColumn.title
				Set:tColumn.cellTitle'="" tColInfo(tColCount,"cellTitle") = tColumn.cellTitle
				Set:tColumn.OnDrawCell'="" tColInfo(tColCount,"method") = tColumn.OnDrawCell
				Set:tColumn.seed'="" tColInfo(tColCount,"seed") = tColumn.seed
				Set:tColumn.onclick'="" tColInfo(tColCount,"onclick") = tColumn.onclick

				#; test for filter
				If (tColumn.filterType '= "") {
					Set tHasFilters = 1
					Set tColInfo(tColCount,"filter") = tColumn
				}
			}
			Else {
				#; use different style for numeric columns
				Set tColInfo(tColCount,"cls") = $S(..%IsTypeNumeric($G(tColTypeByNum(n))):"tpNum",1:"tpStr")
				Set tColInfo(tColCount) = "data"
				Set th = tColNums(n)
			}
			Set tColInfo(tColCount,"th") = th
			Set tColInfo(tColCount,"src") = tColNums(n)
			Set:$D(tColNums(n,"orig")) tColInfo(tColCount,"orig") = tColNums(n,"orig")
		}
		Else {
			#; no data for this column; must be an action
			Set tColInfo(tColCount) = "action"
			Set tColInfo(tColCount,"cls") = "tpAction"
			If $IsObject(tColumn) {
				Set tHeader = $$$ZENVAL(tColumn.header)
				Set tWidth = $$$ZENVAL(tColumn.width)
				Set tStyle = $$$ZENVAL(tColumn.style)

				Set:tHeader'="" tColInfo(tColCount,"th") = tHeader
				Set:tWidth'="" tColInfo(tColCount,"wid") = tWidth
				Set:tStyle'="" tColInfo(tColCount,"style") = tStyle

				Set:tColumn.linkCaption'="" tColInfo(tColCount,"caption") = tColumn.linkCaption
				Set:tColumn.title'="" tColInfo(tColCount,"title") = tColumn.title
				Set:tColumn.link'="" tColInfo(tColCount,"link") = tColumn.link
				Set:tColumn.cellTitle'="" tColInfo(tColCount,"cellTitle") = tColumn.cellTitle
				Set:tColumn.linkConfirm'="" tColInfo(tColCount,"confirm") = tColumn.linkConfirm
				Set:tColumn.OnDrawCell'="" tColInfo(tColCount,"method") = tColumn.OnDrawCell
				Set:tColumn.seed'="" tColInfo(tColCount,"seed") = tColumn.seed
				Set:tColumn.onclick'="" tColInfo(tColCount,"onclick") = tColumn.onclick
			}
		}

		#; further preprocess some of the data
		If $D(tColInfo(tColCount,"link")) {
			#; see if link contains an expression
			If (tColInfo(tColCount,"link")["#(") {
				#; what type of escape to use?
				Set tEsc = $S(tColInfo(tColCount,"link")["javascript:":"JS",1:"URL")
				Set tColInfo(tColCount,"Xlink") = "S %out="_##class(%ZEN.Utils).%ParseExpr(tColInfo(tColCount,"link"),tEsc,2)
				#; if we have a title we need to propagate it further down
				If $D(tColInfo(tColCount,"title")) {
					Set tColInfo(tColCount,"Xlink","title") = tColInfo(tColCount,"title")
				}
				Kill tColInfo(tColCount,"link")
			}
			Else {
				Set tColInfo(tColCount,"link") = " href="""_$ZCVT(tColInfo(tColCount,"link"),"O","HTML")_""""
				If $D(tColInfo(tColCount,"title")) {
					Set tColInfo(tColCount,"link") = tColInfo(tColCount,"link")_" title="""_$ZCVT(tColInfo(tColCount,"title"),"O","HTML")_""""
				}
			}
		}

		If $D(tColInfo(tColCount,"onclick")) {
			If (tColInfo(tColCount,"onclick")["#(") {
				Set tColInfo(tColCount,"Xonclick") = "S %out="_##class(%ZEN.Utils).%ParseExpr(tColInfo(tColCount,"onclick"),"JS",2)
				Kill tColInfo(tColCount,"onclick")
			}
			Else {
				Set tColInfo(tColCount,"onclick") = " onclick="""_$ZCVT(tColInfo(tColCount,"onclick"),"O","HTML")_""""
			}
		}
		
		If $D(tColInfo(tColCount,"cellTitle")) {
			Set tColInfo(tColCount,"cellTitle") = " title="""_$ZCVT(tColInfo(tColCount,"cellTitle"),"O","HTML")_""""
		}

		Set n = $O(tColNums(n))
	}
 	#; build list of conditions for the table
	#; organized by column name
	For i=1:1:..conditions.Count() {
		Set tCondition = ..conditions.GetAt(i)
		If $IsObject(tCondition) {			
			Set tColName = $$$ZENVAL(tCondition.colName)
			If (tColName '="") {
				Set tCellStyle = $$$ZENVAL(tCondition.cellStyle)
				Set tRowStyle = $$$ZENVAL(tCondition.rowStyle)
				If (tCellStyle '= "") {
					#; cell condition
					Set tTargetCol = $$$ZENVAL(tCondition.targetCol)
					Set tTarg = $S(tTargetCol'="":tTargetCol,1:tColName)
					Set idx = 1 + $G(tCellCondition(tTarg))
					Set tCellCondition(tTarg) = idx
					Set tCellCondition(tTarg,idx) = tCondition
				}
				If (tRowStyle '= "") {
					#; row condition
					Set idx = 1 + $G(tRowCondition)
					Set tRowCondition = idx
					Set tRowCondition(idx) = tCondition
				}
			}
		}
	}

	#; now draw the table
	If (..fixedHeaders) {
		#; for ie, we use 2 tables for fixed header
		&html<<div style="width:100%">>
	}
	
	Set ts = $S(tAutoWidth:" style=""table-layout:fixed;height:15px""",1:"")
	&html<<table class="tpTable" border="1" cellspacing="#(..cellSpacing)#" cellpadding="0"#(ts)#>>
	If (..caption'="") { &html<<caption>#($ZCVT(..caption,"O","HTML"))#</caption>> }
	&html<<thead id="#(..%MakeId("tpHead"))#" class="tpHead">>

	#; width of special columns (rownum, etc.)
	Set xWid = ..extraColumnWidth

	#; draw headers based on layout
	If (..headerLayout = "headersOnTop") {
		Do DrawHeaders
		Do DrawFilters
	}
	Else {
		Do DrawFilters
		Do DrawHeaders
	}

	Goto DrawBody	

DrawFilters
	#; draw filters
	If (tHasFilters) {
		&html<<tr valign="bottom" id="#(..%MakeId("filterRow"))#" #($S(..showFilters:"",1:"style=""display: none;"""))#>>
		For n=1:1:tColCount {
			Set tFilter = $G(tColInfo(n,"filter"))
			Set src = $G(tColInfo(n,"orig"),$G(tColInfo(n,"src")))

			If ($IsObject(tFilter) && (src'="")) {
				#; see if the filter value comes from an expression
				Set evaluatedFilter=$S(tFilter.filterValue["#(":$$$ZENVAL(tFilter.filterValue),1:tFilter.filterValue)

				Set thw = $S($G(tColInfo(n,"wid"))="":"",1:" width="""_$G(tColInfo(n,"wid"))_"""")
				&html<<th valign="bottom" nowrap="1"#(thw)#>>
				If (tFilter.filterType = "custom") {
					#; invoke callback to draw filter
					Do ..%DrawFilter(tFilter.OnDrawFilter,src,tFilter)
				}
				Else { // built-in
					Set dis = $S(..filtersDisabled:"disabled",1:"")
					&html<<table class="tpFilterLayout" border="0" cellspacing="#(..cellSpacing)#" width="95%"><tr>>
					If ((tFilter.filterType = "date")||(tFilter.filterType = "datetime")) {
						If (tFilter.filterOp '= "BETWEEN") {
							#; single date box
							If (tFilter.filterLabel'="") {
								&html<<td class="tpFilterLabel" width="5%">#($ZCVT(tFilter.filterLabel,"O","HTML"))#</td>>
							}
							&html<<td nowrap="1"><input #(dis)# type="text" size="12" id="#(..%MakeId("filter1_"_src))#" #(..%Attr("title",tFilter.filterTitle))# class="tpFilterDate" value="#($ZCVT(evaluatedFilter,"O","HTML"))#" onkeypress="zenPage.getComponent(#(..index)#).filterKeyPressed(event,'#(src)#','date',1);" onchange="zenPage.getComponent(#(..index)#).filterChanged('#(src)#',true,'date',1);"><input type="button" onclick="zenPage.getComponent(#(..index)#).showDateSelector('#(src)#',1,'#(tFilter.filterType)#');" class="tpFilterButton" value="..."/></td>>
						}
						Else {
							#; show 2 boxes to allow range entry
							Set t1 = $P(evaluatedFilter,",",1)
							Set t2 = $P(evaluatedFilter,",",2)
							Set c1 = $ZCVT($P(evaluatedFilter,",",1),"O","HTML")
							Set c2 = $ZCVT($P(evaluatedFilter,",",2),"O","HTML")
							If (c1'="") {
								&html<<td class="tpFilterLabel" width="5%">#(c1)#</td>>
							}
							&html<<td nowrap="1"><input #(dis)# type="text" size="12" id="#(..%MakeId("filter1_"_src))#" #(..%Attr("title",tFilter.filterTitle))# class="tpFilterDate" value="#($ZCVT(t1,"O","HTML"))#" onkeypress="zenPage.getComponent(#(..index)#).filterKeyPressed(event,'#(src)#','date',1);" onchange="zenPage.getComponent(#(..index)#).filterChanged('#(src)#',true,'date',1);"><input type="button" onclick="zenPage.getComponent(#(..index)#).showDateSelector('#(src)#',1,'#(tFilter.filterType)#');" class="tpFilterButton" value="..."/></td>>
							&html<</tr><tr>>
							If (c2'="") {
								&html<<td class="tpFilterLabel" width="5%">#(c2)#</td>>
							}
							&html<<td nowrap="1"><input #(dis)# type="text" size="12" id="#(..%MakeId("filter2_"_src))#" #(..%Attr("title",tFilter.filterTitle))# class="tpFilterDate" value="#($ZCVT(t2,"O","HTML"))#" onkeypress="zenPage.getComponent(#(..index)#).filterKeyPressed(event,'#(src)#','date',2);" onchange="zenPage.getComponent(#(..index)#).filterChanged('#(src)#',true,'date',2);"><input type="button" onclick="zenPage.getComponent(#(..index)#).showDateSelector('#(src)#',2,'#(tFilter.filterType)#');" class="tpFilterButton" value="..."/></td>>
						}
					}
					ElseIf (tFilter.filterType = "enum") {
						If (tFilter.filterLabel'="") {
							&html<<td class="tpFilterLabel" width="5%">#($ZCVT(tFilter.filterLabel,"O","HTML"))#</td>>
						}
						&html<<td nowrap="1"><select #(dis)# id="#(..%MakeId("filter1_"_src))#" #(..%Attr("title",tFilter.filterTitle))# class="tpFilter" onchange="zenPage.getComponent(#(..index)#).filterChanged('#(src)#',true);">>
						&html<<option value=""></option>>
						For p=1:1:$L(tFilter.filterEnum,",") {
							Set ev = $P(tFilter.filterEnum,",",p)
							Set ed = $S(tFilter.filterEnumDisplay="":ev,1:$P(tFilter.filterEnumDisplay,",",p))
							&html<<option #($S(evaluatedFilter=ev:"selected",1:""))# value="#($ZCVT(ev,"O","HTML"))#">#($ZCVT(ed,"O","HTML"))#</option>>
						}
						&html<</select></td>>
					}
					ElseIf (tFilter.filterType = "query") {
						If (tFilter.filterLabel'="") {
							&html<<td class="tpFilterLabel" width="5%">#($ZCVT(tFilter.filterLabel,"O","HTML"))#</td>>
						}
						#; execute the filter query
						#; (do this as part of snapshot)
						Set tError = ""
						Set tFqValCol = 1
						Set tFqDispCol = 1
						If (tFilter.filterQuery = "") {
							Set tError = "No query specified for filter"
						}
						Else {
							Set tSC = $$$OK
							Do {
								Set tRS = ##class(%ResultSet).%New()
								Set tSC = tRS.Prepare(tFilter.filterQuery)
								If $$$ISERR(tSC) Quit

								Set tSC = tRS.%Execute()
								If $$$ISERR(tSC) Quit

								If tRS.%ResultColumnCount > 1 {
									Set tFqDispCol = 2
								}
								
							} While(0)
							
							If $$$ISERR(tSC) {
								Do $System.Status.DecomposeStatus(tSC,.err)
								Set tError = $G(err(1))
							}
						}
						
						If (tError = "") {
							&html<<td nowrap="1"><select #(dis)# id="#(..%MakeId("filter1_"_src))#" #(..%Attr("title",tFilter.filterTitle))# class="tpFilter" onchange="zenPage.getComponent(#(..index)#).filterChanged('#(src)#',true);">>
							&html<<option value=""></option>>
							While (tRS.%Next(.tSC)) {
								If $$$ISERR(tSC) {
									Do $System.Status.DecomposeStatus(tSC,.err)
									Set tError = $G(err(1))
									Quit
								}
								Set ev = tRS.%GetData(tFqValCol)
								&html<<option #($S(evaluatedFilter=ev:"selected",1:""))# value="#($ZCVT(ev,"O","HTML"))#">#($ZCVT(tRS.%GetData(tFqDispCol),"O","HTML"))#</option>>
							}
							&html<</select></td>>
						}
						Set tRS = ""

						If (tError '= "") {
							&html<<td style="color:red;">#(tError)#</td>>
						}
					}
					Else {
						If (tFilter.filterLabel'="") {
							&html<<td class="tpFilterLabel" width="5%">#($ZCVT(tFilter.filterLabel,"O","HTML"))#</td>>
						}					
						&html<<td nowrap="1"><input placeholder='Поиск...' #(dis)# type="text" id="#(..%MakeId("filter1_"_src))#" #(..%Attr("title",tFilter.filterTitle))# class="tpFilter" value="#($ZCVT(evaluatedFilter,"O","HTML"))#" onkeypress="zenPage.getComponent(#(..index)#).filterKeyPressed(event,'#(src)#');" onchange="zenPage.getComponent(#(..index)#).filterChanged('#(src)#',true);"></td>>
					}
					&html<</tr></table>>
				}
				&html<</th>>
			}
			Else {
				Set wid = $Case(tColInfo(n),"checkbox":xWid,"rownum":xWid,"selector":xWid,:$G(tColInfo(n,"wid")))
				Set thw = $S(wid="":"",1:" width="""_wid_"""")
				&html<<th#(thw)#>&nbsp;</th>>
			}
		}
		#; add extra column for scrollbar
		If (..fixedHeaders) { &html<<th width="#($S(tIE:"10px",1:"7px"))#">&nbsp;</th>> }
	}
	Quit
DrawHeaders
	#; draw headers
	Set tUserColCount = 0

	&html<<tr>>
	For n=1:1:tColCount {
		Set type = tColInfo(n)
		Set thw = $S(xWid="":"",1:" width="""_xWid_"""")
		If (type = "selector") {
			&html<<th#(thw)# onclick="zenPage.getComponent(#(..index)#).headerClick('');">&nbsp;&nbsp;&nbsp;</th>>
		}
		ElseIf (type = "action") {
			Set title = $S($G(tColInfo(n,"title"))="":"",1:" title="""_$ZCVT(tColInfo(n,"title"),"O","HTML")_"""")
			Set thw = $S($G(tColInfo(n,"wid"))="":"",1:" width="""_$G(tColInfo(n,"wid"))_"""")
			&html<<th#(title)##(thw)# onclick="zenPage.getComponent(#(..index)#).headerClick('');">&nbsp;#($ZCVT($G(tColInfo(n,"th")),"O","HTML"))#&nbsp;</th>>
			Set tUserColCount = tUserColCount + 1
		}
		ElseIf (type = "checkbox") {
			&html<<th#(thw)#><input type="checkbox" id="chkAll" onclick="zenPage.getComponent(#(..index)#).cbHeaderClick(this);"/></th>>
		}
		ElseIf (type = "rownum") {
			&html<<th#(thw)# onclick="zenPage.getComponent(#(..index)#).headerClick('');">&nbsp;#</th>>
		}
		Else {
			Set tUserColCount = tUserColCount + 1
			Set tName = $G(tColInfo(n,"src"))
			Set cls = $S(..currColumn=tName:"class=""tpHdrSelected""",1:"")
			Set srt = $S(..currColumn=tName:$S(..sortOrder="asc":"&raquo;",..sortOrder="desc":"&laquo;",1:""),1:"")
			Set title = $S($G(tColInfo(n,"title"))="":"",1:" title="""_$ZCVT(tColInfo(n,"title"),"O","HTML")_"""")
			Set thw = $S($G(tColInfo(n,"wid"))="":"",1:" width="""_$G(tColInfo(n,"wid"))_"""")
			&html<<th#(title)# #(cls)##(thw)# id="#(..%MakeId("th_"_tName))#" onclick="zenPage.getComponent(#(..index)#).headerClick('#($ZCVT(tName,"O","JS"))#');">#($ZCVT($G(tColInfo(n,"th")),"O","HTML"))#&nbsp;#(srt)#</th>>
		}
	}
	#; add extra column for scrollbar
	If (..fixedHeaders) { &html<<th width="#($S(tIE:"10px",1:"7px"))#">&nbsp;</th>> }
	&html<</tr></thead>>
	Quit

DrawBody
    
	Set tBodyHeight = ..bodyHeight
	Set tBodyHeight = $S(tBodyHeight="":"20.0em",1:tBodyHeight)

	If (..fixedHeaders) {
		#; for ie, we use 2 tables for fixed header
		&html<</table></div><div id="#(..%MakeId("tpBody"))#" class="tpBodyFixed" style="height: #(tBodyHeight)#; width:100%"><table class="tpTable" border="0" cellspacing="#(..cellSpacing)#" cellpadding="0"><tbody>>
	}
	Else {
		
		&html<<tbody class="tpBody" id="#(..%MakeId("tpBody"))#" style="height: #(..bodyHeight)#;">>

	}

	#; draw rows
	New %query,%out
	Set tRow = 0 // row within page
	Set tStartRow = (..currPage-1) * ..pageSize // starting query row for this page
	Set tKey = ""
	Set tVal = ""
	Set tMaxRows = $S(..pageSize=0:..maxRows,1:..pageSize)
	Set tSortOrder = $Case(..sortOrder,"asc":1,"desc":-1,:0)
	If (..useSnapshot && tSortOrder && (..currColumn'="") && (..snapshotId'="")) {
		#; find initial sort value
		Set tVal = $O(^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"index",..currColumn,""),tSortOrder)
	}
	
	#; get logical value of table
	Set tLogicalVal = $$$ZENVAL(..value)

	Set tMore = 1
	While ((tMaxRows=0)||(tRow<tMaxRows)) {
		#; get next row
		If (..useSnapshot && (..snapshotId'="")) {
			If (tSortOrder && (..currColumn'="") ) {
				#; use sort index
				Set tBeforeStart = (tRow=0)&&(tStartRow>0)
				Set tqRow = 0 // row in query
				If (tVal'="") {
					Do {
						Set tKey = $O(^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"index",..currColumn,tVal,tKey),tSortOrder)
						If (tKey = "") {
							#; try next value
							Set tVal = $O(^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"index",..currColumn,tVal),tSortOrder)
							Set:tVal'="" tKey = $O(^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"index",..currColumn,tVal,""),tSortOrder)
						}
						Set tqRow = tqRow + 1 
					} While (tBeforeStart && (tqRow <= tStartRow)) // loop until we get to first displayed row
				}

				Quit:tKey=""
				Set tSnapData = $G(^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"data",tKey))
			}
			Else {
				#; use main temp file
				Set:(tRow=0)&&(tStartRow>0) tKey=(tStartRow)
				Set tKey = $O(^CacheTemp.zenData(%session.SessionId,..snapshotId,..index,"data",tKey),1,tSnapData)
				Quit:tKey=""
			}
		}
		ElseIf $IsObject(pRS) {
			If 'pRS.%Next(.tSC) {
				Set tMore = 0
				Quit
			}
			Quit:$$$ISERR(tSC)
		}
		Else {
			Quit
		}
		Set tRow = tRow + 1

		#; copy data for this row into %query
		Kill %query
		For n=1:1:tColCount {
			#; get col value
			Set tName = $G(tColInfo(n,"src"))
			If (tName'="") {
				If (..useSnapshot) {
					Set c = tColNames(tName)
					Set %query(tName) = $LG(tSnapData,c)
				}
				Else {
					Set %query(tName) = pRS.%Get(tName)
					Set:(%query(tName)=$c(0)) %query(tName) = ""
				}
			}
		}

		#; get data values for hidden columns
		For n=1:1:tHiddenCols {
			#; get col value
			Set tName = $G(tHiddenCols(n))
			If (tName'="") { 
				If (..useSnapshot) {
					Set c = tColNames(tName)
					Set %query(tName) = $LG(tSnapData,c)
				}
				Else {
					Set %query(tName) = pRS.%Get(tName)
					Set:(%query(tName)=$c(0)) %query(tName) = ""
				}
			}
		}

		Set tStatus = ""

		If (..showZebra) {
			Set tStatus = $S(tRow#2=0:"tpEven",1:"tpOdd")
		}
		Else {
			Set tStatus = "tpRow"
		}

		If (tStatus '= "") {
			Set tRowCls = "class="""_tStatus_""""
		}
		Else {
			Set tRowCls = ""
		}

		Set tRowStyle = ""

		#; see if there are any row conditions
		Set tName = $O(tRowCondition(""))
		While (tName '= "") {
			#; evaluate condition
			Set tCondition = tRowCondition(tName)
			Set tEval = tCondition.Eval(.%query)
			If (tEval) {
				Set tRowStyle = "style=""" _ $$$ZENVAL(tCondition.rowStyle) _ """"
				Quit
			}
			Set tName = $O(tRowCondition(tName))
		}

		#; if there is a valueColumn, get it
		Set tDataVal = ""
		If (..valueColumn'="") {
			Set v = $G(%query(..valueColumn))
			If (v = tLogicalVal) {
				#; this row matches the current value of the table
				#; select it
				Set ..selectedIndex = tRow - 1
			}
			Set tDataVal = "zenValue="""_$ZCVT(v,"O","HTML")_""""
		}
		
		// check onmouseover/onmouseout behaviour
		If (..onmouseoverClass '= "") {
			Set tMouseover = "onmouseover=""zenPage.getComponent('"_..index_"').onmouseHandler('"_(tRow-1)_"',true);"" onmouseout=""zenPage.getComponent('"_..index_"').onmouseHandler('"_(tRow-1)_"',false);"""
		}
		Else {
			Set tMouseover = ""
		}
		&html<<tr #(tDataVal)# #(tRowCls)# #(tRowStyle)# id="#(..%MakeId("tr_"_(tRow-1)))#" onclick="zenPage.getComponent(#(..index)#).clickHandler(#(tRow-1)#);" ondblclick="zenPage.getComponent(#(..index)#).dblclickHandler();" #(tMouseover)#>>
		Set tdwid = $S(tRow=1:" width="""_..extraColumnWidth_"""",1:"")
	
		#; loop over columns
		For n=1:1:tColCount {
			Set type = tColInfo(n)
			If (type = "selector") {
				&html<<td class="tpSel" style="#(tRowSelectorStyle)#" id="#(..%MakeId("selector_"_(tRow-1)))#"#(tdwid)#>&nbsp;</td>>
			}
			ElseIf (type = "checkbox") {
				Set sel = $S($P(..selectedRows,",",tRow+tStartRow)'="":"checked=""1""",1:"")
				&html<<td class="tpCB"#(tdwid)# style="#(tRowCheckboxStyle)#">>
				#; Check if user has condition for checkbox:
				Set tCheckCondition = +$G(tCellCondition("checkbox"))
				If tCheckCondition '= 0 {
					#; If condition is set, check it now
					Set tCondition = $G(tCellCondition("checkbox",tCheckCondition))
					#; If condition met, then checkbox will not be built
					Set tCheckCondition = tCondition.Eval(.%query)		
				}
				#; Build checkbox if no condition for checkbox, or if condition failed:
				If 'tCheckCondition {
					&html<<input type="checkbox" #(sel)# id="#(..%MakeId("cb_"_(tRow-1)))#" onclick="zenPage.getComponent(#(..index)#).cbClick(this,#(tRow-1)#);"/>>
				}
				&html<</td>>
			}
			ElseIf (type = "rownum") {
				&html<<td class="tpRNum" style="#(tRowNumberStyle)#" align="right"#(tdwid)#>#(tRow+tStartRow)#</td>>
			}
			Else {
				Set tADisabled = ""
				Set tHREF = ""
				Set tCellClass = $G(tColInfo(n,"cls"))
				Set tCellStyle = $G(tColInfo(n,"style"))

				#; see if there are cell conditions for this column
				#;YSD2262 - allow to disable/hide action link
				#;YSD2262 If ((type = "data")||(type = "dataAction")) {
				If ((type = "data")||(type = "dataAction")||(type="action")) {
					Set sub = $S(type'="action":"src",1:"caption")
					If $G(tColInfo(n,sub)) '= "" {
					Set idx = $O(tCellCondition(tColInfo(n,sub),""))
					While (idx '= "") {
						#; evaluate condition
						Set tCondition = tCellCondition(tColInfo(n,sub), idx)
						Set tEval = tCondition.Eval(.%query)
						If (tEval) {
							Set tCellStyle = tCellStyle _ $$$ZENVAL(tCondition.cellStyle)
							If (tCondition.cellStyle [ "disabled") {
								Set tADisabled = "disabled"
							}
							Quit
						}
						Set idx = $O(tCellCondition(tColInfo(n,sub),idx))
					}
					}
				}
				If (..nowrap) {
					Set tCellStyle = tCellStyle _ "white-space:nowrap;"
				}
				
				#; IE does not recognize white-space: nowrap;
				#; so we have special code for it
				If (..nowrap) {
					Set tCellStyle = tCellStyle _ " nowrap"
				}
				Set:tCellStyle'="" tCellStyle=" style="""_tCellStyle_""" "
				
				If ((type = "data")||(type = "dataAction")) {
					Set ttl = $S(..showValueInTooltip:" title="""_$ZCVT(%query(tColInfo(n,"src")),"O","HTML")_"""",1:$G(tColInfo(n,"cellTitle")))
				}
				Else {
					Set ttl = $G(tColInfo(n,"cellTitle"))
				}
				#; don't use &html in inner loop to make sure HTML is tight and CR/LF free
				#; add width information for first row (if not "")
				Write "<td",$S(tCellClass="":"",1:" class="""_tCellClass_""""),tCellStyle,ttl,$S((tRow=1)&&($G(tColInfo(n,"wid"))'=""):" width="""_$G(tColInfo(n,"wid"))_"""",1:""),">"
				If (..nowrap) {
					Write "<span style='white-space:nowrap;overflow:hidden;'>"
				}
				If ($G(tColInfo(n,"method"))'="") {
					Do ..%DrawCell($G(tColInfo(n,"method")),$G(tColInfo(n,"src")),$G(tColInfo(n,"seed")))
				}
				Else {
					If ((type = "action")||(type = "dataAction")) {					
						#; get link: see if we have to evaluate expr
						Set tCLICK = ""
						If ($D(tColInfo(n,"Xlink"))) {
								#; result is in %out
							X tColInfo(n,"Xlink")

							// JMD1254: apply additional encoding:
							If (+$G(tColInfo(n,"js"))) {
								// first split off "javascript:"
								Set %out = $P(%out,"javascript:",2,9999)
								Set %out = $ZCVT(%out,"O","UTF8")
								Set %out = $ZCVT(%out,"O","URL")
								Set %out = $ZCVT(%out,"O","HTML")
								Set tHREF = " href=""javascript:"_%out_""""
							}
							Else {
								Set tHREF = " href="""_$ZCVT(%page.%Link(%out),"O","HTML")_""""
							}
							#; check if we need a title for the link
							If ($D(tColInfo(n,"Xlink","title"))) {
								Set tHREF = tHREF_" title="""_$ZCVT(tColInfo(n,"Xlink","title"),"O","HTML")_""""
							}
						}
						Else {
							Set tHREF = %page.%Link($G(tColInfo(n,"link")))
						}
	
						#; get onclick: see if we have to evaluate expr
						If ($D(tColInfo(n,"Xonclick"))) {
							#; result is in %out
							X tColInfo(n,"Xonclick")
							Set tCLICK = " onclick="""_$ZCVT(%out,"O","HTML")_""""
						}
						Else {
							Set tCLICK = %page.%Link($G(tColInfo(n,"onclick")))
						}

						#; test for confirm message
						If ($D(tColInfo(n,"confirm")) && (tCLICK="")) {
							Set tConfirmText = tColInfo(n,"confirm")
							If tConfirmText["%1",$G(%out)'="" {
								Set tConfirmName = $P($P(%out,"'",2),"'",1)
								Set tConfirmText = $$$FormatText(tConfirmText,tConfirmName)
							}
							//Set tCLICK = "onclick=""return confirm('" _ $ZCVT($ZCVT(tConfirmText,"O","HTML"),"O","JS") _ "');"""
							If ($D(tColInfo(n,"Xlink"))) {
								#; result is in %out
								X tColInfo(n,"Xlink")
								Set cLink = %page.%Link(%out)
							}
							Else {
								Set cLink = %page.%Link($G(tColInfo(n,"link")))
							}
							Set tTitle=$S($G(tColInfo(n,"Xlink","title"))'="": tColInfo(n,"Xlink","title"),$G(tColInfo(n,"title"))'="":$G(tColInfo(n,"title")),$G(tColInfo(n,"caption"))'="":$G(tColInfo(n,"caption")),1:"")
							Set tWidth = $L(tConfirmText)*10
							Set tWidth = $S(tWidth<320:320,tWidth>800:800,1:tWidth)
							Set tHeight = 200+(($L(tConfirmText)\80)*19)
							Set tHREF = " href=""#"""
							If (tTitle '= "") {
								Set tHREF = tHREF _ " title=""" _ $zconvert(tTitle,"O","HTML") _ """"
							}
							If cLink [ "&#" Set cLink = $zconvert(cLink,"I","HTML")
							#; strip trailing ' title="..."'
							Set tConfirmTitlePos = $find(cLink,tConfirmStrings("titleTrail"))
							If tConfirmTitlePos {
								Set cLink = $extract(cLink,1,tConfirmTitlePos-1-tConfirmStrings("titleTrailLen"))
							}
							#; strip leading ' href="' prefix and trailing '"'
							If $extract(cLink,1,tConfirmStrings("hrefLen")) = tConfirmStrings("href") {
								Set cLink = $extract(cLink,tConfirmStrings("hrefLen")+1,*)
								If ($extract(cLink,*) = """") {
									Set cLink = $extract(cLink,1,*-1)
								}
							}
							#; strip leading "javascript:"
							If $extract(cLink,1,tConfirmStrings("jsLen")) = tConfirmStrings("js") {
								Set cLink = $extract(cLink,tConfirmStrings("jsLen")+1,*)
							}
							#; Convert "[URL]" to document.location = '[URL]'
							ElseIf cLink '= "" {
								Set cLink = "document.location = '" _ $zconvert(cLink,"O","JS")_"';"
							}
							Set tConfirmParms = "{Msg1:'"_$zconvert($zconvert(tConfirmText,"O","JS"),"O","HTML")_"',Title:'"_$zconvert($zconvert(tTitle,"O","JS"),"O","HTML")_"',Link:'"_$zconvert($zconvert(cLink,"O","JS"),"O","HTML")_"'}"
							Set tCLICK = " onclick=""zen('"_$this.id_"').launchConfirmDialog('%ZEN.Dialog.confirmationDialog.cls','confirmationDialog','resizable,width="_tWidth_",height="_tHeight_"',"_tConfirmParms_"); return false;"""
						}
						#;YSD2262 Write "<a",tHREF,$G(tColInfo(n,"cellTitle")),tADisabled,tCLICK,">"
						If tADisabled = "" {
							Write "<a",tCellStyle,tHREF,$G(tColInfo(n,"cellTitle")),tCLICK,">"
						} Else {
							If type = "dataAction" Write $G(tColInfo(n,"cellTitle"))
						}
					}

					If ((type = "data")||(type = "dataAction")) {
						#; data value
						Set tDataVal = %query(tColInfo(n,"src"))
						;+++++ P6
						if $G(tColInfo(n,"dataType"),"")'="" {
							if (tColInfo(n,"dataType")=16) { //Boolean
                                Write $S(tDataVal="":"&nbsp;",tDataVal="0":"&nbsp;",1:"Да")
                            }elseif  (tColInfo(n,"dataType")=15)||(tColInfo(n,"dataType")=3) { // DOUBLE || CURRENCY
                                Write $S(+tDataVal=0:"&nbsp;",1:##class(p6.UrlUtils).ConvertCurrency2(tDataVal,","," "))
                            }else {
                                Write $S(tDataVal="":"&nbsp;",1:$ZCVT(tDataVal,"O","HTML"))
                            }
						//if tColInfo(n,"cls")="tpNum" set tDataVal=##class(p6.UrlUtils).ConvertCurrency2(tDataVal,","," ")
						;----- P6
						} else {
							Write $S((tDataVal="")||(tDataVal=$C(0)):"&nbsp;",1:$ZCVT(tDataVal,"O","HTML"))
						}
					}
					Else {
						#; check if we have an image:
						if ($D(tColInfo(n,"XlinkImage"))){
							#; result is in %out
							X tColInfo(n,"XlinkImage")
							Write "<img src="""_$ZCVT(%page.%Link(%out),"O","HTML")_"""/>"
						} elseif ($D(tColInfo(n,"linkImage"))) {
							Set tCaption = $G(tColInfo(n,"caption"),$S($G(tHREF)="":"",1:"link"))
							Write "<img src="""_$ZCVT(tColInfo(n,"linkImage"),"O","HTML")_""""_$S(tCaption'="":" alt="""_tCaption_"""",1:"")_"/>"
						} else {
						#; action caption (if we have a link and no caption, show "link")
						Set tCaption = $G(tColInfo(n,"caption"),$S($G(tHREF)="":"",1:"link"))
						#;YSD2262 Write $S(tCaption="":"&nbsp;",1:$ZCVT(tCaption,"O","HTML"))
						 Write $S(tCaption="":"&nbsp;",tADisabled=""!(type="dataAction"):$ZCVT(tCaption,"O","HTML"),1:"-")
					}
					}
					If ((type = "action")||(type = "dataAction")) {
						#;YSD2262 Write "</a>"
						If tADisabled = "" Write "</a>"
					}
				}
				If (..nowrap) { Write "</span>" }
				&html<</td>>
			}
		}
		&html<</tr>>
	}

	If ((tRow = 0)&&(..initialExecute)) {
		#; draw indicator of no results (unless deferred executed)
		Set msgNoResults = ..msgNoResult
		If ($Data(tColInfo)) {
			Set type = tColInfo(1)
			If ((type '= "data")&&(type '= "dataAction")) {
				&html<<td colspan="#(tColCount-tUserColCount)#" width="1%">&nbsp;</td>>
			}
		}
		&html<<td colspan="#(tUserColCount)#" width="99%" class="tpNoResults">&nbsp;#(msgNoResults)#</td>>
	} else {
		$$$QuitOnError(..DrawBottomRow())	
	}

	#; if not in snapshot mode, update rowCount
	If ('..useSnapshot) {
		Set ..rowCount = tRow _ $S(tMore:"+",1:"")
	}

	&html<<tr><td style="border:none;height:99%" colspan="#(tColCount)#" class="tpPadRow"></td></tr></tbody></table>>
	If (tIE && ..fixedHeaders) { &html<</div>> }

	Kill %query
	Quit tSC
}

/*
ClientMethod packRows() [ Language = javascript ]
{
	if (this.hidden) return;
	//if (zenIsIE) {	
	//	this.packRowsIE();
		
	//} else {
		if (!this.bodyHeight) return; // If it wasn't set, this isn't an issue
		if (this.fixedHeaders == false) return;
		if (!navigator) return; // Should never be true in a runtime situation
		var isWebkit=(navigator.userAgent.indexOf("WebKit")>=0);
		var isFF3=(navigator.userAgent.indexOf("Firefox")>=0);
	//if (!(isFF3 || isWebkit)) return; // Either early Firefox or unsupported platform
		var eDiv=this.getEnclosingDiv();
		if (eDiv.offsetWidth==0 || eDiv.offsetHeight==0) return; // Not yet visible
		
		var tHead = document.getElementById("tpHead_"+this.index)
		var tbody = document.getElementById("tpBody_"+this.index)
		
		tbody.scrollWidth = tbody.scrollWidth - 17;
		
		if((tbody.offsetHeight >= tbody.children[0].offsetHeight) || (navigator.userAgent.match(/iPad/i))) {
			for(var i=0;i<tHead.children.length;i++) {
				tHead.children[i].lastElementChild.style.width = "0px"
				tHead.children[i].lastElementChild.style.display = "none"
			}
		} else {
			for(var i=0;i<tHead.children.length;i++) {
				tHead.children[i].lastElementChild.style.width = "12px"
				tHead.children[i].lastElementChild.style.display = ""
			}
		}
		
		var firstTr = new Object()
		
		if(tbody.children[0].children[0].children[0].children[0].className != "tpNoResults"){
			firstTr = tbody.children[0].children[0].children[0];
			if (firstTr.children.length==1) {
				return;	
			}
			for(var j=0; j<firstTr.children.length; j++) {
				if (zenIsIE) {
					var wBorder = 1;
				} else {
					var wBorder = parseInt(window.getComputedStyle(tHead.children[0].children[j],null).borderWidth)
				}
				var lPadding = parseInt(window.getComputedStyle(tHead.children[0].children[j],null).paddingLeft)
				var rPadding = parseInt(window.getComputedStyle(tHead.children[0].children[j],null).paddingRight)
				//if(!isWebkit) {
				//	tHead.children[0].children[j].width = parseInt(window.getComputedStyle(firstTr.children[j],null).width) - wBorder - lPadding - rPadding - 1 + "px";
				//	tHead.children[0].children[j].style.width = parseInt(window.getComputedStyle(firstTr.children[j],null).width) + "px";
				//} else {
					//var corWidth = parseInt(window.getComputedStyle(firstTr.children[j],null).width) - wBorder - lPadding - rPadding - 2;
					var corWidth = parseInt(window.getComputedStyle(firstTr.children[j],null).width) - wBorder - lPadding - rPadding - 2;
					if (corWidth<1) {var corWidth=1;}
					
					//tHead.children[0].children[j].style.width = parseInt(window.getComputedStyle(firstTr.children[j],null).width) + "px";
					tHead.children[0].children[j].style.width = corWidth + "px";
					alert("width="+window.getComputedStyle(firstTr.children[j],null).width + " wBorder=" + wBorder + " lPadding=" + lPadding + " rPadding=" + rPadding + " total= " +corWidth);
				//}
				
			}
		}
	//}
	return;
}
*/

// синхронизация шапки с таблицей. метод #2

ClientMethod packRows() [ Language = javascript ]
{
	
	if (this.hidden) return;
	
	if (!this.bodyHeight) return; // If it wasn't set, this isn't an issue
	if (this.fixedHeaders == false) return;
	if (!navigator) return; // Should never be true in a runtime situation
	var isWebkit=(navigator.userAgent.indexOf("WebKit")>=0);
	var isFF3=(navigator.userAgent.indexOf("Firefox")>=0);
	
	var eDiv=this.getEnclosingDiv();
	if (eDiv.offsetWidth==0 || eDiv.offsetHeight==0) return; // Not yet visible
		
	var tHead = document.getElementById("tpHead_"+this.index)
	var tbody = document.getElementById("tpBody_"+this.index)
		
	
	var br=tHead.getBoundingClientRect()  ;  
	    
    
	var br=tbody.getBoundingClientRect()  ;  
    
	var tableWidth = br.right - br.left;
	
	var firstTr = new Object()
		
	if(tbody.children[0].children[0].children[0].children[0].className != "tpNoResults"){
			firstTr = tbody.children[0].children[0].children[0];
			if (firstTr.children.length==1) {
				return;	
			}
			var totalWidth = 0;
			for(var j=0; j<firstTr.children.length; j++) {
					var totalWidth = totalWidth + parseInt(window.getComputedStyle(firstTr.children[j],null).width);
			}
			
			for(var j=0; j<firstTr.children.length; j++) {
					
					var corWidth = parseInt(window.getComputedStyle(firstTr.children[j],null).width)/totalWidth*tableWidth* 0.90;
					
					tHead.children[0].children[j].style.width = corWidth + "px";
									
			}
			if (tbody.scrollHeight==tbody.clientHeight) {	
				tHead.children[0].children[j].style.width = "0px";
			}
			
		}

	return;
}

/*
///  if the position of the enclosing div for table has not been explicitly set 
///  to some desired value, force its positioning to relative with an offset of 0,0
///  such a that any absolutely positioned child elements will have a known, local
///  offset parent. 
ClientMethod anchorDiv() [ Internal, Language = javascript ]
{
	//PL84286
	if (!this.useKeys) return;
	var node = this.getEnclosingDiv();
	var position = null;
	if (node.currentStyle) // IE Style
		position = node.currentStyle.position;
else if (window.getComputedStyle) {
  var styleObj = window.getComputedStyle(node,null);
  if (styleObj) position = styleObj.position;
}
	if (!(position=="absolute" || position=="relative")) {
		node.style.position = "relative";
		node.style.top = "0px";
		node.style.left = "0px";
	}
}

*/
ClientMethod anchorDiv() [ Internal, Language = javascript ]
{
	
	//PL84286
	if (!this.useKeys) return;
	var node = this.getEnclosingDiv();
	var position = null;
	try {
		if (node.currentStyle) // IE Style
			position = node.currentStyle.position;
		else if (window.getComputedStyle) // W3C Style
			position = window.getComputedStyle(node,null).position;
		if (!(position=="absolute" || position=="relative")) {
			node.style.position = "relative";
			node.style.top = "0px";
			node.style.left = "0px";
		}
	 } catch (e) {
	 }
}

}

