import { Component } from '@angular/core';

import { trigger, state, style, animate, transition, keyframes } from '@angular/animations';

@Component({
  selector: 'app-overview-box',
  templateUrl: './overview-box.component.html',
  // tslint:disable-next-line:use-input-property-decorator
  inputs: ['label', 'icon', 'value', 'color', 'enter'],
  animations: [
    trigger('boxState', [
      state('inactive', style({ transform: 'scale(1)' })),
      state('active',   style({ transform: 'scale(1.1)' })),
      transition('inactive => active', animate('100ms ease-in')),
      transition('active => inactive', animate('100ms ease-out'))
    ]),
    trigger('flyIn', [
      transition(':enter', [
        animate(900, keyframes([
          style({ opacity: 0, transform: 'translateX(+130%)' }),
          style({ opacity: 0.3, transform: 'translateX(0)' }),
          style({ opacity: 1, transform: 'translateX(0)' }),
        ])),
      ])
    ])
  ]
})
export class OverviewBoxComponent {

  label = 'Label';
  icon = 'fa-bar-chart';
  value: number | string = '?';
  color = '1';
  state = 'inactive';

  setColorClass() {
    return { [`overview-box-${this.color}`]: true };
  }

  setIconClasses() {
    return {
      fa: true,
      [this.icon]: true
    };
  }

  toggleState() {
    this.state = this.state === 'active' ? 'inactive' : 'active';
  }
  setFontSize() {
    if (this.value > 99999) {
      return {'font-size': '30px'};
    }
    if (this.value > 999999) {
      return {'font-size': '24px'};
    }
    if (this.value > 9999999) {
      return {'font-size': '20px'};
    }
  }
}
