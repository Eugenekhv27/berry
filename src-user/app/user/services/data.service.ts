import { Injectable } from '@angular/core';
import { Http, Response, Headers, RequestOptionsArgs } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import 'rxjs/add/operator/catch';
import 'rxjs/add/operator/delay';
import 'rxjs/add/observable/throw';

import { SelectItem } from 'primeng/primeng';


@Injectable()
export class DataService {

  constructor(
    private http: Http,
  ) { }

  private getRestServiceUrl() {
    const itemName = 'q2';
    const  defaultUrl = 'http://base.progrepublic.ru/csp/yagoda';

    if (!localStorage.getItem(itemName)) {
      localStorage.setItem(itemName, defaultUrl);
    }
    return localStorage.getItem(itemName);
  }

  private getRequestOptionsArgs(): RequestOptionsArgs {
    const headers = new Headers();
    headers.append('Content-Type', 'application/json;charset=utf-8');
    headers.append('Authorization', 'Basic ' + btoa('getsms:PHWEEj'));
    return { headers };
  }
  getBalance() {
    const q1 = localStorage.getItem('q1');
    const q2 = localStorage.getItem('q2');
    const shopId = localStorage.getItem('q5');
    return this.http.post(
      q2 + '/getbalance', {'q1': q1},
      this.getRequestOptionsArgs()
    )
    .map((resp: Response) => {
      if (!resp.ok) {
        throw new Error('Отрицательный ответ сервера.');
      }
      return resp.json();
    })
    .catch((error: any) => {
      console.log(error);
      return  Observable.of(false);
    });
  }
  getPurchase() {
    const q1 = localStorage.getItem('q1');
    const q2 = localStorage.getItem('q2');
    const shopId = localStorage.getItem('q5');
    return this.http.post(
      q2 + '/getpurchase', {'q1': q1},
      this.getRequestOptionsArgs()
    )
    .map((resp: Response) => {
      if (!resp.ok) {
        throw new Error('Отрицательный ответ сервера.');
      }
      return resp.json();
    })
    .catch((error: any) => {
      console.log(error);
      return  Observable.of(false);
    });
  }

  private isResponseOk(r: Response) {
    return r.json().status.toString().toLowerCase() === 'ok';
  }
 /*
  getGridData(className: string, query: string = '') {
    return this.http.get(
      this.getFullUrl('grid', className, query),
      this.getRequestOptionsArgs()
    );
  }
 */

  private dateToString(d: Date) {
    return d.getFullYear() +
    '-' + ('00' + (d.getMonth() + 1)).slice(-2) +
    '-' + ('00' + (d.getDate())).slice(-2);
  }

  /*
   *
   * @param textToSend - текст сообщения, отправляемого в техподдержку
   */
  sendHelpRequest(textToSend: string): Observable<boolean> {
    return this.http
      .post(
      this.getRestServiceUrl() + '/help-request',
      JSON.stringify({ 'helpRequest': { 'text': textToSend } }),
      this.getRequestOptionsArgs()
      )
      .map(resp => {
        if (this.isResponseOk(resp)) {
          return true;
        } else {
          throw Error('Получен отрицательный ответ сервера: ' + resp.status.toString());
        }
      })
      .catch(error => {
        console.error(error);
        return Observable.of(false);
      });
  }


  /**
   * getTestimonial() - mock, получить Отзыв участника о Покупке
   * @param purchaseId - идентификатор Покупки
   */
  getTestimonial(purchaseId: string) {
    return Observable.of(JSON.stringify(purchaseId)).delay(1600);
  }

  /**
   * postTestimonial() - mock, сохранить на сервере Отзыв участника о Покупке
   * @param tm - объект, описывающий Отзыв
   */
  postTestimonial(tm: { purchaseId: string, date: Date, text: string }) {
    return Observable.of(JSON.stringify(tm)).delay(1600);
  }

  /**
   * getRating() - mock, получить рейтинг покупки
   * @param purchaseId - идентификатор Покупки
   */
  getRating(purchaseId: string) {
    return Observable.of(JSON.stringify(purchaseId)).delay(1600);
  }

  /**
   * postRating() - mock, сохранить на сервере рейтинг покупки
   * @param r - объект, описывающий рейтинг
   */
  postRating(r: { purchaseId: string, date: Date, value: number }) {
    return Observable.of(JSON.stringify(r)).delay(1600);
  }

  /**
   * getBanner() - mock, получение рекламного баннера с сервера
   */
  getBanner() {
    return Observable.of(`
      <style type="text/css"> h3{ color: coral; text-align: center }</style>
      <h3>Здесь могла быть Ваша реклама.</h3>
    `).delay(1600);
  }
}
