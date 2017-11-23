import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';

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

  getData(path: string, urlParams?: any) {
    const options: any = {};

    if (urlParams) {
      options.params = new HttpParams();
      Object.keys(urlParams).forEach(key => {
        options.params = options.params.append(key.toLowerCase(), encodeURIComponent(urlParams[key]));
        console.log(key, urlParams[key], JSON.stringify(urlParams[key]));
      });
    }

    return this.http.get(this.getFullServiceUrl(path), options);
  }
}
