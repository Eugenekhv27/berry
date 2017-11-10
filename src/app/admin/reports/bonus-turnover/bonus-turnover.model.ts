
import { appParseDate, appParseNumber } from '../../../shared/utils';

export class TableRow {
  public date: Date;
  public startBonus: number;
  public endBonus: number;
  public plusBonus: number;
  public minusBonus: number;

  constructor(dataRow: any) {
    this.date = appParseDate(String(dataRow.RepDate));
    this.startBonus = appParseNumber(String(dataRow.StartBonus));
    this.endBonus = appParseNumber(String(dataRow.EndBonus));
    this.plusBonus = appParseNumber(String(dataRow.PlusBonus));
    this.minusBonus = appParseNumber(String(dataRow.MinusBonus));
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
