import { Component, OnInit } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { Location } from '@angular/common';
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
    private route: ActivatedRoute,
    private location: Location
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
    const begindateParam = this.route.snapshot.paramMap.get('begindate');
    const enddateParam = this.route.snapshot.paramMap.get('enddate');
    console.log(this.route.snapshot.paramMap.get('begindate'));
    console.log(this.route.snapshot.paramMap.get('enddate'));
    // если параметр есть и он парсится как дата, то берем это значение
    begindateParam && !isNaN(Date.parse(decodeURIComponent(begindateParam))) ?
      this.startDate = new Date(decodeURIComponent(begindateParam)) :
      this.startDate = new Date(); // иначе берем текущую дату
    enddateParam && !isNaN(Date.parse(decodeURIComponent(enddateParam))) ?
      this.endDate = new Date(decodeURIComponent(enddateParam)) :
      this.endDate = new Date();
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
    this.router.navigate(['/reports/bonuses/' + encodeURIComponent(date.toISOString())]);
  }
  goBack(): void {
    this.location.back();
  }
}
