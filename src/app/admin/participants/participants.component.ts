import { Component, OnInit, ViewChild } from '@angular/core';
import { Response } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/catch';
import 'rxjs/add/operator/finally';

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
import { DataService } from '../services/services';
import { NotifierService } from '../services/services';

@Component({
  selector: 'app-participants',
  templateUrl: './participants.component.html'
})

export class ParticipantsComponent implements OnInit {

  @ViewChild('dataTable') dt: DataTable;

  maxRowsPerPage = 11;

  loading: boolean;
  displayDialog: boolean;
  participantToEdit: Participant;  // имя свойства было object
  participantToEditIsNew = false;
  selectedLine: Participant;
  participantsList: Participant[] = [];
  lines: any[] = [];
  /// сюда выводим ошибки
  errors: Message[] = [];
  msgs: Message[] = [];

  selectedBuyerLine: any; // заглушка (свойство используется в шаблоне)

  constructor(
    private dataService: DataService,
    private notifier: NotifierService
  ) { }

  ngOnInit() {
    this.refreshParticipantsList();
  }

  refreshParticipantsList() {
    this.loading = true;
    this.dataService.getParticipantsList()
      .subscribe((freshList: Participant[]) => {
        console.log(freshList.filter((el, ind) => ind < 9));
        this.participantsList = freshList;
        this.loading = false;
      });
  }

  showDialogToAdd() {
    this.participantToEdit = new Participant();
    this.participantToEditIsNew = true;
    this.displayDialog = true;
  }

  cancel() {
    console.log('- cancel() / cleanup -');
    console.log(this.participantToEdit);
    this.participantToEdit = null;
    this.participantToEditIsNew = false;
    this.displayDialog = false;
    this.refreshParticipantsList();
  }

  save(): void {
    console.log('save()');
    const request = this.dataService.saveParticipant(this.participantToEdit);
    this.notifier.info(String(this.participantToEdit.phone), 'Данные отправлены.');
    request.subscribe(done => {
        if (done) {
          this.notifier.success('Ok!', 'Данные успешно сохранены.');
          this.cancel();
        } else {
          this.notifier.error('Ошибка!', 'Не удалось сохранить элемент.');
        }
      });
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
