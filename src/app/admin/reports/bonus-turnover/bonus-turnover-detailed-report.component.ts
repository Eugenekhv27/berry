import { Component, OnInit } from '@angular/core';
import { Location } from '@angular/common';
import { ActivatedRoute } from '@angular/router';

import { BonusTurnoverService } from './bonus-turnover.service';

@Component({
  selector: 'app-bonus-turnover-detailed-report',
  templateUrl: './bonus-turnover-detailed-report.component.html'
})
export class BonusTurnoverDetailedReportComponent implements OnInit {
  maxRowsPerPage = 14;
  totalsStyle = {'text-align': 'right', 'background-color': '#D9E0E7', 'font-weight': 'bold'};
  date: Date;
  reportData: any;
  loading: boolean;

  constructor(
    private location: Location,
    private route: ActivatedRoute,
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
    const dateParam = this.route.snapshot.paramMap.get('date');

    // если параметр есть и он парсится как дата, то берем это значение
    dateParam && !isNaN(Date.parse(decodeURIComponent(dateParam))) ?
      this.date = new Date(decodeURIComponent(dateParam)) :
      this.date = new Date(); // иначе берем текущую дату

    this.getReport(this.date);
  }

  getReport(date: Date) {
    this.loading = true;
    this.resetReportData();

    this.reportDataService.getDetailedReportData(date)
      .subscribe((reportData: any) => {
        this.reportData = reportData;
        this.loading = false;
      });
  }

  goBack(): void {
    this.location.back();
  }
}
