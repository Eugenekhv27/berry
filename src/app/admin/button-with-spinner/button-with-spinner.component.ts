import { Component, OnInit, Input } from '@angular/core';

@Component({
  selector: 'app-button-with-spinner',
  templateUrl: './button-with-spinner.component.html',
  styles: ['.active { cursor:progress; }']
})
export class ButtonWithSpinnerComponent implements OnInit {
  isActive = false;
  @Input() icon = 'fa-check';
  @Input() label = 'Button with a spinner';
  private initialIcon: string;
  private iconSpin = 'fa-refresh fa-spin';

  constructor() { }

  ngOnInit() {
    this.initialIcon = this.icon;
  }

  spin() {
    this.icon = this.iconSpin;
    this.isActive = true;
  }

  stopSpin() {
    this.icon = this.initialIcon;
    this.isActive = false;
  }

  toggleSpinning(): void {
    this.isActive ? this.stopSpin() : this.spin();
  }
}
