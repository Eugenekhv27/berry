import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { AuthGuard } from './services/auth.guard';
import { AdminComponent} from './admin.component';
import { AdminLoginComponent} from './login/login.component';
import { AdminHelpComponent } from './help/help.component';
import { AdminDashboardComponent } from './dashboard/dashboard.component';
import { AdminParticipantsListComponent } from './participants/participants-list.component';
import { AdminCircularComponent } from './circular/circular.component';
import { AdminReferralSettingsComponent } from './settings/referral-settings.component';
import { AdminDocumentationComponent } from './documentation/documentation.component';

const routes: Routes = [{
    path: '',
    component: AdminComponent,
    children: [
      { path: 'dashboard', component: AdminDashboardComponent, canActivate: [AuthGuard]  },
      { path: 'participants-list', component: AdminParticipantsListComponent, canActivate: [AuthGuard]  },
      { path: 'circular', component: AdminCircularComponent, canActivate: [AuthGuard]  },
      { path: 'bonus-accounting', component: AdminParticipantsListComponent, canActivate: [AuthGuard]  },
      { path: 'settings', component: AdminReferralSettingsComponent, canActivate: [AuthGuard]  },
      { path: 'documentation', component: AdminDocumentationComponent },
      { path: 'login', component: AdminLoginComponent },
      { path: 'help', component: AdminHelpComponent },
      { path: '**', component: AdminLoginComponent }
    ]
}];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class AdminRoutingModule { }
