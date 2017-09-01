import { Component, OnInit } from '@angular/core';

import { CarService } from '../../mocks/services/car.service';
import { Car } from '../../mocks/shared/car';

@Component({
  templateUrl: './dashboard.component.html'
})
export class AdminDashboardComponent implements OnInit {
  cars: Car[];
  chartData: any;

  constructor(private carService: CarService) { }

  ngOnInit() {
    this.carService.getCarsSmall().then(cars => this.cars = cars);

    this.chartData = {
      labels: ['January', 'February', 'March', 'April', 'May', 'June', 'July'],
      datasets: [
        {
          label: 'First Dataset',
          data: [65, 59, 80, 81, 56, 55, 40],
          fill: false,
          borderColor: '#FFC107'
        },
        {
          label: 'Second Dataset',
          data: [28, 48, 40, 19, 86, 27, 90],
          fill: false,
          borderColor: '#03A9F4'
        }
      ]
    }
  }
}
