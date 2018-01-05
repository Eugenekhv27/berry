import {
    ActivatedRouteSnapshot, DetachedRouteHandle
  } from '@angular/router';

// Taken from angular's source code at github:
export declare abstract class RouteReuseStrategy {
    /**
     * Determines if this route (and its subtree) should be detached to be reused later.
     */
    abstract shouldDetach(route: ActivatedRouteSnapshot): boolean;
    /**
     * Stores the detached route.
     */
    abstract store(route: ActivatedRouteSnapshot, handle: DetachedRouteHandle): void;
    /**
     * Determines if this route (and its subtree) should be reattached.
     */
    abstract shouldAttach(route: ActivatedRouteSnapshot): boolean;
    /**
     * Retrieves the previously stored route.
     */
    abstract retrieve(route: ActivatedRouteSnapshot): DetachedRouteHandle;
    /**
     * Determines if a route should be reused.
     */
    abstract shouldReuseRoute(future: ActivatedRouteSnapshot, curr: ActivatedRouteSnapshot): boolean;
}


