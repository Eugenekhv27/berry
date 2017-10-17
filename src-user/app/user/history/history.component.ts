import { Component } from '@angular/core';
import { DataService } from '../services/services';

@Component({
  selector: 'app-history',
  templateUrl: './history.component.html',
})
export class HistoryComponent {
  ratings = [2, 3, 4, 3, 4, 5];
  constructor(
    private dataService: DataService,
  ) { }
}
