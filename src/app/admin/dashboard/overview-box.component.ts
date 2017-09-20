import { Component, OnInit, Input } from '@angular/core';

@Component({
  selector: 'app-overview-box',
  templateUrl: './overview-box.component.html'
})
export class OverviewBoxComponent implements OnInit {

  @Input() label = 'Label';
  @Input() icon = 'fa-bar-chart';
  @Input() value: number | string = 0;
  @Input() color = '1';

  constructor() { }

  ngOnInit() {
  }

  setColorClass() {
    return { [`overview-box-${this.color}`]: true };
  }

  setIconClasses() {
    return {
      fa: true,
      [this.icon]: true
    };
  }
}
