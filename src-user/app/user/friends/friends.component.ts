import { Component, Input } from '@angular/core';
import { DataService } from '../services/services';
import { Friends } from './friends.model';

@Component({
  selector: 'app-friends',
  templateUrl: './friends.component.html',
})
export class FriendsComponent {

  isPhoneEntered = false;
 
  constructor(
    private dataService: DataService,
  ) { }
  
  friend = {
    tel: '',
    transferBonuses: 0
  }
  onclick() {

  }
}
