import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/delay';

import { NotifierService } from '../services/services';
import { data } from './abc-analysis-mock-data';

@Injectable()
export class ABCAnalysisService {
  private restServerName = 'base.progrepublic.ru';

  getReportData(startDate: Date, endDate: Date) {
    console.log('ABCAnalysisService::getReportData()', startDate, endDate);
    return Observable.of(data).delay(1200);
  }
}
