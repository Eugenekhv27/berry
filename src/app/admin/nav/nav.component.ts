import { Component, Input, OnInit, EventEmitter, ViewChild, Inject, forwardRef } from '@angular/core';
import { trigger, state, style, transition, animate } from '@angular/animations';
import { Location } from '@angular/common';
import { Router } from '@angular/router';
import { MenuItem } from 'primeng/primeng';
import { AdminComponent } from '../admin.component';

@Component({
  selector: 'app-nav',
  template: `
        <ul app-nav-menu [item]="model" root="true" class="layout-menu clearfix" [reset]="reset" visible="true"></ul>
    `
})
export class NavComponent implements OnInit {

  @Input() reset: boolean;

  model: MenuItem[];

  constructor( @Inject(forwardRef(() => AdminComponent)) public app: AdminComponent) { }

  ngOnInit() {
    this.model = [
      { label: 'Показатели', icon: 'fa fa-fw fa-dashboard', routerLink: ['/admin/dashboard'] },
      { label: 'Участники бонус-клуба', icon: 'fa fa-fw fa-users', routerLink: ['/admin/participants'] },
      { label: 'Отчет по бонусам', icon: 'fa fa-fw fa-users', routerLink: ['/admin/report'] },
      { label: 'Рассылки', icon: 'fa fa-fw fa-bullhorn', routerLink: ['/admin/circular'] },
      { label: 'Начисление бонусов', icon: 'fa fa-fw fa-star', routerLink: ['/admin/bonuses'] },
      { label: 'Документация', icon: 'fa fa-fw fa-book', routerLink: ['/admin/documentation'] },
    ];
  }

  changeTheme(theme) {
    const themeLink: HTMLLinkElement = <HTMLLinkElement>document.getElementById('theme-css');
    const layoutLink: HTMLLinkElement = <HTMLLinkElement>document.getElementById('layout-css');

    themeLink.href = 'assets/theme/theme-' + theme + '.css';
    layoutLink.href = 'assets/layout/css/layout-' + theme + '.css';
  }
}

@Component({
  selector: '[app-nav-menu]',
  templateUrl: './nav.component.html',
  animations: [
    trigger('children', [
      state('hidden', style({
        height: '0px'
      })),
      state('visible', style({
        height: '*'
      })),
      transition('visible => hidden', animate('400ms cubic-bezier(0.86, 0, 0.07, 1)')),
      transition('hidden => visible', animate('400ms cubic-bezier(0.86, 0, 0.07, 1)'))
    ])
  ]
})
export class NavMenuComponent {

  @Input() item: MenuItem;

  @Input() root: boolean;

  @Input() visible: boolean;

  _reset: boolean;

  activeIndex: number;

  constructor( @Inject(forwardRef(() => AdminComponent)) public app: AdminComponent, public router: Router, public location: Location) { }

  itemClick(event: Event, item: MenuItem, index: number) {
    // avoid processing disabled items
    if (item.disabled) {
      event.preventDefault();
      return true;
    }

    // activate current item and deactivate active sibling if any
    this.activeIndex = (this.activeIndex === index) ? null : index;

    // execute command
    if (item.command) {
      item.command({ originalEvent: event, item: item });
    }

    // prevent hash change
    if (item.items || (!item.url && !item.routerLink)) {
      event.preventDefault();
    }

    // hide menu
    if (!item.items) {
      if (this.app.isHorizontal()) {
        this.app.resetMenu = true;
      } else {
        this.app.resetMenu = false;
      }

      this.app.overlayMenuActive = false;
      this.app.staticMenuMobileActive = false;
    }
  }

  isActive(index: number): boolean {
    return this.activeIndex === index;
  }

  @Input() get reset(): boolean {
    return this._reset;
  }

  set reset(val: boolean) {
    this._reset = val;

    if (this._reset && this.app.isHorizontal()) {
      this.activeIndex = null;
    }
  }
}
