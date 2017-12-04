import { OnInit, Injectable } from '@angular/core';
import { Http, Headers } from '@angular/http';
import { Router } from '@angular/router';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/observable/of';

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
    return this.http
      .get('http://base.progrepublic.ru/csp/bonusclubrest2/getAE',
      { headers }
      )
      .map((resp: any) => {
        if (resp.json().status !== 'OK') {
          throw Error('Получен отрицательный ответ: ' + JSON.stringify(resp.json()));
        }
        localStorage.setItem('accountEncrypt', resp.json().result);
        this.router.navigate([this.redirectUrl]);
        return true;
      })
      .catch((error) => {
        console.error(error);
        return Observable.of(false);
      });
  }

  loginAndRedirectTo(path: string) {
    this.redirectUrl = path;
    this.router.navigate(['/login']);
  }
}
