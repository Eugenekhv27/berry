/// Работа с СМС через сервис smsc.ru
Class p6.Sms Extends %RegisteredObject
{

// логин клиента

// Parameter SMSCLOGIN = "HookahLab";

// пароль или MD5-хеш пароля в нижнем регистре

// Parameter SMSCPASSWORD = 22110099;

/// использовать протокол HTTPS
Parameter SMSCHTTPS = 0;

/// использовать метод POST
Parameter SMSCPOST = 0;

/// "utf-8" "windows-1251"
Parameter SMSCCHARSET = "utf-8";

/// флаг отладки
Parameter SMSCDEBUG = 0;

/// 
/// Метод отправки SMS
/// 
/// обязательные параметры:
/// 
/// phones - список телефонов через запятую или точку с запятой
/// message - отправляемое сообщение
/// 
/// необязательные параметры:
/// 
/// translit - переводить или нет в транслит
/// time - необходимое время доставки в виде строки (DDMMYYhhmm, h1-h2, 0ts, +m)
/// id - идентификатор сообщения. Представляет собой 32-битное число в диапазоне от 1 до 2147483647.
/// format - формат сообщения (0 - обычное sms, 1 - flash-sms, 2 - wap-push, 3 - hlr, 4 - bin, 5 - bin-hex, 6 - ping-sms, 7 - mms, 8 - mail, 9 - call)
/// sender - имя отправителя (Sender ID). Для отключения Sender ID по умолчанию необходимо в качестве имени
/// передать пустую строку или точку.
/// query - строка дополнительных параметров, добавляемая в URL-запрос ("valid=01:00&maxsms=3")
/// 
/// возвращает массив (<id>, <количество sms>, <стоимость>, <баланс>) в случае успешной отправки
/// либо (<id>, -<код ошибки>) в случае ошибки
ClassMethod SendSms(accountId = 0, isCost = 0, phones As %String, message As %String, format As %Integer = 0, subj As %String = "", translit As %Integer = 0, time As %String = "", id As %Integer = 0, sender As %String = "", query As %String = "", returnMessage = "") As %String
{
	//if sender="" set sender="OOO VTK"
	//if format=8 set sender="info@vtkkhv.ru"
	set formats = $ListBuild("flash=1", "push=1", "hlr=1", "bin=1", "bin=2", "ping=1", "mms=1", "mail=1", "call=1")
		set str=""
	for i=1:50:$Length(phones,",") {
		
		set phonesPart = $p(phones,",",i,i+49)
		set m = ..SmscSendCmd(accountId,"send", "cost=3&phones=" _ phonesPart 
			_"&mes=" _message _ "&id=" _ id _ "&translit=" _ translit _ $select(format > 0: "&" _$List(formats,format),1 : "") 
			_$select((sender]""):"&sender=" _ sender ,1: "") _ $select(time] "":"&time=" _ time , 1:"") 
			_$select(query] "":"&" _ query,1: "")_$select(subj] "":"&subj=" _ subj,1: "")
			_$select(isCost:"&cost=1",1:""))
		set ^a.sms.error($h,i)=m
		set ^a.sms.phonesPart($h,i)=phonesPart
		set str = str_"/n Отправлено: "_ $Piece(m,",",2) _ " смс, потрачено:"_$Piece(m,",",3)_ " руб. На балансе осталось:"_$Piece(m,",",4)_ " руб."
	}
		// (id, cnt, cost, balance) или (id, -error)
	
	if returnMessage]"" return returnMessage

	return str
}

// 

// Метод вызова запроса. Формирует URL и делает 3 попытки чтения

ClassMethod SmscSendCmd(accountId = 0, cmd, arg) As %String [ Private ]
{
	
	set login = ##class(ent.Shop).smscLoginGetStored(accountId)
	set password = ##class(ent.Shop).smscPasswordGetStored(accountId)
	//set ^a.sms($H,"cmd")=cmd
	//set ^a.sms($H,"arg")=arg
		set cnt = 0
		
		//set appSet = ##class(admin.AppSet).GetCurrent()

		set arg = "login=" _login _ "&psw=" _ password _ "&fmt=1&charset=" _ ..#SMSCCHARSET _ "&" _ arg
		
		Set httprequest=##class(%Net.HttpRequest).%New()
		Do httprequest.SetHeader("Content-Type","application/x-www-form-urlencoded")
		
		set result = ""
		while ((result = "") && (cnt < 4))	{
			
			if (cnt > 0) hang (2 + cnt)
			Set httprequest.Server="smsc.ru"
			if (cnt > 2) {
				Set httprequest.Server="www2.smsc.ru"
	
			}

			//try {
				//Do httprequest.Get("/sys/" _ cmd _ ".php?"_arg)
				Do httprequest.Post("/sys/" _ cmd _ ".php?"_arg)
				if $isobject(httprequest.HttpResponse.Data) {
					set result = httprequest.HttpResponse.Data.Read(httprequest.HttpResponse.ContentLength)	
					
				} else {
					set result = httprequest.HttpResponse.Data	
				}

				
			//}
			//catch  {
			//}

			
			set cnt = cnt + 1
			do httprequest.Reset()
		}
		
 	quit result
}

/*
/// Метод получения баланса
ClassMethod GetBalance() As %String
{
	 set m = ..SmscSendCmd("balance", "") // (balance) или (0, -error)
	 if (m["0,-") {
		quit ""	 
	 }
	 quit "Остаток на счете "_m_" руб."
}
*/

// 

// без параметров

// 

// возвращает баланс в виде строки или пустую строку в случае ошибки

/*
	CString get_balance(void)
	{
		vector<CString> m = _smsc_send_cmd("balance", ""); // (balance) или (0, -error)

		if (SMSC_DEBUG)
			if (m.size() == 1)
				_print_debug("Сумма на счете: " + m[0]);
			else
				_print_debug("Ошибка №" + m[1].Mid(1, 1));

		return m.size() == 1 ? m[0] : "";
	};
	
	*/

/*
	



	// Метод получения стоимости SMS
	//
	// обязательные параметры:
	//
	// phones - список телефонов через запятую или точку с запятой
	// message - отправляемое сообщение
	//
	// необязательные параметры:
	//
	// translit - переводить или нет в транслит
	// format - формат сообщения (0 - обычное sms, 1 - flash-sms, 2 - wap-push, 3 - hlr, 4 - bin, 5 - bin-hex, 6 - ping-sms, 7 - mms, 8 - mail, 9 - call)
	// sender - имя отправителя (Sender ID)
	// query - строка дополнительных параметров, добавляемая в URL-запрос ("list=79999999999:Ваш пароль: 123\n78888888888:Ваш пароль: 456")
	//
	// возвращает массив (<стоимость>, <количество sms>) либо (0, -<код ошибки>) в случае ошибки

	vector<CString> get_sms_cost(CString phones, CString message, int translit = 0, int format = 0, CString sender = "", CString query = "")
	{
		CString tt;

		CString formats[9] = {"flash=1", "push=1", "hlr=1", "bin=1", "bin=2", "ping=1", "mms=1", "mail=1", "call=1"};
		tt.Format((CString)"%i", translit);

		vector<CString> m = _smsc_send_cmd("send", "cost=1&phones=" + (CString)_urlencode(phones) +
			"&mes=" + (CString)_urlencode(message) + "&translit=" + tt + (format > 0 ? "&" + formats[format-1] : "") +
			(sender != "" ? "&sender=" + (CString)_urlencode(sender) : "") + (query != "" ? "&" + query : ""));

		// (cost, cnt) или (0, -error)

		if (SMSC_DEBUG)
			if (m[1] > "0")
				_print_debug("Стоимость рассылки: " + m[0] + ". Всего SMS: " + m[1]);
			else
				_print_debug("Ошибка №" + m[1].Mid(1, 1));

		return m;
	};

	// Метод проверки статуса отправленного SMS или HLR-запроса
	//
	// id - ID cообщения
	// phone - номер телефона
	//
	// возвращает массив:
	// для отправленного SMS (<статус>, <время изменения>, <код ошибки sms>)
	// для HLR-запроса (<статус>, <время изменения>, <код ошибки sms>, <код IMSI SIM-карты>, <номер сервис-центра>, <код страны регистрации>,
	// <код оператора абонента>, <название страны регистрации>, <название оператора абонента>, <название роуминговой страны>,
	// <название роумингового оператора>)
	//
	// При all = 1 дополнительно возвращаются элементы в конце массива:
	// (<время отправки>, <номер телефона>, <стоимость>, <sender id>, <название статуса>, <текст сообщения>)
	//
	// либо (0, -<код ошибки>) в случае ошибки

	vector<CString> get_status(int id, CString phone, int all = 0)
	{
		CString ans, ir, tr;
		int i;

		ir.Format((CString)"%i", id);
		tr.Format((CString)"%i", all);

		vector<CString> m = _smsc_send_cmd("status", "phone=" + (CString)_urlencode(phone) + "&id=" + ir + (all > 0 ? "&all=" + tr : ""));

		// (status, time, err) или (0, -error)

		if (SMSC_DEBUG)
			if ((m[1] != "") && (m[1] >= "0"))
			{
				time_t tm = _ttoi(m[1]);

				struct tm ltm;
				TCHAR st[100] = {0};

				localtime_s(&ltm, &tm);
				_stprintf_s(st, 100, (CString)"%2d.%2d.%d %2d:%2d:%2d", ltm.tm_mday, (ltm.tm_mon) + 1, (ltm.tm_year) + 1900, ltm.tm_hour, ltm.tm_min, ltm.tm_sec);

				_print_debug( "Статус SMS = " + m[0] + ", время изменения статуса - " + st);
			}
			else
				_print_debug("Ошибка №" + m[1].Mid(1, 1));

		if (all == 1 && m.size() > 9 && (m.size() < 14 || m[14] != "HLR"))
		{
			ans = m[0];

			for (i = 1; i < (int)m.size(); i++)
				ans += "," + m[i];

			m.clear();
			int cp = 0;

			for (i = 0; i < 8; i++)
				m.push_back(ans.Tokenize((CString)",", cp));
			m.push_back(ans.Mid(cp));
		}

		return m;
	};

	// Метод получения баланса
	//
	// без параметров
	//
	// возвращает баланс в виде строки или пустую строку в случае ошибки

	CString get_balance(void)
	{
		vector<CString> m = _smsc_send_cmd("balance", ""); // (balance) или (0, -error)

		if (SMSC_DEBUG)
			if (m.size() == 1)
				_print_debug("Сумма на счете: " + m[0]);
			else
				_print_debug("Ошибка №" + m[1].Mid(1, 1));

		return m.size() == 1 ? m[0] : "";
	};

private:
	// Приватные методы класса SMSС
	//
	// Метод вызова запроса. Формирует URL и делает 3 попытки чтения

	vector<CString> _smsc_send_cmd(CString cmd, CString arg)
	{
		vector<CString> m;
		int cnt = 0;

		arg = "login=" + (CString)_urlencode(SMSC_LOGIN) + "&psw=" + (CString)_urlencode(SMSC_PASSWORD) + "&fmt=1&charset=" + SMSC_CHARSET + "&" + arg;
		CString url = (SMSC_HTTPS ? "https" : "http") + (CString)"://smsc.ru/sys/" + cmd + ".php";

		CString sr, ot, res;    
		INTERNET_PORT pt;
		DWORD st;
		char sz[1024] = {0};

		CInternetSession ses((CString)"Visual C++", PRE_CONFIG_INTERNET_ACCESS);
		CHttpConnection *ds;

		AfxParseURL(url + '?' + arg, st, sr, ot, pt);

		ds = ses.GetHttpConnection(sr, NULL, pt);

		do
		{
			if (cnt > 0) Sleep(2000 + 1000 * cnt);

			if (cnt == 2) {
				url.Replace((CString)"://smsc.ru/", (CString)"://www2.smsc.ru/");

				AfxParseURL(url + '?' + arg, st, sr, ot, pt);
				ds = ses.GetHttpConnection(sr, NULL, pt);
			}

			CHttpFile *pc;

			try {
				if (SMSC_POST || arg.GetLength() > 2000)
				{
					pc = ds->OpenRequest(0, "/sys/" + cmd + ".php", NULL, 1, NULL, NULL, SMSC_HTTPS ? INTERNET_FLAG_SECURE : INTERNET_FLAG_EXISTING_CONNECT);
					pc->SendRequest((CString)"Content-Type: application/x-www-form-urlencoded", (LPVOID)(LPCSTR)(CStringA)arg, arg.GetLength());
				}
				else
				{
					pc = ds->OpenRequest(1, ot, NULL, 1, NULL, NULL, SMSC_HTTPS ? INTERNET_FLAG_SECURE : INTERNET_FLAG_EXISTING_CONNECT);
					pc->SendRequest();
				}

				pc->Read(sz, 1024);
			}
			catch (CInternetException* e) {
			}

			res = sz;

			cnt++;
			pc->Close();
		}
		while ((res == "") && (cnt != 4));

		if (res == "")
		{
			if (SMSC_DEBUG)
				_print_debug("Ошибка чтения адреса: " + url + "?" + arg);

			res = ","; // фиктивный ответ
		}

		ds->Close();
		ses.Close();

		return _explode(res);
	};

	// кодирование параметра в http-запросе

	CStringA _urlencode(CString s_in)
	{
		#if defined _UNICODE || defined UNICODE
			const WCHAR *pt_utf16 = s_in;
			const size_t cch_utf16m = INT_MAX - 1;
			size_t cch_utf16;
		
			::StringCchLengthW(pt_utf16, cch_utf16m, &cch_utf16);

			++cch_utf16;

			int cb_utf8 = ::WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, pt_utf16, static_cast<int>(cch_utf16), NULL, 0, NULL, NULL);

			CStringA s_utf8;
			CHAR *pt_utf8 = s_utf8.GetBuffer(cb_utf8);

			::WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, pt_utf16, static_cast<int>(cch_utf16), pt_utf8, cb_utf8, NULL, NULL);

			s_utf8.ReleaseBuffer();

			return _encode(s_utf8);
		#else
			return _encode(s_in);
		#endif
	};

	CStringA _encode(CStringA s_in)
	{
		CStringA s_out;

		for (int i = 0; i < s_in.GetLength(); i++)
		{
			CHAR ch = s_in[i];

			if ((ch >= '0' && ch <= '9') || (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z'))
				s_out.AppendChar(ch);
	        else
		    {
			    BYTE ccv = static_cast<BYTE>(ch);

	            CHAR eb[4];
		        sprintf_s(eb, sizeof(eb), "%%%02X", ccv);

			    s_out.Append(eb);
			}
		}

		return s_out;
	};

	// вывод отладочной информации

	void _print_debug(CString str)
	{
		MessageBox(NULL, str, NULL, MB_OK);
	};

	// разделение строки, возвращаемой сервером, на массив строк

	vector<CString> _explode(CString str)
	{
		int cp = 0;
		vector<CString> m;

		do
		{
			m.push_back(str.Tokenize((CString)",", cp));
		}
		while (m.back() != "");

		m.pop_back();

		return m;
	};
};

// Examples:
// SMSC *sms = new SMSC();
// СString balance;
// vector<CString> ret;
//
// ret = sms->send_sms("79999999999", "Ваш пароль: 123", 1);
// ret = sms->send_sms("79999999999", "http://smsc.ru\nSMSC.RU", 0, "", 0, 0, "", "maxsms=3");
// ret = sms->send_sms("79999999999", "0605040B8423F0DC0601AE02056A0045C60C036D79736974652E72750001036D7973697465000101", 0, "", 0, 5);
// ret = sms->send_sms("79999999999", "", 0, "", 0, 3);
// ret = sms->get_sms_cost("79999999999", "Вы успешно зарегистрированы!");
// ret = sms->get_status(12345, "79999999999");
// balance = sms->get_balance();
//
// delete sms;

*/
}

