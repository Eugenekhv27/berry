import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { UserComponent } from './user.component';

// import { AuthGuard } from './services/services';

const routes: Routes = [{
  path: '',
  component: UserComponent,
  children: [
    { path: '',  component: UserComponent, pathMatch: 'full' },
//    { path: '**', redirectTo: '' }
  ]
}];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class UserRoutingModule { }
