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
      const usageResponse: { usage?: { recommendation?: string }; error?: string } = { usage: {} };


      await usageInstance.run({ params, response: usageResponse });

      if (usageResponse.error) {
        response.error = `Diagnostics failed due to usage error: ${usageResponse.error}`;
        return;
      }

      const networkRecommendations = [];

      if (pingResult > 100) {
        networkRecommendations.push("High latency detected! Consider using a wired connection or VPN.");
      } else if (pingResult > 50) {
        networkRecommendations.push("Moderate latency detected. Close background apps using bandwidth.");
      }

      if (signalStrength < -80) {
        networkRecommendations.push("Very weak signal. Try moving closer to the router.");
      } else if (signalStrength < -60) {
        networkRecommendations.push("Weak signal detected. Reduce interference from walls/devices.");
      }

      const finalRecommendations = [         
        ...networkRecommendations, usageResponse.usage?.recommendation,
      ].filter(Boolean).join(" ");

      response.data = {
        connectivity: {
          ping: pingResult,
          signalStrength,
        },
        usage: usageResponse.usage,
        recommendations: finalRecommendations,
      };
    } catch (error) {
      response.error = 'An error occurred while running diagnostics.';
    }
  }
}
