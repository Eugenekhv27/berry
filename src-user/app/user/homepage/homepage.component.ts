import { Component } from '@angular/core';
import { DataService, NotifierService } from '../services/services';
import { Router, ActivatedRoute} from '@angular/router';

@Component({
  selector: 'app-homepage',
  templateUrl: './homepage.component.html'
})

export class HomepageComponent {
  constructor(
    private route: ActivatedRoute, private dataService: DataService
  ) { }
  balance = {points: 0,  details: []};
  /*
  {
    points: 12345,
    details: [
      {
        shop: 'Магазин "Клюковка"',
        points: 333
      }, {
        shop: 'Автосервис "Кривошип"',
        points: 500
      }, {
        shop: 'Центр детского творчества "Дубинушка"',
        points: 50
      }, {
        shop: 'Школа иностранных языков "Му-му"',
        points: 50
      }
    ]
  };
  */
  profile = {
    name: '',
    sex: '',
    birthDate: ''
  };
  // tslint:disable-next-line:use-life-cycle-interface
  ngOnInit() {
    // запоминаем с какого магазина ссылка
    const q4 = this.route.snapshot.paramMap.get('q4');
    if (q4) {
      const shopId = atob(q4);
      if (shopId !== null) {
        localStorage.setItem('q5', shopId);
      }
    }
    //
    this.getBalance();
  }
  getBalance() {
    this.dataService.getBalance()
      .subscribe((dd: any) => {
        this.balance = dd.result;
        console.log(dd);
      });
  }
}
