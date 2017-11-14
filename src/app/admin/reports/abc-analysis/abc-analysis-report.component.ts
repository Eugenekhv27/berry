import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

// import { TreeNode } from 'primeng/primeng';

import { russianCalendarLocale } from '../../../shared/locale';
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
  templateUrl: './abc-analysis-report.component.html',
  providers: [ ABCAnalysisService ]
})
export class ABCAnalysisReportComponent implements OnInit {
  readonly calendarLocale = russianCalendarLocale;
  maxRowsPerPage = 14;
  reportData: ReportModel;
  loading: boolean;

  constructor(
    private router: Router,
    private dataService: ABCAnalysisService,
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

  getDetails(selectedRow: TableRow): void {
    this.router.navigate(['/admin/participants/' + encodeURIComponent(selectedRow.id)]);
  }

  /**
   * Функция isNumber() используется в шаблоне
   */
  isNumber(v: any): boolean {
    return typeof v === 'number';
  }
}
