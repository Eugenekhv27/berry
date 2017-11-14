import { DetailsRow } from './details-row.class';

export class OperationEditor extends DetailsRow {
  public selection: any;

  constructor() {
    super();
    this.selection = null;
    this.amount = 0;
    this.points = 0;
  }

  refreshDisplayedData(s: any) {
    this.selection = s;
    this.id = s.id;
    this.date = s.date;
    this.amount = s.amount;
    this.points = s.points;
    this.comment = s.comment;
  }

  updateRow(r: DetailsRow): DetailsRow {
    r.date = String(this.date).trim();
    r.amount = parseFloat(String(this.amount));
    r.points = parseFloat(String(this.points));
    r.comment = String(this.comment).trim();

    return r;
  }

  newRow(id: string = ''): DetailsRow {
    const r = new DetailsRow();
    r.id = id;
    this.updateRow(r);

    this.selection = null;
    return r;
  }
}
