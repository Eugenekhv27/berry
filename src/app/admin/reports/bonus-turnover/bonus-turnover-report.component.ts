import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

import { russianCalendarLocale } from '../../../shared/locale';
import { localBeginningOfTheYear } from '../../../shared/utils';
import { BonusTurnoverService } from './bonus-turnover.service';
import { TableRow } from './bonus-turnover.model';

@Component({
  selector: 'app-bonus-turnover-report',
  templateUrl: './bonus-turnover-report.component.html'
})
export class BonusTurnoverReportComponent implements OnInit {
  readonly calendarLocale = russianCalendarLocale;
  reportHeader = 'Начисление и списание бонусных баллов';

  maxRowsPerPage = 14;
  totalsStyle = {'text-align': 'right', 'background-color': '#D9E0E7', 'font-weight': 'bold'};
  startDate: Date;
  endDate: Date;
  reportData: any;
  loading: boolean;

  constructor(
    private router: Router,
    private reportDataService: BonusTurnoverService,
  ) {
    this.endDate = new Date();
    this.startDate = localBeginningOfTheYear(this.endDate);
    this.resetReportData();
  }

  private resetReportData() {
    this.reportData = {
      table: [],
      totals: { plusBonus: 0, minusBonus: 0 }
    };
  }

  ngOnInit() {
    this.getMainReport();
  }

  getMainReport() {
    this.loading = true;
    this.resetReportData();
    this.reportDataService.getMainReportData(this.startDate, this.endDate)
      .subscribe((reportData: any) => {
        this.reportData.table = reportData.tableRows;
        this.reportData.totals.plusBonus = reportData.tableTotals.plusBonus;
        this.reportData.totals.minusBonus = reportData.tableTotals.minusBonus;
        this.loading = false;
      });
  }

  getDetailedReport(date: Date) {
    this.router.navigate(['/admin/reports/bonuses/' + encodeURIComponent(date.toISOString())]);
  }
}
