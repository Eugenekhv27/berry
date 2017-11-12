import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

import { TreeNode } from 'primeng/primeng';

import { russianCalendarLocale } from '../../../shared/locale';
import { localBeginningOfTheYear } from '../../../shared/utils';
import { ABCAnalysisService } from './abc-analysis.service';

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
  startDate: Date;
  endDate: Date;
  reportTableData: TreeNode[] = [];
  loading: boolean;

  constructor(
    private router: Router,
    private abcS: ABCAnalysisService,
  ) {
    this.endDate = new Date();
    this.startDate = localBeginningOfTheYear(this.endDate);
  }

  ngOnInit() {
    this.getMainReport();
  }

  getMainReport() {
    this.loading = true;
    this.reportTableData = [];
    this.abcS.getReportData(this.startDate, this.endDate)
      .subscribe( data => {
        this.reportTableData = data;
        this.loading = false;
      });
  }

  getDetails(selectedRow: TableRow) {
    this.router.navigate(['/admin/participants/' + encodeURIComponent(selectedRow.id)]);
  }

  isNumber(v: any) {
    return typeof v === 'number';
  }
}
