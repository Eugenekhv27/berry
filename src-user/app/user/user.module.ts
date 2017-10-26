// System
import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';

// UI library components
import {
  ButtonModule,
  GrowlModule,
  ToolbarModule,
  InputMaskModule,
  AccordionModule,
  RatingModule,
  PanelModule,
/*
  ProgressBarModule,
  OverlayPanelModule,
  TreeTableModule,
  TreeNode,
  SharedModule
  CarouselModule,
  DataTableModule,
  DataListModule,
  PanelModule,
  ChartModule,
  MessagesModule,
  SplitButtonModule,
  DialogModule,
  InputTextModule,
  RadioButtonModule,
  CheckboxModule,
  CalendarModule,
  MegaMenuModule,
  MenubarModule,
  MenuItem,
  SharedModule,
  DropdownModule,
  SelectItem,
  FieldsetModule,
  ListboxModule,
  AutoCompleteModule,
  SelectButtonModule,
  TabViewModule,
  InputSwitchModule,
  TooltipModule,
  MultiSelectModule,
  DataScrollerModule,
  InputTextareaModule,
  TriStateCheckboxModule,
*/
} from 'primeng/primeng';

// Application components
import { UserComponent } from './user.component';
import { TopBarComponent } from './top-bar/top-bar.component';
import { ButtonWithSpinnerComponent } from './button-with-spinner/button-with-spinner.component';
import { HomepageComponent } from './homepage/homepage.component';
import { LoginComponent } from './login/login.component';
import { HelpRequestComponent } from './help/help-request.component';
import { NoticeComponent } from './notifier/notice.component';
import { AdvertisementPanelComponent } from './adv-panel/adv-panel.component';
import { BalanceComponent } from './balance/balance.component';
import { HistoryComponent } from './purchase-history/purchase-history.component';
import { PurchaseComponent } from './purchase-history/purchase.component';

// Application pipes
import { SafeHtmlPipe } from './adv-panel/safe-html.pipe';

// Application modules
import { UserRoutingModule } from './user-routing.module';

@NgModule({
  imports: [
    // Angular
    CommonModule,
    FormsModule,
    // PrimeNG
    ButtonModule,
    GrowlModule,
    ToolbarModule,
    InputMaskModule,
    AccordionModule,
    RatingModule,
    PanelModule,
    // ProgressBarModule,
    // OverlayPanelModule,
    // TreeTableModule,
    // DataTableModule,
    // DataListModule,
    // ChartModule,
    // MessagesModule,
    // SplitButtonModule,
    // DialogModule,
    // InputTextModule,
    // RadioButtonModule,
    // CheckboxModule,
    // CalendarModule,
    // routing
    UserRoutingModule,
  ],
  declarations: [
    // components
    UserComponent,
    TopBarComponent,
    ButtonWithSpinnerComponent,
    HomepageComponent,
    LoginComponent,
    HelpRequestComponent,
    NoticeComponent,
    AdvertisementPanelComponent,
    BalanceComponent,
    HistoryComponent,
    PurchaseComponent,
    // pipes
    SafeHtmlPipe,
  ]
})
export class UserModule { }
