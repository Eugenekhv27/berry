import { Injectable } from '@angular/core';
import {
  Router, CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot
} from '@angular/router';

@Injectable()
export class AuthGuard implements CanActivate {

  constructor(private router: Router) { }

  canActivate(
    activatedRoute: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): boolean {
    // if (localStorage.getItem('accountEncrypt')) {
    //   // logged in so return true
    //   return true;
    // }
    // this.router.navigate(['/admin/login']);
    // return false;
    return true;
  }
}
