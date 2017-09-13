Class m.Template Extends %ZEN.Mojo.Component.contentTemplate [ ProcedureBlock ]
{

Parameter DOMAIN;

/// Server-side method to provide content to JSON providers.
/// <var>pProviderName</var> is the name of the provider.
/// <var>pKey</var> is an app-defined key that is used to indicate which content is to be served.
/// <var>pCriteria</var>is an object containing search criteria. This is used for searching.
/// <var>pParms</var> is an array of additional parameters from the JSON provider. (not current used).
/// <var>pObject</var> is the object that will be served to the client in JSON format.
/// <var>pLoad</var> is true is this is called when the page is first being served. In this case, this method will be 
/// called even though there may a client-side method used to load the content.
ClassMethod %OnGetJSONContent(pProviderName As %String, pKey As %String, ByRef pParms, Output pObject As %RegisteredObject, pCriteria As %RegisteredObject, pLoad As %Boolean = 0) As %Status
{
	set tel=$system.Encryption.Base32Decode(%page.AccountCode,1)
	&sql(select Id into :accountId from ent.Buyer where Aka =:tel)
	if SQLCODE set accountId=""
	set %session.Data("UserAccountId")=accountId
	set pObject = ##class(%ZEN.proxyObject).%New()

 	if (pKey = "home") {
	 	
	 	do ##class(m.LogOperations).AddLogLine("home","Открытие первой страницы")
	 	
	 	/// Получаем сколько накопленно баллов у данного покупателя
	 	set balance = 0
		&sql(select sum(PointsSum) into :balance from doc.BonusOperation where Buyer=:accountId)
 		if SQLCODE set balance = 0									
		
 		
		set tList = ##class(%Library.ListOfObjects).%New()
		//set pObject.Header = "Добро пожаловать! Пользователь "_tel
		set pObject.Balance = "<b>Участник: "_tel_"</b><br>"
		set pObject.Balance = pObject.Balance_"<b>На вашем счету накоплено "_ $fnumber(balance,"",2)_ " баллов</b>"
		
		
 	}
 	if (pKey = "step2") {

	 	set pObject.CalcDetail = " Направление: <b>"_%page.Data.FromStation_" - "_%page.Data.ToStation_"</b>"
	 	set pObject.CalcDetail = pObject.CalcDetail_" <br>Груз: <b>"_%page.Data.GoodsWeight_" кг, "_%page.Data.GoodsVolume_" куб. м </b>"
	 	
	 	do ##class(m.LogOperations).AddLogLine("step2-1","Открытие второй страницы. "_pObject.CalcDetail)
	 	
	 
 	}
 	// Дополнительные услуги
 	if (pKey = "step3") { 
 	
 		do ##class(m.LogOperations).AddLogLine("step3","Выбор дополнительных услуг.")
 		
 	
	 	
	 	
	 	
 	}
 	// Страница с окончательным расчетом
 	if (pKey = "finishPage") { 
 		
	     
 		set pObject.FinishContent =  " Направление: <b>"_%page.Data.FromStation_" - "_%page.Data.ToStation_"</b>"
	 	set pObject.FinishContent =  pObject.FinishContent_"<br> Вид перевозки: <b>"_$REPLACE(%page.Data.TransportType_"</b>","контейнерный","Ж/Д")_"</b>"
	 	set pObject.FinishContent =  pObject.FinishContent_"<br> Базовая стоимость: <b>"_%page.Data.StoimTrans_" руб.</b>"
	 
		
		set %page.FinishContent = pObject.FinishContent
		
		do ##class(m.LogOperations).AddLogLine("step4","Страница с окончательным расчетом. "_pObject.FinishContent)
 		
 	}
 	

 	quit $$$OK
}

/// Creates the layout object for the page
ClientMethod getLayout(key, criteria) [ Language = javascript ]
{
 	data = zenPage.getContent('data',key,{},true);
 	var content = null;
 	switch(key) { 
 		
		case 'home' : 
  			// add layout objects to the children array
			content = {
				children:[
				{type:'$header',headerClass:'calcHeader',backcaption:"Назад", caption: '', fixed:false,
						 children:[
						 {type:'$content',content:'<br><br>'},
						 {type:'$grid', children:[
		    				{type:'$img',src:'vape-ko-small.png'},
			    			{type:'$content',content:'Добро пожаловать в Бонус-Клуб!<br> Здесь вы можете узнать количество накопленных баллов и подключать к Бонус-клубу друзей, чтобы получать дополнительные бонусы с их покупок. Бонусами вы можете оплачивать до 100% стоимости товара.<br><br>Vape KnockOut<br>Ул. Дикопольцева, 50<br>757-100',style:"width:80%"},
		    			]},
		    			
		    		]},
		    		{type:'$content',content:'<br><br>'},
		    		{type:'$content',content:'=[Balance]',key:'fincontent'},
		    		{type:'$input',label:'Введите номер телефона вашего друга, и вы будете получать дополнительные баллы с его покупок:', key:"friendTel"},
		    		
		    				
    				{type:'$div',cssClass:'btnNext',children:[	
		    			{type:'$button',caption:'Подключить друга...',key:'send',dataiconpos:'right',style:'btn-next',cssClass:'ui-btn-next'},
		    		]}
		   
		    		
		    		
	
		    		
				]
 			}; 
 			//
				break;	
				
		case 'step2':
		 //alert(data['SelectTrip']);
		 if (data['SelectTrip']== "SelectTrips") {
		 	
		 	var content = zenPage.getLayoutSelectTrip();
	     
	     	break;	
	     } else if(data['SelectTrip']== "skipSelectTrip") {
			var content = zenPage.getLayoutDopService();
	    
	     	break;	 	
	     } else if (data['SelectTrip']== "SelectFromLocalStation") {
		     var content = zenPage.getLayoutSelectLocalFromStation();
		     break;
	     } else if(data['SelectTrip']== "SelectToLocalStation") {
			var content = zenPage.getLayoutSelectLocalToStation();
	    
	     	break;	 	
		 } else {
			var content = zenPage.getLayoutNoTrips();
	    
	     	break;	 	
		 } 
		 case 'step3':
		 
			var content = zenPage.getLayoutDopService();
	    
	     	break;	 	
		  			
	    case 'finishPage':	
	     		content = {
		     	sourceData:data,
				children:[
					{ type: '$header', caption: 'Спасибо!',backcaption:"Назад", fixed:false},
					
					{type:'$content',content:'=[FinishContent]',key:'fincontent'},
					{type:'$input',label:'Введите email или телефон и менеджер перезвонит Вам:',placeholder:"email или телефон...",key:"inputTel"},
					{type:'$div',cssClass:'btnNext',children:[	
						{type:'$button',cssClass:'btnNext',caption:'Отправить расчет в компанию',key:'send'},
					]},
		    		{type:'$footer',fixed:true,children:[
		    			
		    		]}	
	     		]}
	     		zenPage.FinishContent = data['FinishContent'];
	     	break;		
	     		
 	} 

 	return content;
}

/// Client-side content provider method.
/// <var>providerName</var> is the name of the json provider. 
/// <var>key</var> is the key value associated with the request.
/// <var>criteria</var> is the search criteria associated with the request.
ClientMethod onGetContent(providerName, key, criteria) [ Language = javascript ]
{
 	switch (providerName)
 	{ 
 		case 'layout': 
  			return this.getLayout(key,criteria);
 	} 

 	// return null -> fetch data from server (if local cache is empty)
 	return null;
}

ClientMethod onchange(key, value, final, docViewId) [ Language = javascript ]
{
	console.log('change ' + key + ' to ' + value);
 	var view = zen(docViewId);
 	if (key=='AllQtyInput') {
	 
	 
	 	if (parseInt(view.getControlValue('AllQtyInput'))<parseInt(view.getControlValue('OversizedQtyInput'))) {
			view.setControlValue('OversizedQtyInput',view.getControlValue('AllQtyInput'));
	 	}
	 	
 	}
 	if (key=='OversizedQtyInput') {
	 
	 	if (parseInt(view.getControlValue('AllQtyInput'))<parseInt(view.getControlValue('OversizedQtyInput'))) {
			view.setControlValue('OversizedQtyInput',view.getControlValue('AllQtyInput'));
	 	}
	 	
 	}
 	 	/// выбираем услуги
 	if (key.search('ServicesLine')==0) {
	 	
	 	var l = key.length;
 		var curI = key.substring(13,l);	
	 	
	 	console.log('ServicesLine ='+curI);
	 	
	 	console.log('ServicesLine 1 = ' + value);
	 	
	 	zenPage.Services[key]=key+'='+value;
	 	
	 	console.log('ServicesLine 2 = ' + zenPage.Services[key]);
	 	
	 	for (var i in zenPage.Services) {
    		console.log('array = ' + i);
		}
		
		for (j = 0; (j <= 20) ; j++) {
	 		var сontrolValue=view.getControlValue('ServicesLine:'+j);
	 		console.log('getControlValue = ' + сontrolValue);
			zenPage.Services['ServicesLine:'+j]='ServicesLine:'+j+'='+сontrolValue;
	 		
		}
 		return;	
 	}
 	
 	
 	if (key=='transportType1') {
	 	zenPage.IsTransportType1 = value;
	}
	if (key=='transportType2') {
	 	zenPage.IsTransportType2 = value;
	}
	if (key=='transportType3plus') {
	 	zenPage.IsTransportType3plus = value;
	}
	if (key=='IsFromExp') {
	 	zenPage.IsFromExp = value;
 	}
 	if (key=='IsToExp') {
	 	zenPage.IsToExp = value;
 	}
 	if ((key=='fromStationText')||(key=='toStationText')) {
	  
	  if (key=='fromStationText') {
	 	var datalistId = "#dv_19_0_4_4_datalist";
	  }
	  if (key=='toStationText') {
	 	var datalistId = "#dv_19_0_6_6_datalist";
	  }	
	 	
	 	
	  if (value.length>3) {
			 	
		
     	setTimeout(function(value) { 
       		console.log('2 - value:' + value );
			var curvalue = view.getControlValue(key) ;
			console.log('3 - curvalue:' + curvalue );
			if (value==curvalue) {	
			
			var encodestr = zenPage.fixedEncodeURIComponent(value);
            
            var encodestr = encodestr.replace(/\%/gi, "");
			  
			console.log('4 - encodestr utf:' + encodestr );
			

        		var options = {};
           		options.url = "http://base.spidercalc.ru/csp/spiderrest/getStations/"+zenPage.AccountCode+"/"+ encodestr;
           		//options.url = "http://localhost:57773/csp/spiderrest/getStations/"+zenPage.AccountCode+"/"+ encodestr;
        		options.type = "GET";
        		options.async = true,
               	options.dataType = "json";
        		options.error = function (jqXHR, textStatus,errorThrown ) {
	         		alert('error:' + textStatus + errorThrown);	
        		};
        		options.success = function (data) {
	               	$(datalistId).empty();
            
            		for(var i=0;i<data.data.length;i++) {
	            		$(datalistId).append("<option value='" + data.data[i].value + "'></option>");
            		}
        		};
        		$.ajax(options);
			}
        }, 500,value);
	  }
 	}
}

ClientMethod onselect(key, value, docViewId) [ Language = javascript ]
{
	console.log('value ='+value);
	console.log('key ='+key);
	console.log('docViewId ='+docViewId);
	
 	var view = zen(docViewId);
 	
 	if (key=='toStep2') {
	 	
	 	
	 	zenPage.Data = new zenProxy();
	 	//zenPage.Data.FromStation=view.getControlValue('fromStationText');
	 	//zenPage.Data.ToStation=view.getControlValue('toStationText');
	 	
	 	
		alert("Спасибо. Мы подключили вашего друга к бонус-клубу");	
		
	 	
						
		zenPage.Data.GoodsWeight=view.getControlValue('goodsWeight');
		zenPage.Data.GoodsVolume=view.getControlValue('goodsVolume');
		
		
				
 		view.pushDocument('home','layoutCriteria','home');
 		
 		return;	
 	}
 	if (key=='toFinishPage') {
	 	
	 	//data = zenPage.getContent('data',key,{},true);
	 	//zenPage.SelectedTripNo = data['SelectedTripNo'];
	 	//alert(zenPage.SelectedTripNo);
	 	
	 	for (j = 0; (j <= 20) ; j++) {
	 		var сontrolValue=view.getControlValue('ServicesLine:'+j);
	 		console.log('getControlValue = ' + сontrolValue);
			zenPage.Services['ServicesLine:'+j]='ServicesLine:'+j+'='+сontrolValue;
	 		
		}
		console.log('goto 1 ');
	 	zenPage.ArrayToServer(zenPage.Services);
	 	console.log('goto 2 ');
 		view.pushDocument('finishPage','layoutCriteria','finishPage');
 		return;	
 	}
 	if (key=='home') {
	 	
	 	zenPage.IsFromExp = false;
	 	zenPage.IsToExp = false;
	 	zenPage.IsOversized = false;
	 	zenPage.GoodsTemperature = false;
	 	view.pushDocument('home','layoutCriteria','home');
 		
 		return;	
 	}
 	if (key=='send') {
 		var message=view.getControlValue('friendTel');
 		if (message=='') {
	 		alert("Вы не указали телефон вашего друга!");
	 		return;	
 		}
 		
 		
 		//data = zenPage.getContent('data',key,{},true);
 		
 		
 		//alert(view.getControlValue('fincontent'));
 		
		var submitobject={Message:message};
		var response = zenPage.submitData('inputTel',submitobject);
			if (response && response.message) {
				zenPage.showMessage(response.message);
				view.setControlValue('friendTel','');
			}
			//view.pushDocument('home','layoutCriteria','home');
 	}
}

/// Отправка данных на сервер
ClassMethod %OnSubmitData(pKey As %String, pID As %String, pSubmitObject As %RegisteredObject, ByRef pResponseObject As %RegisteredObject) As %Status
{
 Set tSC = $$$OK
 Try {
 	
 	
 	
 	if pKey="inputTel"{
	 	
	 	//set tel=$system.Encryption.Base32Decode(%page.AccountCode,1)
		//&sql(select Id into :accountId from ent.Buyer where Aka =:tel)
		//if SQLCODE set accountId=""
		if +$get(%session.Data("UserAccountId")) {
			set accountId = %session.Data("UserAccountId")
			
		}
		if $get(accountId)="" {
			set tel=$system.Encryption.Base32Decode(%page.AccountCode,1)
			&sql(select Id into :accountId from ent.Buyer where Aka =:tel)
			if SQLCODE set accountId=""
		}
		do ##class(m.LogOperations).AddLogLine("sendContact","Регистрация телефона друга. "_pSubmitObject.Message_" "_accountId)	
		do ##class(ent.Buyer).GetBuyerIdByAka(pSubmitObject.Message,accountId)
	 	
	 	set sendEmail = "vassil@progrepublic.ru,ekaterina@progrepublic.ru"
	 	if sendEmail]"" set sendEmail=$LISTFROMSTRING(sendEmail,",")
	 	else  set sendEmail=""
	 	
	 	set sc =##class(admin.Email).SendEmail(sendEmail,"Регистрация телефона друга: "_pSubmitObject.Message_"<br><br>"_accountId, "Сообщение от HOOKAH Store!" )
	 	 
 		Set pResponseObject = ##class(%ZEN.proxyObject).%New()
 
 		If $$$ISERR(tSC) {
 			Set pResponseObject.message = sc
 			Quit
 		}
 		Set pResponseObject.message = "Информация отправлена!"
 	}
 } Catch(ex) {
 	Set tSC = ex.AsStatus()
 }
 Quit tSC
}

}

