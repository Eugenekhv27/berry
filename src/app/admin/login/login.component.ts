import { Component } from '@angular/core';
import { AuthService } from '../services/auth.service';

import { NotifierService } from '../notifier/notifier.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html'
})
export class LoginComponent {
  login = '';
  password = '';

  constructor(
    private auths: AuthService,
    private notifier: NotifierService
  ) { }

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
