import { OnInit, Injectable } from '@angular/core';
import { Http, Headers } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/observable/of';

@Injectable()
export class AuthService implements OnInit {

  constructor(private http: Http) { }

  ngOnInit() {
    localStorage.setItem('accountEncrypt', '');
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
        return true;
      })
      .catch((error) => {
        console.error(error);
        return Observable.of(false);
      });
  }
}
