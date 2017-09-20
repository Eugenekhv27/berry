import { Component, OnInit } from '@angular/core';
import { Participant } from '../participants/participant.model';
import { DataService, NotifierService } from '../services/services';

function parseDate(s: string) {
  const ps = s
    .split('.')
    .map(v => parseInt(v, 10));
  return new Date(ps[2], ps[1] - 1, ps[0]);
}

class TableRow {
  public date: Date;
  public startBonus: number;
  public endBonus: number;
  public plusBonus: number;
  public minusBonus: number;

  constructor(dataRow: any) {
    // const d =
    //   .split('.')
    //   .map(s => parseInt(s, 10));

    this.date = parseDate(String(dataRow.RepDate));
    // console.log(this.formatDateToString());
    this.startBonus = parseFloat(String(dataRow.StartBonus));
    this.endBonus = parseFloat(String(dataRow.EndBonus));
    this.plusBonus = parseFloat(String(dataRow.PlusBonus));
    this.minusBonus = parseFloat(String(dataRow.MinusBonus));
  }
}

class DetailsRow {
  public phone: string;
  public plusBonus: number;
  public minusBonus: number;

  constructor(dataRow: any) {
    this.phone = String(dataRow.Aka).trim();
    this.plusBonus = parseFloat(String(dataRow.PlusPointsSum));
    this.minusBonus = parseFloat(String(dataRow.MinusPointsSum));
  }
}

@Component({
  selector: 'app-report',
  templateUrl: './report.component.html'
})
export class ReportComponent implements OnInit {
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
  private mainHeader = 'Отчет по бонусным баллам';
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
    private notifier: NotifierService
  ) {
    this.dateRange = [this.startDate, this.endDate];
  }

  ngOnInit() {
    this.getMainReport();
    this.back();

  }

  formatNumberToString(n: number, size = 2, zero = '') {
    return n ? n.toFixed(size) : zero;
  }

  formatDateToString(d: Date) {
    return new Intl.DateTimeFormat('ru-RU').format(d);
  }

  getMainReport() {
    this.loading = true;
    this.tableTotals.plusBonus = 0;
    this.tableTotals.minusBonus = 0;
    this.tableRows = [];

    console.log(this.dateRange);
    console.log(this.startDate, this.endDate);

    this.dataService.getBonusReport(this.startDate, this.endDate)
      .subscribe((reportData: any) => {
        this.tableRows = reportData.rows.map(dataRow => new TableRow(dataRow));
        this.tableTotals.plusBonus = parseFloat(String(reportData.totals.PlusBonus));
        this.tableTotals.minusBonus = parseFloat(String(reportData.totals.MinusBonus));
        this.loading = false;
      });
  }

  getDetailedReport(date: any) {
    this.loading = true;
    this.detailsTable = [];

    this.dataService.getBonusReportDetails(date)
      .subscribe((reportData: any) => {
        console.log(reportData);
        this.detailsTable = reportData.rows.map(dataRow => new DetailsRow(dataRow));
        this.detailsTotals.plusBonus = parseFloat(String(reportData.totals.PlusPointsSum));
        this.detailsTotals.minusBonus = parseFloat(String(reportData.totals.MinusPointsSum));
        console.log('-------');
        console.log(this.showDetails);

        this.loading = false;
      });
  }

  onRowDoubleClick(e: any) {
    this.showDetails = true;
    console.log(e);
    this.getDetailedReport(e.data.date);
    this.showDetails = true;
    this.reportHeader = this.mainHeader + ' за ' + this.formatDateToString(e.data.date);
  }

  back() {
    this.showDetails = false;
    this.reportHeader = this.mainHeader;
    this.detailsTable = [];
  }
}
