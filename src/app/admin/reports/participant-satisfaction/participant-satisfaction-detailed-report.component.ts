import { Component, OnInit } from '@angular/core';
import { Location } from '@angular/common';
import { ActivatedRoute } from '@angular/router';

import { localBeginningOfTheYear } from '../../../shared/utils';
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

  participantId: string;

  constructor(
    private location: Location,
    private route: ActivatedRoute,
    private dataService: ParticipantSatisfactionService,
  ) {
    this.reportData = new ReportModel();
  }

  // если URL-параметр парсится как дата, то возвращает Date, иначе - null
  private parseDateFromParam(dateParam: string): Date | null {
    return isNaN(Date.parse(decodeURIComponent(dateParam))) ?
      null :
      new Date(decodeURIComponent(dateParam));
  }

  ngOnInit() {
    const routeParams = this.route.snapshot.paramMap;

    this.participantId = routeParams.get('id');
    this.reportData.endDate = this.parseDateFromParam(routeParams.get('enddate'))
      || new Date();
    this.reportData.beginDate = this.parseDateFromParam(routeParams.get('begindate'))
      || localBeginningOfTheYear(this.reportData.endDate);

    this.getMainReport();
  }

  getMainReport(): void {
    this.loading = true;
    this.reportData.table.body = [];
    this.dataService.getDetailedReportData(this.participantId, this.reportData.beginDate, this.reportData.endDate)
      .subscribe( repData => {
        this.reportData = <ReportModel>repData;
        this.loading = false;
      });
  }

  goBack(): void {
    this.location.back();
  }
}
