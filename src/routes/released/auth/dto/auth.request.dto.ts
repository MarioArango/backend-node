import { z } from 'zod';

/**
 * -------------
 * login schema
 * -------------
 */

export const loginSchema = z.object({
  username: z.string(),
  password: z.string(),
});

export type TLoginAuthRequestDto = z.infer<typeof loginSchema>;
