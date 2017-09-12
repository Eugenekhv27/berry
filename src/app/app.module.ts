/**
 * Корневой модуль  Angular-приложения
 *
 * BrowserAnimationsModule можно импортировать только в корневом модуле приложения
 * (он нужен для библиотеки PrimeNG в AdminModule, но импортировать его приходится здесь)
 */
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { HttpModule } from '@angular/http';

// Глобальные сервисы
import {
  AuthGuard,
  AuthService,
  DataService,
  NotifierService
} from './admin/services/services';

// корневой компонент Angular-приложения
import { AppComponent } from './app.component';

// Routing (прикладные Angular-модули загружаются через lazy-loading)
import { AppRoutingModule } from './app-routing.module';

@NgModule({
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    HttpModule,
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
  ],
  bootstrap: [
    AppComponent,
  ]
})
export class AppModule { }
