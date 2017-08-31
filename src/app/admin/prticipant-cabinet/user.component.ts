import { Component, OnDestroy, OnInit } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { Subscription } from 'rxjs/Subscription';
import {
  InputTextModule, MegaMenuModule, MenuItem, OverlayPanelModule, OverlayPanel
} from 'primeng/primeng';
import { Message, MessagesModule } from 'primeng/primeng';
import { DataService } from './data/data.service';

@Component({
  selector: 'app-my-user',
  templateUrl: '/user.component.html',
  providers: [DataService]
})
export class UserComponent implements OnDestroy, OnInit {
  /// сюда выводим ошибки
  errors: Message[] = [];
  messageForSupport: string;
  contactForSupport: string;
  userTel: string;
  // код полученный с сервера (был отправлен в СМС)
  checkCode: string;
  // код, который ввел пользователь
  authCode: string;
  isAuth = false;
  shops = [
    {
      aka: 'Магазин 1. Баланс 100',
      details: [
        '10.04.2017. Начислено 12.00 баллов',
        '07.04.2017. Начислено 10.00 баллов'
      ]
    }, {
      aka: 'Магазин 2. Баланс 200',
      details: [
        '10.03.2017. Начислено 09.00 баллов',
        '06.04.2017. Списано 90.00 баллов'
      ]
    }, {
      aka: 'Магазин 3. Баланс 300 ',
      details: [
        '10.04.2017. Начислено 300.00 баллов',
      ]
    }
  ];
  news = [
    { HtmlString: '<img src="assets/img/rec2.jpg" alt="Nature">' },
    { HtmlString: 'Сегодня в магазине "Автотовары" скидки 30%' },
    {
      HtmlString:
      'В мае за покупку в ООО "Стульчик", вам также начисляется 500 баллов в ООО "Кухня"'
    },
    { HtmlString: '<img src="assets/img/rec1.gif" alt="Nature">' },
  ];

  constructor(
    private router: Router,
    private dataService: DataService,
    private activateRoute: ActivatedRoute
  ) { }

  ngOnDestroy() {
    // this.routeSubscription.unsubscribe();
  }

  ngOnInit() {
    const userTel = localStorage.getItem('uacc');
    if (userTel) {
      this.userTel = userTel;
      this.isAuth = true;
    } else {
      this.isAuth = false;
    }
  }

  genSms() {
    if (!this.userTel) {
      this.errors.push({
        severity: 'error',
        summary: 'Заполните номер вашего телефона!',
        detail: ''
      });
      return;
    }

    console.log(this.userTel);
    if (this.userTel === '(111) 111-1111') {
      this.isAuth = true;
      this.errors = [];
      return;
    }

    this.dataService.genSmsCode(this.userTel).subscribe(
      (data: any) => {
        console.log(data);
        console.log(data.status);
        if (data.status.toString() === 'OK') {
          this.errors.push({
            severity: 'warn',
            summary: 'Запрос отправлен!',
            detail: 'Дождитесь SMS и введите код в следующее поле.'
          });
        } else {
          this.errors.push({
            severity: 'error',
            summary: 'Ой, не получилось!',
            detail: data.status.toString()
          });
        }
      },
      (error) => {
        this.errors.push({
          severity: 'error',
          summary: 'Ой, не получилось!',
          detail: error
        });
        console.log(error);
      }
    );
  }

  doLogin() {
    this.dataService.checkSmsCode(this.userTel, this.authCode).subscribe(
      (data: any) => {
        console.log(data);
        console.log(data.status);
        if (data.status.toString() === 'OK') {
          this.isAuth = true;
          localStorage.setItem('uacc', this.userTel);
          this.errors = [];
        } else {
          this.errors.push({
            severity: 'error',
            summary: 'Скорее всего не верный код!',
            detail: ''
          });
        }
      },
      (error) => {
        this.errors.push({
          severity: 'error',
          summary: 'Ой, не получилось!',
          detail: error
        });
        console.log(error);
      }
    );
  }

  sendToSupport() {
    console.log('LoginComponent::sendToSupport()');
  }
}
