export interface IResponse<T = unknown> {
  success: boolean;
  message: string;
  record?: T;
  records?: T[];
}
