/// Отправка СМС и голосовых сообщений
Class doc.SendSms Extends p6.Integrity
{

/// Отправить SMS
Property SendSms As p6.dt.Boolean [ InitialExpression = 0 ];

/// Отправить голосовое сообщение
Property SendVoice As p6.dt.Boolean [ InitialExpression = 0 ];

/// Текст сообщения
Property Message As %String(MAXLEN = 2000);

/// Телефон для тестирования сообщения
Property TestTel As %String;

Method Run(isTest = 1) As %String
{
	if (..SendSms=0) && (..SendVoice=0) {
		quit "Не выбран тип отправляемого сообщения"
	}
	
	if isTest {
		if ..SendSms {
			set result = ##class(p6.Sms).SendSms(..TestTel,..Message,0)
		}
		if ..SendVoice {
			set result = ##class(p6.Sms).SendSms(..TestTel,..Message,9)
		}
		quit result
	}
	
	
	//set whereClauseSmsTel="(SmsTel is not null)"_orgTypeSQL_""
	
	set (qSmsTels,qEmails)=""
	set err=$$$OK
	SET myquery="select List(Aka) from ent.Buyer "
  	SET rset=##class(%ResultSet.SQL).%Prepare(myquery,.err,"")
    WHILE rset.%Next() {
    	set qSmsTels = rset.%GetData(1)
    }
  	  
	set err=$$$OK
	/*
	SET myquery="select List(Email) from ent.Org where "_whereClauseEmail
  	SET rset=##class(%ResultSet.SQL).%Prepare(myquery,.err,"")
    WHILE rset.%Next() {
    	set qEmails = rset.%GetData(1)
    }
    
    */
	set result = qSmsTels
	if ..SendSms {
		set result = ##class(p6.Sms).SendSms(qSmsTels,..Message,0)
		set ^a.sms3 = qSmsTels
	}
	if ..SendVoice {
		set result = ##class(p6.Sms).SendSms(qSmsTels,..Message,9)
	}
	
	quit result
}

}

