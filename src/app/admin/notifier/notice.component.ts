
import { Component } from '@angular/core';
import { Notice } from './notice.model';
import { NotifierService } from './notifier.service';

@Component({
  selector: 'app-notice',
  templateUrl: './notice.component.html'
})
export class NoticeComponent {

  public notices: Notice[] = [];

  constructor(private notifier: NotifierService) {
    this.notifier.noticesQueue
      .subscribe( newNotice => {
        this.notices.push(newNotice);
      });
  }
}
