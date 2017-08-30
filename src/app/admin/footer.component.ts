import { Component, Inject, forwardRef } from '@angular/core';
import { AdminComponent } from './admin.component';

@Component({
  selector: 'app-footer',
  template: `
        <div class="footer">
            <div class="card clearfix">
                <span class="footer-text-left">BONUS CLUB</span>
                <span class="footer-text-right"><span class="ui-icon ui-icon-copyright"></span>  <span>All Rights Reserved</span></span>
            </div>
        </div>
    `
})
export class AdminFooterComponent {

}
