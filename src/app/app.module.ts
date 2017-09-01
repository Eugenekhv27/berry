// системные
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';

// модули приложения
import { AppComponent } from './app.component';
import { AdminModule } from './admin/admin.module';

// сервисы моки (модули-подделки)
import { AuthGuard } from './auth.guard';
import { CarService } from './mocks/services/car.service';
import { DataService } from './mocks/services/data.service';

// routing
import { AppRoutingModule } from './app-routing.module';

@NgModule({
  imports: [
    // Angular
    BrowserModule,
    BrowserAnimationsModule,
    FormsModule,
    HttpModule,
    // routing
    AppRoutingModule,
    // модули приложения
    AdminModule
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
