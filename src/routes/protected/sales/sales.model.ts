import { IResponse } from '@/types/responses';
import { TGetSalesRequestDto } from './dto/sales.request.dto';

export class SalesModel {
  getSales(payload: TGetSalesRequestDto): IResponse {
    return {
      success: true,
      message: 'Sales retrieved successfully',
    };
  }
}
