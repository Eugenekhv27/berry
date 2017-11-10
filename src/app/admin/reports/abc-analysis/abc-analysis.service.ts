import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/delay';

import { TreeNode } from 'primeng/primeng';

import { NotifierService } from '../../services/services';
import { abc_json } from './abc-analysis-mock-data';


@Injectable()
export class ABCAnalysisService {
  private restServerName = 'base.progrepublic.ru';

  getReportData(startDate: Date, endDate: Date) {
    console.log('ABCAnalysisService::getReportData()', startDate, endDate);
    return Observable.of(<TreeNode[]> JSON.parse(abc_json).abc).delay(1200);
  }
}
