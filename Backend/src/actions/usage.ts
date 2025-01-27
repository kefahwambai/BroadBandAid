import { Action,api } from 'actionhero';

export class Usage extends Action {
    constructor() {
      super();
      this.name = 'usage';
      this.description = 'Fetch user usage and recommend plans';
      this.inputs = {
        userId: { required: true },
      };
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

      response.usage = {
        name: user.name,
        plan: user.plan_name,
        usagePercentage: `${usagePercentage.toFixed(2)}%`,
        recommendation:
          usagePercentage > 90
            ? 'Upgrade your plan to avoid overage charges.'
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
};
