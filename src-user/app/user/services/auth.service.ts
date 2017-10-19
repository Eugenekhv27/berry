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
    localStorage.setItem('accountEncrypt', '');
  }

  private normalizePhone(phone: string):string {
    return phone
      .replace(/[ -]/g, '') // убрать побелы и дефисы
      .replace(/^(7)/,"+$1") // добавить в начало плюс, если его нет
      .replace(/^([^\+][^7])/,"+7$1"); // добавить в начало +7, если нет
  }

  isLoggedIn(): boolean {
    return Boolean(localStorage.getItem('accountEncrypt'));
  }

  logout(): void {
    localStorage.setItem('accountEncrypt', '');
  }

  login({ login = '', password = '' }): Observable<boolean> {
    const auth = btoa(login + ':' + password);
    localStorage.setItem('loginpassword', auth);
    const headers = new Headers({ Authorization: 'Basic ' + auth });
    console.log('AuthService()');
    return this.http
      .get('http://base.progrepublic.ru/csp/bonusclubrest2/getAE',
      { headers }
      )
      .map((resp: any) => {
        console.log('Статус ответа: ' + resp.status);
        if (resp.json().status !== 'OK') {
          throw Error('Получен отрицательный ответ: ' + JSON.stringify(resp.json()));
        }
        console.log(resp.json());
        localStorage.setItem('accountEncrypt', resp.json().result);
        this.router.navigate([this.redirectUrl]);
        return true;
      })
      .catch((error) => {
        console.error(error);
        return Observable.of(false);
      });
  }

  smsLogin({ phone = '', code = '' }): Observable<boolean> {
    console.log(this.normalizePhone(phone), code);
    // имитация: вероятность успешного логина 1/2
    return Observable.of(
      Math.random() > 0.5 ?
      (this.router.navigate([this.redirectUrl]), true) :
      false
    ).delay(2000);
  }

  loginAndRedirectTo(path: string) {
    this.redirectUrl = path;
    this.router.navigate(['/admin/login']);
  }
}
