
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';

@Injectable()
export class DataService {

  constructor() {
  }

  sendHelpRequest(arg: any): any {
    return {};
  }

  getParticipantsList(): any {
    return Observable.of([]);
  }

  getBonusReport(startDate: any, endDate: any) {
    return Observable.of({ rows: [], totals: []});
  }

  getBonusReportDetails(date: any) {
    return Observable.of({ rows: [], totals: []});
  }

  getDashboardData() {
    return Observable.of({
      participantCount: 1,
      purchaseCount: 2,
      purchaseAmount: 3,
      averagePurchaseAmount: 4,
      chart: {
        dates: [],
        participantCount: [],
      }
    });
  }

  saveParticipant(arg: any): any {
    return {};
  }

  getGridData(className: string, query: string = ''): any {
    return Observable.of([]);
  }

  /**
   * Сервисы, используемые только в приложении для Участника
   */
  genSmsCode(arg: any): any {
    return {};
  }

  checkSmsCode(tel: any, code: any): any {
    return {};
  }
}
