import { Action, api } from 'actionhero';
import ispPlans from '../../models/ispPlan';
import User from '../../models/user';
import ISPPlan from '../../models/ispPlan';

export class UpdatePlan extends Action {
  constructor() {
    super();
    this.name = "updatePlan";
    this.description = "Update user plan and reset data usage.";
    this.inputs = {
      userId: { required: true },
      planId: { required: true },
      planLimit: { required: true },
      timeLimit: { required: true },
      expiryDate: { required: true },
      dataLimit: { required: true },
    };
  }

  async run({ params, response }: { params: { userId: string; planId: string; planLimit: number; timeLimit: number; expiryDate: string; dataLimit: number }; response: { error?: string; message?: string } }) {
    const { userId, planId, planLimit, timeLimit, expiryDate, dataLimit } = params;

    try {
      const updateQuery = `
        UPDATE "Users"
        SET "planId" = $1, "planLimit" = $2, "timeLimit" = $3, "expiryDate" = $4, "dataLimit" = $5, "dataUsed" = 0
        WHERE "id" = $6;
      `;
      await api.database.pool.query(updateQuery, [planId, planLimit, timeLimit, expiryDate, dataLimit, userId]);

      response.message = "Plan updated successfully.";
    } catch (error: unknown) {
      if (error instanceof Error) {
        console.error("Error updating plan:", error.message);
        response.error = error.message;
      } else {
        console.error("Unexpected error:", error);
        response.error = "An unexpected error occurred.";
      }
    }
  }
}

export class IspPlan extends Action {
    constructor() {
        super();
        this.name = 'getIspPlans';
        this.description = 'Fetch all ISP plans';
        this.outputExample = { plans: [] };
        this.inputs = {};
    }

    async run({ response }: { response: any}) {
        try {
            const plans = await ispPlans.findAll();
            response.plans = plans;
        } catch (error) {
            response.error = 'Failed to fetch ISP plans';
        }
    }
}

export class GetIspPlan extends Action {
    constructor() {
        super();
        this.name = 'getIspPlan';
        this.description = 'Fetch a specific ISP plan by user ID';
        this.outputExample = { plan: {} };
        this.inputs = {
            userId: { required: true }
        };
    }

    async run({ params, response }: { params: { userId: string }, response: { error?: string, plan?: object } }) {
        try {
            const user = await User.findOne({
                where: { id: params.userId },
                include: [
                    {
                        model: ISPPlan,
                        as: "plan", 
                    },
                ],
            });

            if (!user) {
                response.error = `No user found with ID ${params.userId}`;
            } else if (!user.plan) {  
                response.error = `User ${params.userId} does not have an assigned ISP plan`;
            } else {
                response.plan = {
                    id: user.plan.id, 
                    name: user.plan.name, 
                    provider: user.plan.provider, 
                    planLimit: user.plan.dataLimit, 
                    dataUsed: user.dataUsed, 
                    dataLimit: user.dataLimit, 
                    timeLimit: user.plan.timeLimit, 
                    expiryDate: user.plan.timeLimit, 
                    price: user.plan.price
                };
            }
        } catch (error) {
            response.error = 'Failed to fetch ISP plan';
        }
    }
}
