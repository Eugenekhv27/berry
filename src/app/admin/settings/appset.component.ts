import { Input, Component, EventEmitter, Output, OnInit } from '@angular/core';
// import { Observable } from 'rxjs/Observable';
// import { Http, Response, Headers } from '@angular/http';
// import 'rxjs/add/operator/map';
// import 'rxjs/add/operator/catch';
// import 'rxjs/add/observable/throw';

// import { Message } from 'primeng/primeng';
// import { SelectItem } from 'primeng/primeng';
import { AppSet } from './appset';
// import { DataService } from './data/data.service';

@Component({
  selector: 'app-my-appset',
  templateUrl: '/appset.component.html',
//  providers: [DataService]
})
export class AppSetComponent implements OnInit {
  @Input()
  object: AppSet = new AppSet(null, 'hello@progrepublic.ru', null, '5', '3', '2');

//  errors: Message[] = [];

//  constructor(private dataService: DataService) { }

  ngOnInit() {
    // this.dataService.getAppSetData()
    //   .subscribe((resp: Response) => {

    //     if (resp.json().status === 'OK') {
    //       console.log('OK');
    //       this.object = resp.json().result;
    //       console.log(this.object);
    //     }
    //   });
  }

  save() {
    console.log('lksadkjflasdjkdsjaf s dlakjf dsjfldsj ');
  //   const sendJson = { object: this.object };

  //   this.dataService.saveObject('admin.AppSet', sendJson)
  //     .subscribe((data: Response) => {
  //       if (data.status.toString() !== 'OK') {
  //         this.errors.push(
  //           { severity: 'error', summary: 'Не сохранилось!', detail: data.status.toString() }
  //         );
  //       }
  //     });
  }
}
