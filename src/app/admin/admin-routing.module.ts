import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { AdminComponent } from './admin.component';
import { LoginComponent } from './login/login.component';
import { DashboardComponent } from './dashboard/dashboard.component';
import { ParticipantsComponent } from './participants/participants.component';
import { ParticipantDetailsComponent } from './participants/participant-details.component';
import { CircularComponent } from './circular/circular.component';
import { BonusCalculatorComponent } from './bonuses/bonus-calculator.component';
import { DocumentationComponent } from './documentation/documentation.component';
import { BonusTurnoverReportComponent } from './reports/bonus-turnover/bonus-turnover-report.component';
import { BonusTurnoverDetailedReportComponent } from './reports/bonus-turnover/bonus-turnover-detailed-report.component';
import { ParticipantSatisfactionReportComponent
} from './reports/participant-satisfaction/participant-satisfaction-report.component';
import { ParticipantSatisfactionDetailedReportComponent
} from './reports/participant-satisfaction/participant-satisfaction-detailed-report.component';
import { ABCAnalysisReportComponent } from './reports/abc-analysis/abc-analysis-report.component';

import { AuthGuard } from './services/services';

const routes: Routes = [{
  path: '',
  component: AdminComponent,
  children: [
    { path: 'login', component: LoginComponent },
    { path: 'documentation', component: DocumentationComponent },
    { path: 'dashboard', component: DashboardComponent, canActivate: [AuthGuard] },
    { path: 'participants', component: ParticipantsComponent, canActivate: [AuthGuard] },
    { path: 'participants/:id', component: ParticipantDetailsComponent, canActivate: [AuthGuard] },
    { path: 'reports/bonuses', component: BonusTurnoverReportComponent, canActivate: [AuthGuard] },
    { path: 'reports/bonuses/:date', component: BonusTurnoverDetailedReportComponent, canActivate: [AuthGuard] },
    { path: 'reports/satisfaction', component: ParticipantSatisfactionReportComponent, canActivate: [AuthGuard] },
    { path: 'reports/satisfaction/details', component: ParticipantSatisfactionDetailedReportComponent, canActivate: [AuthGuard] },
    { path: 'reports/abc', component: ABCAnalysisReportComponent, canActivate: [AuthGuard] },
    { path: 'circular', component: CircularComponent, canActivate: [AuthGuard] },
    { path: 'bonuses', component: BonusCalculatorComponent, canActivate: [AuthGuard] },
    { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
    { path: '**', redirectTo: 'dashboard' }
  ]
}];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class AdminRoutingModule { }
