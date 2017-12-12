Class admin.Email Extends %RegisteredObject
{

Property smtpserv As %String(TRUNCATE = 1);

Property FromName As %String(TRUNCATE = 1);

Property ToEmail As %String(TRUNCATE = 1);

Property Subject As %String(TRUNCATE = 1);

ClassMethod SendEmailToBoss(msg, subject) As %Status
{
	
	$$$QuitOnError(..SendEmail("Elena@dtk-m.ru",msg,subject))
	$$$QuitOnError(..SendEmail("vassil@progrepublic.ru",msg,subject))
	/// cmc
	$$$QuitOnError(..SendEmail("vassil@send.smsc.ru",msg,"+79625020828"))
	$$$QuitOnError(..SendEmail("vassil@send.smsc.ru",msg,"+79852205138"))
	
	quit $$$OK
}

ClassMethod SendEmail(ToEmail = "vassil@progrepublic.ru", TextData = "Пусто", subject = "") As %Status
{
	set smtpserv  = "smtp.mail.ru" //"smtp.gmail.com"

    set FromName  = "progrepublic@mail.ru"  //"base-dtk@progrepublic.ru"

    	
	if TextData = "" set TextData = "Nothing"
	// Create an SMTP object and connect to a server
 	
 	Set Mailer = ##class(%Net.SMTP).%New()
 	set Mailer.SSLConfiguration="ssl"
 	//set Mailer.UseSTARTTLS=1
 	set Mailer.port=465
 	// Fill in the name of your mail server
	Set Mailer.smtpserver = smtpserv
	set auth=##class(%Net.Authenticator).%New() ; use default authentication list
	set auth.UserName= "progrepublic@mail.ru"   //"base-dtk@progrepublic.ru"
	set auth.Password= "5F077it"   //"dtkdtkdtk"
	set Mailer.authenticator=auth
	Set Mailer.AuthFrom=auth.UserName
 	// Create a Message object and fill in From, To, Subject
	Set Msg = ##class(%Net.MailMessage).%New()
 	Set Msg.IsHTML="1"
	Set Msg.From=FromName
	if $LISTVALID(ToEmail)=1 {
		for i=1:1:$ListLength(ToEmail) {
		 do Msg.To.Insert($List(ToEmail,i))
		}
	} else {
		$$$QuitOnError(Msg.To.Insert(ToEmail))	
	}
	Set Msg.Subject = subject
	$$$QuitOnError(Msg.TextData.Write(TextData))
 	$$$QuitOnError(Mailer.Send(Msg))
 	kill Msg
	kill Mailer
	quit $$$OK
}

}

