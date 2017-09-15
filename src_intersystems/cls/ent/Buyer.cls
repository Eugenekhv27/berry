/// Покупатель
Class ent.Buyer Extends p6.Integrity [ ClassType = persistent ]
{

Index SuperBuyerIndex On SuperBuyer;

/// Номер телефона
Property Aka As %String(PATTERN = "1""+7""1""(""3N1"")""7N");

/// Этот номер уже зарегистрирован
Index AkaIndex On Aka [ Unique ];

/// Имя
Property Name As %String(MAXLEN = 200);

/// Коментарий
Property Comment As %String(MAXLEN = 2000);

/// Покупатель, который привлек
Relationship SuperBuyer As ent.Buyer [ Cardinality = one, Inverse = BottomBuyers ];

/// Покупатели, которых пригласил данный покупатель
Relationship BottomBuyers As ent.Buyer [ Cardinality = many, Inverse = SuperBuyer ];

Relationship BonusOperations As doc.BonusOperation [ Cardinality = many, Inverse = Buyer ];

/// Магазин
Relationship Shop As ent.Shop(JSONIGNORE = 1) [ Cardinality = one, Inverse = Buyer ];

Property RegDate As p6.dt.Date [ SqlComputeCode = {set {RegDate} = +$H }, SqlComputed, SqlComputeOnChange = %%INSERT ];

/// Бонусов на счете
Property BonusSum As p6.dt.Float [ Calculated, SqlComputeCode = {
		new balance,buyerId
		set buyerId = {%%ID}
		&sql(select sum(PointsSum) into :balance from doc.BonusOperation where Buyer=:buyerId)
		set {BonusSum}=balance}, SqlComputed ];

ClassMethod SendHelloBuyer(tel = "") As %Status
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
	$$$QuitOnError(##class(p6.Sms).SendSms(tel,message))	
	quit $$$OK
}

/// разрешаем сохранять объект только через метод Save()
Method %OnBeforeSave(Insert As p6.dt.Boolean) As %Status [ Private, PublicList = (NewObject, canSave) ]
{
   $$$QuitOnError(##super(Insert))	
  if Insert {
	do ..SendHelloBuyer(..Aka)
  }
  quit $$$OK
}

/// получить Id по номеру телефона
/// и создать новый если еще нет такой записи
ClassMethod GetBuyerIdByAka(aAka, prentBuyerId = "", ByRef sc = {$$$OK}, fromTel = "", isCreate = {$$$YES}) As %String
{
	if (fromTel="+7null") set fromTel=""
	set result=""
	set aAka = $tr(aAka," ","")
	set aAka = $tr(aAka,"-","")
	set ^a.resttest($h,"fromTel - GetBuyerIdByAka")=fromTel
	&sql(select Id into :result from ent.Buyer where Aka[:aAka)	
	if SQLCODE set result=""
	if ('isCreate) && (result="") {
		set sc = $$$ERROR(1000,"Данного номера нет в базе")
		quit result
	}
	
	if result="" {
		set obj = ..%New()
		set obj.Aka = aAka
		
		/// Кто привлек, по номеру телефона (из 1С)
		if (fromTel]"") {
			&sql(select Id into :prentBuyerId from ent.Buyer where Aka[:fromTel)	
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
		set sc = $$$ERROR(1000,"Этот номер уже есть в базе")
	}
	
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
</Data>
<DataLocation>^ent.BuyerD</DataLocation>
<DefaultData>BuyerDefaultData</DefaultData>
<IdLocation>^ent.BuyerD</IdLocation>
<IndexLocation>^ent.BuyerI</IndexLocation>
<StreamLocation>^ent.BuyerS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

