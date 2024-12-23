import { NextFunction, Request, Response, Router } from 'express';
import { SalesModel } from './sales.model';
import { validateSchema } from '@/helpers/validateSchema';
import { getSalesSchema, TGetSalesRequestDto } from './dto/sales.request.dto';

export class SalesController {
  public path: string = '/sales';
  public router: Router = Router();
  private salesModel = new SalesModel();

  constructor() {
    this.router.get('/', validateSchema(getSalesSchema), this.getSales);
  }

  getSales(req: Request, res: Response, next: NextFunction) {
    const payload: TGetSalesRequestDto = req.body;
    res.json(this.salesModel.getSales(payload));
  }
}
