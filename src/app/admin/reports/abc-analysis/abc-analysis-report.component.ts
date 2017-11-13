import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

// import { TreeNode } from 'primeng/primeng';

import { russianCalendarLocale } from '../../../shared/locale';
import { localBeginningOfTheYear } from '../../../shared/utils';
import { ABCAnalysisService } from './abc-analysis.service';
import { ReportModel } from '../shared/report.model';

interface TableRow {
  id: string;
  phone: string;
  balance: number;
  plusPoints: number;
  minusPoints: number;
}

@Component({
  selector: 'app-abc-analysis-report',
  templateUrl: './abc-analysis-report.component.html'
})
export class ABCAnalysisReportComponent implements OnInit {
  readonly calendarLocale = russianCalendarLocale;
  maxRowsPerPage = 14;
  reportData: ReportModel;
  loading: boolean;

  constructor(
    private router: Router,
    private abcS: ABCAnalysisService,
  ) {
    this.reportData = new ReportModel();
    this.reportData.table.body = [];
    this.reportData.endDate = new Date();
    this.reportData.beginDate = localBeginningOfTheYear(this.reportData.endDate);
  }

  ngOnInit(): void {
    this.getMainReport();
  }

  getMainReport(): void {
    this.loading = true;
    this.reportData.table.body = [];
    this.abcS.getReportData(this.reportData.beginDate, this.reportData.endDate)
      .subscribe( repData => {
        this.reportData = <ReportModel>repData;
        this.loading = false;
      });
  }

  getDetails(selectedRow: TableRow): void {
    this.router.navigate(['/admin/participants/' + encodeURIComponent(selectedRow.id)]);
  }

  isNumber(v: any): boolean {
    return typeof v === 'number';
  }
}
