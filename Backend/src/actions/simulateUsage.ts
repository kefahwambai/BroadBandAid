import { Action, api } from "actionhero";

export class SimulateUsage extends Action {
  constructor() {
    super();
    this.name = "simulateUsage";
    this.description = "Simulates internet data usage for a user.";
    this.inputs = {
      userId: { required: true },
    };
  }

  async run({ params, response }: { params: { userId: string }; response: { error?: string; usage?: object } }) {
    const { userId } = params;

    try {
      if (!api.database || !api.database.pool) {
        throw new Error("Database connection is not initialized.");
      }

      const { rows } = await api.database.pool.query(
        'SELECT "planLimit", "dataUsed" FROM "Users" WHERE "id" = $1',
        [userId]
      );

      if (rows.length === 0) {
        throw new Error("User not found.");
      }

      const user = rows[0];

      if (user.planLimit === undefined || user.dataUsed === undefined) {
        throw new Error("Invalid user data: Missing `planLimit` or `dataUsed`.");
      }

      const simulatedUsageIncrease = (Math.random() * 0.04) + 0.01; 
      let newUsage = parseFloat(user.dataUsed) + simulatedUsageIncrease;

      if (newUsage > user.planLimit) {
        newUsage = user.planLimit;
      }

      const usagePercentage = (newUsage / user.planLimit) * 100;

      await api.database.pool.query(
        'UPDATE "Users" SET "dataUsed" = $1 WHERE "id" = $2',
        [newUsage, userId]
      );

      response.usage = {
        userId,
        dataUsed: Math.round(newUsage),
        planLimit: user.planLimit,
        usagePercentage: `${Math.round(usagePercentage)}%`,
      };
    } catch (error: unknown) {
      if (error instanceof Error) {
        console.error("Error in simulateUsage:", error.message);
        response.error = error.message;
      } else {
        console.error("Unexpected error:", error);
        response.error = "An unexpected error occurred.";
      }
    }
  }
}