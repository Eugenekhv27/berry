import { Component, Inject, forwardRef } from '@angular/core';
import { AdminComponent } from '../admin.component';

@Component({
  selector: 'app-topbar',
  templateUrl: './top-bar.component.html'
})
export class TopBarComponent {

  constructor( @Inject(forwardRef(() => AdminComponent)) public app: AdminComponent) { }

}
