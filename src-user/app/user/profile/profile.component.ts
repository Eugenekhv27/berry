import { Component, Input } from '@angular/core';
import { DataService } from '../services/services';
import { Profile } from './profile.model';

@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html',
})
export class ProfileComponent {
  @Input() profile: Profile;

  readOnly = false;
  

  constructor(
    private dataService: DataService,
  ) { }
  sexOptions = [
    {label: '', value: null},
    {label: 'Мужской', value: 'Мужской'},
    {label: 'Женский', value: 'Женский'},
  ];
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
activeButton() {
  if ((this.profile.name) && (this.profile.birthDate) && (this.profile.sex)) {
    return true;
  } else {
    return false;
  }
}
}
