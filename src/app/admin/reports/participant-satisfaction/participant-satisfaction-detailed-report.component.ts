import { Component, OnInit } from '@angular/core';
import { Location } from '@angular/common';

import { ParticipantSatisfactionService } from './participant-satisfaction.service';
import { ReportModel } from '../shared/report.model';

@Component({
  selector: 'app-participant-satisfaction-detailed-report',
  templateUrl: './participant-satisfaction-detailed-report.component.html',
  providers: [ ParticipantSatisfactionService ]
})
export class ParticipantSatisfactionDetailedReportComponent implements OnInit {
  reportData: ReportModel;
  loading: boolean;

  constructor(
    private location: Location,
    private dataService: ParticipantSatisfactionService,
  ) {
    this.reportData = new ReportModel();
  }

  ngOnInit() {
    this.getMainReport();
  }

  getMainReport(): void {
    this.loading = true;
    this.reportData.table.body = [];
    this.dataService.getDetailedReportData(this.reportData.beginDate, this.reportData.endDate)
      .subscribe( repData => {
        this.reportData = <ReportModel>repData;
        this.loading = false;
      });
  }

  goBack(): void {
    this.location.back();
  }
}
