// системные
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';

// библиотечные
import {
  PanelModule,
  DataTableModule,
  ChartModule,
  GrowlModule,
  MessagesModule,
  SplitButtonModule,
  InputMaskModule,
  /*
  InputTextModule,
  MegaMenuModule,
  MenubarModule,
  MenuItem,
  SharedModule,
  DialogModule,
  ButtonModule,
  DropdownModule,
  SelectItem,
  FieldsetModule,
  ListboxModule,
  AutoCompleteModule,
  CheckboxModule,
  SpinnerModule,
  SelectButtonModule,
  TabViewModule,
  InputSwitchModule,
  OverlayPanelModule,
  CalendarModule,
  TooltipModule,
  MultiSelectModule,
  DataScrollerModule,
  RadioButtonModule,
  ToolbarModule,
  InputTextareaModule,
  TriStateCheckboxModule,
  AccordionModule,
  DataListModule
*/
} from 'primeng/primeng';

// раутинг
import { AppRoutes } from './app.routes';

// наши
import { AuthGuard } from './auth.guard';
import { AdminComponent } from './admin/admin.component';
import { AdminLoginComponent } from './admin/login/login.component';
import { AdminHelpComponent } from './admin/help/help.component';
import { AdminNavComponent, AdminNavMenuComponent } from './admin/nav.component';
import { AdminTopBarComponent } from './admin/top-bar.component';
import { AdminFooterComponent } from './admin/footer.component';
import { AdminDashboardComponent } from './admin/dashboard/dashboard.component';
import { AdminParticipantsListComponent } from './admin/participants/participants-list.component';
import { AdminCircularComponent } from './admin/circular/circular.component';
import { AdminReferralSettingsComponent } from './admin/settings/referral-settings.component';
import { AdminDocumentationComponent } from './admin/documentation/documentation.component';

// моки (модули-подделки)
import { CarService } from './mocks/services/car.service';
import { DataService } from './mocks/services/data.service';

@NgModule({
  imports: [
    // Angular
    BrowserModule,
    BrowserAnimationsModule,
    FormsModule,
    HttpModule,
    // PrimeNG
    PanelModule,
    DataTableModule,
    ChartModule,
    GrowlModule,
    MessagesModule,
    SplitButtonModule,
    InputMaskModule,
    // routing
    AppRoutes,
  ],
  declarations: [
    AdminComponent,
    AdminLoginComponent,
    AdminHelpComponent,
    AdminNavComponent,
    AdminNavMenuComponent,
    AdminTopBarComponent,
    AdminFooterComponent,
    AdminDashboardComponent,
    AdminParticipantsListComponent,
    AdminCircularComponent,
    AdminReferralSettingsComponent,
    AdminDocumentationComponent,
  ],
  providers: [
    AuthGuard,
    CarService,
    DataService,
  ],
  bootstrap: [
    AdminComponent,
  ]
})
export class AppModule { }
