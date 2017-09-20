import { Component, OnInit, Input, Output } from '@angular/core';
import { Participant } from '../participants/participant.model';
import { DataService, NotifierService } from '../services/services';

class TableRow {
  public id: string;
  public phone: string;
  public name: string;
  public points: number;
  public changePoints: number;
  public changePercent: number;
  public newPoints: number;

  constructor(p: Participant) {
    this.id = String(p.ID);
    this.phone = String(p.phone).trim();
    this.name = String(p.Name || '').trim();
    this.points = Number.parseFloat(String(p.Bonus));
    this.changePoints = 0;
    this.changePercent = 0;
    this.newPoints = 0;
  }
}

@Component({
  selector: 'app-participant-selector',
  templateUrl: './participant-selector.component.html'
})
export class ParticipantSelectorComponent implements OnInit {
  loading: boolean;
  tableRows: TableRow[] = [];
  maxRowsPerPage = 10;
  selection: TableRow[] = [];
  private calculateRowChanges = row => row;

  constructor(
    private dataService: DataService,
    private notifier: NotifierService
  ) { }

  ngOnInit() {
    this.refreshParticipantsList();
  }

  formatNumberToString(n: number, size = 2, zero = '') {
    return n ? n.toFixed(size) : zero;
  }

  setCalculationFunction(fn: any) {
    this.calculateRowChanges = fn;
  }

  refreshParticipantsList() {
    this.loading = true;

    this.dataService.getParticipantsList()
      .subscribe((freshList: Participant[]) => {
        console.log(freshList);
        console.log(freshList.map(p => new TableRow(p)));
        this.tableRows = freshList.map(p => new TableRow(p));
        this.clearChanges();
        this.loading = false;
      });
  }

  clearRowChanges(row: any) {
    row.changePoints = row.changePercent = row.newPoints = 0;
    return row;
  }

  calculateChanges(): void {
    this.clearChanges();
    this.selection.map(this.calculateRowChanges);
  }

  clearChanges(): void {
    this.tableRows.map(this.clearRowChanges);
  }

  onRowSelect(e) {
    this.calculateRowChanges(e.data);
  }

  onRowUnselect(e: any) {
    this.clearRowChanges(e.data);
  }

  onHeaderCheckboxToggle(e) {
    this.calculateChanges();
  }
}
