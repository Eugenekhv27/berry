import { Component, OnInit, ViewChild } from '@angular/core';
// import { Response } from '@angular/http';
// import 'rxjs/add/operator/catch';

// import { SelectItem } from 'primeng/primeng';
// import { OverlayPanelModule, OverlayPanel, DataTable } from 'primeng/primeng';
// import { TooltipModule } from 'primeng/primeng';
// import { Message, MessagesModule } from 'primeng/primeng';
// import { MultiSelectModule, MenuItem } from 'primeng/primeng';
import {
  DataTable,
  Message,
  MenuItem,
} from 'primeng/primeng';

import { Participant } from './participant.model';
// import { DataService } from '../services/data.service';
import { DataService } from '../../mocks/services/data.service';

@Component({
  selector: 'app-participants-list',
  templateUrl: './participants-list.component.html'
})

export class ParticipantsListComponent implements OnInit {

  @ViewChild('dataTable') dt: DataTable;

  maxRowsPerPage = 11;

  displayDialog: boolean;
  participantToEdit: Participant;  // имя свойства было object
  participantToEditIsNew = false;
  selectedLine: Participant;
  participantsList: Participant[] = [];
  lines: any[] = [];
  /// сюда выводим ошибки
  errors: Message[] = [];
  msgs: Message[] = [];
  /// для кнопки удалить
  items: MenuItem[];

  selectedBuyerLine: any; // заглушка (свойство используется в шаблоне)

  constructor(private dataService: DataService) { }

  ngOnInit() {
    /// для кнопки удалить
    this.items = [
      {
        label: 'Удалить', icon: 'fa-close', command: () => { this.delete(); }
      }, {
        label: 'Отменить', icon: 'fa fa-hand-o-left',
        command: () => { this.displayDialog = false; this.msgs = []; }
      }
    ];

    this.participantsList = this.dataService.getGridData('ent.Participant');

    // this.dataService.getGridData('ent.Participant')
    //   .subscribe((resp: Response) => {
    //     this.participantsList = resp.json().children;
    //   });
  }

  showDialogToAdd() {
    this.participantToEdit = new Participant();
    this.participantToEditIsNew = true;
    this.displayDialog = true;
  }

  cancel() {
    console.log('---');
    console.log(this.participantToEdit);
    this.participantToEditIsNew = false;
    this.displayDialog = false;
  }

  save() {
    console.log('save() - сохранялка');
    this.cancel();
    // console.log('save()');
    // console.log(this.object);
    // console.log(this.object.LinesForDel);
    // this.msgs = [];
    // const sendJson = { object: this.object };
    // console.log(sendJson);
    // this.dataService.saveObject('ent.Participant', sendJson).subscribe(
    //   (data: Response) => {
    //     console.log(data);
    //     console.log(data.status);
    //     if (data.status.toString() === 'OK') {
    //       this.object = null;
    //       this.displayDialog = false;
    //       this.ngOnInit();
    //     } else {
    //       this.errors.push({
    //         severity: 'error',
    //         summary: 'Не сохранилось!',
    //         detail: data.status.toString()
    //       });
    //     }
    //   },
    //   (error) => {
    //     this.errors.push({
    //       severity: 'error',
    //       summary: 'Не сохранилось!',
    //       detail: error
    //     });
    //     console.log(error);
    //   }
    // );
  }

  delete() {
    console.log('delete() - удалялка');
    this.cancel();
    // this.msgs = [];
    // this.dataService.deleteObject('ent.Participant', this.object.objectId)
    //   .subscribe((data: Response) => {
    //     if (data.json().status === 'OK') {
    //       this.object = null;
    //       this.displayDialog = false;
    //       this.ngOnInit();
    //     } else {
    //       this.errors.push({
    //         severity: 'error',
    //         summary: 'Не сохранилось!',
    //         detail: data.json().status
    //       });
    //     }
    //   });
  }

  getParticipantByPhone(phone: string): Participant {
    return this.participantsList.find(p => p.phone === phone);
  }

  onRowDoubleClick({ data }) {
    console.log('доппель-клик');
    console.log(data);
    this.participantToEditIsNew = false;
    this.participantToEdit = Object.assign(
      new Participant(),
      this.getParticipantByPhone(data.phone)
    );
    this.displayDialog = true;
    // this.dataService.getObjectData('ent.Participant', event.data.ID)
    //   .subscribe((resp: Response) => {
    //     console.log(resp);
    //     console.log(resp.json());
    //     if (resp.json().status === 'OK') {
    //       console.log('OK');
    //       this.object = resp.json().result;
    //       this.displayDialog = true;
    //       console.log(this.object);
    //     } else {
    //       this.errors.push({
    //         severity: 'error',
    //         summary: 'Не получилось открыть!',
    //         detail: resp.json().status
    //       });
    //     }
    //   });
  }
}



// Object.assign(target, ...sources)

// export class DataTableCrudDemo implements OnInit {

//       displayDialog: boolean;

//       car: Car = new PrimeCar();

//       selectedCar: Car;

//       newCar: boolean;

//       cars: Car[];

//       constructor(private carService: CarService) { }

//       ngOnInit() {
//           this.carService.getCarsSmall().then(cars => this.cars = cars);
//       }



//       save() {
//           let cars = [...this.cars];
//           if(this.newCar)
//               cars.push(this.car);
//           else
//               cars[this.findSelectedCarIndex()] = this.car;

//           this.cars = cars;
//           this.car = null;
//           this.displayDialog = false;
//       }

//       delete() {
//           let index = this.findSelectedCarIndex();
//           this.cars = this.cars.filter((val,i) => i!=index);
//           this.car = null;
//           this.displayDialog = false;
//       }

//       onRowSelect(event) {
//           this.newCar = false;
//           this.car = this.cloneCar(event.data);
//           this.displayDialog = true;
//       }

//       cloneCar(c: Car): Car {
//           let car = new PrimeCar();
//           for(let prop in c) {
//               car[prop] = c[prop];
//           }
//           return car;
//       }

//       findSelectedCarIndex(): number {
//           return this.cars.indexOf(this.selectedCar);
//       }
//   }

//   class PrimeCar implements Car {

//       constructor(public vin?, public year?, public brand?, public color?) {}
//   }
