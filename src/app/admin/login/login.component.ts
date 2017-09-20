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

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private auths: AuthService,
    private notifier: NotifierService
  ) { }

  ngOnInit() {
    const server = this.route.snapshot.paramMap.get('server');
    if (server) {
      localStorage.setItem('restServiceUrl', decodeURIComponent(server));
    }

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
