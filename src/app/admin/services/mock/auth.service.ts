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
    console.log('Mock AuthService::login()');

    // const auth = btoa(login + ':' + password);
    // localStorage.setItem('loginpassword', auth);
    // const headers = new Headers({ Authorization: 'Basic ' + auth });

    localStorage.setItem('accountEncrypt', 'mock');
    this.router.navigate([this.redirectUrl]);

    return Observable.of(true);
  }

  loginAndRedirectTo(path: string) {
    this.redirectUrl = path;
    this.router.navigate(['/login']);
  }
}
