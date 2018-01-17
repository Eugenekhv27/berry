import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

// import { TreeNode } from 'primeng/primeng';
import { MenuItem} from 'primeng/primeng';

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
  items = [
    {label: 'Отправить SMS', icon: 'fa fa-fw fa-bullhorn', routerLink: ['/circular']},
    {label: 'Начислить бонусы', icon: 'fa fa-fw fa-star', routerLink: ['/bonuses']}
  ];
  /// Критерии отчета
  beginDate;
  endDate;
  aPrecent = 80;
  bPrecent = 15;
  cPrecent = 5;
  sex: string;
  beginAge: number;
  endAge: number;
  abcPlus: string;
  abcBalance: string;
  abcMinus: string;

  sexOptions =
   [
    {label: 'Не важно', value: null},
    {label: 'Неизвестно', value: 'Неизвестно'},
    {label: 'Мужской', value: 'Мужской'},
    {label: 'Женский', value: 'Женский'}
  ];
  abcGroupOptions =
  [
   {label: 'Не важно', value: null},
   {label: 'A', value: 'A'},
   {label: 'B', value: 'B'},
   {label: 'C', value: 'C'}
 ];

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
    this.loading = true;
    this.reportData = [];
    const reportCriteria = {
      'reportName': 'abc-analysis-report',
      'beginDate': this.beginDate,
      'endDate': this.endDate,
      'aPrecent': this.aPrecent,
      'bPrecent': this.bPrecent,
      'cPrecent': this.cPrecent,
      'saveInBuyer': isFix,
      'sex': this.sex,
      'beginAge': this.beginAge,
      'endAge': this.endAge,
      'abcPlus': this.abcPlus,
      'abcBalance': this.abcBalance,
      'abcMinus': this.abcMinus
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
