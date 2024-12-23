import { Application } from 'express';
import { AuthController } from './released/auth/auth.controller';

export class Routes {
  private app: Application;
  private routesReleased = [new AuthController()];
  private routesProtected = [];

  constructor(app: Application) {
    this.app = app;
    this.generateRoutesReleased();
    this.generateRoutesProtected();
  }

  generateRoutesReleased() {
    this.routesReleased.forEach(route => {
      this.app.use(route.path, route.router);
    });
  }

  generateRoutesProtected() {
    // this.routesProtected.forEach(route => {
    //   this.app.use(route.path, route.router);
    // });
  }
}
