Class admin.SessionEventsWeb Extends %CSP.SessionEvents [ ClassType = "", Not ProcedureBlock ]
{

ClassMethod OnStartSession() As %Status
{
   
   try { s x=$system.License.PublicWebAppUser() } catch { /* log error */ }
   //kill ^a.Session2
	//s ^a.Session2(111) = $username
	set %session.Language="ru"
	//$$$QuitOnError(..UpdateUserAccountId())	
	
	quit $$$OK
}

ClassMethod UpdateUserAccountId() As %Status
{
	set username=$username
	set qUserAccountId=""
	&sql(select Id into :qUserAccountId from admin.UserAccount where Aka=:username)
	if SQLCODE set qUserAccountId=""
	set %session.Data("UserAccountId")=qUserAccountId
	quit $$$OK
}

}

