/**
 * Корневой модуль  Angular-приложения
 *
 * BrowserAnimationsModule можно импортировать только в корневом модуле приложения
 * (он нужен для библиотеки PrimeNG в AdminModule, но импортировать его приходится здесь)
 */
import { NgModule, LOCALE_ID } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { HttpClientModule } from '@angular/common/http';

import { HttpModule } from '@angular/http'; // TODO - убрать, устаревшая конструкция

// Глобальные сервисы
import {
  AuthGuard,
  AuthService,
  DataService,
  NotifierService,
  UtilsService
} from './admin/services/services';

// корневой компонент Angular-приложения
import { AppComponent } from './app.component';

// Routing (прикладные Angular-модули загружаются через lazy-loading)
import { AppRoutingModule } from './app-routing.module';

@NgModule({
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    HttpModule, // TODO - убрать, устаревшая конструкция
    HttpClientModule,
    AppRoutingModule,
  ],
  declarations: [
    AppComponent,
  ],
  providers: [
    AuthService,
    AuthGuard,
    NotifierService,
    DataService,
    UtilsService,
    { provide: LOCALE_ID, useValue: 'ru-RU' },
  ],
  bootstrap: [
    AppComponent,
  ]
})
export class AppModule { }
