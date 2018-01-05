import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

import { russianCalendarLocale } from '../../../shared/locale';
import { ReportModel } from '../shared/report.model';
import { DataService, NotifierService } from '../../../admin/services/services';

interface TableRow {
  id: string;
  name: string;
  attractedClients: number;
  saleSum: number;
  averageCheck: number;
  qtyCheck: number;
}

@Component({
  // tslint:disable-next-line:component-selector
  selector: 'sellers-kpi-report',
  templateUrl: './sellers-kpi-report.component.html',
  providers: [ DataService ]
})
export class SellersKpiReportComponent implements OnInit {
  readonly calendarLocale = russianCalendarLocale;
  maxRowsPerPage = 14;
  reportData: Array<TableRow>;
  reportTotals = {'attractedClients': 0, 'saleSum': 0, 'qtyCheck': 0};
  loading: boolean;
  /// Критерии отчета
  beginDate;
  endDate;

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
      'reportName': 'sellers-kpi-report',
      'beginDate': this.beginDate,
      'endDate': this.endDate
    };
    this.dataService.getReportData(reportCriteria)
      .subscribe((repData) => {
        this.reportData = repData.children;
        this.reportTotals = repData.totals;
        this.loading = false;
      });
  }

  // getDetails(selectedRow: TableRow): void {
  //   this.router.navigate(['/participants/' + encodeURIComponent(selectedRow.id)]);
  // }

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
