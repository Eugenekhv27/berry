import { Component, OnInit } from '@angular/core';
import { Participant } from '../participants/participant.model';
import { DataService, NotifierService, UtilsService } from '../services/services';
import { russianCalendarLocale } from '../../shared/locale';

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

function sanitizeNumber(v: string|number) {
  return isNaN(parseFloat(String(v))) ? 0 : parseFloat(String(v));
}

@Component({
  selector: 'app-bonus-turnover-report',
  templateUrl: './bonus-turnover-report.component.html'
})
export class BonusTurnoverReportComponent implements OnInit {
  readonly calendarLocale = russianCalendarLocale;

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
  private mainHeader = 'Начисление и списание бонусных баллов';
  reportHeader: string;

  selection: TableRow[] = [];

  loading: boolean;

  constructor(
    private dataService: DataService,
    private notifier: NotifierService,
    public u: UtilsService
  ) {
    this.dateRange = [this.startDate, this.endDate];
  }

  ngOnInit() {
    this.getMainReport();
    this.back();

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
        this.tableTotals.plusBonus = sanitizeNumber(reportData.totals.PlusBonus);
        this.tableTotals.minusBonus = sanitizeNumber(reportData.totals.MinusBonus);
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
        this.detailsTotals.plusBonus = sanitizeNumber(reportData.totals.PlusPointsSum);
        this.detailsTotals.minusBonus = sanitizeNumber(reportData.totals.MinusPointsSum);
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
    this.reportHeader = this.mainHeader + ' за ' + this.u.formatDate(e.data.date);
  }

  back() {
    this.showDetails = false;
    this.reportHeader = this.mainHeader;
    this.detailsTable = [];
  }
}
