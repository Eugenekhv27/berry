
import { Component, EventEmitter, Input, Output } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/observable/empty';
import 'rxjs/add/observable/timer';
import 'rxjs/add/operator/do';
import 'rxjs/add/operator/mapTo';
import 'rxjs/add/operator/mergeMap';
import 'rxjs/add/operator/takeUntil';

import { Notice } from './notice.model';
import { NotifierService } from './notifier.service';

const DEFAULT_LIFETIME = 0;

@Component({
  selector: 'app-notice',
  templateUrl: './notice.component.html'
})
export class NoticeComponent {

  public notices: Notice[] = [];
  @Input() style: any;
  @Input() styleClass: any;
  @Input() life = DEFAULT_LIFETIME;
  @Output() onClose = new EventEmitter<Notice>();
  @Output() onClick = new EventEmitter<Notice>();
  @Output() onNoticesChanged = new EventEmitter<Array<Notice>>();

  constructor(private notiS: NotifierService) {
    this.subscribeForMessages();
  }

  public subscribeForMessages() {
    this.notices = [];
    this.notiS.getMessageStream()
      .do(message => {
        this.notices.push(message);
        this.onNoticesChanged.emit(this.notices);
      })
      .mergeMap(message => this.getLifeTimeStream(message.id))
      .takeUntil(this.notiS.getCancelStream())
      .subscribe(
      messageId => this.removeMessage(messageId),
      err => {
        throw err;
      },
      () => this.subscribeForMessages()
      );
  }

  public removeMessage(messageId: string) {
    const index = this.notices.findIndex(message => message.id === messageId);
    if (index >= 0) {
      this.notices.splice(index, 1);
      this.onNoticesChanged.emit(this.notices);
    }
  }

  public getLifeTimeStream(messageId: string): Observable<any> {
    if (this.life > DEFAULT_LIFETIME) {
      return Observable.timer(this.life)
        .mapTo(messageId);
    }
    return Observable.empty();
  }

  public noticeClosed($event) {
    this.emitMessage($event, this.onClose);
  }

  public noticeClicked($event): void {
    this.emitMessage($event, this.onClick);
  }

  emitMessage($event, emitter: EventEmitter<Notice>) {
    const message = $event.message;
    if (message) {
      emitter.next(message);
    }
  }
}
