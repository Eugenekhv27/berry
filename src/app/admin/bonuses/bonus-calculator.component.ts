import { Component, OnInit, ViewChild } from '@angular/core';
import { NotifierService } from '../notifier/notifier.service';
import { ParticipantSelectorComponent } from './participant-selector.component';

@Component({
  selector: 'app-bonus-calculator',
  templateUrl: './bonus-calculator.component.html'
})
export class BonusCalculatorComponent implements OnInit {
  usePercents = true;
  changeBy = '123';

  @ViewChild(ParticipantSelectorComponent)
  private selectionTable: ParticipantSelectorComponent;

  constructor(
    private notifier: NotifierService
  ) { }

  ngOnInit() {
    this.selectionTable.setCalculationFunction(elem => {
      const delta = Number.parseFloat(this.changeBy);

      if (this.usePercents) {
        elem.changePoints = delta / 100 * elem.points;
        elem.changePercent = delta;
      } else {
        elem.changePoints = delta;
        if (elem.points === 0) {
          elem.changePercent = delta === 0 ? 0 : 9999.99;
        } else {
          elem.changePercent = (delta / elem.points) * 100;
        }
      }
      elem.newPoints = elem.points + elem.changePoints;

      return elem;
    });
  }

  onKey(e: any) {
    if (e.key === 'Enter') {
      this.calculatePoints();
    }
  }

  calculatePoints() {
    console.log(this.changeBy);
    console.log(this.selectionTable.selection);
    this.selectionTable.calculateChanges();
  }
}
