import { Component, OnInit } from '@angular/core';
import { DataService } from '../services/services';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html'
})
export class DashboardComponent implements OnInit {

  participantCount: number | string = '?';
  purchaseCount: number | string = '?';
  purchaseAmount: number | string = '?';
  averagePurchaseAmount: number | string = '?';

  chartData: any;
  chartOptions: any;

  constructor(private dataService: DataService) { }

  ngOnInit() {
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
  }
}
