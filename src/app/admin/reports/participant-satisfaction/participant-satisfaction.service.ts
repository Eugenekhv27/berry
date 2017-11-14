/**
 * Этот сервис поставляет данные для отчета "Удовлетворенность участников" и
 * также отвечает за обработку ошибок при получении данных.
 * Провайдер декларируется локально в компоненте.
 */
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';

import { NotifierService } from '../../services/services';
import { RestService } from '../../../shared/services/rest.service';
import { ReportModel } from '../shared/report.model';

@Injectable()
export class ParticipantSatisfactionService {

  constructor(
    private rest: RestService,
    private notifier: NotifierService
  ) {}

  getReportData(startDate: Date, endDate: Date) {
    return this.rest.getData('/admin/reports/satisfaction', { startDate, endDate })
      .map((data: any) => {
        const report = new ReportModel();
        report.beginDate = new Date(data.beginDate);
        report.endDate = new Date(data.endDate);
        report.table = data['table'];
        console.log(report);
        return report;
      })
      .catch((err: any, caught: Observable<any>) => {
        // TODO: здесь надо написать вменяемую обработку ошибок и выдачу сообщений в NotifierService
        this.notifier.error('Ошибка!', 'Данные не получены');
        console.error(err);
        return Observable.of([]);
      });
  }
}
