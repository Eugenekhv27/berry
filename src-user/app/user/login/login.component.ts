import { Component, OnInit, ViewChild } from '@angular/core';
import { Router, ActivatedRoute} from '@angular/router';
import { AuthService, NotifierService } from '../services/services';
import { ButtonWithSpinnerComponent } from '../button-with-spinner/button-with-spinner.component';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html'
})
export class LoginComponent implements OnInit {
  phone = '';
  code = '';
  isPhoneEntered = false;
  isCodeEntered = false;

  @ViewChild(ButtonWithSpinnerComponent)
  private confirmButton: ButtonWithSpinnerComponent;

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private auths: AuthService,
    private notifier: NotifierService
  ) { }

  ngOnInit() {
    const server = this.route.snapshot.paramMap.get('server');
    if (server !== null) {
      localStorage.setItem('restServiceUrl', decodeURIComponent(server));
    }

    this.auths.logout();
  }

  // doLogin(): void {
  //   this.auths
  //     .login({ login: this.login, password: this.password })
  //     .subscribe(loginSuccess => {
  //       if (!loginSuccess) {
  //         this.notifier.warning('Ошибка!', 'Не удалось войти в систему.');
  //       }
  //     });
  // }

  requestSMS(): void {
    // this.auths
    //   .login({ login: this.login, password: this.password })
    //   .subscribe(loginSuccess => {
    //     if (!loginSuccess) {
    //       this.notifier.warning('Ошибка!', 'Не удалось войти в систему.');
    //     }
    //   });
  }

  confirmCode(): void {
    this.confirmButton.spin();
    this.auths
      .smsLogin({ phone: this.phone, code: this.code })
      .subscribe(loginSuccess => {
        if (!loginSuccess) {
          this.notifier.warning('Ошибка!', 'Недействительный код.');
        }
        this.confirmButton.stopSpin();
      });
  }
}
