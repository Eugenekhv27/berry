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
  templateUrl: './participants-list.component.html',
  providers: [DataService]
})

export class ParticipantsListComponent implements OnInit {

  @ViewChild('dataTable') dt: DataTable;

  maxRowsPerPage = 10;
  rowsSelectionMode = 'single';

  displayDialog: boolean;
  object: Participant;
  selectedLine: Participant;
  data: Participant[] = [];
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

    this.data = this.dataService.getGridData('ent.Participant');

    // this.dataService.getGridData('ent.Participant')
    //   .subscribe((resp: Response) => {
    //     this.data = resp.json().children;
    //   });
  }

  addLine() {
    this.lines.push({ RubSum: '100' });
  }

  showDialogToAdd() {
    this.object = new Participant(new Participant());
    this.lines = [];
    this.displayDialog = true;
  }

  save() {
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

  public onRowClick(event: any) {
    console.log('клик');
    console.log(event.data);
    this.selectedLine = event.data;
  }

  onRowDoubleClick(event: any) {
    console.log('доппель-клик');
    console.log(event.data);
    this.rowsSelectionMode = '';
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

  deleteLine(line: any) {
    // console.log(line);
    // if (!this.object.LinesForDel) {
    //   this.object.LinesForDel = [];
    // }
    // this.object.LinesForDel.push(line);
    // const index = this.lines.indexOf(line);
    // this.lines.splice(index, 1);
  }

  onEditInitTable() {
    console.log('BuyerComponent::onEditInitTable()');
  }
}
