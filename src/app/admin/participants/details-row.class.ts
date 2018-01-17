
export class DetailsRow {
  public id: string;
  public date: string;
  public amount: number;
  public points: number;
  public comment: string;

  constructor(dataRow: any = {_id: '', DocDate: '', RubSum: '', PointsSum: '', Comment: ''}) {
    if (dataRow) {
      this.id = String(dataRow._id).trim();
      this.date = String(dataRow.DocDate).trim();
      this.amount = parseFloat(String(dataRow.RubSum));
      this.points = parseFloat(String(dataRow.PointsSum));
      this.comment = String(dataRow.Comment).trim();
    }
  }
}
