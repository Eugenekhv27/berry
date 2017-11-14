import { Component } from '@angular/core';
import { DataService } from '../services/services';

@Component({
  selector: 'app-adv-panel',
  templateUrl: './adv-panel.component.html',
})
export class AdvertisementPanelComponent {
  banner = '';

  constructor(
    private dataService: DataService,
  ) {
    this.getBanner();
  }

  getBanner() {
    this.dataService.getBanner()
      .subscribe(html => {
        this.banner = html;
      });
  }
}
