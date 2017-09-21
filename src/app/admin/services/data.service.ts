/**
 * На 06.09.2017 на стороне сервера реализованы следующие методы:
 *  <Route Url="/putPoints/:userTel/:uuid/:rubSum/:pointsSum/:fromTel" Method="GET" Call="PutPoints"/>
 *  <Route Url="/getBalance/:userTel/:fromTel" Method="GET" Call="GetBalance"/>
 *  <Route Url="/payByPoints/:userTel/:uuid/:points" Method="GET" Call="PayByPoints"/>
 *  <Route Url="/genCode/:userTel" Method="GET" Call="GenCode"/>
 *  <Route Url="/checkCode/:userTel/:code" Method="GET" Call="CheckCode"/>
 *  <Route Method="GET" Url="/getAE" Call="GetAE" />
 *  <Route Method="GET" Url="/:encriptId/grid/:className/" Call="GetForGridByClassName" />
 * Обращение по другим путям будет вызывать ошибки.
 */

import 'rxjs/add/operator/toPromise';
import 'rxjs/add/operator/map';
import 'rxjs/add/operator/catch';
import 'rxjs/add/operator/delay';
import 'rxjs/add/observable/throw';
import { Injectable } from '@angular/core';
import { Http, Response, Headers, RequestOptionsArgs } from '@angular/http';
import { Observable } from 'rxjs/Observable';

import { SelectItem } from 'primeng/primeng';
import { Participant } from '../participants/participant.model';

@Injectable()
export class DataService {
  // Пока по умолчанию подключение к тестовой базе: base.progrepublic.ru/csp/bonusclubrest2/...
  private readonly defaultRestServiceUrl = 'http://base.progrepublic.ru/csp/bonusclubrest2';
  private restServiceUrl = 'http://base.progrepublic.ru/csp/bonusclubrest2';
  private restServerName = 'base.progrepublic.ru';

  constructor(
    private http: Http,
  ) {
    this.restServiceUrl = this.defaultRestServiceUrl;
  //  this.restServiceUrl = this.getRestServiceUrl('restServiceUrl');
  }

  private getRestServiceUrl(name: string) {
    if (!localStorage.getItem(name)) {
      localStorage.putItem(name, this.defaultRestServiceUrl);
    }
    return localStorage.getItem(name);
  }

  private getRequestOptionsArgs(): RequestOptionsArgs {
    const headers = new Headers();
    headers.append('Content-Type', 'application/json;charset=utf-8');
    headers.append('Authorization', 'Basic ' + localStorage.getItem('loginpassword')); 7
    return { headers };
  }

  private getFullUrl(...args) {
    const query = args
      .map(val => encodeURIComponent(val).replace(new RegExp('%', 'g'), '~'))
      .join('/');
    return this.restServiceUrl + '/' +
      localStorage.getItem('accountEncrypt') + '/' +
      query;
  }

  getGridData(className: string, query: string = '') {
    return this.http.get(
      this.getFullUrl('grid', className, query),
      this.getRequestOptionsArgs()
    );
  }

  private dateToString(d: Date) {
    return d.getFullYear() +
    '-' + ('00' + (d.getMonth() + 1)).slice(-2) +
    '-' + ('00' + (d.getDate())).slice(-2);
  }

  getBonusReport(startDate: any, endDate: any) {
    console.log(this.dateToString(startDate), this.dateToString(endDate));
    return this.http.get(
      this.getFullUrl('bonusReport', this.dateToString(startDate), this.dateToString(endDate)),
      this.getRequestOptionsArgs()
    )
    .map((resp: Response) => {
      if (!resp.ok) {
        throw new Error('Отрицательный ответ сервера при сохранении объекта.');
      }
      return { rows: resp.json()[0].children, totals: resp.json()[1].totals[0] };
    })
    .catch((error: any) => {
      console.log(error);
      return  Observable.of(false);
    });
  }

  getBonusReportDetails(date: any) {
    console.log(this.dateToString(date));
    return this.http.get(
      this.getFullUrl('bonusReportDetails', this.dateToString(date)),
      this.getRequestOptionsArgs()
    )
    .map((resp: Response) => {
      if (!resp.ok) {
        throw new Error('Отрицательный ответ сервера.');
      }
      return { rows: resp.json()[0].children, totals: resp.json()[1].totals[0] };
    })
    .catch((error: any) => {
      console.log(error);
      return  Observable.of(false);
    });
  }

  getDashboardData() {
    return this.http.get(
      this.getFullUrl('dashboard'),
      this.getRequestOptionsArgs()
    )
    .map((resp: Response) => {
      if (!resp.ok) {
        throw new Error('Отрицательный ответ сервера.');
      }
      return resp.json().summary;
    })
    .catch((error: any) => {
      console.log(error);
      return  Observable.of(false);
    });
  }

  getParticipantsList() {
    const p = new Participant();
    return this.getGridData('ent.Buyer')
      .map((resp: Response) => {
        return resp.json().children.map(p.convertForFront);
      });
  }

  saveParticipant(aParticipant: any) {
    return this.saveObject('ent.Buyer', aParticipant.convertForServer());
  }

  getObjectData(className: string, ID: string, phone?: string) {
    const accountEncrypt = localStorage.getItem('accountEncrypt');

    const akaToUrl = encodeURIComponent(phone).replace(new RegExp('%', 'g'), '~');
    const auth = localStorage.getItem('loginpassword');
    const headers = new Headers({ Authorization: 'Basic ' + auth });
    return this.http.get(
      'http://' + this.restServerName +
      '/csp/bonusclubrest2/' + accountEncrypt +
      '/getObject/' + className + '/' + ID + '/' + akaToUrl,
      { headers }
    );
  }

  saveObject(className: string, anObject: any) {
    return this.http
      .post(
        this.getFullUrl('save', className),
        JSON.stringify({ object: anObject }),
        this.getRequestOptionsArgs()
      )
      .map((resp: Response) => {
        if (resp.status.toString() !== 'OK') {
          throw new Error('Отрицательный ответ сервера при сохранении объекта.');
        }
        return true;
      })
      .catch((error: any) => {
        console.log(error);
        return  Observable.of(false);
      });
  }

  deleteObject(className: string, ID: string) {
    const accountEncrypt = localStorage.getItem('accountEncrypt');
    const auth = localStorage.getItem('loginpassword');
    const headers = new Headers({ Authorization: 'Basic ' + auth });
    return this.http.delete(
      'http://' + this.restServerName +
      '/csp/bonusclubrest2/' + accountEncrypt +
      '/delObject/' + className + '/' + ID,
      { headers }
    );
  }

  // getAppSetData(accountEncryptParam = '') {
  //   let accountEncrypt: any; // Шифрованный индефикатор аккаунта
  //   if (accountEncryptParam !== '') {
  //     accountEncrypt = accountEncryptParam;
  //   } else {
  //     accountEncrypt = localStorage.getItem('accountEncrypt');
  //   }
  //   const auth = localStorage.getItem('loginpassword');
  //   const headers = new Headers({ Authorization: 'Basic ' + auth });

  //   return this.http.get(
  //     'http://' + this.restServerName +
  //     '/csp/bonusclubrest2/' + accountEncrypt + '/getAppSet',
  //     { headers }
  //   );
  // }

  /**
   * Метод не вполне отлажен в части обработки ответа сервера,
   * т.к. сервер не понимает запрос sendHelpRequest и не выдает ответ
   *
   * @param textToSend - текст сообщения, отправляемого в техподдержку
   */
  sendHelpRequest(textToSend: string): Observable<boolean> {
    return this.http
      .post(
      this.getFullUrl('help-request'),
      JSON.stringify({ 'helpRequest': { 'text': textToSend } }),
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

  /**
   * Отправить на сервер запрос на SMS или голосовую рассылку
   * @param textToSend - текст рассылаемого сообщения
   * @param phones - список телефонов для рассылки SMS
   */
  sendRequestForCircular(textToSend: string, phones: string[], type: string = 'sms'): Observable<boolean> {
    const request = {
      [type + 'Circular']: {
        'text': textToSend,
        'phones': phones
      }
    };

    return this.http
      .post(
      this.getFullUrl(type + '-circular'),
      JSON.stringify(request),
      this.getRequestOptionsArgs()
      )
      .map(resp => {
        console.log('Статус ответа: ' + resp.status);
        if (!resp.ok) {
          throw Error('Получен отрицательный ответ сервера: ' + resp.status.toString());
        }
        console.log(resp);
        return true;
      })
      .catch(error => {
        console.error(error);
        return Observable.of(false);
      });
  }

  /**
   * Запрос на изменение баланса бонусных баллов
   * @param points - величина изменения в баллах
   * @param ids - массив идентификаторов объектов "Участник"
   */
  changeBonusPoints(points: number, ids: string[]): Observable<boolean> {
    const request = {
      'changeBonus': {
        'ids': ids,
        'points': points
      }
    };

    return this.http
      .post(
      this.getFullUrl('change-bonus'),
      JSON.stringify(request),
      this.getRequestOptionsArgs()
      )
      .map(resp => {
        console.log('Статус ответа: ' + resp.status);
        if (!resp.ok) {
          throw Error('Получен отрицательный ответ сервера: ' + resp.status.toString());
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
      'http://' + this.restServerName +
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
      'http://' + this.restServerName +
      '/csp/bonusclubrest2/checkCode/' + userTel + '/' + code,
      { headers }
    )
      .map((resp: Response) => resp.json())
      .catch((error: any) => Observable.throw(error));
  }
}
