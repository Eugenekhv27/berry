
import { russianCalendarLocale } from '../../../shared/locale';
import { localBeginningOfTheYear } from '../../../shared/utils';

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
  settings = { calendarLocale: russianCalendarLocale, maxRowsPerPage: 14};

  constructor() {
    this.table = { body: [], totals: {} };
    this.endDate = new Date();
    this.beginDate = localBeginningOfTheYear(this.endDate);
  }
}
