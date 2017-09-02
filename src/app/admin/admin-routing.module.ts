import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { AdminComponent} from './admin.component';
import { AdminLoginComponent} from './login/login.component';
import { AdminHelpComponent } from './help/help.component';
import { AdminDashboardComponent } from './dashboard/dashboard.component';
import { AdminParticipantsListComponent } from './participants/participants-list.component';
import { AdminCircularComponent } from './circular/circular.component';
import { AdminReferralSettingsComponent } from './settings/referral-settings.component';
import { AdminDocumentationComponent } from './documentation/documentation.component';

import { AuthGuard } from './services/auth-guard.service';

const routes: Routes = [{
    path: '',
    component: AdminComponent,
    children: [
      { path: 'documentation', component: AdminDocumentationComponent },
      { path: 'login', component: AdminLoginComponent },
      { path: '',
        canActivate: [AuthGuard],
        children: [
          { path: 'dashboard', component: AdminDashboardComponent  },
          { path: 'participants-list', component: AdminParticipantsListComponent },
          { path: 'circular', component: AdminCircularComponent },
          { path: 'bonus-accounting', component: AdminParticipantsListComponent },
          { path: 'settings', component: AdminReferralSettingsComponent },
          { path: 'help', component: AdminHelpComponent },
        ]
      }
//      { path: '**', component: AdminLoginComponent }
    ]
}];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class AdminRoutingModule { }
