
import { appParseDate, appParseNumber } from '../../../shared/utils';

export class TableRow {
  public date: Date;
  public repMonth: string;
  public startBonus: number;
  public endBonus: number;
  public plusBonus: number;
  public minusBonus: number;
  public beginDate: string;
  public endDate: string;

  constructor(dataRow: any) {
    if (dataRow.RepDate) {
      this.date = appParseDate(String(dataRow.RepDate));
    }
    if (dataRow.repMonth) {
      this.repMonth = dataRow.repMonth;
    }
    this.startBonus = appParseNumber(String(dataRow.StartBonus));
    this.endBonus = appParseNumber(String(dataRow.EndBonus));
    this.plusBonus = appParseNumber(String(dataRow.PlusBonus));
    this.minusBonus = appParseNumber(String(dataRow.MinusBonus));
    this.beginDate = dataRow.beginDate;
    this.endDate = dataRow.endDate;
  }
}

export class DetailsRow {
  public phone: string;
  public plusBonus: number;
  public minusBonus: number;

  constructor(dataRow: any) {
    this.phone = String(dataRow.Aka).trim();
    this.plusBonus = appParseNumber(String(dataRow.PlusPointsSum));
    this.minusBonus = appParseNumber(String(dataRow.MinusPointsSum));
  }
}
