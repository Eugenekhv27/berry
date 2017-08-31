// системные
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { AppRoutes } from './app.routes';
import { NgModule } from '@angular/core';

// библиотечные
import {
  PanelModule,
  DataTableModule,
  ChartModule,
  // InputTextModule,
  // MegaMenuModule,
  // MenubarModule,
  // MenuItem,
  // SharedModule,
  // DialogModule,
  // ButtonModule,
  // DropdownModule,
  // SelectItem,
  // FieldsetModule,
  // ListboxModule,
  // SplitButtonModule,
  // AutoCompleteModule,
  // CheckboxModule,
  // SpinnerModule,
  // SelectButtonModule,
  // TabViewModule,
  // InputSwitchModule,
  // OverlayPanelModule,
  // CalendarModule,
  // TooltipModule,
  // GrowlModule,
  // MessagesModule,
  // MultiSelectModule,
  // InputMaskModule,
  // DataScrollerModule,
  // RadioButtonModule,
  // ToolbarModule,
  // InputTextareaModule,
  // TriStateCheckboxModule,
  // AccordionModule,
  // DataListModule
} from 'primeng/primeng';

// наши
import { AdminComponent } from './admin/admin.component';
import { AdminNavComponent, AdminNavMenuComponent } from './admin/nav.component';
import { AdminTopBarComponent } from './admin/top-bar.component';
import { AdminFooterComponent } from './admin/footer.component';

import { AdminDashboardComponent } from './admin/dashboard/dashboard.component';

import { AppSetComponent } from './admin/settings/appset.component';

@NgModule({
  imports: [
    // Angular
    BrowserModule,
    BrowserAnimationsModule,
    AppRoutes,
    // PrimeNG
    PanelModule,
    DataTableModule,
    ChartModule,
  ],
  declarations: [
    AdminComponent,
    AdminNavComponent,
    AdminNavMenuComponent,
    AdminTopBarComponent,
    AdminFooterComponent,
    AdminDashboardComponent,
    AppSetComponent
  ],
  providers: [

  ],
  bootstrap: [
    AdminComponent,
  ]
})
export class AppModule { }
