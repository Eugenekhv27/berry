import { Component, OnInit } from '@angular/core';
import { Participant } from '../participants/participant.model';
import { DataService, NotifierService, UtilsService } from '../services/services';

import { data } from './abc-analysis-mock-data';

interface TableRow {
  'phone': string;
  'balance': number;
  'plusPoints': number;
  'minusPoints': number;
}

function sanitizeNumber(v: string|number) {
  return isNaN(parseFloat(String(v))) ? 0 : parseFloat(String(v));
}

@Component({
  selector: 'app-abc-analysis-report',
  templateUrl: './abc-analysis-report.component.html'
})
export class ABCAnalysisReportComponent implements OnInit {
  maxRowsPerPage = 14;
  rowStyle = {'text-align': 'right'};
  totalsStyle = {'text-align': 'right', 'background-color': '#D9E0E7', 'font-weight': 'bold'};

  dateRange: Date[];

  startDate = new Date('2017');
  endDate = new Date();

  tableRows: TableRow[] = [];
  tableTotals = { plusBonus: 0, minusBonus: 0 };

  detailsTable = [];
  detailsTotals = { plusBonus: 0, minusBonus: 0 };

  showDetails = false;
  private mainHeader = 'ABC-анализ';
  reportHeader: string;

  selection: TableRow[] = [];

  loading: boolean;

  readonly ru = {
    firstDayOfWeek: 1,
    dayNames: ['Воскресенье', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    dayNamesShort: ['Вск', 'Пнд', 'Втр', 'Срд', 'Чтв', 'Птн', 'Сбт'],
    dayNamesMin: ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'],
    monthNames: [
      'Январь', 'Февраль', 'Март',
      'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь',
      'Октябрь', 'Ноябрь', 'Декабрь'
    ],
    monthNamesShort: [ 'Янв', 'Feb', 'Mar', 'Apr', 'Май', 'Jun', 'Jul', 'Aug', 'Сен', 'Окт', 'Nov', 'Dec' ],
    today: 'сегодня',
    clear: 'пусто'
  };

  constructor(
    private dataService: DataService,
    private notifier: NotifierService,
  ) {
    this.dateRange = [this.startDate, this.endDate];
  }

  ngOnInit() {
    this.getMainReport();
    this.back();
  }

  getMainReport() {
    // this.loading = true;
    this.tableTotals.plusBonus = 0;
    this.tableTotals.minusBonus = 0;
    this.tableRows = [];

    console.log(this.dateRange);
    console.log(this.startDate, this.endDate);

    this.tableRows = data;

    // this.dataService.getBonusReport(this.startDate, this.endDate)
    //   .subscribe((reportData: any) => {
    //     this.tableRows = reportData.rows.map(dataRow => new TableRow(dataRow));
    //     this.tableTotals.plusBonus = sanitizeNumber(reportData.totals.PlusBonus);
    //     this.tableTotals.minusBonus = sanitizeNumber(reportData.totals.MinusBonus);
    //     this.loading = false;
    //   });
  }

  // getDetailedReport(date: any) {
  //   this.loading = true;
  //   this.detailsTable = [];

  //   this.dataService.getBonusReportDetails(date)
  //     .subscribe((reportData: any) => {
  //       console.log(reportData);
  //       this.detailsTable = reportData.rows.map(dataRow => new DetailsRow(dataRow));
  //       this.detailsTotals.plusBonus = sanitizeNumber(reportData.totals.PlusPointsSum);
  //       this.detailsTotals.minusBonus = sanitizeNumber(reportData.totals.MinusPointsSum);
  //       console.log('-------');
  //       console.log(this.showDetails);

  //       this.loading = false;
  //     });
  // }

  // onRowDoubleClick(e: any) {
  //   this.showDetails = true;
  //   console.log(e);
  //   this.getDetailedReport(e.data.date);
  //   this.showDetails = true;
  //   this.reportHeader = this.mainHeader + ' за ' + this.u.formatDate(e.data.date);
  // }

  back() {
    this.showDetails = false;
    this.reportHeader = this.mainHeader;
    this.detailsTable = [];
  }
}
