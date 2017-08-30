import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { AppRoutes } from './app.routes';
import { NgModule } from '@angular/core';

import { AdminComponent } from './admin/admin.component';
import { AdminNavComponent, AdminNavMenuComponent } from './admin/nav.component';
import { AdminTopBarComponent } from './admin/top-bar.component';
import { AdminFooterComponent } from './admin/footer.component';

@NgModule({
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    AppRoutes,
  ],
  declarations: [
    AdminComponent,
    AdminNavComponent,
    AdminNavMenuComponent,
    AdminTopBarComponent,
    AdminFooterComponent,
  ],
  providers: [

  ],
  bootstrap: [
    AdminComponent,
  ]
})
export class AppModule { }
