import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

import { ParticipantSatisfactionService } from './participant-satisfaction.service';
import { ReportModel } from '../shared/report.model';

@Component({
  selector: 'app-participant-satisfaction-report',
  templateUrl: './participant-satisfaction-report.component.html',
  providers: [ ParticipantSatisfactionService ]
})
export class ParticipantSatisfactionReportComponent implements OnInit {
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

  private isFirstColumnClicked(event: any): boolean {
    let content;

    if (event.originalEvent.target.tagName === 'SPAN') {
      content = event.originalEvent.target.previousElementSibling;
    } else if (event.originalEvent.target.tagName === 'TD') {
      content = event.originalEvent.target.firstElementChild;
    }

    return (content.tagName.toLowerCase() === 'span'
      && content.className.toLowerCase() === 'ui-column-title'
      && content.innerHTML.toLowerCase() === 'участник');
  }

  getDetails(event: any): void {
    const selectedRow = event.data;

    // если клик на перовой колонке, то открыть карточку участника
    if (this.isFirstColumnClicked(event)) {
        this.router.navigate(['/admin/participants/' + encodeURIComponent(selectedRow.id)]);
    } else {
      // если на любой другой - детализированный отчет
      this.router.navigate(['/admin/reports/satisfaction/details']);
    }
  }
}
