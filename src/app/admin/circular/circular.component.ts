import { Component, OnInit, ViewChild } from '@angular/core';
import { Response } from '@angular/http';
import 'rxjs/add/operator/catch';

import {
  DataTable,
  Message, MessagesModule,
  MultiSelectModule, MenuItem
} from 'primeng/primeng';

import { Participant } from '../../shared/model/participant.model';
import { NotifierService, DataService, UtilsService } from '../services/services';

@Component({
  selector: 'app-circular',
  templateUrl: './circular.component.html'
})
export class CircularComponent implements OnInit {

  @ViewChild('dataTable') dt: DataTable;

  maxRowsPerPage = 12;
  loading: boolean;
  filterValue = '';
  selectedRows: Participant[] = [];
  numberOfSelectedRows = 0;
  receivers: Participant[] = [];
  messageText = '';
  tel = '';
  caption = '';
  displaySetting = false;

  smscPassword = '';
  smscLogin = '';

  constructor(
    private notifier: NotifierService,
    private dataService: DataService,
    public u: UtilsService
  ) { }

  ngOnInit() {
    const criteria = localStorage.getItem('SmsFilter');
    this.caption = localStorage.getItem('SmsFilterCaption');
    this.refreshParticipantsList(JSON.parse(criteria));
  }
  refreshParticipantsList(a: any ) {
    this.loading = true;
    a.className = 'ent.Buyer';
    this.dataService.getFilteredGrid(a)
      .subscribe((data: any) => {
        this.receivers = data.children;
        this.loading = false;
      });
  }

  /**
   * Обновляет индикатор количества выбранных строк. Учитывает фильтр.
   */
  refreshNumberOfSelectedRows() {
    setTimeout(() => this.numberOfSelectedRows = this.getSelectedRowsFiltered().length, 0);
  }

  /**
   * Возвращает true, если аргумент прошел фильтр filterValue
   */
  private isPassedFilter(v: string | number): boolean {
     return String(v).toLowerCase().includes(this.filterValue.toLowerCase());
  }

  /**
   * Возвращает список выбранных строк таблицы, проходящих фильтр filterValue.
   * Для прохождения фильтра достаточно, чтобы хотя бы одно свойство содержало
   * значение, заданное в качестве фильтра (filterValue).
   * Проверяются только выводимые в таблицу свойства объекта Participant.
   */
  private getSelectedRowsFiltered(): Participant[] {
    return this.selectedRows.filter((elem) => {
      return ['comment', 'balance', 'phone']
      .map(key => this.isPassedFilter(elem[key]))
      .includes(true);
    });
  }

  private getPhoneList(): string[] {
    return this.getSelectedRowsFiltered().map((elem) => elem.phone);
  }

  private sendMessage() {
    console.log('SmsComponent::sendMessage()');
    console.log(this.messageText);
    console.log(this.getSelectedRowsFiltered());
  }

  private isReadyToSend(): boolean {
    let isReady = true;

    if (!this.messageText) {
      isReady = false;
      this.notifier.warning('Пустое сообщение!', 'Напишите текст для рассылки в поле для ввода текста');
    }

    if (this.getSelectedRowsFiltered().length < 1) {
      isReady = false;
      this.notifier.warning('Не выбраны адресаты!', 'Выберите адресатов рассылки в таблице');
    }

    return isReady;
  }

  sendRequestForSmsCircular(): void {
    if (!this.isReadyToSend()) {
      return;
    }

    this.dataService.sendRequestForCircular(this.messageText, this.getPhoneList(), 'sms')
      .subscribe(sendSuccess => {
        if (sendSuccess) {
          this.notifier.success('Команда отправлена.', 'SMS-рассылка будет выполнена сервером в ближайшее время.');
        } else {
          this.notifier.error('Ошибка!', 'Не удалось отправить командуна выполнение рассылки.');
        }
      });
  }

  sendRequestForVoiceCircular(): void {
    if (!this.isReadyToSend()) {
      return;
    }

    this.dataService.sendRequestForCircular(this.messageText, this.getPhoneList(), 'voice')
      .subscribe(sendSuccess => {
        if (sendSuccess) {
          this.notifier.success('Команда отправлена.', 'Голосовая рассылка будет выполнена сервером в ближайшее время.');
        } else {
          this.notifier.error('Ошибка!', 'Не удалось отправить команду на выполнение рассылки.');
        }
      });
  }
  calcMoney() {
    const criteria = localStorage.getItem('SmsFilter');
    this.dataService.circularCalcMoney(this.messageText, criteria, 'sms')
      .subscribe(sendSuccess => {
        if (sendSuccess) {
          this.notifier.success('Выполнено.', '');
          // this.messageText = '';
        } else {
          this.notifier.error('Ошибка!', 'Не удалось отправить команду.');
        }
      });
  }
  testSms() {
    const tel = [this.tel];
    this.dataService.sendRequestForCircular(this.messageText, tel, 'sms')
    .subscribe(sendSuccess => {
      if (sendSuccess) {
        this.notifier.success('Команда отправлена.', 'Тестовое сообщение отправлено.');
      } else {
        this.notifier.error('Ошибка!', 'Не удалось отправить команду на выполнение рассылки.');
      }
    });
  }
  setSmscSetting() {
    this.dataService.sendSmscSetting(this.smscLogin, this.smscPassword)
    .subscribe(sendSuccess => {
      if (sendSuccess) {
        this.notifier.success('Сохранено.', '');
      } else {
        this.notifier.error('Ошибка!', 'Не удалось сохранить');
      }
    });
  }
}

