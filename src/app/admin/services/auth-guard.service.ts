import { Injectable } from '@angular/core';
import {
  Router, CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot
} from '@angular/router';
import { AuthService } from '../services/auth.service';

@Injectable()
export class AuthGuard implements CanActivate {

  constructor(
    private auth: AuthService,
    private router: Router
  ) { }

  canActivate(
    activatedRoute: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): boolean {
    if (this.auth.isLoggedIn()) {
      return true;
    } else {
      this.auth.redirectUrl = state.url;
      this.router.navigate(['/admin/login']);
      return false;
    }
  }
}
