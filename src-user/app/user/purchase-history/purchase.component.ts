import { Component, Input } from '@angular/core';
import { DataService, NotifierService } from '../services/services';
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
    private dataService: DataService,
    private notifier: NotifierService
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

  postTestimonial() {
    if (!this.testimonialText.trim()) {
      this.notifier.warning('Нет отзыва!', 'Нельзя отправить пустой отзыв. Напишите отзыв в поле для ввода текста.');
      return;
    }

    this.dataService.postTestimonial({
      purchaseId: this.purchase.id,
      date: new Date(),
      text: this.testimonialText.trim()
    }).subscribe((v) => console.log(v));
  }

  changeRating() {
    console.log('rating ' + this.purchase.rating);
    this.dataService.postRating({
      purchaseId: this.purchase.id,
      date: new Date(),
      value: this.purchase.rating
    }).subscribe((v) => console.log(v));
  }
}
