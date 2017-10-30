import { Component } from '@angular/core';
import { DataService, NotifierService } from '../services/services';

@Component({
  selector: 'app-homepage',
  templateUrl: './homepage.component.html'
})
export class HomepageComponent {
  balance = {
    points: 12345,
    plusPoints: +345,
    minusPoints: -456,
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
}
