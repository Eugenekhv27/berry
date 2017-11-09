import { Component, OnInit } from '@angular/core';
import { ABCAnalysisService } from './abc-analysis.service';

import { russianCalendarLocale } from '../../shared/locale';

import { data } from './abc-analysis-mock-data';

interface TableRow {
  'phone': string;
  'balance': number;
  'plusPoints': number;
  'minusPoints': number;
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
  tableRows: TableRow[] = [];
  reportHeader = 'ABC-анализ';
  loading: boolean;

  constructor(
    private abcData: ABCAnalysisService,
  ) {
    this.startDate = new Date('2017');
    this.endDate = new Date();
  }

  ngOnInit() {
    this.getMainReport();
  }

  getMainReport() {
    // this.loading = true;
    this.tableRows = [];

    console.log(this.startDate, this.endDate);

    this.tableRows = data;
  }

  getDetails(selectedRow: any) {
    console.log(selectedRow);
  }
}
