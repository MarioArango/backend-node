import express from 'express';
import { validateEnv } from './config/env';
import { Routes } from './routes';

const app = express();

app.set('PORT', process.env.PORT || 8080);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

validateEnv();

new Routes(app);

app.listen(app.get('PORT'), () => {
  console.log(`Listening on port ${app.get('PORT')}`);
});
