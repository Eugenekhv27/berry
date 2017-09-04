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
  DialogModule,
  /*
  InputTextModule,
  MegaMenuModule,
  MenubarModule,
  MenuItem,
  SharedModule,
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
import { LoginComponent } from './login/login.component';
import { HelpRequestComponent } from './help/help-request.component';
import { NavComponent, NavMenuComponent } from './nav/nav.component';
import { TopBarComponent } from './top-bar/top-bar.component';
import { FooterComponent } from './footer/footer.component';
import { DashboardComponent } from './dashboard/dashboard.component';
import { ParticipantsListComponent } from './participants/participants-list.component';
import { CircularComponent } from './circular/circular.component';
import { ReferralSettingsComponent } from './settings/referral-settings.component';
import { DocumentationComponent } from './documentation/documentation.component';
import { NoticeComponent } from './notifier/notice.component';

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
    DialogModule,
    // routing
    AdminRoutingModule,
  ],
  declarations: [
    AdminComponent,
    LoginComponent,
    HelpRequestComponent,
    NavComponent,
    NavMenuComponent,
    TopBarComponent,
    FooterComponent,
    DashboardComponent,
    ParticipantsListComponent,
    CircularComponent,
    ReferralSettingsComponent,
    DocumentationComponent,
    NoticeComponent
  ]
})
export class AdminModule { }
