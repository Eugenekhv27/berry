import { Component, OnInit } from '@angular/core';
import { Location } from '@angular/common';

import { DataService, NotifierService } from '../../services/services';
import { russianCalendarLocale } from '../../../shared/locale';
import { localBeginningOfTheYear } from '../../../shared/utils';

@Component({
  selector: 'app-participant-satisfaction-detailed-report',
  templateUrl: './participant-satisfaction-detailed-report.component.html'
})
export class ParticipantSatisfactionDetailedReportComponent implements OnInit {
  readonly calendarLocale = russianCalendarLocale;

  maxRowsPerPage = 14;
  rowStyle = {'text-align': 'right'};
  totalsStyle = {'text-align': 'right', 'background-color': '#D9E0E7', 'font-weight': 'bold'};

  startDate: Date;
  endDate: Date;

  detailsTable = [];
  detailsTotals = { plusBonus: 0, minusBonus: 0 };

  loading: boolean;

  constructor(
    private location: Location,
    private dataService: DataService,
    private notifier: NotifierService,
  ) {
    this.endDate = new Date();
    this.startDate = localBeginningOfTheYear(this.endDate);
  }

  ngOnInit() {
    this.getMainReport();
  }

  getMainReport() {
    // this.loading = true;

    console.log(this.startDate, this.endDate);
  }

  getDetailedReport(date: any) {
  //  this.loading = true;
  //  this.detailsTable = [];
  }

  onRowDoubleClick(e: any) {
    console.log(e);
  }

  goBack(): void {
    this.location.back();
  }
}
