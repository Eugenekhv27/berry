import { ReportModel } from '../shared/report.model';

export class SatisfactionDetailedReportModel extends ReportModel {
  participant: { id: string, phone: string};

  constructor(dataFromJson?: any) {
    super();
    this.participant = { id: null, phone: null };

    if (dataFromJson) {
      this.beginDate = new Date(dataFromJson.beginDate);
      this.endDate = new Date(dataFromJson.endDate);
      this.participant = dataFromJson.participant;
      this.table = dataFromJson['table'];
    }
  }
}
