import { Component } from '@angular/core';
import { DataService } from '../services/services';

@Component({
  selector: 'app-adv-panel',
  templateUrl: './adv-panel.component.html',
})
export class AdvertisementPanelComponent {
  constructor(
    private dataService: DataService,
  ) { }
}
