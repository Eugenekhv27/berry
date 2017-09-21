import { Component, OnInit, ViewChild } from '@angular/core';
import { NotifierService, DataService } from '../services/services';
import { ParticipantSelectorComponent } from './participant-selector.component';
import { ButtonWithSpinnerComponent } from '../button-with-spinner/button-with-spinner.component';

@Component({
  selector: 'app-bonus-calculator',
  templateUrl: './bonus-calculator.component.html'
})
export class BonusCalculatorComponent implements OnInit {
  usePercents = false;
  changeBy = '1';
  private savingTimeoutID: any = null;


  @ViewChild(ParticipantSelectorComponent)
  private selectionTable: ParticipantSelectorComponent;

  @ViewChild(ButtonWithSpinnerComponent)
  private saveButton: ButtonWithSpinnerComponent;

  constructor(
    private notifier: NotifierService,
    private dataService: DataService
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

  private onKey(e: any) {
    if (['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-',
      'Enter', 'Backspace', 'Delete'].includes(e.key)) {
      this.calculatePoints();
    }
  }

  private calculatePoints(): void {
    this.selectionTable.calculateChanges();
  }

  private isReadyToSave(): boolean {
    let isReady = true;

    if (isNaN(parseFloat(this.changeBy))) {
      isReady = false;
      this.notifier.warning('Неправильное значение: ' + this.changeBy, 'Введите число');
    }


    if (parseFloat(this.changeBy) === 0) {
      isReady = false;
      this.notifier.warning('На задана величина изменения', 'Введите ненулевое значение');
    }

    if (this.selectionTable.selection.length < 1) {
      isReady = false;
      this.notifier.warning('Не выбраны участники!', 'Выберите участников для начисления баллов');
    }

    return isReady;
  }

  private save(): void {
    if (!this.isReadyToSave()) {
      return;
    }

    this.saveButton.spin();

    this.dataService
      .changeBonusPoints(
      parseFloat(this.changeBy),
      this.selectionTable.selection.map(elem => String(elem.id))
      )
      .subscribe(sendSuccess => {
        if (sendSuccess) {
          this.notifier.success('Ok!', 'Данные успешно сохранены.');
          this.changeBy = '0';
        } else {
          this.notifier.error('Ошибка!', 'Не удалось сохранить данные.');
        }
        this.saveButton.stopSpin();
      });
  }
}
