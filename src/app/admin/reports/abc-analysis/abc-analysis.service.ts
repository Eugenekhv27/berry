import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';

import { TreeNode } from 'primeng/primeng';

import { NotifierService } from '../../services/services';
import { RestService } from '../../../shared/services/rest.service';

@Injectable()
export class ABCAnalysisService {

  constructor(
    private rest: RestService,
    private notifier: NotifierService
  ) {}

  getReportData(startDate: Date, endDate: Date) {
    return this.rest.getData('/admin/reports/abc', { startDate, endDate })
      .map((result: any) => {
        return result['data']['tableData']['body'];
      })
      .catch((err: any, caught: Observable<any>) => {
        // TODO: здесь надо написать вменяемую обработку ошибок и выдачу сообщений в NotifierService
        this.notifier.error('Ошибка!', 'Данные не получены');
        return Observable.of([]);
      });
  }
}
