import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { Participant } from '../../shared/model/participant.model';
import { DataService, NotifierService } from '../services/services';
import {SelectItem} from 'primeng/primeng';

@Component({
  selector: 'app-participants',
  templateUrl: './participants.component.html'
})

export class ParticipantsComponent implements OnInit {

  participantsList: Participant[] = [];
  selectedLine: Participant;
  maxRowsPerPage = 11;
  loading: boolean;
  abcGroupOptions =
   [
    {label: 'Не важно', value: null},
    {label: 'A', value: 'A'},
    {label: 'B', value: 'B'},
    {label: 'C', value: 'C'}
  ];
  sexOptions =
   [
    {label: 'Не важно', value: null},
    {label: 'Неизвестно', value: 'Неизвестно'},
    {label: 'Мужской', value: 'Мужской'},
    {label: 'Женский', value: 'Женский'}
  ];

  // для фильтров
  beginRegDate: string;
  endRegDate: string;
  beginBonusSum: number;
  endBonusSum: number;
  withOnePurchase: boolean;
  abcGroup: string;
  withAttractBuyers: boolean;
  sex: string;

  ru = {
      firstDayOfWeek: 1,
      dayNames: ['Воскресенье', 'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота'],
      dayNamesShort: ["Вск", "Пон", "Вт", "Сред", "Чет", "Птн", "Суб"],
      dayNamesMin: ["Вс","Пн","Вт","Ср","Чт","Пт","Сб"],
      monthNames: [ "Январь","Февраль","Март","Апрель","Май","Июнь","Июль","Август","Сентябрь","Октябрь","Ноябрь","Декабрь" ],
      monthNamesShort: [ "Янв", "Фев", "Мар", "Апр", "Май", "Июн","Июл", "Авг", "Сент", "Окт", "Нбр", "Дек" ],
      today: 'Сегодня',
      clear: 'Очистить'
    };

  constructor(
    private router: Router,
    private dataService: DataService,
    private notifier: NotifierService
  ) { }

  ngOnInit() {
    this.refreshParticipantsList({});
  }

  refreshParticipantsList(a: any ) {
    this.loading = true;
    this.dataService.getParticipantsList(a)
      .subscribe((freshList: Participant[]) => {
        this.participantsList = freshList;
        this.loading = false;
      });
  }

  onRowDoubleClick() {
    this.router.navigate(['/participants/' + encodeURIComponent(this.selectedLine.id)]);
  }

  openNewParticipantForm() {
    this.router.navigate(['/participants/new']);
  }
  refreshParticipantsListByFilter() {
    const a = {
      'beginRegDate': this.beginRegDate,
      'endRegDate': this.endRegDate,
      'beginBonusSum': this.beginBonusSum,
      'endBonusSum': this.endBonusSum,
      'withOnePurchase': this.withOnePurchase,
      'abcGroup': this.abcGroup,
      'withAttractBuyers': this.withAttractBuyers,
      'sex': this.sex
    };
    this.refreshParticipantsList(a);
  }
 }
