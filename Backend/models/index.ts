import { Sequelize } from 'sequelize';
import dotenv from "dotenv";

dotenv.config();

export const sequelize = new Sequelize({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || '5432', 10),
  username: process.env.POSTGRES_USERNAME,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.DB_NAME,
  dialect: 'postgres',
  logging: false,
});
