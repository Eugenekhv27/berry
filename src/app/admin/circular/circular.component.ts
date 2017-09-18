import { Component, OnInit, ViewChild } from '@angular/core';
import { Response } from '@angular/http';
import 'rxjs/add/operator/catch';

import {
  DataTable,
  Message, MessagesModule,
  MultiSelectModule, MenuItem
} from 'primeng/primeng';

import { Participant } from '../participants/participant.model';
import { DataService } from '../services/services';

@Component({
  selector: 'app-circular',
  styles: [`
    #btNapr { width: 200px; }
  `],
  templateUrl: './circular.component.html',
  providers: [DataService]
})
export class CircularComponent implements OnInit {

  @ViewChild('dataTable') dt: DataTable;

  displayDialog: boolean;
  object: Participant;
  selectedLine: Participant;
  data: Participant[] = [];
  lines: any[] = [];

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
        command: () => { this.displayDialog = false; }
      }
    ];

    this.refreshParticipantsList();
  }

  refreshParticipantsList() {
    this.dataService.getParticipantsList()
      .subscribe((freshList: Participant[]) => {
        this.data = freshList;
      });
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
    // этот метод здесь, скорее всего, не нужен
    console.log('save()');
  }

  delete() {
    // этот метод здесь, скорее всего, не нужен
    console.log('delete()');
  }

  onRowDblclickBuyer(event: any) {
    // этот метод здесь, скорее всего, не нужен
    console.log('onRowDblclickBuyer()');
    console.log(event.data);
  }

  deleteLine(line: any) {
    // этот метод здесь, скорее всего, не нужен
    console.log('delete()');
    console.log(line);
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
