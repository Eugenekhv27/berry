import { Component, OnInit } from '@angular/core';
import { Router, ActivatedRoute, Params } from '@angular/router';
import { Http, Headers } from '@angular/http';

import { Message } from 'primeng/primeng';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html'
})
export class AdminLoginComponent implements OnInit {
  restServerUrl;
  login: string;
  password: string;
  notCall: string[] = [];
  /// сюда выводим ошибки
  errors: Message[] = [];

  constructor(private router: Router, private http: Http) { }

  ngOnInit() {
    localStorage.setItem('accountEncrypt', '');
    this.restServerUrl = 'base.progrepublic.ru';
  }

  doLogin() {
    const auth = btoa(this.login + ':' + this.password);
    localStorage.setItem('loginpassword', auth);
    const headers = new Headers({ Authorization: 'Basic ' + auth });
    this.http
      .get('http://' + this.restServerUrl + '/csp/bonusclubrest2/getAE',
      { headers }
      )
      .subscribe(
      (resp: any) => {
        console.log(resp.json());
        console.log(resp.json().status);
        if (resp.json().status === 'OK') {
          console.log('OK');
          const accountEncrypt = resp.json().result;
          console.log(accountEncrypt);
          localStorage.setItem('accountEncrypt', accountEncrypt);
          this.router.navigate(['/admin/buyers']);
        } else {
          console.log(resp.json().status);
          console.log(resp.status);
          this.errors.push({
            severity: 'error',
            summary: 'Не получилось войти! 1',
            detail: resp.json().status
          });
        }
      },
      (error) => {
        console.log(error);
        this.errors.push({
          severity: 'error',
          summary: 'Не получилось войти! 3',
          detail: error
        });
        console.log(error);
      }
      );
  }
}
