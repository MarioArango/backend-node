import { IResponse } from '@/types/responses';
import { AuthDao } from './auth.dao';
import { TLoginAuthRequestDto } from './dto/auth.request.dto';

export class AuthModel {
  private authDao = new AuthDao();

  login(payload: TLoginAuthRequestDto): IResponse {
    return this.authDao.login(payload);
  }
}
