export interface ReportTable {
  body: Array<any>;
  totals: {
    [key: string]: number | string
  };
}

export class ReportModel {
  title: string;
  beginDate: Date;
  endDate: Date;
  table: ReportTable;

  constructor() {
    this.table = { body: [], totals: {} };
  }
}
