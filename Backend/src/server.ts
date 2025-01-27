import express from 'express';
import { Process } from 'actionhero';
import { sequelize } from '../models/index';
require('dotenv').config();

const app = express();

async function main() {
  try {
    await sequelize.authenticate();
    console.log("Database connected successfully.");

    await sequelize.sync({ alter: true });

    const actionhero = new Process();
    await actionhero.start();
    console.log("Actionhero server started.");

    app.use(express.json());
    app.use(express.urlencoded({ extended: true }));

    app.listen(8081, () => {
      console.log("Custom server running on port 8080");
    });

  } catch (error) {
    console.error("Error starting server:", error);
    process.exit(1);
  }
}

main();
