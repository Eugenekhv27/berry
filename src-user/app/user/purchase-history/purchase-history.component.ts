import { Component, OnInit } from '@angular/core';
import { DataService } from '../services/services';
import { Purchase } from './purchase.model';
import { Router } from '@angular/router';
/*
const p = [
  {
    id: '123',
    date: '2017-10-17T15:55:11.000Z',
    shop: 'Магазин «Клюковка»',
    points: '+123',
    money: 1234,
    rating: 3,
    detailsSummary: 'на сумму 1234 руб',
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
    date: '2017-10-17T13:44:22.000Z',
    shop: 'Автосервис «Кривошип»',
    points: '+432',
    money: 4321,
    rating: 2,
    detailsSummary: 'на сумму 4321 руб',
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
    date: '2017-10-17T12:12:08.000Z',
    shop: 'Магазин «Клюковка»',
    points: '+432',
    money: 4321,
    rating: 2,
    detailsSummary: 'на сумму 4321 руб',
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
    date: '2017-10-16T12:34:08.000Z',
    shop: 'Парикмахерская «Кудряшка»',
    points: '+80',
    money: 800,
    rating: 3,
    detailsSummary: 'на сумму 800 руб',
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
    date: '2017-10-14T18:12:38.000Z',
    shop: 'Фитнесс-клуб «Качалка и мочалка»',
    points: '-120',
    money: 1200,
    rating: 4,
    detailsSummary: 'на сумму 1200 руб',
    details: [
      {
        article: 'Абонемент',
        money: 1200,
      },
    ]
  }
];
*/

@Component({
  selector: 'app-history',
  templateUrl: './purchase-history.component.html',
})
export class HistoryComponent implements OnInit {
  purchases: Purchase[];

  constructor(
    private dataService: DataService,
    private router: Router
  ) { }
  
  ngOnInit() {
    this.purchases = [];
    this.getPurchase();
  }
  logout() {
    localStorage.setItem('q1', '');
    this.router.navigate(['/login']);
  }
  getPurchase() {
    this.dataService.getPurchase()
      .subscribe((dd: any) => {
        this.purchases = dd.result;
        console.log(dd);
      });
  }

}

