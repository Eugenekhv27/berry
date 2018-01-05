import { Component, OnInit } from '@angular/core';
import { DataService } from '../services/services';
import { russianCalendarLocale } from '../../shared/locale';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html'
})
export class DashboardComponent implements OnInit {
  readonly calendarLocale = russianCalendarLocale;
  beginDate;
  endDate;
  // KPI
  kpiBeginDate: string;
  kpiEndDate: string;
  kpiPeriod: Date[] = [];
  
  incomingByWeekDayBeginDate;
  participantCount: number | string = '?';
  purchaseCount: number | string = '?';
  purchaseAmount: number | string = '?';
  averagePurchaseAmount: number | string = '?';

  chartData: any;
  chartOptions: any;

  sellersKpiData = {'totals': {'attractedClients': 0, 'saleSum': 0, 'qtyCheck': 0}};

  incomingByWeekDay = {
    labels: ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'],
    datasets: [
      {
        label: 'Новые клиенты',
        backgroundColor: '#42A5F5',
        borderColor: '#1E88E5',
        data: [0, 0, 0, 0, 0, 0, 0]
      },
      {
        label: 'Повторные покупки',
        backgroundColor: '#9CCC65',
        borderColor: '#7CB342',
        data: [0, 0, 0, 0, 0, 0, 0]
      }
    ]
  };
  topClientsData = {};

  sexData;

  constructor(private dataService: DataService) { }

  ngOnInit() {
    const curDate = new Date();
    this.beginDate = this.dateToString(new Date(curDate.getFullYear(), curDate.getMonth(), 1)) ;
    this.endDate = this.dateToString(curDate) ;

    this.kpiBeginDate = this.beginDate;
    this.kpiEndDate = this.endDate;
    this.kpiPeriod[0] = new Date(curDate.getFullYear(), curDate.getMonth(), 1);
    this.kpiPeriod[1] = new Date();
    // для графика выручка по дням недели отчет за последние 7 дней
    this.incomingByWeekDayBeginDate = this.dateToString(
      new Date(
          curDate.setTime(curDate.getTime() - (7 * 24 * 60 * 60 * 1000))
        )
      );

    this.chartOptions = {
      title: {
        display: true,
        text: 'Количество участников'.toUpperCase(),
        fontSize: 20
      },
      legend: {
        display: false
      }
    };

    this.getData();
  }

  private newChartData(x: any[], y: any[]) {
    return {
      labels: x,
      datasets: [
        {
          label: '',
          data: y,
          fill: false,
          borderColor: '#FFC107'
        }
      ]
    };
  }

  getData() {
    this.dataService.getDashboardData()
      .subscribe((dd: any) => {
        this.participantCount = dd.participantCount;
        this.purchaseCount = dd.purchaseCount;
        this.purchaseAmount = dd.purchaseAmount;
        this.averagePurchaseAmount = dd.averagePurchaseAmount;

        this.chartData = this.newChartData(dd.chart.dates, dd.chart.participantCount);
      });
      const reportCriteria1 = {
        'reportName': 'sellers-kpi-report',
        'beginDate': this.beginDate,
        'endDate': this.endDate
      };
      this.dataService.getReportData(reportCriteria1)
        .subscribe((repData) => {
          this.sellersKpiData = repData;
          // this.loading = false;
        });
      const reportCriteria2 = {
          'reportName': 'incoming-by-week-day-report',
          'beginDate': this.beginDate,
          'endDate': this.endDate
        };
      this.dataService.getReportData(reportCriteria2)
        .subscribe((repData) => {
          this.incomingByWeekDay = repData;
            // this.loading = false;
        });
      const reportCriteria3 = {
          'reportName': 'top-clients-report',
          'beginDate': this.beginDate,
          'endDate': this.endDate
        };
      this.dataService.getReportData(reportCriteria3)
        .subscribe((repData) => {
          this.topClientsData = repData;
            // this.loading = false;
        });
      const reportCriteria4 = {
          'reportName': 'sex-chart',
          'beginDate': this.beginDate,
          'endDate': this.endDate
        };
      this.dataService.getReportData(reportCriteria4)
        .subscribe((repData) => {
          this.sexData = repData;
        });
  }
  private dateToString(d: Date) {
    return ('00' + (d.getDate())).slice(-2)
    + '.' + ('00' + (d.getMonth() + 1)).slice(-2)
    + '.' + d.getFullYear();
  }
kpiDateOnClose() {
  // this.kpiBeginDate = this.kpiPeriod

  }
}
