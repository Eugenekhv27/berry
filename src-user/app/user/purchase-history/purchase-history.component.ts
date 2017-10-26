import { Component } from '@angular/core';
import { DataService } from '../services/services';
import { Purchase } from './purchase.model';

const p = [
  {
    id: '123',
    date: '17.10.2017',
    shop: 'Магазин «Клюковка»',
    points: 123,
    money: 1234,
    rating: 3,
    detailsSummary: 'на сумму 1234 руб',
    testimonialId: '12345',
    details: [
      {
        article: 'Что-то',
        money: 123,
      }, {
        article: 'Нечто',
        money: 234,
      }, {
        article: 'Что-то с чем-то',
        money: 345,
      },
    ]
  }, {
    id: '234',
    date: '17.10.2017',
    shop: 'Автосервис «Кривошип»',
    points: 432,
    money: 4321,
    rating: 2,
    detailsSummary: 'на сумму 4321 руб',
    testimonialId: '',
    details: [
      {
        article: 'Штуковина',
        money: 123,
      }, {
        article: 'Фиговина',
        money: 234,
      }, {
        article: 'Загогулина',
        money: 345,
      },
    ]
  }, {
    id: '324',
    date: '17.10.2017',
    shop: 'Магазин «Клюковка»',
    points: 432,
    money: 4321,
    rating: 2,
    detailsSummary: 'на сумму 4321 руб',
    testimonialId: '',
    details: [
      {
        article: 'Нужное',
        money: 12,
      }, {
        article: 'Полезное',
        money: 23,
      }, {
        article: 'Фигня',
        money: 345,
      },
    ]
  }, {
    id: '345',
    date: '16.10.2017',
    shop: 'Парикмахерская «Кудряшка»',
    points: 80,
    money: 800,
    rating: 3,
    detailsSummary: 'на сумму 800 руб',
    testimonialId: '',
    details: [
      {
        article: 'Стрижка',
        money: 500,
      }, {
        article: 'Брижка',
        money: 300,
      },
    ]
  }, {
    id: '456',
    date: '14.10.2017',
    shop: 'Фитнесс-клуб «Качалка и мочалка»',
    points: 120,
    money: 1200,
    rating: 4,
    detailsSummary: 'на сумму 1200 руб',
    testimonialId: '',
    details: [
      {
        article: 'Абонемент',
        money: 1200,
      },
    ]
  }
];

@Component({
  selector: 'app-history',
  templateUrl: './purchase-history.component.html',
})
export class HistoryComponent {
  purchases: Purchase[];

  constructor(
    private dataService: DataService,
  ) {
    this.purchases = p;
  }
}
