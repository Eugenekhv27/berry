import { Component, OnInit } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { Subscription } from 'rxjs/Subscription';
import {
  InputTextModule, MegaMenuModule,
  MenuItem, OverlayPanelModule,
  OverlayPanel, Message, MessagesModule
} from 'primeng/primeng';
import { DataService } from '../../mocks/services/data.service';

@Component({
  selector: 'app-ask-for-help',
  templateUrl: './help.component.html',
  providers: [DataService]
})
export class AdminHelpComponent implements OnInit {
  messageForSupport: string;
  calcurl: string;
  accountEncrypt: string;
  drawPublicButton: string;
  hideCalcPane = true;
  /// сюда выводим ошибки
  errors: Message[] = [];

  private routeSubscription: Subscription;

  constructor(
    private router: Router,
    private dataService: DataService,
    private activateRoute: ActivatedRoute
  ) {
    this.accountEncrypt = localStorage.getItem('accountEncrypt');
    this.calcurl = 'data-url=\'http://base.spidercalc.ru/calc;ae=' + this.accountEncrypt + '\'';
    this.hideCalcPane = activateRoute.snapshot.params['hideCalcPane'];
  }

  ngOnInit() {
  }

  sendToSupport() {
    this.accountEncrypt = localStorage.getItem('accountEncrypt');

    if (!this.accountEncrypt) {
      this.errors.push({
        severity: 'error',
        summary: 'Зарегистрируйтесь!',
        detail: 'Для начала стоит зарегистрирваться в системе'
      });
      return;
    }

    if (!this.messageForSupport) {
      this.errors.push({
        severity: 'error',
        summary: 'Пустое сообщение!',
        detail: 'Напишите подробней ваш вопрос'
      });
      return;
    }

    this.dataService.sendToSupport(this.messageForSupport)
      .subscribe(
      (data: Response) => {
        console.log(data);
        console.log(data.status);
        if (data.status.toString() === 'OK') {
          this.errors.push({
            severity: 'warn',
            summary: 'Сообщение отправлено!',
            detail: 'Максимальное время ответа 24 часа.'
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
        this.errors.push({ severity: 'error', summary: 'Ой, не получилось!', detail: error });
        console.log(error);
      }
      );
  }
}
