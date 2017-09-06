import 'rxjs/add/operator/toPromise';
import 'rxjs/add/operator/map';
import 'rxjs/add/operator/catch';
import 'rxjs/add/observable/throw';
import { Injectable } from '@angular/core';
import { Http, Response, Headers, RequestOptionsArgs  } from '@angular/http';
import { Observable } from 'rxjs/Observable';

import { SelectItem } from 'primeng/primeng';

@Injectable()
export class DataService {
  private restServerUrl: string;

  constructor(private http: Http) {
    // Подключение пока к тесовой базе base.progrepublic.ru/csp/bonusclubrest2/...
    this.restServerUrl = 'base.progrepublic.ru';
  }

  private getRequestOptionsArgs(): RequestOptionsArgs {
    const headers = new Headers();
    headers.append('Content-Type', 'application/json;charset=utf-8');
    headers.append('Authorization', 'Basic ' + localStorage.getItem('loginpassword'));7

    return { headers };
  }

  private getFullUrl(query = '') {
    return 'http://' + this.restServerUrl +
      '/csp/bonusclubrest2/' + localStorage.getItem('accountEncrypt') +
      '/' + encodeURIComponent(query).replace(new RegExp('%', 'g'), '~');
  }

  getGridData(className: string, query: string = '', accountEncryptParam = '') {
    let accountEncrypt: any; // Шифрованный индефикатор аккаунта
    if (accountEncryptParam !== '') {
      accountEncrypt = accountEncryptParam;
    } else {
      accountEncrypt = localStorage.getItem('accountEncrypt');
    }
    const auth = localStorage.getItem('loginpassword');
    const headers = new Headers({ Authorization: 'Basic ' + auth });
    const queryToUrl = encodeURIComponent(query).replace(new RegExp('%', 'g'), '~');
    return this.http.get(
      'http://' + this.restServerUrl +
      '/csp/bonusclubrest2/' + accountEncrypt +
      '/grid/' + className + '/' + queryToUrl,
      { headers }
    );
  }

  akaToPhone(o: any) {
    o.phone = o.Aka;
    delete o.Aka;
    return o;
  }

  getParticipantsList() {
    return this.getGridData('ent.Buyer')
      .map((resp: Response) => {
        return resp.json().children.map(this.akaToPhone);
      });
  }

  getObjectData(className: string, ID: string, phone?: string) {
    const accountEncrypt = localStorage.getItem('accountEncrypt');

    const akaToUrl = encodeURIComponent(phone).replace(new RegExp('%', 'g'), '~');
    const auth = localStorage.getItem('loginpassword');
    const headers = new Headers({ Authorization: 'Basic ' + auth });
    return this.http.get(
      'http://' + this.restServerUrl +
      '/csp/bonusclubrest2/' + accountEncrypt +
      '/getObject/' + className + '/' + ID + '/' + akaToUrl,
      { headers }
    );
  }

  saveObject(className: string, obj: any) {
    const body = JSON.stringify(obj);
    const headers = new Headers();
    headers.append('Content-Type', 'application/json;charset=utf-8');
    const accountEncrypt = localStorage.getItem('accountEncrypt');
    const auth = localStorage.getItem('loginpassword');
    headers.append('Authorization', 'Basic ' + auth);
    return this.http.post(
      'http://' + this.restServerUrl +
      '/csp/bonusclubrest2/' + accountEncrypt + '/save/' + className,
      body,
      { headers }
    )
      .map((resp: Response) => resp.json())
      .catch((error: any) => Observable.throw(error));
  }

  deleteObject(className: string, ID: string) {
    const accountEncrypt = localStorage.getItem('accountEncrypt');
    const auth = localStorage.getItem('loginpassword');
    const headers = new Headers({ Authorization: 'Basic ' + auth });
    return this.http.delete(
      'http://' + this.restServerUrl +
      '/csp/bonusclubrest2/' + accountEncrypt +
      '/delObject/' + className + '/' + ID,
      { headers }
    );
  }

  getAppSetData(accountEncryptParam = '') {
    let accountEncrypt: any; // Шифрованный индефикатор аккаунта
    if (accountEncryptParam !== '') {
      accountEncrypt = accountEncryptParam;
    } else {
      accountEncrypt = localStorage.getItem('accountEncrypt');
    }
    const auth = localStorage.getItem('loginpassword');
    const headers = new Headers({ Authorization: 'Basic ' + auth });

    return this.http.get(
      'http://' + this.restServerUrl +
      '/csp/bonusclubrest2/' + accountEncrypt + '/getAppSet',
      { headers }
    );
  }

  /**
   * Метод не вполне отлажен в части обработки ответа сервера,
   * т.к. сервер не понимает запрос sendToSupport и не выдает ответ
   *
   * @param textToSend - текст сообщения, отправляемого в техподдержку
   */
  sendToSupport(textToSend: string): Observable<boolean> {
    return this.http
      .post(
        this.getFullUrl('sendToSupport'),
        textToSend,
        this.getRequestOptionsArgs()
      )
      .map(resp => {
        console.log('Статус ответа: ' + resp.status);
        if (resp.status.toString() !== 'OK') {
          throw Error('Получен отрицательный ответ: ' + resp.status.toString());
        }
        console.log(resp);
        return true;
      })
      .catch(error => {
        console.error(error);
        return Observable.of(false);
      });
  }

  genSmsCode(userTel: string) {
    const headers = new Headers();
    headers.append('Content-Type', 'application/json;charset=utf-8');
    const auth = btoa('checkSms:checkSms123098');
    headers.append('Authorization', 'Basic ' + auth);
    return this.http.get(
      'http://' + this.restServerUrl +
      '/csp/bonusclubrest2/genCode/' + userTel,
      { headers }
    )
      .map((resp: Response) => resp.json())
      .catch((error: any) => Observable.throw(error));
  }

  checkSmsCode(userTel: string, code: string) {
    const headers = new Headers();
    headers.append('Content-Type', 'application/json;charset=utf-8');
    const auth = btoa('checkSms:checkSms123098');
    headers.append('Authorization', 'Basic ' + auth);
    return this.http.get(
      'http://' + this.restServerUrl +
      '/csp/bonusclubrest2/checkCode/' + userTel + '/' + code,
      { headers }
    )
      .map((resp: Response) => resp.json())
      .catch((error: any) => Observable.throw(error));
  }
}
