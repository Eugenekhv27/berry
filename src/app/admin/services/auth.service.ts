import { OnInit, Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { Http, Headers } from '@angular/http';
import { NotifierService } from '../notifier/notifier.service';

@Injectable()
export class AuthService implements OnInit {

  constructor(
    private router: Router,
    private http: Http,
    private notifier: NotifierService
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

  login({ login = '', password = '' }) {
    const auth = btoa(login + ':' + password);
    localStorage.setItem('loginpassword', auth);
    const headers = new Headers({ Authorization: 'Basic ' + auth });

    this.http
      .get('http://base.progrepublic.ru/csp/bonusclubrest2/getAE',
      { headers }
      )
      .subscribe(
      (resp: any) => {
        console.log(resp.status);
        console.log(resp.json());
        if (resp.json().status === 'OK') {
          this.notifier.success('Вход выполнен.', login);
          localStorage.setItem('accountEncrypt', resp.json().result);
          this.router.navigate(['/admin/circular']);
        } else {
          this.notifier.error('Не получилось войти! 1', resp.json().status);
        }
      },
      (error) => {
        console.log(error);
        this.notifier.error('Не получилось войти! 3', error);
      }
      );
  }
}
