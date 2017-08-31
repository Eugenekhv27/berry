import { Routes, RouterModule } from '@angular/router';
import { ModuleWithProviders } from '@angular/core';

import { AdminDashboardComponent } from './admin/dashboard/dashboard.component';
import { AdminParticipantsListComponent } from './admin/participants/participants-list.component';
// import {FormsDemo} from './demo/view/formsdemo';
// import {DataDemo} from './demo/view/datademo';
// import {PanelsDemo} from './demo/view/panelsdemo';
// import {OverlaysDemo} from './demo/view/overlaysdemo';
// import {MenusDemo} from './demo/view/menusdemo';
// import {MessagesDemo} from './demo/view/messagesdemo';
// import {MiscDemo} from './demo/view/miscdemo';
// import {EmptyDemo} from './demo/view/emptydemo';
// import {ChartsDemo} from './demo/view/chartsdemo';
// import {FileDemo} from './demo/view/filedemo';
import { AdminReferralSettingsComponent } from './admin/settings/referral-settings.component';
import { AdminDocumentationComponent } from './admin/documentation/documentation.component';

export const routes: Routes = [
  { path: 'dashboard', component: AdminDashboardComponent },
  { path: 'participants-list', component: AdminParticipantsListComponent },
  // { path: 'forms', component: FormsDemo },
  // { path: 'data', component: DataDemo },
  // { path: 'panels', component: PanelsDemo },
  // { path: 'overlays', component: OverlaysDemo },
  // { path: 'menus', component: MenusDemo },
  // { path: 'messages', component: MessagesDemo },
  // { path: 'misc', component: MiscDemo },
  // { path: 'empty', component: EmptyDemo },
  // { path: 'charts', component: ChartsDemo },
  // { path: 'file', component: FileDemo },
  { path: 'settings', component: AdminReferralSettingsComponent },
  { path: 'documentation', component: AdminDocumentationComponent }
];

export const AppRoutes: ModuleWithProviders = RouterModule.forRoot(routes);
