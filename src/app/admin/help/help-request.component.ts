import { Component } from '@angular/core';
import { DataService } from '../services/services';
import { NotifierService } from '../services/services';

@Component({
  selector: 'app-help-request',
  templateUrl: './help-request.component.html'
})
export class HelpRequestComponent {
  helpRequestText: string;

  constructor(
    private dataService: DataService,
    private notifier: NotifierService
  ) { }

  sendHelpRequest() {
    if (!this.helpRequestText) {
      this.notifier.warning('Пустое сообщение!', 'Напишите ваш вопрос в поле для ввода текста');
      return;
    }

    this.dataService.sendHelpRequest(this.helpRequestText)
      .subscribe(sendSuccess => {
        if (sendSuccess) {
          this.notifier.success('Сообщение отправлено!', 'Максимальное время ответа 24 часа');
          this.helpRequestText = '';
        } else {
          this.notifier.error('Ошибка!', 'Не удалось отправить сообщение.');
        }
      });
  }
}
