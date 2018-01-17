import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

import { russianCalendarLocale } from '../../../shared/locale';
import { localBeginningOfTheYear } from '../../../shared/utils';
import { BonusTurnoverService } from './bonus-turnover.service';
import { TableRow } from './bonus-turnover.model';

@Component({
  selector: 'app-bonus-turnover-year-report',
  templateUrl: './bonus-turnover-year-report.component.html'
})
export class BonusTurnoverYearReportComponent implements OnInit {
  readonly calendarLocale = russianCalendarLocale;
  reportHeader = 'Начисление и списание бонусов';

  maxRowsPerPage = 14;
  totalsStyle = {'text-align': 'right', 'background-color': '#D9E0E7', 'font-weight': 'bold'};
  reportData: any;
  loading: boolean;

  startDate: Date;
  endDate: Date;

  constructor(
    private router: Router,
    private reportDataService: BonusTurnoverService,
  ) {
    this.resetReportData();
  }

  private resetReportData() {
    this.reportData = {
      table: [],
      totals: { plusBonus: 0, minusBonus: 0 }
    };
  }

  ngOnInit() {
    this.startDate = new Date(2017, 1, 1);
    this.endDate = new Date();
    this.getMainReport();
  }

  getMainReport() {
    this.loading = true;
    this.resetReportData();
    this.reportDataService.getYearReportData(this.startDate, this.endDate)
      .subscribe((reportData: any) => {
        this.reportData.table = reportData.tableRows;
        this.reportData.totals.plusBonus = reportData.tableTotals.plusBonus;
        this.reportData.totals.minusBonus = reportData.tableTotals.minusBonus;
        this.loading = false;
      });
  }

  getDetailedReport(line: any) {
    console.log(line);
     // this.router.navigate(['/reports/bonuses/' + encodeURIComponent(date.toISOString())]);
     this.router.navigate(['/reports/bonuses/' + encodeURIComponent(line.beginDate) + '/' + encodeURIComponent(line.endDate)]);
  }
}
