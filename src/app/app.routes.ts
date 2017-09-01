import { Routes, RouterModule } from '@angular/router';
import { ModuleWithProviders } from '@angular/core';

import { AuthGuard } from './auth.guard';

import { AdminLoginComponent} from './admin/login/login.component';
import { AdminDashboardComponent } from './admin/dashboard/dashboard.component';
import { AdminParticipantsListComponent } from './admin/participants/participants-list.component';
import { AdminReferralSettingsComponent } from './admin/settings/referral-settings.component';
import { AdminDocumentationComponent } from './admin/documentation/documentation.component';

const adminRoutes: Routes = [
  { path: 'dashboard', component: AdminDashboardComponent, canActivate: [AuthGuard]  },
  { path: 'participants-list', component: AdminParticipantsListComponent, canActivate: [AuthGuard]  },
  { path: 'settings', component: AdminReferralSettingsComponent, canActivate: [AuthGuard]  },
  { path: 'documentation', component: AdminDocumentationComponent },
  { path: 'login', component: AdminLoginComponent },
  { path: '**', component: AdminLoginComponent }
];

export const routes: Routes = [
  { path: 'admin', children: adminRoutes }
];

export const AppRoutes: ModuleWithProviders = RouterModule.forRoot(routes);
