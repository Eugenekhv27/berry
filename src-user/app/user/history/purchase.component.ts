import { Component, Input } from '@angular/core';
import { Purchase } from './purchase.model';

@Component({
  selector: 'app-purchase',
  templateUrl: './purchase.component.html',
})
export class PurchaseComponent {
  @Input() purchase: Purchase;
  isTestimonialFormVisible = false;
  tabIndex: number;
  testimonialText = '';

  constructor(
  ) { }

  toggleTestimonialForm() {
    if (this.isTestimonialFormVisible) {
      this.tabIndex = 99;
      setTimeout(() => this.isTestimonialFormVisible = false, 500);
    } else {
      this.isTestimonialFormVisible = true;
      setTimeout(() => this.tabIndex = 0, 200);
    }
  }

  sendTestimonial() {
    console.log(this.testimonialText);
  }
}
