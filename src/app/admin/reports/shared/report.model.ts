export class ReportModel {
  title: string;
  beginDate: Date;
  endDate: Date;
  table = {
    body: [],
    totals: {}
  };

  constructor() {
  }
}
