import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

import { russianCalendarLocale } from '../../../shared/locale';
import { localBeginningOfTheYear } from '../../../shared/utils';
import { ParticipantSatisfactionService } from './participant-satisfaction.service';
import { TableRow } from './participant-satisfaction.model';
import { ReportModel } from '../shared/report.model';

@Component({
  selector: 'app-participant-satisfaction-report',
  templateUrl: './participant-satisfaction-report.component.html',
  providers: [ ParticipantSatisfactionService ]
})
export class ParticipantSatisfactionReportComponent implements OnInit {
  readonly calendarLocale = russianCalendarLocale;
  maxRowsPerPage = 14;
  totalsStyle = {'text-align': 'right', 'background-color': '#D9E0E7', 'font-weight': 'bold'};
  reportData: ReportModel;
  loading: boolean;

  constructor(
    private router: Router,
    private dataService: ParticipantSatisfactionService,
  ) {
    this.reportData = new ReportModel();
  }

  ngOnInit(): void {
    this.getMainReport();
  }

  getMainReport(): void {
    this.loading = true;
    this.reportData.table.body = [];
    this.dataService.getReportData(this.reportData.beginDate, this.reportData.endDate)
      .subscribe( repData => {
        this.reportData = <ReportModel>repData;
        this.loading = false;
      });
  }

  getDetails(elem: any): void {
    console.log(elem);
    this.router.navigate(['/admin/reports/satisfaction/details']);
  }
}
