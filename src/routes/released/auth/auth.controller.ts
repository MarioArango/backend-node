import { NextFunction, Request, Response, Router } from 'express';
import { AuthModel } from './auth.model';
import { validateSchema } from '@/helpers/validateSchema';
import { loginSchema, TLoginAuthRequestDto } from './dto/auth.request.dto';

export class AuthController {
  public path: string = '/auth';
  public router: Router = Router();
  private authModel = new AuthModel();

  constructor() {
    this.router.post('/login', validateSchema(loginSchema), this.login);
  }

  login(req: Request, res: Response, next: NextFunction) {
    const payload: TLoginAuthRequestDto = req.body;
    res.json(this.authModel.login(payload));
  }
}
