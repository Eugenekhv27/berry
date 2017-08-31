import { Component, Input, OnInit, EventEmitter, ViewChild, Inject, forwardRef } from '@angular/core';
import { trigger, state, style, transition, animate } from '@angular/animations';
import { Location } from '@angular/common';
import { Router } from '@angular/router';
import { MenuItem } from 'primeng/primeng';
import { AdminComponent } from './admin.component';

@Component({
  selector: 'app-nav',
  template: `
        <ul app-nav-menu [item]="model" root="true" class="layout-menu clearfix" [reset]="reset" visible="true"></ul>
    `
})
export class AdminNavComponent implements OnInit {

  @Input() reset: boolean;

  model: MenuItem[];

  constructor( @Inject(forwardRef(() => AdminComponent)) public app: AdminComponent) { }

  ngOnInit() {
    this.model = [
      { label: 'Dashboard', icon: 'fa fa-fw fa-dashboard', routerLink: ['/dashboard'] },
      { label: 'Участники', icon: 'fa fa-fw fa-users', routerLink: ['/'] },
      { label: 'Рассылки', icon: 'fa fa-fw fa-bullhorn', routerLink: ['/'] },
      { label: 'Начисление бонусов', icon: 'fa fa-fw fa-star', routerLink: ['/'] },
      { label: 'Настройки', icon: 'fa fa-fw fa-gear',
        items: [
          {
            label: 'Главное меню', icon: 'fa fa-fw fa-bars',
            items: [
              { label: 'Слева', icon: 'fa fa-fw fa-bars', command: () => this.app.changeToStaticMenu() },
              { label: 'Оверлей', icon: 'fa fa-fw fa-bars', command: () => this.app.changeToOverlayMenu() },
              { label: 'Горизонтально', icon: 'fa fa-fw fa-bars', command: () => this.app.changeToHorizontalMenu() }
            ]
          },
          {
            label: 'Цветовая гамма', icon: 'fa fa-fw fa-paint-brush',
            items: [
              { label: 'Turquoise', icon: 'fa fa-fw fa-paint-brush', command: (event) => { this.changeTheme('turquoise') } },
              { label: 'Blue', icon: 'fa fa-fw fa-paint-brush', command: (event) => { this.changeTheme('blue') } },
              { label: 'Purple', icon: 'fa fa-fw fa-paint-brush', command: (event) => { this.changeTheme('purple') } },
              { label: 'Orange', icon: 'fa fa-fw fa-paint-brush', command: (event) => { this.changeTheme('orange') } },
              { label: 'Pink', icon: 'fa fa-fw fa-paint-brush', command: (event) => { this.changeTheme('pink') } },
              { label: 'Light Blue', icon: 'fa fa-fw fa-paint-brush', command: (event) => { this.changeTheme('light-blue') } },
              { label: 'Green', icon: 'fa fa-fw fa-paint-brush', command: (event) => { this.changeTheme('green') } },
              { label: 'Deep Purple', icon: 'fa fa-fw fa-paint-brush', command: (event) => { this.changeTheme('deep-purple') } }
            ]
          },
          { label: 'Реф. проценты', icon: 'fa fa-fw fa-percent', routerLink: ['/settings'] },
        ]
      },
      { label: 'Документация', icon: 'fa fa-fw fa-book', routerLink: ['/documentation'] },
      { label: 'Помощь', icon: 'fa fa-fw fa-life-ring', routerLink: ['/help'] },
    ];
  }

  changeTheme(theme) {
    let themeLink: HTMLLinkElement = <HTMLLinkElement>document.getElementById('theme-css');
    let layoutLink: HTMLLinkElement = <HTMLLinkElement>document.getElementById('layout-css');

    themeLink.href = 'assets/theme/theme-' + theme + '.css';
    layoutLink.href = 'assets/layout/css/layout-' + theme + '.css';
  }
}

@Component({
  selector: '[app-nav-menu]',
  template: `
        <ng-template ngFor let-child let-i="index" [ngForOf]="(root ? item : item.items)">
            <li [ngClass]="{'active-menuitem': isActive(i)}" [class]="child.badgeStyleClass" *ngIf="child.visible === false ? false : true">
                <a [href]="child.url||'#'" (click)="itemClick($event,child,i)" *ngIf="!child.routerLink" [attr.tabindex]="!visible ? '-1' : null"  [attr.target]="child.target">
                    <i [ngClass]="child.icon"></i>
                    <span>{{child.label}}</span>
                    <span class="menuitem-badge" *ngIf="child.badge">{{child.badge}}</span>
                    <i class="fa fa-fw fa-angle-down" *ngIf="child.items"></i>
                </a>

                <a (click)="itemClick($event,child,i)" *ngIf="child.routerLink" [attr.target]="child.target"
                    [routerLink]="child.routerLink" routerLinkActive="active-menuitem-routerlink" [routerLinkActiveOptions]="{exact: true}">
                    <i [ngClass]="child.icon"></i>
                    <span>{{child.label}}</span>
                    <span class="menuitem-badge" *ngIf="child.badge">{{child.badge}}</span>
                    <i class="fa fa-fw fa-angle-down" *ngIf="child.items"></i>
                </a>
                <ul app-nav-menu [item]="child" *ngIf="child.items" [@children]="isActive(i) ? 'visible' : 'hidden'" [visible]="isActive(i)" [reset]="reset"></ul>
            </li>
        </ng-template>
    `,
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
export class AdminNavMenuComponent {

  @Input() item: MenuItem;

  @Input() root: boolean;

  @Input() visible: boolean;

  _reset: boolean;

  activeIndex: number;

  constructor( @Inject(forwardRef(() => AdminComponent)) public app: AdminComponent, public router: Router, public location: Location) { }

  itemClick(event: Event, item: MenuItem, index: number)  {
    //avoid processing disabled items
    if (item.disabled) {
      event.preventDefault();
      return true;
    }

    //activate current item and deactivate active sibling if any
    this.activeIndex = (this.activeIndex === index) ? null : index;

    //execute command
    if (item.command) {
      item.command({ originalEvent: event, item: item });
    }

    //prevent hash change
    if (item.items || (!item.url && !item.routerLink)) {
      event.preventDefault();
    }

    //hide menu
    if (!item.items) {
      if (this.app.isHorizontal())
        this.app.resetMenu = true;
      else
        this.app.resetMenu = false;

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
