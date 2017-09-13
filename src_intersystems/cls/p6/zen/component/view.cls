/// Компонент служит для показа текста без возможности редактирования
Class p6.zen.component.view Extends %ZEN.Component.control
{

/// This is the XML namespace for this component
Parameter NAMESPACE = "http://www.dimas.ru/p6";

/// Если истина, то заменять все подстроки вида http://link
/// на ссылки т.е. на &lt;a href="http://link"&gt;http://link&lt;/a&gt;
Property isParseURL As %ZEN.Datatype.boolean [ InitialExpression = {$$$NO} ];

XData Style
{
<style type="text/css">
.p6view {
	font-weight:bold;
}
</style>
}

Method %OnAddToPageAfter() As %Status
{
	if ..label="" {
		set form=..%GetForm()
		set className=form.%controller.modelClass
		set ..label=##class(p6.ClassDefinition).GetPropertyCaption(className,..dataBinding)
	}
	if ..id="" {
		set ..id=$tr(..dataBinding,"%.()","____")
	}
	if ..name="" {
		set ..name=..id
	}
	Quit $$$OK
}

Method %DrawHTML()
{
	set form=..%GetForm()
	set className=form.%controller.modelClass
	// после сохранения формы теряет связь с контроллером, либо он просто не переинициализируется=(
	if className="" quit
	
	set property=..dataBinding
	
	set info(0,"type")=className
	set info(0,"val")=form.%controller.modelId
	set info(0,"name")=""
	
	for i=1:1:$LENGTH(property,".") {
		set prop=$P(property,".",i)
		set propType=##class(p6.ClassDefinition).GetPropertyType(info(i-1,"type"),prop)
		
		set info(i,"name")=prop
		set info(i,"type")=propType
		
		if (info(i-1,"val")'="") {
			if ##class(p6.ClassDefinition).IsPropertyCalculated(info(i-1,"type"),prop) {
				// пока вычисляемые поля могут быть только последними
				// непонятно как их вытащить не открывая объект
				set info(i,"val")=..value
			}else {
				set info(i,"val")=$zobjclassmethod(info(i-1,"type"),prop_"GetStored",info(i-1,"val"))	
			}
		}else {
			set info(i,"val")=""
		}
		
	}
	
	set data=$G(info($O(info(""),-1),"val"))
	set propType=$G(info($O(info(""),-1),"type"))
	set propName=$G(info($O(info(""),-1),"name"))
	set fatherPropType=$G(info($O(info($O(info(""),-1)),-1),"type"))
	
	if propType="p6.dt.Date" {
		set data=##class(p6.dt.Date).LogicalToDisplay(##class(p6.dt.Date).DisplayToLogical(data))
	}elseif ##class(%Dictionary.CompiledProperty).%OpenId(fatherPropType_"||"_propName).Parameters.IsDefined("DISPLAYLIST") {
		set data=$zobjclassmethod(fatherPropType,propName_"LogicalToDisplay",data)
 	}elseif ##class(p6.ClassDefinition).IsClassPersistent(propType) {
		set data=$zobjclassmethod(propType,"GetDisplayValue",data)		
	}
	
	set ..value=data
	if data="" set data=" "
	
	&html<<div class="p6view">>
	set temp=$ZCVT(data,"O","HTML")
	if ..isParseURL {
		set num=($LENGTH(temp,"http://")-1)
		set alredy=0
		if num'=0 {
			for i=1:1:num {
				set tempWthSpac=$TR(temp,$C(13)," ")
				set tempWthSpac=$TR(tempWthSpac,$C(10)," ")
				set startStr=$PIECE(tempWthSpac,"http://",1,i+alredy)
				set endStr=$PIECE(tempWthSpac,"http://",i+alredy+1,$LENGTH(tempWthSpac,"http://"))
				set urlStr="http://"_$PIECE(endStr," ",1)
				set endStr2=$PIECE(endStr," ",2,$LENGTH(endStr," "))
					
				set startStr=$EXTRACT(temp,1,$LENGTH(startStr))
				set urlStr=$EXTRACT(temp,$LENGTH(startStr)+1,($LENGTH(startStr)+$LENGTH(urlStr)))
				set endStr2=$EXTRACT(temp,$LENGTH(startStr)+$LENGTH(urlStr)+1,$LENGTH(temp))
				
				set temp=startStr_"<A target=_blank href="""_urlStr_""">"_urlStr_"</A> "_endStr2
				set alredy=alredy+1
			}
		}
	}
	&html<#(##class(p6.Convert).Replace(temp,$c(13),"<br />"))#>
	&html<</div>>
	
	quit
}

}

