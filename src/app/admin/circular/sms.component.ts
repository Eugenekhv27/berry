import { Component, OnInit, ViewChild } from '@angular/core';
import { Response } from '@angular/http';
import 'rxjs/add/operator/catch';

import { SelectItem } from 'primeng/primeng';
import { OverlayPanelModule, OverlayPanel, DataTable } from 'primeng/primeng';
import { TooltipModule } from 'primeng/primeng';
import { Message, MessagesModule } from 'primeng/primeng';
import { MultiSelectModule, MenuItem } from 'primeng/primeng';

import { Buyer } from './data/buyer';
import { DataService } from './data/data.service';

@Component({
  selector: 'app-my-app',
  styles: [`
    #btNapr { width: 200px; }
  `],
  templateUrl: '/sms.component.html',
  providers: [DataService]
})

export class SmsComponent implements OnInit {

  @ViewChild('dataTable') dt: DataTable;

  displayDialog: boolean;
  object: Buyer;
  selectedLine: Buyer;
  data: Buyer[] = [];
  lines: any[] = [];
  /// сюда выводим ошибки
  errors: Message[] = [];
  msgs: Message[] = [];
  /// для кнопки удалить
  items: MenuItem[];

  selectedBuyerLine: any; // заглушка (свойство используется в шаблоне)
  messageForSupport: string;

  constructor(private dataService: DataService) { }

  ngOnInit() {
    /// для кнопки удалить
    this.items = [
      {
        label: 'Удалить',
        icon: 'fa-close',
        command: () => { this.delete(); }
      }, {
        label: 'Отменить',
        icon: 'fa fa-hand-o-left',
        command: () => { this.displayDialog = false; this.msgs = []; }
      }
    ];

    this.dataService.getGridData('ent.Buyer')
      .subscribe((resp: Response) => {
        this.data = resp.json().children;
      });
  }

  addLine() {
    this.lines.push({ RubSum: '100' });
  }

  showDialogToAdd() {
    this.object = new Buyer(new Buyer());
    this.lines = [];
    this.displayDialog = true;
  }

  save() {
    console.log('save()');
    console.log(this.object);
    console.log(this.object.LinesForDel);
    this.msgs = [];
    const sendJson = { object: this.object };
    console.log(sendJson);
    this.dataService.saveObject('ent.Buyer', sendJson).subscribe(
      (data: Response) => {
        console.log(data);
        console.log(data.status);
        if (data.status.toString() === 'OK') {
          this.object = null;
          this.displayDialog = false;
          this.ngOnInit();
        } else {
          this.errors.push(
            { severity: 'error', summary: 'Не сохранилось!', detail: data.status.toString() }
          );
        }
      },
      (error) => {
        this.errors.push({ severity: 'error', summary: 'Не сохранилось!', detail: error });
        console.log(error);
      }
    );
  }

  delete() {
    this.msgs = [];
    this.dataService.deleteObject('ent.Buyer', this.object.objectId)
      .subscribe((data: Response) => {
        if (data.json().status === 'OK') {
          this.object = null;
          this.displayDialog = false;
          this.ngOnInit();
        } else {
          this.errors.push(
            { severity: 'error', summary: 'Не сохранилось!', detail: data.json().status }
          );
        }
      });
  }

  onRowDblclickBuyer(event: any) {
    // this.newLine = false;
    console.log(event.data);
    this.dataService.getObjectData('ent.Buyer', event.data.ID)
      .subscribe((resp: Response) => {
        console.log(resp);
        console.log(resp.json());
        if (resp.json().status === 'OK') {
          console.log('OK');
          this.object = resp.json().result;
          this.displayDialog = true;
          console.log(this.object);
        } else {
          this.errors.push(
            { severity: 'error', summary: 'Не получилось открыть!', detail: resp.json().status }
          );
        }
      });
  }

  deleteLine(line: any) {
    console.log(line);
    if (!this.object.LinesForDel) {
      this.object.LinesForDel = [];
    }
    this.object.LinesForDel.push(line);
    const index = this.lines.indexOf(line);
    this.lines.splice(index, 1);
  }

  // заглушки
  sendToSupport() {
    console.log('SmsComponent::sendToSupport()');
    console.log(this.messageForSupport);
  }

  onEditInitTable() {
    console.log('BuyerComponent::onEditInitTable()');
  }
}
