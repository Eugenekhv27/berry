import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { BonusAccountOperation } from '../../shared/model/participant.model';
import { DataService, NotifierService } from '../services/services';
import {SelectItem} from 'primeng/primeng';

@Component({
  selector: 'app-transactions',
  templateUrl: './transactions.component.html'
})

export class TransactionsComponent implements OnInit {

  transactionsList: BonusAccountOperation[] = [];
  totals = {};
  selectedLine: BonusAccountOperation;
  maxRowsPerPage = 11;
  loading: boolean;
  totalsStyle = {'text-align': 'right', 'background-color': '#D9E0E7', 'font-weight': 'bold'};
//   abcGroupOptions =
//    [
//     {label: 'Не важно', value: null},
//     {label: 'A', value: 'A'},
//     {label: 'B', value: 'B'},
//     {label: 'C', value: 'C'}
// ];

  // для фильтров
  beginRegDate: string;
  endRegDate: string;
  beginBonusSum: number;
  endBonusSum: number;
  tel: string;

  ru = {
      firstDayOfWeek: 1,
      dayNames: ['Воскресенье', 'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота'],
      dayNamesShort: ['Вск', 'Пон', 'Вт', 'Сред', 'Чет', 'Птн', 'Суб'],
      dayNamesMin: ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'],
      monthNames: [ 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь' ],
      monthNamesShort: [ 'Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн', 'Июл', 'Авг', 'Сент', 'Окт', 'Нбр', 'Дек' ],
      today: 'Сегодня',
      clear: 'Очистить'
    };

  constructor(
    private router: Router,
    private dataService: DataService,
    private notifier: NotifierService
  ) { }

  ngOnInit() {
    this.refreshTransactionsList({});
  }

  refreshTransactionsList(a: any ) {
    this.loading = true;
    a.className = 'doc.BonusOperation';
    this.dataService.getFilteredGrid(a)
      .subscribe((data: any) => {
        this.transactionsList = data[0].children;
        this.totals = data[1].totals[0];
        this.loading = false;
      });
  }

  refreshTransactionsListByFilter() {
    const a = {
      'beginRegDate': this.beginRegDate,
      'endRegDate': this.endRegDate,
      'beginBonusSum': this.beginBonusSum,
      'endBonusSum': this.endBonusSum,
      'tel' : this.tel
    };
    this.refreshTransactionsList(a);
  }
  onRowDblclick(event) {
    console.log(event);
    this.router.navigate(['/participants/' + encodeURIComponent(this.selectedLine.participantId)]);
  }
 }
