import { Component, OnInit, ViewChild } from '@angular/core';
import { NotifierService } from '../services/services';
import { ParticipantSelectorComponent } from './participant-selector.component';
import { ButtonWithSpinnerComponent } from '../button-with-spinner/button-with-spinner.component';

@Component({
  selector: 'app-bonus-calculator',
  templateUrl: './bonus-calculator.component.html'
})
export class BonusCalculatorComponent implements OnInit {
  
  changeBy = '10';
  private savingTimeoutID: any = null;


  @ViewChild(ParticipantSelectorComponent)
  private selectionTable: ParticipantSelectorComponent;

  @ViewChild(ButtonWithSpinnerComponent)
  private saveButton: ButtonWithSpinnerComponent;

  constructor(
    private notifier: NotifierService
  ) { }

  ngOnInit() {
    this.selectionTable.setCalculationFunction(elem => {
      const delta = Number.parseFloat(this.changeBy);

      
        elem.changePoints = delta;
        if (elem.points === 0) {
          elem.changePercent = delta === 0 ? 0 : 9999.99;
        } else {
          elem.changePercent = (delta / elem.points) * 100;
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

  calculatePoints(): void {
    console.log(this.changeBy);
    console.log(this.selectionTable.selection);
    this.selectionTable.calculateChanges();
  }

  save(): void {
    if (this.savingTimeoutID) {
      return;
    }
    this.saveButton.spin();
    this.savingTimeoutID = setTimeout(() => {
      
      this.saveButton.stopSpin();
      this.savingTimeoutID = null;
      this.notifier.success('Выполнено', 'Данные успешно сохранены');
    } , 3000);
  }
}
