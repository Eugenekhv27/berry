/// Покупатель
Class ent.Buyer Extends p6.Integrity [ ClassType = persistent ]
{

Index SuperBuyerIndex On SuperBuyer;

/// Номер телефона
Property Aka As %String(PATTERN = "1""+7""1""(""3N1"")""7N");

/// Этот номер уже зарегистрирован
Index AkaIndex On (Shop, Aka) [ Unique ];

/// Имя
Property Name As %String(MAXLEN = 200);

/// Дата рождения
Property BirthDate As p6.dt.Date;

Property age As %String [ Calculated, SqlComputeCode = {set {age} = ##class(ent.Buyer).GetAge({Id}) }, SqlComputed ];

/// Пол
Property Sex As %String(VALUELIST = " Мужской Женский Неизвестно");

/// Коментарий
Property Comment As %String(MAXLEN = 2000);

/// Покупатель, который привлек
Relationship SuperBuyer As ent.Buyer [ Cardinality = one, Inverse = BottomBuyers ];

/// Покупатели, которых пригласил данный покупатель
Relationship BottomBuyers As ent.Buyer [ Cardinality = many, Inverse = SuperBuyer ];

Relationship BonusOperations As doc.BonusOperation [ Cardinality = many, Inverse = Buyer ];

/// Магазин
Relationship Shop As ent.Shop(JSONIGNORE = 1) [ Cardinality = one, Inverse = Buyer, Required ];

Property RegDate As p6.dt.Date [ SqlComputeCode = {set {RegDate} = +$H }, SqlComputed, SqlComputeOnChange = %%INSERT ];

/// Код доступа для входа в ЛК
Property accessCode As %String;

/// Бонусов на счете
Property BonusSum As p6.dt.Float [ Calculated, SqlComputeCode = {
		new balance,buyerId
		set buyerId = {%%ID}
		&sql(select sum(PointsSum) into :balance from doc.BonusOperation where Buyer=:buyerId)
		set {BonusSum}=balance}, SqlComputed ];

/// Город
Property city As ent.City;

/// Город строкой (для заполнения через dadata.ru)
Property cityString As %String(MAXLEN = 200);

/// Электронная почта
Property email As %String(MAXLEN = 200);

/// Потрачено рублей
Property payRubSum As p6.dt.Float [ Calculated, SqlComputeCode = {
		new result,buyerId
		set buyerId = {%%ID}
		&sql(select sum(RubSum) into :result from doc.BonusOperation where Buyer=:buyerId)
		set {PayRubSum}=result}, SqlComputed ];

/// Потрачено бонусов
Property payBonus As p6.dt.Float [ Calculated, SqlComputeCode = {
		new result,buyerId
		set buyerId = {%%ID}
		&sql(select sum(MinusPointsSum) into :result from doc.BonusOperation where Buyer=:buyerId)
		set {payBonus}=result}, SqlComputed ];

/// Сколько человек привлек
Property attractedCount As %Integer [ Calculated, SqlComputeCode = {
		new result,buyerId
		set buyerId = {%%ID}
		&sql(select count(Id) into :result from ent.Buyer where SuperBuyer=:buyerId)
		set {attractedCount}=result}, SqlComputed ];

/// Группа ABC
Property abcGroup As %String [ Calculated, SqlComputeCode = {
		new result,buyerId
		set result = ""
		set buyerId = {%%ID}
		&sql(select top 1 groupName into :result from ent.BuyerAbcGroup where buyer=:buyerId order by onDate desc)
		set {abcGroup}=result}, SqlComputed ];

ClassMethod SendHelloBuyer(tel = "", accaountId = 0) As %Status
{
	//if '(($e(tel)="8") || ($e(tel,1,2)="+7")) {
	//	set tel = "+7"_tel
	//}
	
	if $system.INetInfo.LocalHostName()="1CloudWinSe-001" {
		set servername = "bonus.vapeko.ru"
	} else {
		set servername = "localhost:57773"
	}
	set message = "Спасибо за регистрацию! Проверить бонусы www.vapeko.ru"
	
	//set message = "С каждой покупки Вам начисляются бонусы. Узнавайте на сайте www.vapeko.ru сколько вы уже накопили!"	
	/*
	set message = "Вы подключены к бонусной программе VAPE K.O. "
		_"Баллы будут начисляются с каждой вашей покупки. "
		_"И дополнительные баллы с покупок друзей, которых вы подключите. "
		_"Перейдите по ссылке и добавьте друзей. Там же смотрите накопленные баллы:"
		_" http://"_servername_"/csp/bc/main.csp?acc="_$system.Encryption.Base32Encode(tel,1)
	*/	
	$$$QuitOnError(##class(p6.Sms).SendSms(accaountId,,tel,message))	
	quit $$$OK
}

Method %OnBeforeSave(Insert As p6.dt.Boolean) As %Status [ Private, PublicList = (NewObject, canSave) ]
{
  $$$QuitOnError(##super(Insert))	
  if Insert {
	if ..Shop]"" {
		set accaountId = ..Shop.%Id()	
	} else {
		set accaountId = 0	
	} 
	do ..SendHelloBuyer(..Aka,accaountId)
  }
  
  quit $$$OK
}

/// This callback method is invoked when the current object is added to the SaveSet,
/// either because %Save() was invoked on this object or on an object that references this object.
/// %OnAddToSaveSet can modify the current object. It can also add other objects to the current
/// SaveSet by invoking %AddToSaveSet or remove objects by calling %RemoveFromSaveSet.
/// 
/// <P>If this method returns an error status then %Save() will fail and the transaction
/// will be rolled back.
Method %OnAddToSaveSet(depth As %Integer = 3, insert As %Integer = 0, callcount As %Integer = 0) As %Status [ Private, ServerOnly = 1 ]
{
 	if ..cityString]"" {
		set ..city = ##class(ent.City).GetByAka(..Shop,..cityString)
	
  	}
	Quit $$$OK
}

/// получить Id по номеру телефона
/// и создать новый если еще нет такой записи
ClassMethod GetBuyerIdByAka(aAka, prentBuyerId = "", ByRef sc = {$$$OK}, fromTel = "", isCreate = {$$$YES}, accountId = "") As %String
{
	if ($p(aAka,"(",1)="8") || ($p(aAka,"(",1)="7") || ($p(aAka,"(",1)="") {
		set $p(aAka,"(",1) = "+7"
 	}
	if (fromTel="+7null") set fromTel=""
	set result=""
	set aAka = $tr(aAka," ","")
	set aAka = $tr(aAka,"-","")
	//set ^a.resttest($h,"fromTel - GetBuyerIdByAka")=fromTel
	&sql(select Id into :result from ent.Buyer where Aka[:aAka and Shop=:accountId)	
	if SQLCODE set result=""
	if ('isCreate) && (result="") {
		set sc = $$$ERROR(10000,"Данного номера нет в базе")
		quit result
	}
	
	if result="" {
		set obj = ..%New()
		set obj.Aka = aAka
		set obj.Shop = ##class(ent.Shop).%OpenId(accountId)
		
		/// Кто привлек, по номеру телефона (из 1С)
		if (fromTel]"") {
			&sql(select Id into :prentBuyerId from ent.Buyer where Aka[:fromTel and Shop=:accountId)	
			if SQLCODE set prentBuyerId=""
		}
		/// Кто привлек, по ID 
		if prentBuyerId]"" {
			set obj.SuperBuyer = ##class(ent.Buyer).%OpenId(prentBuyerId)	
			set obj.Comment = "Привлек "_fromTel
		}
		set sc = obj.Save()
		if $$$ISOK(sc) {
			set result = obj.%Id()	
		}	
		
	} else {
		set sc = $$$ERROR(10000,"Этот номер уже есть в базе")
	}
	
	quit result
}

ClassMethod GetForGrid(query = "", accountId = "", citeriaObject = {{}}) As %Status
{
 //	kill ^a.sql
	//set ^a.citeriaObject = citeriaObject.%ToJSON()

    set st = $$$OK
    set sql = "select Id as id,nvl(Name,'') as name,Aka as phone, age,Comment as comment,(select sum(PointsSum) from doc.BonusOperation where Buyer=b.Id) as balance,"
    	_" (select top 1 guestLevel->name from ent.BuyerLevel where Buyer=b.Id order by onDate desc) as guestLevel,"
    	_" (select top 1 groupName from ent.BuyerAbcGroup where Buyer=b.Id order by onDate desc) as abcGroup,"
    	_" Sex as sex"
    	_" from ent.Buyer b"
    	_ " where Shop="_accountId 
    	
    if (citeriaObject.beginRegDate]"") {
	 	set beginRegDate = ##class(p6.Date).DisplayToLogical(citeriaObject.beginRegDate)
	 	set beginRegDate = $ZD(beginRegDate,3)
	 	set sql = sql _" and RegDate>='"_beginRegDate_"'"
    }
    if (citeriaObject.endRegDate]"") {
	 	set beginRegDate = ##class(p6.Date).DisplayToLogical(citeriaObject.endRegDate)
	 	set beginRegDate = $ZD(beginRegDate,3)
	 	set sql = sql _" and RegDate<='"_beginRegDate_"'"
    }
    if (citeriaObject.beginBonusSum]"") {
	 	set sql = sql _" and BonusSum>="_citeriaObject.beginBonusSum
    }
    if (citeriaObject.endBonusSum]"") {
	 	set sql = sql _" and BonusSum<="_citeriaObject.endBonusSum
    }
    if (citeriaObject.withOnePurchase) { // с одной покупкой
	    set sql = sql _" and ((select count(Id) from doc.BonusOperation where Buyer = b.Id)=1)"
    }
    if (citeriaObject.moreOnePurchase) { // больше одной покупки
	    set sql = sql _" and ((select count(Id) from doc.BonusOperation where Buyer = b.Id)>1)"
    }
    if (citeriaObject.abcGroup]"") { // Группа ABC
	    set sql = sql _" and (abcGroup = '"_citeriaObject.abcGroup_"')"
    }
    if (citeriaObject.withAttractBuyers=1) { // Есть привлеченные
	    set sql = sql _" and (Id in (select SuperBuyer from ent.Buyer))"
    }
    if (citeriaObject.sex]"") { // Пол
    	set aSex = $zconvert(citeriaObject.sex,"I","UTF8")
    	if aSex="Неизвестно" {
	    	set sql = sql _"and ((Sex is null) or (Sex = '"_aSex_"'))"
    	} else {
	    	set sql = sql _" and (Sex = '"_aSex_"')"
    	}
    }
    if (citeriaObject.tel]"") { // Номер телефона
	    set sql = sql _" and (Aka = '"_citeriaObject.tel_"')"
    }
    if (citeriaObject.daysNotPurchases]"") { // Дней не было покупок
    	set onDate = $zd(+$H-citeriaObject.daysNotPurchases,3)
	    set sql = sql _" and ( Id not in (select Buyer from doc.BonusOperation where DocDate > '"_onDate_"' and Buyer is not null))"
    }	
    if query]"" {
	 set sql = sql _" and "_query  
    }
	set sql = sql _ " order by Aka"
	set ^a.sql = sql
    // set ^a.sql(1) = citeriaObject.abcGroup
    do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,sql,,1000)
    quit st
}

ClassMethod GetAge(Id) As %String
{
	set result=""
	set bithDate = ##class(ent.Buyer).BirthDateGetStored(Id)
	if (bithDate]"") set result = $p(+$H-bithDate/365,".",1)
	quit result
}

Storage Default
{
<Data name="BuyerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Aka</Value>
</Value>
<Value name="3">
<Value>SuperBuyer</Value>
</Value>
<Value name="4">
<Value>Comment</Value>
</Value>
<Value name="5">
<Value>Name</Value>
</Value>
<Value name="6">
<Value>Shop</Value>
</Value>
<Value name="7">
<Value>RegDate</Value>
</Value>
<Value name="8">
<Value>BirthDate</Value>
</Value>
<Value name="9">
<Value>Sex</Value>
</Value>
<Value name="10">
<Value>city</Value>
</Value>
<Value name="11">
<Value>accessCode</Value>
</Value>
<Value name="12">
<Value>cityString</Value>
</Value>
<Value name="13">
<Value>email</Value>
</Value>
</Data>
<DataLocation>^ent.BuyerD</DataLocation>
<DefaultData>BuyerDefaultData</DefaultData>
<IdLocation>^ent.BuyerD</IdLocation>
<IndexLocation>^ent.BuyerI</IndexLocation>
<StreamLocation>^ent.BuyerS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

