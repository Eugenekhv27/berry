import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { AdminComponent } from './admin.component';
import { LoginComponent } from './login/login.component';
import { DashboardComponent } from './dashboard/dashboard.component';
import { ParticipantsComponent } from './participants/participants.component';
import { CircularComponent } from './circular/circular.component';
import { BonusCalculatorComponent } from './bonuses/bonus-calculator.component';
import { DocumentationComponent } from './documentation/documentation.component';
import { ReportComponent } from './report/report.component';

import { AuthGuard } from './services/services';

const routes: Routes = [{
  path: '',
  component: AdminComponent,
  children: [
    { path: 'login', component: LoginComponent },
    { path: 'documentation', component: DocumentationComponent },
    { path: 'dashboard', component: DashboardComponent, canActivate: [AuthGuard] },
    { path: 'participants', component: ParticipantsComponent, canActivate: [AuthGuard] },
    { path: 'report', component: ReportComponent, canActivate: [AuthGuard] },
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
