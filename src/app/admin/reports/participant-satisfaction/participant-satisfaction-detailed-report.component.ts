import { Component, OnInit } from '@angular/core';
import { Location } from '@angular/common';
import { ActivatedRoute } from '@angular/router';

import { localBeginningOfTheYear } from '../../../shared/utils';
import { ParticipantSatisfactionService } from './participant-satisfaction.service';
import { SatisfactionDetailedReportModel } from './participant-satisfaction.model';

@Component({
  selector: 'app-participant-satisfaction-detailed-report',
  templateUrl: './participant-satisfaction-detailed-report.component.html',
  providers: [ ParticipantSatisfactionService ]
})
export class ParticipantSatisfactionDetailedReportComponent implements OnInit {
  reportData: SatisfactionDetailedReportModel;
  loading: boolean;

  constructor(
    private location: Location,
    private route: ActivatedRoute,
    private dataService: ParticipantSatisfactionService,
  ) {
    this.reportData = new SatisfactionDetailedReportModel();
  }

  // если URL-параметр парсится как дата, то возвращает Date, иначе - null
  private parseDateFromParam(dateParam: string): Date | null {
    return isNaN(Date.parse(decodeURIComponent(dateParam))) ?
      null :
      new Date(decodeURIComponent(dateParam));
  }

  ngOnInit() {
    const routeParams = this.route.snapshot.paramMap;

    this.reportData.participant.id = routeParams.get('id');
    this.reportData.endDate = this.parseDateFromParam(routeParams.get('enddate'))
      || new Date();
    this.reportData.beginDate = this.parseDateFromParam(routeParams.get('begindate'))
      || localBeginningOfTheYear(this.reportData.endDate);

    this.getMainReport();
  }

  getMainReport(): void {
    console.log('отчет');
    console.log(this.reportData);

    this.loading = true;
    this.reportData.table.body = [];
    this.dataService.getDetailedReportData(
      this.reportData.participant.id,
      this.reportData.beginDate,
      this.reportData.endDate
    ).subscribe( repData => {
      this.reportData = <SatisfactionDetailedReportModel>repData;
      this.loading = false;
    });
  }

  goBack(): void {
    this.location.back();
  }
}
