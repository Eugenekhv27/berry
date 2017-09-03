import { Component, OnInit } from '@angular/core';
import { DataService } from '../../mocks/services/data.service';
import { NotifierService } from '../notifier/notifier.service';

@Component({
  selector: 'app-help-request',
  templateUrl: './help-request.component.html'
})
export class HelpRequestComponent implements OnInit {
  helpRequest: string;

  constructor(
    private dataService: DataService,
    private notifier: NotifierService
  ) { }

  ngOnInit() {
  }

  sendToSupport() {
    if (!this.helpRequest) {
      this.notifier.warning('Пустое сообщение!', 'Напишите ваш вопрос в поле для ввода текста');
      return;
    }

    this.dataService.sendToSupport(this.helpRequest)
      .subscribe(
      (data: Response) => {
        console.log(data);
        console.log(data.status);
        if (data.status.toString() === 'OK') {
          this.notifier.success('Сообщение отправлено!', 'Максимальное время ответа 24 часа');
        } else {
          this.notifier.error('Не удалось отправить!', data.status.toString());
        }
      },
      (error) => {
        this.notifier.error('Не удалось отправить!', error);
        console.log(error);
      }
      );
  }
}
