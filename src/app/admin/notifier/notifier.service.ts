import { Subject } from 'rxjs/Subject';
import { Injectable } from '@angular/core';
import { Notice } from './notice.model';

@Injectable()
export class NotifierService {

  public noticesQueue = new Subject<Notice>();
  private idHead = 0;

  public success = this.createMessage.bind(this, 'success');
  public info    = this.createMessage.bind(this, 'info');
  public warning = this.createMessage.bind(this, 'warn');
  public error   = this.createMessage.bind(this, 'error');

  constructor() {
  }

  private getNextID() {
    this.idHead += 1;
    return String(this.idHead);
  }

  private createMessage(severity: string, summary: string, detail: string): void {
    this.noticesQueue.next({ id: this.getNextID(), severity, summary, detail });
  }
}
