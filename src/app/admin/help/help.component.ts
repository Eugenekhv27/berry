import { Component, OnInit } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { Subscription } from 'rxjs/Subscription';
import {
  InputTextModule, MegaMenuModule,
  MenuItem, OverlayPanelModule,
  OverlayPanel
} from 'primeng/primeng';
import { DataService } from '../../mocks/services/data.service';


import { NotifierService } from '../notifier/notifier.service';

@Component({
  selector: 'app-ask-for-help',
  templateUrl: './help.component.html',
  providers: [DataService]
})
export class AdminHelpComponent implements OnInit {
  helpRequest: string;
  accountEncrypt: string;
  drawPublicButton: string;
  hideCalcPane = true;

  private routeSubscription: Subscription;

  constructor(
    private router: Router,
    private dataService: DataService,
    private activateRoute: ActivatedRoute,
    private notifier: NotifierService
  ) {
    this.accountEncrypt = localStorage.getItem('accountEncrypt');
    this.hideCalcPane = activateRoute.snapshot.params['hideCalcPane'];
  }

  ngOnInit() {
  }

  sendToSupport() {
    this.accountEncrypt = localStorage.getItem('accountEncrypt');

    if (!this.helpRequest) {
      this.notifier.warning('Напишите ваш вопрос в поле для ввода текста', 'Пустое сообщение!');
      return;
    }

    if (!this.accountEncrypt) {
      this.notifier.warning('Только зарегистрированные пользователи могут отправлять запросы в службу поддержки', 'Зарегистрируйтесь!');
      return;
    }

    this.dataService.sendToSupport(this.helpRequest)
      .subscribe(
      (data: Response) => {
        console.log(data);
        console.log(data.status);
        if (data.status.toString() === 'OK') {
          this.notifier.success('Максимальное время ответа 24 часа', 'Сообщение отправлено!');
        } else {
          this.notifier.error(data.status.toString(), 'Не удалось отправить!');
        }
      },
      (error) => {
        this.notifier.error(error, 'Не удалось отправить!');
        console.log(error);
      }
      );
  }
}
