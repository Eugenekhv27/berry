// системные
import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';

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

// наши
import { AdminComponent } from './admin.component';
import { AdminLoginComponent } from './login/login.component';
import { AdminHelpComponent } from './help/help.component';
import { AdminNavComponent, AdminNavMenuComponent } from './nav/nav.component';
import { AdminTopBarComponent } from './top-bar/top-bar.component';
import { AdminFooterComponent } from './footer/footer.component';
import { AdminDashboardComponent } from './dashboard/dashboard.component';
import { AdminParticipantsListComponent } from './participants/participants-list.component';
import { AdminCircularComponent } from './circular/circular.component';
import { AdminReferralSettingsComponent } from './settings/referral-settings.component';
import { AdminDocumentationComponent } from './documentation/documentation.component';

import { NoticeComponent } from './notifier/notice.component';
import { NotifierService } from './notifier/notifier.service';

import { AdminRoutingModule } from './admin-routing.module';

@NgModule({
  imports: [
    // Angular
    CommonModule,
    FormsModule,
    // PrimeNG
    PanelModule,
    DataTableModule,
    ChartModule,
    GrowlModule,
    MessagesModule,
    SplitButtonModule,
    InputMaskModule,
    // routing
    AdminRoutingModule,
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
    NoticeComponent
  ],
  providers: [
    NotifierService
  ]
})
export class AdminModule { }
