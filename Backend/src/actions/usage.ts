import { Action, api } from 'actionhero';
import * as tf from '@tensorflow/tfjs-node';

export class Usage extends Action {
  constructor() {
    super();
    this.name = 'usage';
    this.description = 'Fetch user usage and recommend plans';
    this.inputs = {
      userId: { required: true },
    };
  }

  private getUpgradePlan(usagePercentage: number): string {
    if (usagePercentage >= 100) return "Gigabit Plan";
    if (usagePercentage >= 80) return "Super Fast Plan";
    if (usagePercentage >= 60) return "Unlimited Plan";
    if (usagePercentage >= 40) return "Premium Plan";
    return "Basic Plan";
  }

  private static model: tf.Sequential | null = null;

  private async getTrainedModel(): Promise<tf.Sequential> {
    if (!Usage.model) {
      Usage.model = tf.sequential();
      Usage.model.add(tf.layers.dense({ units: 10, activation: 'relu', inputShape: [1] }));
      Usage.model.add(tf.layers.dense({ units: 1 }));
      Usage.model.compile({ optimizer: tf.train.sgd(0.001), loss: 'meanSquaredError' });

      const xs = tf.tensor1d([10, 30, 50, 70, 90, 100, 110, 120]).div(120);
      const ys = tf.tensor1d([1, 2, 2, 3, 4, 4, 5, 5]).div(5);

      await Usage.model.fit(xs, ys, { epochs: 200 });
      console.log("Model trained.");
    }
    return Usage.model;
  }

  async predictUpgrade(usagePercentage: number): Promise<string> {
    const trainedModel = await this.getTrainedModel();
    const prediction = trainedModel.predict(tf.tensor2d([usagePercentage / 100], [1, 1])) as tf.Tensor;

    let predictedValue = Math.round(prediction.dataSync()[0] * 5);
    predictedValue = Math.max(1, Math.min(predictedValue, 5));

    console.log(`Predicted Plan Level: ${predictedValue}`);
    return this.getUpgradePlan(predictedValue * 20);
  }

  async run({ params, response }: { params: { userId: string }, response: { error?: string, usage?: object } }) {
    const userId = params.userId;
    console.log(`Processing request for User ID: ${userId}`);

    const query = `
      SELECT u.name, u."planLimit", u."dataUsed", p.name AS plan_name, p.price
      FROM "Users" u
      JOIN "ISPPlans" p ON u."planLimit" = p."dataLimit"
      WHERE u.id = $1::INTEGER;
    `;

    try {
      const result = await api.database.pool.query(query, [userId]);
      if (result.rows.length === 0) {
        throw new Error('User not found.');
      }

      const user = result.rows[0];
      const usagePercentage = (user.dataUsed / user.planLimit) * 100;

      console.log(`User ${userId} - Usage: ${usagePercentage.toFixed(2)}%`);
      
      const recommendedPlan = await this.predictUpgrade(usagePercentage);

      response.usage = {
        name: user.name,
        currentPlan: user.plan_name,
        usagePercentage: `${usagePercentage.toFixed(2)}%`,
        recommendation:
          usagePercentage >= 100
            ? `You've exceeded your plan limit! Recommended upgrade: ${recommendedPlan}`
            : usagePercentage > 75
            ? `You're close to your limit. Consider upgrading to: ${recommendedPlan}`
            : usagePercentage > 50
            ? `You're at 50% usage. Keep track or upgrade to: ${recommendedPlan}`
            : 'Your usage is within limits. No upgrade needed.',
      };
    } catch (error: unknown) {
      if (error instanceof Error) {
        console.error("Error fetching user data:", error.message);
        response.error = error.message;
      } else {
        console.error("Unexpected error:", error);
        response.error = 'An unexpected error occurred.';
      }
    }
  }
}
