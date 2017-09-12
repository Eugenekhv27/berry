import { Component } from '@angular/core';
import { DataService } from '../services/services';
import { NotifierService } from '../services/services';

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
          this.helpRequest = '';
        } else {
          this.notifier.error('Ошибка!', 'Не удалось отправить сообщение.');
        }
      });
  }
}
