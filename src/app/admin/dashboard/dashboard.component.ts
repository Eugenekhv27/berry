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
  incomingByWeekDayPeriod: Date[] = [];
  disabledDays = [0, 1, 2, 3, 4, 5, 6];
  
  incomingByWeekDayBeginDate;
  topClientsPeriod: Date[] = [];
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
  incomingByMonth;
  incomingByMonthBeginDate: string;
  topClientsData = {};

  sexData;
  ageData;
  averageCheckData;
  averageCheckMax = 3000;

  ageSections = [
    {color: '#1976D2', rangeValues : [0, 17]},
    {color: '#d23819', rangeValues : [18, 22]},
    {color: '#ff0095', rangeValues : [23, 45]},
    {color: '#00ff04', rangeValues : [46, 100]}
  ];
  averageCheckSections = [
    {color: '#1976D2', rangeValues : [0, 100]},
    {color: '#d23819', rangeValues : [100, 500]},
    {color: '#ff0095', rangeValues : [500, 3000]}
  ];
  constructor(private dataService: DataService) { }

  ngOnInit() {
    const curDate = new Date();
    this.beginDate = this.dateToString(new Date(curDate.getFullYear(), curDate.getMonth(), 1)) ;
    this.endDate = this.dateToString(curDate) ;

    this.kpiBeginDate = this.beginDate;
    this.kpiEndDate = this.endDate;
    this.kpiPeriod[0] = new Date(curDate.getFullYear(), curDate.getMonth(), 1);
    this.kpiPeriod[1] = new Date();
    this.topClientsPeriod[0] = new Date(curDate.getFullYear(), curDate.getMonth(), 1);
    this.topClientsPeriod[1] = new Date();
    // для графика выручка по дням недели отчет за последние 7 дней
    this.incomingByWeekDayPeriod[0] = new Date(curDate.setTime(curDate.getTime() - (7 * 24 * 60 * 60 * 1000)));
    this.incomingByWeekDayPeriod[1] = new Date();
    this.incomingByWeekDayBeginDate = this.dateToString(this.incomingByWeekDayPeriod[0]);
    this.incomingByMonthBeginDate = this.dateToString(new Date(curDate.getFullYear() - 1, curDate.getMonth(), 1)) ;
    this.disabledDays.splice(curDate.getDay(), 1);
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
      const reportCriteria5 = {
          'reportName': 'age-chart',
          'ageSections': this.ageSections
        };
      this.dataService.getReportData(reportCriteria5)
        .subscribe((repData) => {
          this.ageData = repData;
        });
      const reportCriteria6 = {
          'reportName': 'average-check-chart',
          'averageCheckSections': this.averageCheckSections
        };
      this.dataService.getReportData(reportCriteria6)
        .subscribe((repData) => {
          this.averageCheckData = repData;
        });
      const reportCriteria7 = {
          'reportName': 'incoming-by-month-report',
          'beginDate': this.incomingByMonthBeginDate,
          'endDate': this.endDate
        };
      this.dataService.getReportData(reportCriteria7)
        .subscribe((repData) => {
          this.incomingByMonth = repData;
        });
  }
  private dateToString(d: Date) {
    return ('00' + (d.getDate())).slice(-2)
    + '.' + ('00' + (d.getMonth() + 1)).slice(-2)
    + '.' + d.getFullYear();
  }
kpiDateOnClose() {
  this.kpiBeginDate = this.dateToString(this.kpiPeriod[0]);
  this.kpiEndDate = this.dateToString(this.kpiPeriod[1]);
  const reportCriteria1 = {
    'reportName': 'sellers-kpi-report',
    'beginDate': this.kpiBeginDate,
    'endDate': this.kpiEndDate
  };
  this.dataService.getReportData(reportCriteria1)
    .subscribe((repData) => {
      this.sellersKpiData = repData;
      // this.loading = false;
    });

  }
  incomingByWeekDayUpate() {
    const beginDate = this.dateToString(this.incomingByWeekDayPeriod[0]);
    const endDate = this.dateToString(this.incomingByWeekDayPeriod[1]);
    const reportCriteria2 = {
      'reportName': 'incoming-by-week-day-report',
      'beginDate': beginDate,
      'endDate': endDate
    };
  this.dataService.getReportData(reportCriteria2)
    .subscribe((repData) => {
      this.incomingByWeekDay = repData;
        // this.loading = false;
    });
  }
  topClientsUpdate() {
    const beginDate = this.dateToString(this.topClientsPeriod[0]);
    const endDate = this.dateToString(this.topClientsPeriod[1]);
    const reportCriteria3 = {
      'reportName': 'top-clients-report',
      'beginDate': beginDate,
      'endDate': endDate
    };
  this.dataService.getReportData(reportCriteria3)
    .subscribe((repData) => {
      this.topClientsData = repData;
        // this.loading = false;
    });
  }
  // методы для диаграммы возраста
  ageAddSection() {
    this.ageSections.push({color: '#00ff04', rangeValues : [60, 100]});
  }
  ageDeleteSection() {
    this.ageSections.splice(this.ageSections.length - 1, 1);
  }
  ageRangeValuesChange(e, i) {
    if (i > 0) {
      this.ageSections[i - 1].rangeValues = [this.ageSections[i - 1].rangeValues[0], e.values[0]];
    }
    if (i < (this.ageSections.length - 1)) {
      this.ageSections[i + 1].rangeValues = [e.values[1], this.ageSections[i + 1].rangeValues[1]];
    }
  }
  ageUpdate() {
    const reportCriteria5 = {
      'reportName': 'age-chart',
      'ageSections': this.ageSections
    };
  this.dataService.getReportData(reportCriteria5)
    .subscribe((repData) => {
      this.ageData = repData;
        // this.loading = false;
    });
  }
  // методы для диаграммы среднего чека
  averageCheckAddSection() {
    this.averageCheckSections.push({color: '#00ff04', rangeValues : [500, this.averageCheckMax]});
  }
  averageCheckDeleteSection() {
    this.averageCheckSections.splice(this.averageCheckSections.length - 1, 1);
  }
  averageCheckRangeValuesChange(e, i) {
    if (i > 0) {
      this.averageCheckSections[i - 1].rangeValues = [this.averageCheckSections[i - 1].rangeValues[0], e.values[0]];
    }
    if (i < (this.averageCheckSections.length - 1)) {
      this.averageCheckSections[i + 1].rangeValues = [e.values[1], this.averageCheckSections[i + 1].rangeValues[1]];
    }
  }
  averageCheckMaxChange() {
    let index;
    for (index = 0; index < this.averageCheckSections.length; ++index) {
      this.averageCheckSections[index] = this.averageCheckSections[index];
    }
    this.averageCheckSections[(this.averageCheckSections.length - 1)].rangeValues =
      [this.averageCheckSections[(this.averageCheckSections.length - 1)].rangeValues[0],
      this.averageCheckMax];
  }
  averageCheckUpdate() {
    const reportCriteria6 = {
      'reportName': 'average-check-chart',
      'averageCheckSections': this.averageCheckSections
    };
  this.dataService.getReportData(reportCriteria6)
    .subscribe((repData) => {
      this.averageCheckData = repData;
        // this.loading = false;
    });
  }
}
