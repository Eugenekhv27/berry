import { Injectable } from '@angular/core';

@Injectable()
export class UtilsService {

  constructor(
  ) { }

  formatNumber(n: number, size = 2, zero = '') {
    return n ? n.toFixed(size) : zero;
  }

  formatDate(d: Date) {
    return Intl.DateTimeFormat('ru-RU').format(d);
  }

  appParseDate(s: string) {
    const ps = s
      .split('.')
      .map(v => parseInt(v, 10));
    return new Date(ps[2], ps[1] - 1, ps[0]);
  }

  parseNumber(v: string|number) {
    return isNaN(parseFloat(String(v))) ? 0 : parseFloat(String(v));
  }
}
