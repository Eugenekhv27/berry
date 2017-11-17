Class admin.LogObject Extends admin.Log [ ClassType = persistent, Not ProcedureBlock ]
{

/// Индекс для свойства Class
Index ClassIndex On Class;

/// Индекс для свойства ObjectId
Index ObjectIdIndex On ObjectId;

Property Class As %String(TRUNCATE = 1);

Property ObjectId As %String(TRUNCATE = 1);

Property Method As %String(TRUNCATE = 1);

Property CurrentState As %String(MAXLEN = 14000, TRUNCATE = 0);

Property Changes As %String [ Calculated, SqlComputeCode = {set {Changes}=##class(admin.LogObject).GetChanges({admin.LogObject.ID})}, SqlComputed ];

ClassMethod GetChanges(id As %String) As %String
{
	new last,current,res,i,objid
	set res = ""
	set last = ""
	set current = ""
	&sql(select ObjectId into :objid 
		from admin.LogObject 
		where Id=:id)
	&sql(select top 1 CurrentState into :last 
		from admin.LogObject 
		where ObjectId=:objid and ID<:id 
		order by Id desc)
	if SQLCODE set last = ""
	&sql(select CurrentState into :current 
		from admin.LogObject 
		where ObjectId=:objid and ID=:id)
	if SQLCODE set current = ""
	set length = $LENGTH(current, "<br>")
	for i=0:1:length {
		set piece = $Piece(current,"<br>",i)
		if '(last[piece) set res = res_piece_" "
	}
	quit res
}

/*ClassMethod GetCurStDelimiter() As %String
{
	quit "<br>"
}*/

/*ClassMethod IsCurStateLog(class As %Library.String = "") As %String
{
	xecute "set isCS=##class("_class_").%GetParameter(""LOGDETALISATIONWITHSTATE"")"
	quit isCS
}*/
/// [Previously private]
ClassMethod GetCurrentStateFor(class As %Library.String = "", id As %Library.String = "") As %String
{
	new rs,i,currentState,column,value,valueName,propertyType,query,rset
	set rs = ##class(%Library.ResultSet).%New("%DynamicQuery.SQL")
 	do rs.Prepare("select * from "_class_" where id="_id,0,"RUNTIME")
 	do rs.Execute("")
    do rs.Next()
    set currentState = ""
    set value = ""
    set propertyType = ""
    set valueName = ""
    for i=2:1:rs.GetColumnCount() //Skip Id
    {
	    set value = rs.GetData(i)
	    set valueName = rs.GetColumnName(i)
	    
	    
	    
	    if ($length(value)=0) {
			continue    
		}
	    
	    set column = ##class(p6.ClassDefinition).GetPropertyCaption(class, rs.GetColumnName(i))
	    set currentState = currentState_column_": "
	    
	    set propertyType = ##class(p6.ClassDefinition).GetPropertyType(class, valueName)
	    if propertyType["dtk" || (propertyType["ent") {
			set query = "select Aka from "_propertyType_" where id="_value
			set rset = ##class(%ResultSet.SQL).%Prepare(query, .err, "")
			while rset.%Next() {
				set currentState = currentState_rset.Aka_"["_value_"]" 
			}
			kill rset
	    } else {
		    if (valueName["Date") && (+value>0) {
			set value = ##class(p6.Date).LogicalToDisplay(value)
		}
	    
	    if value="1" {
		    set value = "Да"
	    }
	    elseif value="0" {
		    set value = "Нет"
	    }
	    
	    if valueName="TripStatusEng" {
			continue   
	    }
	    
	    	if valueName="TripStatus" {
		    	if value="FromStation" {
					set value = "Склад отпр"
		    	}
		    	elseif value="ToLoad" {
			    	set value = "К погрузке"
		    	}
		    	elseif value="Going" {
			    	set value = "В пути"
		    	}
		    	elseif value="CrossStation" {
			    	set value = "Склад ПрП"
		    	}
		    	elseif value="ToStation" {
			    	set value = "Склад получ"
		    	}
		    	elseif value="GiveToClient" {
			    	set value = "Выдан"
		    	}
	    	}
			set currentState = currentState_value
	    }
	    set currentState = currentState_"<br>"
    }
  	kill rs
  	quit currentState
}

/// Создание записи протокола по OREF
ClassMethod Put(object As %Library.String = "", method As %Library.String = "")
{
 if (object=$$$NULLOREF) do ..PutId("","",method)
 else  do ..PutId(object.%ClassName(1),object.%Id(),method)
 quit
}

/// Создание записи протокола по ID
ClassMethod PutId(class As %Library.String = "", id As %Library.String = "", method As %Library.String = "")
{
 new log
 set log = ..%New()
 set log.Class = class
 set log.ObjectId = id
 set log.CurrentState=""
 if (class]""){
	 //if (..IsCurStateLog(class))&&(id]"") set log.CurrentState=..GetCurrentStateFor(class,id)
	 if ##class(p6.ClassDefinition).GetParameter(class, "LogCurrentState") {
	 	set log.CurrentState=..GetCurrentStateFor(class, id)
	 }
 }
 set log.Method = method
 do log.Save()
 kill log
 quit
}

ClassMethod GetClassesLastId(aLogId As %String, ByRef aResult As %String) As %Status [ ProcedureBlock = 1 ]
{
   set i=$order(^admin.LogD(aLogId),-1)
   while i'="" {
	  set className=$li(^admin.LogD(i,"LogObject"),1) 
	  set classId=$li(^admin.LogD(i,"LogObject"),2) 
	  set method=$li(^admin.LogD(i,"LogObject"),3)
      if $get(aResult(className))<classId set aResult(className)=classId
	  set i=$order(^admin.LogD(i),-1)
   }
   quit $$$OK
}

ClassMethod GetObjectOwnerId(classname As %String, objectId As %String) As %String
{
	set user = ""
	&sql(select UserSys into :user from admin.LogObject 
				where Class=:classname and Method='N' and ObjectId=:objectId)
				
	quit user
}

ClassMethod GetObjectFirstEditorId(classname As %String, objectId As %String) As %String
{
	set user = ""
	set date = ""
	&sql(select UserSys, min(DtLog) into :user, :date
		 from admin.LogObject 
		 where Class=:classname and ObjectId=:objectId
		 group by ObjectId )
				
	quit user
}

Storage Default
{
<Data name="LogObjectDefaultData">
<Subscript>"LogObject"</Subscript>
<Value name="1">
<Value>Class</Value>
</Value>
<Value name="2">
<Value>ObjectId</Value>
</Value>
<Value name="3">
<Value>Method</Value>
</Value>
<Value name="4">
<Value>CurrentState</Value>
</Value>
</Data>
<DefaultData>LogObjectDefaultData</DefaultData>
<Property name="Class"/>
<Property name="Comment"/>
<Property name="CurrentState"/>
<Property name="DtLog"/>
<Property name="Method"/>
<Property name="ObjectId"/>
<Property name="Session"/>
<Property name="UserSys"/>
<Type>%Library.CacheStorage</Type>
}

}

