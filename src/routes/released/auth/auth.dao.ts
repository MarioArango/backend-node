import { IResponse } from '@/types/responses';
import { TLoginAuthRequestDto } from './dto/auth.request.dto';

export class AuthDao {
  login(payload: TLoginAuthRequestDto): IResponse {
    return {
      success: true,
      message: '',
      record: {},
    };
  }
}
