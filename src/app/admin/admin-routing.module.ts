import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { AdminComponent} from './admin.component';
import { LoginComponent} from './login/login.component';
import { HelpRequestComponent } from './help/help-request.component';
import { DashboardComponent } from './dashboard/dashboard.component';
import { ParticipantsListComponent } from './participants/participants-list.component';
import { CircularComponent } from './circular/circular.component';
import { ReferralSettingsComponent } from './settings/referral-settings.component';
import { DocumentationComponent } from './documentation/documentation.component';

import { AuthGuard } from './services/auth-guard.service';

const routes: Routes = [{
    path: '',
    component: AdminComponent,
    children: [
      { path: 'documentation', component: DocumentationComponent },
      { path: 'login', component: LoginComponent },
      { path: '',
        canActivate: [AuthGuard],
        children: [
          { path: 'dashboard', component: DashboardComponent  },
          { path: 'participants-list', component: ParticipantsListComponent },
          { path: 'circular', component: CircularComponent },
          { path: 'bonus-accounting', component: ParticipantsListComponent },
          { path: 'settings', component: ReferralSettingsComponent },
          { path: 'help', component: HelpRequestComponent },
        ]
      }
//      { path: '**', component: LoginComponent }
    ]
}];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class AdminRoutingModule { }
