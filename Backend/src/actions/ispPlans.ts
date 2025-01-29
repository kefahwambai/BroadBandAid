import { Action } from 'actionhero';
import ispPlans from '../../models/ispPlan';

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
        this.description = 'Fetch a specific ISP plan by ID';
        this.outputExample = { plan: {} };
        this.inputs = {
            id: { required: true }
        };
    }

    async run({ params, response }: { params: { id: string }, response: { error?: string, plan?: object } }) {
        try {
            const plan = await ispPlans.findByPk(params.id);
            if (!plan) {
                response.error = 'ISP plan not found';
            } else {
                response.plan = plan;
            }
        } catch (error) {
            response.error = 'Failed to fetch ISP plan';
        }
    }
}
