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
  shopCode = '';
  serverUrl = 'http://base.progrepublic.ru/csp/yagodarest';
  // serverUrl = 'http://localhost:57773/csp/yagoda';
  isPhoneEntered = false;
  isShopCodeEntered = false;
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
    if (this.route.snapshot.paramMap.get('q4')) {
      this.shopCode = this.route.snapshot.paramMap.get('q4');
      this.isShopCodeEntered = true;
    }
    if (localStorage.getItem('q1') && localStorage.getItem('q2')) {
      this.router.navigate(['/']);
    }
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
       .getSmsCode(this.phone, this.shopCode)
       .subscribe(loginSuccess => {
         if (!loginSuccess) {
           this.notifier.warning('Ошибка!', 'Скорее всего неверно ввели код.');
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
