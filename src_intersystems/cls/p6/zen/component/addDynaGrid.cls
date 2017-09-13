/// Компонент служит для создания таблицы с возожностью редактирования.<br>
/// При двойном клике по ячейке в ней появляется поле редактирования (галочка,поле ввода,список)<br>
/// <br>
/// Обновление таблицы(через JS):<br>
/// <example LANGUAGE=JS>
///  zenPage.CreateDataSet(table,table.dataSet,table.configSet);
///  table.refreshContents();
/// </example>
Class p6.zen.component.addDynaGrid Extends %ZEN.Component.dynaGrid
{

Property scrollIntoView As %ZEN.Datatype.boolean [ InitialExpression = 0 ];

/// This is the XML namespace for this component.
Parameter NAMESPACE = "http://www.dimas.ru/p6";

/// Ссылка на метод заполняющий <property>dataSet</property> и <property>configSet</property>
Property OnCreateDataSet As %ZEN.Datatype.delegator(FORMALSPEC = "pGrid:%ZEN.Component.dynaGrid,pDataSet:%ZEN.Auxiliary.dataSet,pConfigSet:%ZEN.Auxiliary.dataSet", RETURNTYPE = "%Status");

/// В классе <class>%ZEN.Auxiliary.dataSet</class> существуют Label(подписи) и Value(значения)<br>
/// Label-указывает на тип контрола:<br>
/// <ul>
///  <li>1- текстовое поле </li>
///  <li>2- текстовое поле с проверкой и нормализацией даты </li>
///  <li>3- список </li>
///  <li>4- галочка </li>
///  <li>5- многострочное текстовое поле (только IE) </li>
///  <li>6- текстовое поле с проверкой и нормализацией времени </li>
/// </ul>
/// Value в строке указывает:<br>
/// <ul>
///  <li>для списка- варианты выбора(без пустого!)</li>
///  <li>для галочки 1-что показывать если true;   2-если false</li>
///  <li>для многострочное - количествово строчек</li>
/// </ul>
Property configSet As %ZEN.Auxiliary.dataSet(ZENSETTING = 0);

/// Метод для заполнения <property>dataSet</property> и <property>confidSet</property> при помощи  такого списка передаваемого в параметре:
/// <example>
/// set gridInfo=$lb(
/// 	$lb("Колонка 1", "Колонка 2","..."),  // заголовок колонки
/// 	$lb(        "1",         "4","..."),  //тип колонки
/// 	$lb(         "",   "создано","..."),  // аргументы типа
/// 	$lb(         "","не создано","...")
/// )
/// </example>
/// 	Предпологается для использования внутри <property>OnCreateDataSet</property> чтобы упростить код
Method CreateDataSetFromList(gridInfo As %List)
{
	Do ..configSet.%Clear()
	Do ..dataSet.%Clear()
	//kill ^a.SetLabel
	//set ^a.SetLabel=$LISTLENGTH($LISTGET(gridInfo,1))
	
	for numCol=1:1:($LISTLENGTH($LISTGET(gridInfo,1))) {
		
		//set ^a.SetLabel(numCol)=$LISTGET($LISTGET(gridInfo,1),numCol)
		
		
		Do ..dataSet.%SetLabel($LISTGET($LISTGET(gridInfo,1),numCol),numCol,2)
		Do ..configSet.%SetLabel($LISTGET($LISTGET(gridInfo,2),numCol),numCol,2)
		
		if ($LISTGET($LISTGET(gridInfo,2),numCol))="3" {
			set numSel=0
			while(1) {
				set curItem=$LISTGET($LISTGET(gridInfo,3+numSel),numCol)
				if curItem="" quit
				do ..configSet.%SetValue(curItem,1+numSel,numCol)
				set numSel=numSel+1
			}
		} elseif ($LISTGET($LISTGET(gridInfo,2),numCol))="4" {
			set yesVal=$LISTGET($LISTGET(gridInfo,3),numCol)
			if yesVal="" set yesVal="да"
			do ..configSet.%SetValue(yesVal,1,numCol)
			set noVal=$LISTGET($LISTGET(gridInfo,4),numCol)
			if noVal="" set noVal="нет"
			do ..configSet.%SetValue(noVal,2,numCol)
		}elseif ($LISTGET($LISTGET(gridInfo,2),numCol))="5" {
			do ..configSet.%SetValue($LISTGET($LISTGET(gridInfo,3),numCol),1,numCol)
		}
		
	}
}

Method %CreateDataSet() As %Status
{
	Set $ZT="Trap"
	Set tSC = $$$OK

	Set tHost = $S($IsObject(..composite):..composite,1:$G(%page))
	If ($IsObject(tHost) && (..OnCreateDataSet '= "")) {
		#; dispatch
		Set tSC = $zobjmethod(tHost,..OnCreateDataSet,$this,..dataSet,..configSet)
	}
Done
	Quit tSC
Trap
	Set $ZT=""
	Set tSC = $$$ERROR($$$GeneralError,$ZE)
	Goto Done
}

/// Return the HTML that renders the cell editor for the given cell.
/// <var>r</var> and <var>c</var> are 1-based.
ClientMethod getEditCellHTML(r, c, value) [ Language = javascript ]
{
	// test for user callback
	var html = '';
	var usercode = '';
	if (this.oneditcell) {
		usercode = zenInvokeCallbackMethod(this.oneditcell,this,'oneditcell','value',value);
	}
	if (usercode && '' != usercode) {
		html = usercode;
	}
	else {
		var configSet = this.getConfigSet();
		var type=configSet.getLabel(c-1,2);
		switch(type) 
		{
			case "2":
				html = '<input class="dynaGridInput" id="cellEditor" type="text" value="'+zenEscapeXML(value)+'" onblur="zenPage.getComponent('+this.index+').stopEditCell(false,2);">';
			break;
			
			case "3":
				html='<select class="dynaGridInput" id="cellEditor" onblur="zenPage.getComponent('+this.index+').stopEditCell(false,3);">';
				html=html+'<option value=""></option>';
				var i=0
				while(true)
				{
					var data=configSet.getData(i,c-1);
					if(data=="") break;
					if(value==data)html=html+'<option value="'+data+'" selected>'+data+'</option>';
					else html=html+'<option value="'+data+'">'+data+'</option>';	
					i++;
				}
				html=html+'</select>';
			break;
			
			case "4":
			
			
				if(value==configSet.getData(0,c-1)) {
			
					html='<input class="dynaGridInput" id="cellEditor" type="checkbox" value="'+zenEscapeXML(value)+'"  onblur="zenPage.getComponent('+this.index+').stopEditCell(false,4);" checked>';
				}
				else {
			
					html='<input class="dynaGridInput" id="cellEditor" type="checkbox" value="'+zenEscapeXML(value)+'" onblur="zenPage.getComponent('+this.index+').stopEditCell(false,4);">';
				}
			break;
			
			case "5":
				var rows=configSet.getData(0,c-1);
				if(rows=="") {
					rows=3;
				}
				html = '<TEXTAREA class="dynaGridInput" id="cellEditor" rows='+rows+' onblur="zenPage.getComponent('+this.index+').stopEditCell(false,5);">'+zenEscapeXML(value)+'</textarea>'
			break;			
			
			case "6":
				html = '<input class="dynaGridInput" id="cellEditor" type="text" value="'+zenEscapeXML(value)+'" onblur="zenPage.getComponent('+this.index+').stopEditCell(false,6);">';
			break;			
			
			default:
				html = '<input class="dynaGridInput" id="cellEditor" type="text" value="'+zenEscapeXML(value)+'" onblur="zenPage.getComponent('+this.index+').stopEditCell(false);">';
			break;
		}
	}
	return html;
}

/// Stop editing of the current cell.<br>
/// If <var>cancel</var> is true, then do not save current control value.<br>
/// mode -режим работы для разных типов(в соответствии с configSet)
ClientMethod stopEditCell(cancel, mode) [ Language = javascript ]
{
	cancel = (null==cancel) ? false : cancel;
	var value;
	var configSet = this.getConfigSet();
	
	if (this.currDiv && this.cellHasFocus) {
		// get rid of edit control in cell; save value
		this.cellHasFocus = false;
		this.F2Mode = false;
		var cell = this.window.document.getElementById("cellEditor");
		zenASSERT(cell,"Unable to find cellEditor control",arguments);
		//if (cell) {
			if(cancel)
			{
				value=this.getCellValue(this.currRow, this.currColumn);
			}else {
				//type=configSet.getLabel(this.currColumn-1,2)
				switch(mode)
				{
					case 2: 
						value=this.NormalizeDate(cell.value);
						break;		
				
					case 4: 
						if(cell.checked)
							value=configSet.getData(0,this.currColumn-1);
						else
							value=configSet.getData(1,this.currColumn-1);
						break;
					
					case 6: 
						value=this.NormalizeTime(cell.value);
						break;					
										
					default: 
						value = cell.value;
						break;
				}
		//	}
			this.currDiv.onclick = this.oldOnclick;
			this.setCellValue(value, this.currRow, this.currColumn);
			cell.value = '';
		}
		this.currDiv = null;

		// invoke cell onchangecell callback, if present
		if (!cancel) {
			zenInvokeCallbackMethod(this.onchangecell,this,'onchangecell');
		}

		// invoke grid-wide onchange callback, if present
		zenInvokeCallbackMethod(this.onchange,this,'onchange');

		// give focus back to invisible control
		this.focus();
	}
}

Method NormalizeDate(aDate As %String = "") As %String [ CodeMode = expression, ZenMethod ]
{
##class(p6.dt.Date).LogicalToDisplay(##class(p6.dt.Date).DisplayToLogical(aDate))
}

Method NormalizeTime(aTime As %String = "") As %String [ CodeMode = expression, ZenMethod ]
{
##class(p6.dt.Time).LogicalToDisplay(##class(p6.dt.Time).DisplayToLogical(aTime))
}

Method %OnNew(initvalue As %CacheString) As %Status [ Private, ProcedureBlock = 1 ]
{
	#; make sure we have a dataSet property
	Set ..dataSet = ##class(%ZEN.Auxiliary.dataSet).%New(2)
	Set ..configSet = ##class(%ZEN.Auxiliary.dataSet).%New(2)
	Do:$IsObject($G(%page)) %page.%AddComponent(..dataSet)
	Do:$IsObject($G(%page)) %page.%AddComponent(..configSet)
	Quit $$$OK
}

/// Return the dataSet object associated with this grid.
ClientMethod getConfigSet() [ Language = javascript ]
{
	var controller = this.getController();
	return (controller ? controller : this.configSet);
}

/// Client-side method to render this component.
ClientMethod renderContents() [ Language = javascript ]
{

	try {
		var controller = this.getController();
		if (null == controller) {
			// try to connect to dataController
			this.connectToController();
		}

		zenInvokeCallbackMethod(this.onrender,this,'onrender');

		var encDiv = this.getEnclosingDiv();
		// test if we have not been rendered yet
		if (encDiv == null) return;

		// build HTML for grid
		var html = new Array();

		// extra wrapper div to make ie happy
	//	html[html.length] = '<div id="'+this.makeId('wrapper')+'" class="dynaGridWrapper">';

		// use hidden control to make sure there is a value to submit
		html[html.length] = '<input type="hidden" id="'+this.makeId('control')+'" name="'+this.name+'" value="'+this.value+'"/>';

		var gcls = this.disabled ? 'dynaGridDisabled' : this.gridClass;
		html[html.length] = '<table id="'+this.makeId('table')+'" class="'+gcls+'" border="0" cellspacing="0" cellpadding="0" width="100%">';
		
		
		var dataSet = this.getDataSet();
		var cols = dataSet.getDimSize(2);
		if (cols < 2) {
			this.F2Mode = true;
		}
		else {
			this.F2Mode = false;
		}

		if (zenIsMissing(dataSet)) {
			html[html.length] = '<tr><td>dynaGrid has no data.</td></tr>';
		}
		else {
			zenASSERT(dataSet.getDimensions()>0,"dataSet must have at least one dimension.",arguments);

			// if there are cell overrides, organize them
			// cellInfo[page][row][col]
			var cellInfo = null;
			if (this.cells.length) {
				cellInfo = [];
				for (var k = 0; k < this.cells.length; k++) {
					var info = this.cells[k];
					var page = parseInt(info.page!==''?info.page:1,10);
					var row = parseInt(info.row!==''?info.row:1,10);
					var col = parseInt(info.column!==''?info.column:1,10);
					if (!cellInfo[page]) {
						cellInfo[page] = [];
					}
					if (!cellInfo[page][row]) {
						cellInfo[page][row] = [];
					}
					cellInfo[page][row][col] = info;
				}
			}

			// column headers
			if (this.showColumnLabels) {
				html[html.length] = '<tr>';
				if (this.showRowLabels) {
					// gridLabel in corner
					var glbl;
					if (dataSet.getDimensions() > 2) {
						// 3-D grid: show page label
						glbl = dataSet.getLabel(this.currPage-1,3);
						glbl = (''==glbl? this.currPage : glbl);
						glbl = '<a onclick="zenPage.getComponent('+this.index+').previousPage();">&laquo;</a>' + '&nbsp;' + '<a onclick="zenPage.getComponent('+this.index+').nextPage();">&raquo;</a>&nbsp;' + glbl;

					}
					else {
						glbl = (''==this.gridLabel?'&nbsp;':this.gridLabel);
					}
					var glblstyle = this.columnHeaderStyle;
					if (this.borders=='none') {
						glblstyle += 'border:none;';
					}
					html[html.length] = '<th nowrap="1" id="gridLabel_'+this.index+'" style="'+glblstyle+'" class="dynaGridLabel"'+'onclick="zenPage.getComponent('+this.index+').gridLabelHandler();">'+glbl+'</th>';
				}
				for (var c = 0; c < cols; c++) {
					var cinfo = this.getColumnInfo(c);
					if (cinfo && cinfo.hidden) continue;

					var data = cinfo ? cinfo.label : '';
					data = ('' == data) ? dataSet.getLabel(c,2) : data;
					data = ('' == data) ? '&nbsp;' : data;
					var thstyle = this.columnHeaderStyle;
					if (this.borders=="none") {
						thstyle += 'border: none;';
					}
					var thtip = '';
					var dbl = 'ondblclick="zenPage.getComponent('+this.index+').columnLabelDblClickHandler('+(c+1)+');"';
					html[html.length] = '<th nowrap="1" style="'+thstyle+'" id="thCol_'+(c+1)+'_'+this.index+'" class="dynaGridColumn"'+' '+dbl+' onclick="zenPage.getComponent('+this.index+').columnLabelHandler('+(c+1)+');">' + data + '</th>';
				}
				if (this.showArrows) {
					var rowCount = 2;
					for (var r = 0; r < dataSet.getDimSize(1); r++) {
						var rinfo = this.getRowInfo(r);
						if (rinfo && rinfo.hidden) continue;
						rowCount++;
					}
					html[html.length] = '<td class="dynaGridArrow" style="width: 24px; text-align:center;padding:2px;" rowspan="'+rowCount+'" title="'+$$$Text('Add column')+'" onclick="zenPage.getComponent('+this.index+').arrowHandler(\'columns\');">' + '<input type="image" src="images/arrowBR.png"/>' + '</td>';
				}
				html[html.length] = '</tr>';
			}

			// data: D1(rows) D2(cols)
			for (var r = 0; r < dataSet.getDimSize(1); r++) {
				var rinfo = this.getRowInfo(r);
				if (rinfo && rinfo.hidden) continue;

				var rprio = (null!=rinfo && rinfo.priority!=='') ? parseInt(rinfo.priority,10) : 1;
				var rformat = (null!=rinfo&&''!==rinfo.format) ? rinfo.format : this.format;
				var rstyle = '';
				if (this.borders=="none") {
					rstyle += 'border: none;';
				}
				rstyle += this.style + ((null!=rinfo&&null!=rinfo.style) ? rinfo.style : '');
				var rvalue = (null!=rinfo&&null!=rinfo.value) ? rinfo.value : '';
				var rtip = (null!=rinfo&&null!=rinfo.title) ? rinfo.title : '';
				var rro = (null!=rinfo&&null!=rinfo.readOnly) ? rinfo.readOnly : false;
				var rhgt = (null!=rinfo&&null!=rinfo.height) ? (''!=rinfo.height?' height="'+rinfo.height+'"':'') : '';
				var rcls = '';
				if (this.showZebra) {
					rcls = ' class="'+((r%2)?'dynaGridRowOdd':'dynaGridRowEven')+'"';
				}
				html[html.length] = '<tr'+rhgt+rcls+'>';

				// label
				if (this.showRowLabels) {
					var thstyle = this.rowHeaderStyle;
					if (this.borders=="none") {
						thstyle += 'border: none;';
					}
					if (this.showZebra) {
						thstyle += 'background: none;';
					}
					var data = rinfo ? rinfo.label : '';
					data = ('' == data) ? dataSet.getLabel(r,1) : data;
					data = ('' == data) ? '&nbsp;' : data;
					var dbl = 'ondblclick="zenPage.getComponent('+this.index+').rowLabelDblClickHandler('+(r+1)+');"';
					html[html.length] = '<th nowrap="1" style="'+thstyle+'" id="thRow_'+(r+1)+'_'+this.index+'" class="dynaGridRow"'+' '+dbl+' onclick="zenPage.getComponent('+this.index+').rowLabelHandler('+(r+1)+');">' + data + '</th>';
				}

				for (var c = 0; c < cols; c++) {
					var cinfo = this.getColumnInfo(c);
					if (cinfo && cinfo.hidden) continue;

					var tdstyle = rstyle;
					var tdformat = rformat;
					var tdvalue = rvalue;
					var cprio = 1;
					var tdtip = rtip;
					var cro = (null!=cinfo) ? cinfo.readOnly : false;
					if (null!=cinfo) {
						cprio = (cinfo.priority==='') ? 1 : parseInt(cinfo.priority,10);
						if ('undefined' != typeof cinfo.value && cinfo.value!=='') {
							if (cprio >= rprio) {
								tdvalue = cinfo.value;
							}
						}
						if ('undefined' != typeof cinfo.format && cinfo.format!=='') {
							if (cprio >= rprio) {
								tdformat = cinfo.format;
							}
						}
						if (cprio >= rprio) {
							tdstyle = tdstyle + cinfo.style;
						}
						else {
							tdstyle = cinfo.style + tdstyle;
						}
						if (cprio >= rprio) {
							tdtip = (''!=cinfo.title) ? cinfo.title : tdtip;
						}
					}

					var events = ' onclick="zenPage.getComponent('+this.index+').cellClickHandler('+(r+1)+','+(c+1)+',event);" ondblclick="zenPage.getComponent('+this.index+').cellDblClickHandler('+(r+1)+','+(c+1)+',event);"'
					var data = dataSet.getData(r,c,this.currPage-1);
					if (data==='' && tdvalue!=='') {
						data = tdvalue;
					}
					if (this.ongetcellvalue!='') {
						var ndata = zenInvokeCallbackMethod(this.ongetcellvalue,this,'ongetcellvalue','row',r+1,'col',c+1,'data',data);
						if (ndata !== null) {
							data = ndata;
						}
					}

					var page = 0;
					if (cellInfo && cellInfo[page+1]&&cellInfo[page+1][r+1]&&cellInfo[page+1][r+1][c+1]) {
						var clinfo = cellInfo[page+1][r+1][c+1];
						if (clinfo.style!='') {
							tdstyle = clinfo.style;
						}
						if (clinfo.format!='') {
							tdformat = clinfo.format;
						}
					}

					data = data!==null ? data : '';
					data = this.getCellContents(data,r+1,c+1);

					if ('' != tdstyle) {
						tdstyle = ' style="'+tdstyle+'"';
					}
					if ('' != tdtip) {
						tdtip = ' title="'+tdtip+'"';
					}

					var cls = (this.currRow == (r+1) && this.currColumn == (c+1)) ? ' class="selected"' : '';

					data = (tdformat!='') ? zenFormatNumber(data,tdformat) : data;
					
					html[html.length] = '<td ' + (this.nowrap ? 'nowrap="1" ' : '') + 'valign="middle"'+tdstyle+tdtip+'>';
					html[html.length] = '<div id="td_'+(r+1)+'_'+(c+1)+'_'+this.index+'" '+events+cls+'>'+data+'</div>';
					html[html.length] = '</td>';
				}
				html[html.length] = '</tr>';
			}
		}

		if (this.showArrows) {
			var colCount = cols + 1;
			html[html.length] = '<tr>';
			html[html.length] = '<td class="dynaGridArrow" style="text-align:center;padding:2px;" colspan="'+colCount+'"  title="'+$$$Text('Add row')+'" onclick="zenPage.getComponent('+this.index+').arrowHandler(\'rows\');">' + '<input type="image" src="images/arrowBD.png"/>' + '</td>';
			html[html.length] = '</tr>';
		}
		html[html.length] = '</table>';

		// insert invisible input to catch key events
		// SAM107 implement equivalent styling to that removed by JMD625 to fix blank line problem without breaking chrome
		//html[html.length] = '<div style="position:relative; display:block; height:0px; width:0px; overflow:hidden; fontSize:0px; lineHeight:0px" >';
		html[html.length] = '<div style="top:0px;left:0px;position:absolute; display:block; height:0px; width:0px; overflow:hidden; font-size:0px; line-height:0px" >';
		// JMD625: remove style so that Chrome will give focus!
		//html[html.length] = '<input type="text" id="'+this.makeId('invisible')+'" style="top:0px;left:0px;position:absolute; border: 0px solid green;width:0;height:0;" onkeydown="zenPage.getComponent('+this.index+').gridKeyDownHandler(event);" onkeypress="zenPage.getComponent('+this.index+').gridKeyPressHandler(event);" onfocus="zenPage.getComponent('+this.index+').gridKeyFocus();" onblur="zenPage.getComponent('+this.index+').gridKeyBlur();"/>';
		html[html.length] = '<input type="text" tabindex="'+this.tabIndex+'" id="'+this.makeId('invisible')+'"  onkeydown="return zenPage.getComponent('+this.index+').gridKeyDownHandler(event);" onkeypress="return zenPage.getComponent('+this.index+').gridKeyPressHandler(event);" onfocus="zenPage.getComponent('+this.index+').gridKeyFocus();" onblur="zenPage.getComponent('+this.index+').gridKeyBlur();"/>';
		html[html.length] = '</div>';

	//	html[html.length] = '</div>';
	
		encDiv.innerHTML = html.join('');
		this.adjustSizes();
	}
	catch(ex) {
		zenExceptionHandler(ex,arguments,'Error in renderContents.');
	}
}

/*
/// Client-side method to render this component.
ClientMethod renderContents() [ Language = javascript ]
{
	var controller = this.getController();
	if (null == controller) {
		// try to connect to dataController
		this.connectToController();
	}

	var encDiv = this.getEnclosingDiv();
	// test if we have not been rendered yet
	if (encDiv == null) return;

	// build HTML for grid
	var html = new Array();

	// use hidden control to make sure there is a value to submit
	html[html.length] = '<input type="hidden" id="'+this.makeId('control')+'" name="'+this.name+'" value="'+this.value+'">';


	var dataSet = this.getDataSet();
	var cols = dataSet.getDimSize(2);
	if (cols < 2) {
		this.F2Mode = true;
	}
	else {
		this.F2Mode = false;
	}

	if (!zenIsMissing(dataSet) && (dataSet.getDimensions() > 2)) {
		html[html.length] = '<button onclick="zenPage.getComponent('+this.index+').previousPage();">&nbsp;&laquo;&nbsp;</button>' + '&nbsp;' + '<button onclick="zenPage.getComponent('+this.index+').nextPage();">&nbsp;&raquo;&nbsp;</button>&nbsp;' + this.currPage;
	}
	html[html.length] = '<table id="'+this.makeId('table')+'" class="'+this.gridClass+'" border="0" cellspacing="0" cellpadding="0">';
	
	if (zenIsMissing(dataSet)) {
		html[html.length] = '<tr><td>dynaGrid has no data.</td></tr>';
	}
	else {
		
		
		
		zenASSERT(dataSet.getDimensions()>0,"dataSet must have at least one dimension.",arguments);



		// column headers
		if (this.showColumnLabels) {
			html[html.length] = '<tr>';
			if (this.showRowLabels) {
				// gridLabel in corner
				var glbl;
				glbl = (''==this.gridLabel?'&nbsp;':this.gridLabel);
				html[html.length] = '<th nowrap="1" id="gridLabel_'+this.index+'" class="dynaGridLabel"'+'>'+glbl+'</th>';
			}
			for (var c = 0; c < cols; c++) {
				var cinfo = this.getColumnInfo(c);
				if (cinfo && cinfo.hidden) continue;

				var data = dataSet.getLabel(c,2);
				data = ('' == data) ? '&nbsp;' : data;
				var thstyle = '';
				var thtip = '';
				html[html.length] = '<th nowrap="1" id="thCol_'+(c+1)+'_'+this.index+'" class="dynaGridColumn"'+' onclick="zenPage.getComponent('+this.index+').columnLabelHandler('+(c+1)+');">' + data + '</th>';
			}
			html[html.length] = '</tr>';
		}

		// data: D1(rows) D2(cols)
		for (var r = 0; r < dataSet.getDimSize(1); r++) {
			var rinfo = this.getRowInfo(r);
			if (rinfo && rinfo.hidden) continue;

			var rstyle = (null!=rinfo&&null!=rinfo.style) ? rinfo.style : '';
			var rtip = (null!=rinfo&&null!=rinfo.title) ? rinfo.title : '';
			var rro = (null!=rinfo&&null!=rinfo.readOnly) ? rinfo.readOnly : false;
			var rhgt = (null!=rinfo&&null!=rinfo.height) ? (''!=rinfo.height?' height="'+rinfo.height+'"':'') : '';
			html[html.length] = '<tr'+rhgt+'>';

			// label
			if (this.showRowLabels) {
				var data = dataSet.getLabel(r,1);
				data = ('' == data) ? '&nbsp;' : data;
				html[html.length] = '<th nowrap="1" id="thRow_'+(r+1)+'_'+this.index+'" class="dynaGridRow"'+' onclick="zenPage.getComponent('+this.index+').rowLabelHandler('+(r+1)+');">' + data + '</th>';
			}

			for (var c = 0; c < cols; c++) {
				var cinfo = this.getColumnInfo(c);
				if (cinfo && cinfo.hidden) continue;

				var tdstyle = rstyle;
				var tdtip = rtip;
				var cro = (null!=cinfo) ? cinfo.readOnly : false;
				if (null!=cinfo) {
					tdstyle += cinfo.style;
					tdtip = (''!=cinfo.title) ? cinfo.title : tdtip;
				}
				if ('' != tdstyle) {
					tdstyle = ' style="'+tdstyle+'"';
				}
				if ('' != tdtip) {
					tdtip = ' title="'+tdtip+'"';
				}

				var events = ' onclick="zenPage.getComponent('+this.index+').cellClickHandler('+(r+1)+','+(c+1)+');" ondblclick="zenPage.getComponent('+this.index+').cellDblClickHandler('+(r+1)+','+(c+1)+');"'
				var data = dataSet.getData(r,c,this.currPage-1);
				data = this.getCellContents(data,r+1,c+1);
				var cls = (this.currRow == (r+1) && this.currColumn == (c+1)) ? ' class="selected"' : '';

				html[html.length] = '<td nowrap="1" valign="middle"'+tdstyle+tdtip+'>';
				if (!insertInput) {
					// insert invisible input to catch key events
					if (zenIsIE) {
						style="style=\"top:0px;left:0px;position:absolute;border: 0px solid green;width:0;height:0;\"";
					}else {
						style="style=\"top:0px;left:0px;position:fixed;border: 0px solid green;width:0;height:0;\"";
					}
					html[html.length] = '<input type="text" id="'+this.makeId('invisible')+'" '+style+' onkeydown="zenPage.getComponent('+this.index+').gridKeyDownHandler(event);" onkeypress="zenPage.getComponent('+this.index+').gridKeyPressHandler(event);" onfocus="zenPage.getComponent('+this.index+').gridKeyFocus();" onblur="zenPage.getComponent('+this.index+').gridKeyBlur();"/>';
					var insertInput=true;
				}
				html[html.length] = '<div id="td_'+(r+1)+'_'+(c+1)+'_'+this.index+'" '+events+cls+'>'+data+'</div>';
				html[html.length] = '</td>';
			}
			html[html.length] = '</tr>';
		}
	}

	html[html.length] = '</table>';
	
	encDiv.innerHTML = html.join('');
	this.adjustSizes();
}
*/
/// Set the value of grid cell; Row and column are 1-based.
ClientMethod setCellValue(value, r, c) [ Language = javascript ]
{
	var dataSet = this.getDataSet();
	var configSet = this.getConfigSet();
	
	var type=configSet.getLabel(c-1,2)
	
	if (!zenIsMissing(dataSet)) {
		
		switch(type)
		{
			case 2:
				value=this.NormalizeDate(value);
			break;
					
			case 6:
				value=this.NormalizeTime(value);
			break;					
										
			default:
			break;
		}		
		
		dataSet.setData(value,r-1,c-1,this.currPage-1);

		// if there is a controller, notify it
		var controller = this.getController();
		if (controller) {
			// note: series # is 1-based
			this.sendEventToController('propertyChange',controller.getPropertyName(r-1),value,c);
		}
	}

	var div = this.findElement("td_"+r + "_" + c);
	if (div) {
		value = this.getCellContents(value,r,c);
		div.innerHTML = value;
	}
}

/// Adjust the column sizes of this grid.
ClientMethod adjustSizes() [ Language = javascript ]
{
	try {
		// find available width and divy it up
		var dataSet = this.getDataSet();
		var cols = dataSet.getDimSize(2);
		var rows = dataSet.getDimSize(1);
	
		var encDiv = this.getEnclosingDiv();
		var wrapper = this.findElement("wrapper");
		var tbl = this.findElement("table");

		var dEdgeW = this.getEdgeWidth(encDiv,0,1,1);
		var wEdgeW = this.getEdgeWidth(wrapper,0,1,1);
		var tEdgeW = this.getEdgeWidth(tbl,1,1,1);
	
		var colW = parseFloat(this.columnWidth);
		var rlW = parseFloat(this.rowLabelWidth);
	
		var defWidth=null;
		if (window.getComputedStyle) var defWidth=this.getCSSWidthSpec(encDiv);
		else var defWidth=encDiv.currentStyle.width;
	
		var insideW=null;
		if (encDiv.offsetWidth>0) var insideW=encDiv.offsetWidth-dEdgeW;
		else {
			if (!(defWidth.indexOf) || defWidth.indexOf("px")>0) var insideW=parseFloat(defWidth)-dEdgeW;
		}
	
		if (this.showRowLabels && insideW && this.rowLabelWidth.indexOf("%")>0) {
			rlW = Math.floor(insideW*rlW/100);
		}
		var cHead=[]; //Array of nodes governing size of individual columns
		if (this.showRowLabels) {  // If the first column is row labels, pick it up
			if (this.showColumnLabels) {
				var th = this.findElement("gridLabel");
				if (th) cHead.push(th);
			}
			else {
				var div = this.findElement("thRow_1");
				if (div) cHead.push(div);
			}
		}
		for (var c = 0; c < cols; c++) { // now get top cells for all the data columns
			if (this.showColumnLabels) {
				var th = this.findElement("thCol_"+(c+1));
				// even if null, add to list!
				cHead.push(th);
			}
			else {
				var div = this.findElement("td_1_" + (c+1));
				if (div && div.parentNode) {
					cHead.push(div.parentNode);
				}
				else {
					cHead.push(null);
				}
			}
		}

		// Now find out how wide each column is supposed to be
		var wide = [];
		var unit = [];
		var sumPercent = 0; // total percentage widths
		var sumFixed = 0; // total pixels reserved for the interior of fixed width columns
		var edgeSum = 0; // total pixels reserved for cell separators and row labels (if any)
		var minWedge = 100; // smallest percentage specified wedge
		if (this.showRowLabels) edgeSum = rlW+this.getEdgeWidth(cHead[0],0,1,1);
		for (var c = 0; c < cols; c++) {
			var cinfo = this.getColumnInfo(c);
			if (cinfo && cinfo.hidden) continue;
			edgeSum += cHead[c] ? this.getEdgeWidth(cHead[c],0,1,1) : 0;

			if (cinfo && !isNaN(parseFloat(cinfo.width))) {
				wide[c] = parseFloat(cinfo.width);
				unit[c] = cinfo.width.indexOf ? (cinfo.width.indexOf('%')<0) : true;
				if (unit[c]) sumFixed += wide[c];
				else {
					sumPercent+=wide[c];
					if (wide[c]<minWedge) minWedge=wide[c];
				}
			}
			else {
				wide[c] = colW;
				unit[c] = true;
				sumFixed += colW;
			}
		}

		// Now resolve issues with percentages. 	For any width marked as a percentage
		// convert it to a pixel value and correct the units flag
		if (sumPercent>0) { // extra processing required
			if (sumPercent==100 || sumFixed==0) {
				var percentScale = 100 / sumPercent;
				if (insideW==null) {
					var oneUnit=(colW/(minWedge))*percentScale;
					for (var c=0;c<wide.length;c++) {
						if (!unit[c]) {
							wide[c]=Math.floor(wide[c]*oneUnit);
							unit[c]=true;
						}
					}
				}
				else {
					// bound this by the enclosing div size (hopefully specified)
					var space=percentScale*(insideW-edgeSum)/100;
					// space should now be the max space within the enclosing div tp play with
					for (var c=0;c<wide.length;c++) {
						wide[c]=Math.floor(space*wide[c]);
						unit[c]=true;
					}
				}
			}
			else {
				// only some of the columns are percentage based, need to balance
				// size of data area based on fixed elements
				var oneUnit=sumFixed/(100-sumPercent);
				for (var c=0;c<wide.length;c++) {
					if (!unit[c]) {
						wide[c]=Math.floor(wide[c]*oneUnit);
						unit[c]=true;
					}
				}
			
			}
		}
	
		// Address case where rowLabel width is percentage a when total grid size is unbounded
		if (this.showRowLabels && insideW==null && this.rowLabelWidth.indexOf("%")>0) {
			insideW=0;
			for (var c=0;c<wide.length;c++) insideW+=wide[c];
			edgeSum -= rlW;
			rlW = Math.floor(insideW*rlW/100);
			edgeSum += rlW;
		}

		// FINALLY update the table to reflect the desired geometry
		if (this.showRowLabels) {
			cHead[0].style.width=rlW+"px";
			var ofs=1;
		}
		else {
			ofs=0;
		}
		var w=edgeSum;
		for (var c = 0; c < cols; c++) {
			var cinfo = this.getColumnInfo(c);
			if ((cinfo && !cinfo.hidden) || !cinfo) {
				if (wide[c]<0) wide[c]=0;
				if (cHead[ofs]) {
					cHead[ofs].style.width=wide[c]+"px";
				}
				w+=wide[c];
			}
			ofs++;
		}
		wrapper.style.width=(w+(this.showArrows?30:0))+"px";
	}
	catch(ex) {
		//zenExceptionHandler(ex,arguments,'Error in adjustSizes.');
	}
}

/// Display edit control in the current cell.
/// If <var>defval</var> is defined, then use it as the initial value in the editor.
/// <var>which</var> indicates what type of cell is being edited: "row" (row label), "column" 
/// (column label), otherwise a data cell.
ClientMethod editCell(defval, which) [ Language = javascript ]
{
	var value;
	var r = this.currRow;
	var c = this.currColumn;
	which = ('undefined'==typeof which) ? 'cell' : which;
	defval = ('undefined'==typeof defval) ? null : defval;
	if ((which=='cell') && !this.isCellEditable(r,c)) {
		// not editable
		return;
	}
	if (r > 0 && c > 0) {
		switch(which) {
		case 'row':
			var div = this.findElement("thRow_"+r);
			zenASSERT(div,"Unable to find div element",arguments);
			var dataSet = this.getDataSet();
			value = (dataSet) ? dataSet.getLabel(r-1,1) : '';
			div.innerHTML = this.getEditCellHTML(r,0,value,'row');
			break;
		case 'column':
			var div = this.findElement("thCol_"+c);
			zenASSERT(div,"Unable to find div element",arguments);
			var dataSet = this.getDataSet();
			value = (dataSet) ? dataSet.getLabel(c-1,2) : '';
			div.innerHTML = this.getEditCellHTML(0,c,value,'column');
			break;
		default:
			var div = this.findElement("td_"+r + "_" + c);
			zenASSERT(div,"Unable to find div element",arguments);
			value = (null!=defval) ? defval : this.getCellValue(r,c);
			
			try {
				div.innerHTML = this.getEditCellHTML(r,c,value);
			}catch(e) {
				return;
			}
			break;
		}
		this.oldOnclick = div.onclick;
		div.onclick = '';
		this.currDiv = div;
		this.currEditType = which;

		// have font style for editor match the cell
		var style = '';
		if (div.parentNode && div.parentNode.style) {
			if (div.parentNode.style.fontSize!='') {
				style += 'font-size:' + div.parentNode.style.fontSize + ';';
			}
			if (div.parentNode.style.fontFamily!='') {
				style += 'font-family:' + div.parentNode.style.fontFamily + ';';
			}
		}

		// set size of control
		var celledit = this.window.document.getElementById("cellEditor");
		var w = div.parentNode.offsetWidth-1;
		var h = div.parentNode.offsetHeight-(zenIsIE ? 4 : 2);
		
		// JMD
		if (div.parentNode.style.paddingTop) {
			var pad = parseInt(div.parentNode.style.paddingTop);
			if (!isNaN(pad)) {
				h -= pad;
			}
		}
		if (div.parentNode.style.paddingBottom) {
			var pad = parseInt(div.parentNode.style.paddingBottom);
			if (!isNaN(pad)) {
				h -= pad;
			}
		}

		celledit.style.cssText = 'width:'+w+'px;height:'+h+'px;' + style;
		this.cellHasFocus = true;

		// give focus to control
		if (celledit.focus) {
			celledit.focus();
		}
		// force cursor to end of control
		if ('undefined' != typeof value) {
			if (celledit.setSelectionRange) {
				try {
					var ln = value.toString().length;
					celledit.setSelectionRange(ln,ln);
				} catch (e) {}
					
			}
			else { // ie!
				var v = celledit.value;
				celledit.value = '';
				celledit.value = v;
			}
		}
		// select
		if (null == defval && celledit.select) {
			celledit.select();
		}
	}
}

}

