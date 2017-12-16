import { Component, OnInit, ViewChild } from '@angular/core';
import { Router, ActivatedRoute} from '@angular/router';
import { AuthService, NotifierService } from '../services/services';
import { ButtonWithSpinnerComponent } from '../button-with-spinner/button-with-spinner.component';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  // tslint:disable-next-line:use-host-property-decorator
  host: {'(window:keydown)': 'hotkeys($event)'}
})
export class LoginComponent implements OnInit {
  phone = '';
  code = '';
  // serverUrl = 'http://base.progrepublic.ru/csp/bonusclubrest';
  serverUrl = 'http://localhost:57773/csp/yagoda';
  isPhoneEntered = false;
  isCodeEntered = false;
  urlDialogdispaly = false;

  @ViewChild(ButtonWithSpinnerComponent)
  private confirmButton: ButtonWithSpinnerComponent;

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private auths: AuthService,
    private notifier: NotifierService
  ) { }

  ngOnInit() {
    const q4 = this.route.snapshot.paramMap.get('q4');
    const shopId = atob(q4);
    if (shopId !== null) {
      localStorage.setItem('shopId', shopId);
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
    localStorage.setItem('q2', this.serverUrl);
    this.auths
       .getSmsCode(this.phone)
       .subscribe(loginSuccess => {
         if (!loginSuccess) {
           this.notifier.warning('Ошибка!', 'Не удалось отправить запрос.');
         }
       });
  }

  confirmCode(): void {
    this.confirmButton.spin();
    this.auths
      .confirmCode( this.phone, this.code )
      .subscribe(loginSuccess => {
        if (!loginSuccess) {
          this.notifier.warning('Ошибка!', 'Недействительный код.');
        }
        this.confirmButton.stopSpin();
      });
  }
  // форма для изменния адреса сервера
  hotkeys(event) {
    if ((event.key === 'U') && (event.altKey) && (event.ctrlKey) && (event.shiftKey)) {
      this.urlDialogdispaly = true;
    }
 }
}
