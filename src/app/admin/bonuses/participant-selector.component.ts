import { Component, OnInit, Input, Output } from '@angular/core';
import { Participant } from '../../shared/model/participant.model';
import { DataService, NotifierService, UtilsService } from '../services/services';

class TableRow {
  public id: string;
  public phone: string;
  public name: string;
  public points: number;
  public changePoints: number;
  public newPoints: number;

  public ppp: any;

  constructor(p: Participant) {
    this.id = p.id;
    this.phone = p.phone;
    this.name = p.name;
    this.points = p.balance;
    this.changePoints = 0;
    this.newPoints = 0;

    this.ppp = p;
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
    private notifier: NotifierService,
    public u: UtilsService
  ) { }

  ngOnInit() {
    this.refreshParticipantsList();
  }

  setCalculationFunction(fn: any) {
    this.calculateRowChanges = fn;
  }

  refreshParticipantsList() {
    this.loading = true;

    this.dataService.getParticipantsList()
      .subscribe((freshList: Participant[]) => {
        console.log(freshList);
        this.tableRows = freshList.map(p => new TableRow(p));
        console.log(this.tableRows);
        this.clearChanges();
        this.loading = false;
      });
  }

  clearRowChanges(row: any) {
    row.changePoints = row.newPoints = 0;
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
