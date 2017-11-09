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
  InputTextModule,
  RadioButtonModule,
  CheckboxModule,
  CalendarModule,
  /*
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
  SelectButtonModule,
  TabViewModule,
  InputSwitchModule,
  OverlayPanelModule,
  TooltipModule,
  MultiSelectModule,
  DataScrollerModule,
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
import { NavComponent } from './nav/nav.component';
import { NavMenuComponent } from './nav/nav-menu.component';
import { TopBarComponent } from './top-bar/top-bar.component';
import { FooterComponent } from './footer/footer.component';
import { DashboardComponent } from './dashboard/dashboard.component';
import { OverviewBoxComponent } from './dashboard/overview-box.component';
import { ParticipantsComponent } from './participants/participants.component';
import { CircularComponent } from './circular/circular.component';
import { BonusCalculatorComponent } from './bonuses/bonus-calculator.component';
import { ParticipantSelectorComponent } from './bonuses/participant-selector.component';
import { DocumentationComponent } from './documentation/documentation.component';
import { NoticeComponent } from './notifier/notice.component';
import { ButtonWithSpinnerComponent } from './button-with-spinner/button-with-spinner.component';
import { BonusTurnoverReportComponent } from './reports/bonus-turnover/bonus-turnover-report.component';
import { ParticipantSatisfactionReportComponent } from './reports/participant-satisfaction/participant-satisfaction-report.component';
import { ABCAnalysisReportComponent } from './reports/abc-analysis/abc-analysis-report.component';
import { ParticipantDetailsComponent } from './participants/participant-details.component';


import { AdminRoutingModule } from './admin-routing.module';

// специализированные сервисы
import { ABCAnalysisService } from './reports/abc-analysis/abc-analysis.service';

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
    InputTextModule,
    RadioButtonModule,
    CheckboxModule,
    CalendarModule,
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
    OverviewBoxComponent,
    ParticipantsComponent,
    ParticipantSelectorComponent,
    CircularComponent,
    BonusCalculatorComponent,
    DocumentationComponent,
    NoticeComponent,
    ButtonWithSpinnerComponent,
    BonusTurnoverReportComponent,
    ParticipantSatisfactionReportComponent,
    ABCAnalysisReportComponent,
    ParticipantDetailsComponent,
  ],
  providers: [
    ABCAnalysisService,
  ]
})
export class AdminModule { }
