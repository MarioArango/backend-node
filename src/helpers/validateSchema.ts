import { NextFunction, Request, Response } from 'express';
import { z } from 'zod';

export const validateSchema = (schema: z.Schema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      schema.parse(req.body);
      next();
    } catch (error) {
      next(error);
    }
  };
};
