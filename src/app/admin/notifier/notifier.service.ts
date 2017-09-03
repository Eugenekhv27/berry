import { Subject } from 'rxjs/Subject';
import { Injectable } from '@angular/core';
import { Notice } from './notice.model';

@Injectable()
export class NotifierService {

  public noticesQueue = new Subject<Notice>();
  private idHead = 0;

  constructor() {
  }

  private getNextID() {
    this.idHead += 1;
    return String(this.idHead);
  }

  public success(messageContent: string, summary: string, additionalProperties?: any): void {
    this.createMessage('success', summary, messageContent, additionalProperties);
  }

  public info(messageContent: string, summary: string, additionalProperties?: any): void {
    this.createMessage('info', summary, messageContent, additionalProperties);
  }

  public warning(messageContent: string, summary: string, additionalProperties?: any): void {
    this.createMessage('warn', summary, messageContent, additionalProperties);
  }

  public error(messageContent: string, summary: string, additionalProperties?: any): void {
    this.createMessage('error', summary, messageContent, additionalProperties);
  }

  private createMessage(severity: string, summary: string, detail: string, additionalProperties?: any): void {
    if (additionalProperties) {
      this.noticesQueue.next({ id: this.getNextID(), severity, summary, detail, additionalProperties });
    } else {
      this.noticesQueue.next({ id: this.getNextID(), severity, summary, detail });
    }
  }
}
