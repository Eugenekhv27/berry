import { Component, OnInit, ViewChild } from '@angular/core';
import { Router, ActivatedRoute, ParamMap } from '@angular/router';
import { Location } from '@angular/common';
import 'rxjs/add/operator/switchMap';
import { DataService, NotifierService, UtilsService } from '../services/services';
import { DataTable } from 'primeng/primeng';
import {MenuModule, MenuItem} from 'primeng/primeng';
import {TabViewModule} from 'primeng/primeng';
import {SelectItem} from 'primeng/primeng';

import { Participant } from '../../shared/model/participant.model';
import { DetailsRow } from './details-row.class';
import { OperationEditor } from './operation-editor.class';

@Component({
  selector: 'app-participant-details',
  templateUrl: './participant-details.component.html',
})
export class ParticipantDetailsComponent implements OnInit {
  @ViewChild('dt') dt: DataTable;
  participantEditor = { id: '', date: '', balance: '', phone: '', name: '', referrer: '', comment: '', birthDate: null, sex: 'Неизвестно', age: null, payRubSum:'',payBonus:'',attractedCount:''};
//  participant: Participant;
  isNew: false;
  detailsTable = [];
  rowStyle = {'text-align': 'right', 'width': '13em'};
  loading = true;
  maxRowsPerPage = 12;

  operationEditor: OperationEditor;

  isDeleteButtonDisabled = true;

  readOnly = true;
  toDoItems: MenuItem[];
  sexOptions: SelectItem[];
  displayPlusBonusDialog: boolean = false;
  
  plusBonusEditor;
  ru = {
    firstDayOfWeek: 1,
    dayNames: ["Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"],
    dayNamesShort: ["Вск", "Пон", "Вт", "Сред", "Чет", "Птн", "Суб"],
    dayNamesMin: ["Вс","Пн","Вт","Ср","Чт","Пт","Сб"],
    monthNames: [ "Январь","Февраль","Март","Апрель","Май","Июнь","Июль","Август","Сентябрь","Октябрь","Ноябрь","Декабрь" ],
    monthNamesShort: [ "Янв", "Фев", "Мар", "Апр", "Май", "Июн","Июл", "Авг", "Сент", "Окт", "Нбр", "Дек" ],
    today: 'Сегодня',
    clear: 'Очистить'
};


  private idBase: number;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private location: Location,
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
      this.participantEditor.date = this.u.formatDate(new Date());
      this.participantEditor.birthDate = this.u.formatDate(new Date());  
    } else {
      this.getData(id);
    }
    this.operationEditor = new OperationEditor();
    this.toDoItems =
      [
        {label: 'Начислить бонусы', icon: 'fa fa-plus-square', command: () => {
          this.displayPlusBonusDialog = true;
      }},
        {label: 'Редактировать', icon: 'fa fa-pencil-square-o', command: () => {
          this.doEdit();
      }},
        {label: 'Удалить из АКБ', icon: 'fa-close', command: () => {
          this.delete();
      }}
      ];
    this.sexOptions = [
      {label:'Неизвестно', value:'Неизвестно'},
      {label:'Мужской', value:'Мужской'},
      {label:'Женский', value:'Женский'},
    ];
    const now = new Date();
    // const nowString = now.getDay.toString() + '.' + now.getMonth.toString() + '.' + // // now.getFullYear.toString();
    this.plusBonusEditor = {onDate: '', bonusSum: 0, comment: '', buyerId: id};
  }

  goBack(): void {
    this.detailsTable = [];
    this.location.back();
  }

  getData(id: string) {
    this.loading = true;
    this.detailsTable = [];

    this.dataService.getParticipantDetails(id)
      .subscribe((data: any) => {

        this.detailsTable = data.result.BonusOperations.map(dataRow => new DetailsRow(dataRow));
        this.participantEditor = {
          id: data.result._id || '',
          date: data.result.RegDate || '',
          balance: data.result.BonusSum || '',
          phone: data.result.Aka || '',
          name: data.result.Name || '',
          birthDate: data.result.BirthDate || '',
          age: data.result.age || '',
          sex: data.result.Sex || '',
          referrer: data.result.SuperBuyer ? data.result.SuperBuyer.Aka : '',
          comment: data.result.Comment || '',
          payRubSum: data.result.payRubSum || '',
          payBonus: data.result.payBonus || '',
          attractedCount: data.result.attractedCount || ''
        };

        console.log(this.participantEditor);
        
        this.loading = false;
        this.isDeleteButtonDisabled = false;
      });
  }

  createParticipantObject(): Participant {
    const p = new Participant();
    const pe = this.participantEditor;

    p.id = pe.id;
    p.phone = pe.phone.replace(/ /g, '').replace(/-/g, '');
    p.name = pe.name;
    p.birthDate = pe.birthDate;
    p.sex = pe.sex;
    p.comment = pe.comment;
    p.referrer.id = '';
    p.referrer.phone = pe.referrer;
    p.referrals = [];
    p.operations = [];
    p.shop = 'GE';

    return p;
  }
  doEdit() {
    this.readOnly = false;
  }

  save(): void {
    const request = this.dataService.saveParticipant(this.createParticipantObject());
    this.notifier.info(String(this.participantEditor.phone), 'Данные отправлены.');
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
    const ind = this.detailsTable.indexOf(this.dt.selection);
    this.detailsTable = this.detailsTable.filter((val, i) => i !== ind);
    this.dt.selection = null;
    this.operationEditor = new OperationEditor();
  }

  onRowSelect(e: any) {
    this.operationEditor.refreshDisplayedData(this.dt.selection);
  }

  private getNewId() {
    this.idBase += 1;
    return '~~' + String(this.idBase);
  }
  doPlusBonus() {
    const request = this.dataService.doPlusBonus(this.plusBonusEditor);
    request.subscribe(done => {
        if (done) {
          this.notifier.success('Ok!', 'Данные успешно сохранены.');
          this.displayPlusBonusDialog = false;
          this.getData(this.plusBonusEditor.buyerId);
        } else {
          this.notifier.error('Ошибка!', 'Не удалось сохранить.');
        }
      });
    
  }
}
