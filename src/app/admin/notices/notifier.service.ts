
import { Observable } from 'rxjs/Observable';
import { Subject } from 'rxjs/Subject';
import { Injectable } from '@angular/core';
import { Notice } from './notice.model';

@Injectable()
export class NotifierService {

  private message$: Subject<Notice> = new Subject<Notice>();
  private cancel$: Subject<any> = new Subject<any>();
  private idHead = 0;

  constructor() {
  }

  private getNextID() {
    return String(this.idHead++);
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
      this.message$.next({ id: this.getNextID(), severity, summary, detail, additionalProperties });
    } else {
      this.message$.next({ id: this.getNextID(), severity, summary, detail });
    }
  }

  public clearMessages(): void {
    this.cancel$.next();
  }

  public getMessageStream(): Observable<Notice> {
    return this.message$.asObservable();
  }

  public getCancelStream(): Observable<boolean> {
    return this.cancel$.asObservable();
  }
}
