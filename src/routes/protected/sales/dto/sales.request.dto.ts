import { z } from 'zod';

/**
 * -------------
 * sales schema
 * -------------
 */

export const getSalesSchema = z.object({
  price: z.number(),
});

export type TGetSalesRequestDto = z.infer<typeof getSalesSchema>;
