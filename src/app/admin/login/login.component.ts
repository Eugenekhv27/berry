import { Component } from '@angular/core';
import { AuthService } from '../services/auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html'
})
export class LoginComponent {
  login = '';
  password = '';

  constructor(private auths: AuthService) { }

  doLogin(): void {
    this.auths.login({ login: this.login, password: this.password });
  }
}
