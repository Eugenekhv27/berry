import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { Participant } from './participant.model';
import { DataService, NotifierService } from '../services/services';

@Component({
  selector: 'app-participants',
  templateUrl: './participants.component.html'
})

export class ParticipantsComponent implements OnInit {

  participantsList: Participant[] = [];
  selectedLine: Participant;
  maxRowsPerPage = 11;
  loading: boolean;

  constructor(
    private router: Router,
    private dataService: DataService,
    private notifier: NotifierService
  ) { }

  ngOnInit() {
    this.refreshParticipantsList();
  }

  refreshParticipantsList() {
    this.loading = true;
    this.dataService.getParticipantsList()
      .subscribe((freshList: Participant[]) => {
        console.log(freshList.filter((el, ind) => ind < 9));
        this.participantsList = freshList;
        this.loading = false;
      });
  }

  onRowDoubleClick() {
    console.log('доппель-клик');
    console.log(this.selectedLine);
    this.router.navigate(['/admin/participants/' + encodeURIComponent(this.selectedLine.ID)]);
  }

  openNewParticipantForm() {
    this.router.navigate(['/admin/participants/new']);
  }
 }
