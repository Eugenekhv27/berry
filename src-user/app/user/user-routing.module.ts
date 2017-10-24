import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { UserComponent } from './user.component';
import { HomepageComponent } from './homepage/homepage.component';
import { LoginComponent } from './login/login.component';
// import { AuthGuard } from './services/services';

const routes: Routes = [{
  path: '',
  component: UserComponent,
  children: [
    { path: '',  component: HomepageComponent, pathMatch: 'full' },
    { path: 'login',  component: LoginComponent, pathMatch: 'full' },
    { path: '**', redirectTo: '' }
  ]
}];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class UserRoutingModule { }
