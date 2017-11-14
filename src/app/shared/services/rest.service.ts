import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable()
export class RestService {

  constructor(
    private http: HttpClient
  ) {}

  private getRootServiceUrl() {
    const itemName = 'restServiceUrl';
    const  defaultUrl = 'http://base.progrepublic.ru/csp/bonusclubrest';

    if (!localStorage.getItem(itemName)) {
      localStorage.setItem(itemName, defaultUrl);
    }
    return localStorage.getItem(itemName);
  }

  private getFullServiceUrl(path: string): string {
    return `http://localhost:3030${path}`;
  }

  getData(path: string, requestBody?: any) {
    return this.http.get(this.getFullServiceUrl(path));
  }
}
