import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

// import { TreeNode } from 'primeng/primeng';

import { russianCalendarLocale } from '../../../shared/locale';
// import { ABCAnalysisService } from './abc-analysis.service';
import { ReportModel } from '../shared/report.model';
import { DataService, NotifierService } from '../../../admin/services/services';

interface TableRow {
  id: string;
  name: string;
  balance: number;
  balanceCaregory: string;
  plusPoints: number;
  plusPointsCaregory: string;
  minusPoints: number;
  minusPointsCaregory: string;
}

@Component({
  selector: 'app-abc-analysis-report',
  templateUrl: './abc-analysis-report.component.html',
  providers: [ DataService ]
})
export class ABCAnalysisReportComponent implements OnInit {
  readonly calendarLocale = russianCalendarLocale;
  maxRowsPerPage = 14;
  reportData: Array<TableRow>;
  loading: boolean;
  displaySetting = false;
  /// Критерии отчета
  beginDate;
  endDate;
  aPrecent = 80;
  bPrecent = 15;
  cPrecent = 5;

  constructor(
    private router: Router,
    private dataService: DataService,
  ) {
    this.reportData = [];
  }

  ngOnInit(): void {
    
    const curDate = new Date();
    this.beginDate = this.dateToString(new Date(curDate.getFullYear(), curDate.getMonth(), 1)) ;
    this.endDate = this.dateToString(curDate) ;
    this.getMainReport();
  }

  getMainReport(isFix = false): void {
    console.log(this.beginDate);
    this.loading = true;
    this.reportData = [];
    const reportCriteria = {
      'reportName': 'abc-analysis-report',
      'beginDate': this.beginDate,
      'endDate': this.endDate,
      'aPrecent': this.aPrecent,
      'bPrecent': this.bPrecent,
      'cPrecent': this.cPrecent,
      'saveInBuyer': isFix
    };
    this.dataService.getReportData(reportCriteria)
      .subscribe((repData) => {
        this.reportData = repData.children;
        this.loading = false;
      });
  }

  getDetails(selectedRow: TableRow): void {
    this.router.navigate(['/participants/' + encodeURIComponent(selectedRow.id)]);
  }
  settingClick() {
    this.displaySetting = true;
  }

  /**
   * Функция isNumber() используется в шаблоне
   */
  isNumber(v: any): boolean {
    return typeof v === 'number';
  }
private dateToString(d: Date) {
    return ('00' + (d.getDate())).slice(-2)
    + '.' + ('00' + (d.getMonth() + 1)).slice(-2)
    + '.' + d.getFullYear();
  }
}
