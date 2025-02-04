import { Action } from 'actionhero';
import ispPlans from '../../models/ispPlan';
import User from '../../models/user';
import ISPPlan from '../../models/ispPlan';

export class UpdatePlan extends Action {
    constructor() {
      super();
      this.name = 'updatePlan';
      this.description = 'Update user plan limit';
      this.inputs = {
        userId: { required: true },
        planId: {required: true},
        planLimit: { required: true },
        timeLimit: { required: true }, 
        expiryDate: {required: true},
        dataLimit: {required: true}
      };
    }
  
    async run({ params, response }: { params: any; response: any }) {
      try {
        const user = await User.findOne({ where: { id: Number(params.userId) } });
        if (!user) {
          response.success = false;
          response.message = 'User not found.';
          return;
        }
        user.planId = params.planId;
        user.planLimit = params.planLimit;
        user.timeLimit = params.timeLimit;
        user.expiryDate = params.expiryDate;
        user.dataLimit = params.dataLimit;
        await user.save();
  
        response.success = true;
        response.message = 'Plan updated successfully.';
      } catch (error: any) {
        response.success = false;
        response.message = `Failed to update plan: ${error.message}`;
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
