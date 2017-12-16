import { OnInit, Injectable } from '@angular/core';
import { Http, Headers } from '@angular/http';
import { Router } from '@angular/router';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/observable/of';
import 'rxjs/add/operator/delay';

@Injectable()
export class AuthService implements OnInit {

  private redirectUrl = '/';

  constructor(
    private http: Http,
    private router: Router
  ) { }

  ngOnInit() {
    
  }

  private normalizePhone(phone: string):string {
    return phone
      .replace(/[ -]/g, '') // убрать побелы и дефисы
      .replace(/^(7)/,"+$1") // добавить в начало плюс, если его нет
      .replace(/^([^\+][^7])/,"+7$1"); // добавить в начало +7, если нет
  }

  isLoggedIn(): boolean {
    return Boolean(localStorage.getItem('q1'));
  }

  logout(): void {
    localStorage.setItem('q1', '');
  }

  loginAndRedirectTo(path: string) {
    this.redirectUrl = path;
    this.router.navigate(['/login']);
  }
  getSmsCode(phone = '', shopCode = ''): Observable<boolean> {
    console.log(this.normalizePhone(phone));
    const auth = btoa('getsms:PHWEEj');
    const headers = new Headers({ Authorization: 'Basic ' + auth });
    console.log('getSmsCode()' + phone);
    const serverUrl = localStorage.getItem('q2');
    const pPhone = btoa(this.normalizePhone(phone));
    return this.http
      .get(serverUrl +  '/getaccesscode/' + pPhone + '/' + shopCode,
      { headers }
      )
      .map((resp: any) => {
        console.log('Статус ответа: ' + resp.status);
        if (resp.json().status !== 'OK') {
          throw Error('Получен отрицательный ответ: ' + JSON.stringify(resp.json()));
        }
        console.log(resp.json());
        localStorage.setItem('q5', resp.json().result.shop);
        // localStorage.setItem('q1', phone + ':' + resp.json().result.accesscode);
        // this.router.navigate([this.redirectUrl]);
        return true;
      })
      .catch((error) => {
        console.error(error);
        return Observable.of(false);
      });
  }
  confirmCode(phone = '' , code = ''): Observable<boolean> {
    console.log(phone);
    console.log(code);
    const auth = btoa('getsms:PHWEEj');
    const headers = new Headers({ Authorization: 'Basic ' + auth });
    const serverUrl = localStorage.getItem('q2');
    const pPhone = btoa(this.normalizePhone(phone));
    return this.http
      .get(serverUrl +  '/confirmcode/' + pPhone + '/' + localStorage.getItem('q5') + '/' + code,
      { headers }
      )
      .map((resp: any) => {
        console.log('Статус ответа: ' + resp.status);
        if (resp.json().status !== 'OK') {
          throw Error('Получен отрицательный ответ: ' + JSON.stringify(resp.json()));
        } else {
          console.log(resp.json());
          console.log('q1=' + this.normalizePhone(phone) + ':' + code);
          localStorage.setItem('q1', this.normalizePhone(phone) + ':' + code);
          this.router.navigate(['/']);
        }
        return true;
      })
      .catch((error) => {
        console.error(error);
        return Observable.of(false);
      });
  }
}
