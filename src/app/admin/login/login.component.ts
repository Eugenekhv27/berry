import { Component, OnInit } from '@angular/core';
import { AuthService, NotifierService } from '../services/services';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html'
})
export class LoginComponent implements OnInit {
  login = '';
  password = '';

  constructor(
    private auths: AuthService,
    private notifier: NotifierService
  ) { }

  ngOnInit() {
    this.auths.logout();
  }

  doLogin(): void {
    this.auths
      .login({ login: this.login, password: this.password })
      .subscribe(loginSuccess => {
        if (!loginSuccess) {
          this.notifier.warning('Ошибка!', 'Не удалось войти в систему.');
        }
      });
  }
}
