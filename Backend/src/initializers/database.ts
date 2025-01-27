import { Initializer, api } from "actionhero";
import { Pool } from "pg";
import dotenv from "dotenv";

dotenv.config();

export class DatabaseInitializer extends Initializer {
  constructor() {
    super();
    this.name = "database";
    this.loadPriority = 100;
  }

  async initialize() {
    api.database = {
      pool: new Pool({
        user: process.env.POSTGRES_USERNAME,
        host: process.env.DB_HOST,
        database: process.env.DB_NAME,
        password: process.env.POSTGRES_PASSWORD,
        port: 5432,
      }),
    };

    try {
        await api.database.pool.connect();
        console.log("Database pool enabled", "info");
      } catch (error: unknown) {
        if (error instanceof Error) {
          console.log(`Failed to connect to database: ${error.message}`, "error");
        } else {
          console.log("An unexpected error occurred during database initialization", "error");
        }
      }
    }
  
    async stop() {
      await api.database.pool.end();
      api.log("Database connection closed", "info");
    }
}
