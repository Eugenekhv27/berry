import { Component, OnInit, ViewChild } from '@angular/core';
import { Router, ActivatedRoute, ParamMap } from '@angular/router';
import 'rxjs/add/operator/switchMap';
import { DataService, NotifierService, UtilsService } from '../services/services';
import { DataTable } from 'primeng/primeng';

import { DetailsRow } from './details-row.class';
import { OperationEditor } from './operation-editor.class';

@Component({
  selector: 'app-participant-details',
  templateUrl: './participant-details.component.html',
})
export class ParticipantDetailsComponent implements OnInit {
  @ViewChild('dt') dt: DataTable;
  participant = { id: '', date: '', balance: '', phone: '', name: '', referrer: '', comment: ''};
  isNew: false;
  detailsTable = [];
  rowStyle = {'text-align': 'right', 'width': '13em'};
  loading = true;
  maxRowsPerPage = 12;

  operationEditor: OperationEditor;

  isDeleteButtonDisabled = true;

  private idBase: number;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private notifier: NotifierService,
    private dataService: DataService,
    public u: UtilsService
  ) {
    this.idBase = new Date().getTime();
  }

  ngOnInit() {
    const id = this.route.snapshot.paramMap.get('id');
    if (id === 'new') {
      this.detailsTable = [];
      this.loading = false;
      this.participant.date = this.u.formatDate(new Date());
    } else {
      this.getData(id);
    }
    this.operationEditor = new OperationEditor();
  }

  back() {
    this.detailsTable = [];
    this.router.navigate(['/admin/participants']);
  }

  getData(id: string) {
    this.loading = true;
    this.detailsTable = [];

    this.dataService.getParticipantDetails(id)
      .subscribe((data: any) => {
        console.log(data);
        this.detailsTable = data.result.BonusOperations.map(dataRow => new DetailsRow(dataRow));
        this.participant = {
          id: data.result._id || '',
          date: data.result.RegDate || '',
          balance: data.result.BonusSum || '',
          phone: data.result.Aka || '',
          name: data.result.Name || '',
          referrer: data.result.SuperBuyer ? data.result.SuperBuyer.Aka : '',
          comment: data.result.Comment || ''
        };
        this.loading = false;
        this.isDeleteButtonDisabled = false;

        console.log(this.detailsTable);
        console.log(this.participant);

      });
  }

  save(): void {
    console.log('save()');
    const request = this.dataService.saveParticipant(this.participant);
    this.notifier.info(String(this.participant.phone), 'Данные отправлены.');
    request.subscribe(done => {
        if (done) {
          this.notifier.success('Ok!', 'Данные успешно сохранены.');
        } else {
          this.notifier.error('Ошибка!', 'Не удалось сохранить элемент.');
        }
      });
  }

  delete() {
    console.log('delete() - удалялка');
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

  private lastPageFirstRowIndex() {
    return  Math.floor(this.detailsTable.length / this.maxRowsPerPage) * this.maxRowsPerPage;
  }

  saveLine() {
    const ind = this.detailsTable.indexOf(this.dt.selection);
    this.operationEditor.updateRow(this.detailsTable[ind]);
    this.detailsTable = [...this.detailsTable];
  }

  newLine() {
    const newTable = [...this.detailsTable];

    newTable.push(this.operationEditor.newRow(this.getNewId()));
    this.detailsTable = newTable;
    /*
    * Если нужно программным образом выбрать строку таблицы, то нужно свойству selection
    *  присвоить ссылку на соответствующий элемент массива значений, привязанного к таблице.
    */
    this.dt.selection = this.detailsTable[this.detailsTable.length - 1];
    /*
    * Если нужно программным образом перейти на другую страницу паджинатора,
    * то нужно задать индекс первой строки и выполнить paginate()
    */
    this.dt.first = this.lastPageFirstRowIndex();
    this.dt.paginate();
    setTimeout(() => this.operationEditor.refreshDisplayedData(this.dt.selection), 0);
  }

  deleteLine() {
    console.log(this.dt.selection);
    const ind = this.detailsTable.indexOf(this.dt.selection);
    this.detailsTable = this.detailsTable.filter((val, i) => i !== ind);
    this.dt.selection = null;
    this.operationEditor = new OperationEditor();
  }

  onRowSelect(e: any) {
    console.log('onRowSelect() - селектилка');
    console.log(this.dt.selection);

    this.operationEditor.refreshDisplayedData(this.dt.selection);
  }

  private getNewId() {
    this.idBase += 1;
    return '~~' + String(this.idBase);
  }
}
