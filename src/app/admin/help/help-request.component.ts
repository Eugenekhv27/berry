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
      this.notifier.warning('Напишите ваш вопрос в поле для ввода текста', 'Пустое сообщение!');
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
