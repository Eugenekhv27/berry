// системные
import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';

// библиотечные
import {
  ToolbarModule,
  InputMaskModule,
  AccordionModule,
  OverlayPanelModule,
  DataListModule,
/*
  PanelModule,
  DataTableModule,
  ChartModule,
  GrowlModule,
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
  ButtonModule,
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

import { UserRoutingModule } from './user-routing.module';

@NgModule({
  imports: [
    // Angular
    CommonModule,
    FormsModule,
    // PrimeNG
    ToolbarModule,
    InputMaskModule,
    AccordionModule,
    OverlayPanelModule,
    DataListModule,
    // PanelModule,
    // DataTableModule,
    // ChartModule,
    // GrowlModule,
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
  ]
})
export class UserModule { }
