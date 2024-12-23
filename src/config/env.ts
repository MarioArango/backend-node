import { z } from 'zod';

const envSchema = z.object({
  PORT: z.number().positive(),
});

export type TEnv = z.infer<typeof envSchema>;

export const validateEnv = () => {
  try {
    envSchema.parse(process.env);
  } catch (error) {
    throw Error('');
  }
};
