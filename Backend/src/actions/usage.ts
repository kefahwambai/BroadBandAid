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

  async predictUpgrade(usage: number): Promise<number> {
    const model = tf.sequential();
    model.add(tf.layers.dense({ units: 10, activation: 'relu', inputShape: [1] }));
    model.add(tf.layers.dense({ units: 1 }));
    model.compile({  optimizer: tf.train.sgd(0.001), loss: 'meanSquaredError' });

    const xs = tf.tensor1d([50, 60, 70, 80, 90, 100, 110, 120]).div(100);
    const ys = tf.tensor1d([1, 1, 2, 2, 3, 3, 4, 5]).div(5);

    await model.fit(xs, ys, { epochs: 100 });
    const prediction = model.predict(tf.tensor2d([usage], [1, 1])) as tf.Tensor;

    let predictedValue = prediction.dataSync()[0] * 5;
    predictedValue = Math.max(1, Math.min(predictedValue, 5)); 
  
    return predictedValue;
  }

  async run({ params, response }: { params: { userId: string }, response: { error?: string, usage?: object } }) {
    const userId = params.userId;
    console.log('User ID:', userId);

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

      const predictedUpgrade = await this.predictUpgrade(usagePercentage);

      response.usage = {
        name: user.name,
        plan: user.plan_name,
        usagePercentage: `${usagePercentage.toFixed(2)}%`,
        recommendation:
        usagePercentage >= 100
          ? `You have exceeded your plan limit! Predicted upgrade level: ${predictedUpgrade.toFixed(2)}`
          : usagePercentage > 90
          ? `Upgrade your plan to avoid overage charges. Predicted upgrade level: ${predictedUpgrade.toFixed(2)}`
          : 'Your usage is within limits.',
      };
    } catch (error: unknown) {
      if (error instanceof Error) {
        response.error = error.message;
      } else {
        response.error = 'An unexpected error occurred.';
      }
    }
  }
}
