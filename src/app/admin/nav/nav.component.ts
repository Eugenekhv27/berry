import { Component, Input, OnInit, Inject, forwardRef } from '@angular/core';
import { MenuItem } from 'primeng/primeng';

@Component({
  selector: 'app-nav',
  templateUrl: './nav.component.html'
})
export class NavComponent implements OnInit {

  @Input() reset: boolean;

  mainMenu: MenuItem[];

  ngOnInit() {
    this.mainMenu = [
      { label: 'Показатели', icon: 'fa fa-fw fa-dashboard', routerLink: ['/dashboard'] },
      { label: 'АКБ', icon: 'fa fa-fw fa-users', routerLink: ['/participants'] },
      { label: 'Транзакции', icon: 'fa fa-shopping-cart', routerLink: ['/transactions'] },
      {
        label: 'Отчеты', icon: 'fa fa-fw fa-pie-chart',
        items: [
          { label: 'Оборот бонусов', icon: 'fa fa-fw fa-pie-chart', routerLink: ['/reports/bonusesyears'] },
          { label: 'Удовлетворенность', icon: 'fa fa-fw fa-bar-chart', routerLink: ['/reports/satisfaction'] },
          { label: 'ABC-анализ', icon: 'fa fa-fw fa-line-chart', routerLink: ['/reports/abc'] },
          { label: 'KPI продавцов', icon: 'fa fa-male', routerLink: ['/reports/sellerskpi'] },
        ]
      },
      { label: 'Рассылки', icon: 'fa fa-fw fa-bullhorn', routerLink: ['/circular'] },
      { label: 'Начисление бонусов', icon: 'fa fa-fw fa-star', routerLink: ['/bonuses'] },
      { label: 'Документация', icon: 'fa fa-fw fa-book', routerLink: ['/documentation'] },
    ];
  }
}
