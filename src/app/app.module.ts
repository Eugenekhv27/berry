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
import { AuthGuard } from './admin/services/auth.guard';
import { CarService } from './mocks/services/car.service';
import { DataService } from './mocks/services/data.service';

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
    AuthGuard,
    CarService,
    DataService,
  ],
  bootstrap: [
    AppComponent,
  ]
})
export class AppModule { }
