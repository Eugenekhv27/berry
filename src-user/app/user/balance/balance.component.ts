import { Component, Input } from '@angular/core';
import { DataService } from '../services/services';
import { Balance } from './balance.model';

@Component({
  selector: 'app-balance',
  templateUrl: './balance.component.html',
})
export class BalanceComponent {
  @Input() balance: Balance;

  constructor(
    private dataService: DataService,
  ) { }
}
