import { Component, Inject, forwardRef } from '@angular/core';
import { AdminComponent } from '../admin.component';

@Component({
  selector: 'app-footer',
  template: `
    <div class="footer">
      <div class="card clearfix">
        <span class="footer-text-left">ЯГОДА </span>
        <span class="footer-text-right">телефон: +7 (4212) 62-08-28<br>email: hello@progrepublic.ru, Skype: Vassil2010</span>
      </div>
    </div>
  `
})
export class FooterComponent {

}
