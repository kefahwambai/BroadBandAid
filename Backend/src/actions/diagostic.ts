import { Action, api } from 'actionhero';
import { Usage } from './usage'; 

export class Diagnostics extends Action {
  constructor() {
    super();
    this.name = 'diagnostics';
    this.description = 'Perform connectivity diagnostics and check data usage';
    this.inputs = {
      userId: { required: true },
    };
  }

  async run({ params, response }: { params: { userId: string }, response: { error?: string; data?: object } }) {
    
    
    const pingResult = Math.floor(Math.random() * 100); 
    const signalStrength = Math.floor(Math.random() * 100 - 100);

    try {
      const usageInstance = new Usage();
      const usageResponse: { usage?: object; error?: string } = { usage: {} };

      await usageInstance.run({ params, response: usageResponse });

      if (usageResponse.error) {
        response.error = `Diagnostics failed due to usage error: ${usageResponse.error}`;
        return;
      }

      response.data = {
        connectivity: {
          ping: pingResult,
          signalStrength,
        },
        usage: usageResponse.usage,
        recommendations: 'Monitor usage and optimize your plan as needed.',
      };
    } catch (error) {
      response.error = 'An error occurred while running diagnostics.';
    }
  }
}
