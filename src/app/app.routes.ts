import { Routes, RouterModule } from '@angular/router';
import { ModuleWithProviders } from '@angular/core';

import { AdminDashboardComponent } from './admin/dashboard/dashboard.component';
import { AdminParticipantsListComponent } from './admin/participants/participants-list.component';
import { AdminReferralSettingsComponent } from './admin/settings/referral-settings.component';
import { AdminDocumentationComponent } from './admin/documentation/documentation.component';

const routes: Routes = [
  { path: 'dashboard', component: AdminDashboardComponent },
  { path: 'participants-list', component: AdminParticipantsListComponent },
  { path: 'settings', component: AdminReferralSettingsComponent },
  { path: 'documentation', component: AdminDocumentationComponent }
];

export const AppRoutes: ModuleWithProviders = RouterModule.forRoot(routes);
