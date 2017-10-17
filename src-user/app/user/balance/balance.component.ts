import { Component } from '@angular/core';
import { DataService } from '../services/services';

@Component({
  selector: 'app-balance',
  templateUrl: './balance.component.html',
})
export class BalanceComponent {
  balance = 12345;
  plusPoints = '+345';
  minusPoints = '-456';

  constructor(
    private dataService: DataService,
  ) { }
}
