// системные
import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';

// библиотечные
import {
  ButtonModule,
  GrowlModule,
  ToolbarModule,
  InputMaskModule,
  AccordionModule,
  RatingModule,
  PanelModule,
/*
  TreeTableModule,
  TreeNode,
  SharedModule
  CarouselModule,
  OverlayPanelModule,
  DataListModule,
  PanelModule,
  DataTableModule,
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

// наши
import { UserComponent } from './user.component';
import { TopBarComponent } from './top-bar/top-bar.component';
import { HelpRequestComponent } from './help/help-request.component';
import { NoticeComponent } from './notifier/notice.component';
import { AdvertisementPanelComponent } from './adv-panel/adv-panel.component';
import { BalanceComponent } from './balance/balance.component';
import { HistoryComponent } from './history/history.component';

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
    // TreeTableModule,
    // OverlayPanelModule,
    // DataListModule,
    // DataTableModule,
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
    UserComponent,
    TopBarComponent,
    HelpRequestComponent,
    NoticeComponent,
    AdvertisementPanelComponent,
    BalanceComponent,
    HistoryComponent,
  ]
})
export class UserModule { }
