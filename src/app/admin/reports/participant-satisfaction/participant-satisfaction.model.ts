import { appParseNumber } from '../../../shared/utils';

export interface TableRow {
  phone: string;
  money: number;
  balance: number;
  minusPoints: number;
  ratedPurchases: number;
  averageRating: number;
}

export class DetailsRow {
  phone: string;
  plusBonus: number;
  minusBonus: number;

  constructor(dataRow: any) {
    this.phone = String(dataRow.Aka).trim();
    this.plusBonus = parseFloat(String(dataRow.PlusPointsSum));
    this.minusBonus = parseFloat(String(dataRow.MinusPointsSum));
  }
}
