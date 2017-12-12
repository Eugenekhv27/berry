import { Component, OnInit } from '@angular/core';
import { Router, ActivatedRoute} from '@angular/router';
import { AuthService, NotifierService } from '../services/services';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html'
})
export class LoginComponent implements OnInit {
  login = '';
  password = '';
  server = '';

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private auths: AuthService,
    private notifier: NotifierService
  ) { }

  ngOnInit() {
    this.server = localStorage.getItem(encodeURIComponent('restServiceUrl'));
    this.auths.logout();
  }

  doLogin(): void {
    this.auths
      .login({ login: this.login, password: this.password })
      .subscribe(loginSuccess => {
        localStorage.setItem('restServiceUrl', decodeURIComponent(this.server));
        if (!loginSuccess) {
          this.notifier.warning('Ошибка!', 'Не удалось войти в систему.');
        }
      });
  }
}
