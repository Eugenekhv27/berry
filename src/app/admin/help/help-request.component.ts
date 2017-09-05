import { Component } from '@angular/core';
import { DataService } from '../services/data.service';
import { NotifierService } from '../notifier/notifier.service';

@Component({
  selector: 'app-help-request',
  templateUrl: './help-request.component.html'
})
export class HelpRequestComponent {
  helpRequest: string;

  constructor(
    private dataService: DataService,
    private notifier: NotifierService
  ) { }

  sendHelpRequest() {
    if (!this.helpRequest) {
      this.notifier.warning('Пустое сообщение!', 'Напишите ваш вопрос в поле для ввода текста');
      return;
    }

    this.dataService.sendToSupport(this.helpRequest)
      .subscribe(sendSuccess => {
        if (sendSuccess) {
          this.notifier.success('Сообщение отправлено!', 'Максимальное время ответа 24 часа');
        } else {
          this.notifier.error('Ошибка!', 'Не удалось отправить сообщение.');
        }
      });

      // .subscribe(
      // (data: Response) => {
      //   console.log(data);
      //   console.log(data.status);
      //   if (data.status.toString() === 'OK') {
      //     this.notifier.success('Сообщение отправлено!', 'Максимальное время ответа 24 часа');
      //   } else {
      //     this.notifier.error('Не удалось отправить!', data.status.toString());
      //   }
      // },
      // (error) => {
      //   this.notifier.error('Не удалось отправить!', error);
      //   console.log(error);
      // }
      // );
  }
}
