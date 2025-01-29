import { Action, config, api, RouteType } from "actionhero";
import * as fs from "fs";
import * as path from "path";
import { PackageJson } from "type-fest";

const SWAGGER_VERSION = "2.0";
const API_VERSION = ""; 

const parentPackageJSON: PackageJson = JSON.parse(
  fs.readFileSync(path.join(__dirname, "..", "..", "package.json")).toString(),
);

const responses = {
  200: {
    description: "Successful operation",
    schema: { type: "object" },
  },
  400: {
    description: "Invalid input",
  },
  404: {
    description: "Not Found",
  },
  422: {
    description: "Missing or invalid params",
  },
  500: {
    description: "Server error",
  },
};

interface Input {
  type?: string;
  required?: boolean;
  default?: string | number | boolean;
}

interface ActionInputs {
  [inputName: string]: Input;
}

export class Swagger extends Action {
  name = "swagger";
  description = "Return API documentation in the OpenAPI specification";
  outputExample = {};

  getLatestAction(route: RouteType): Action | undefined {
    let matchedAction: Action | undefined = undefined;
    Object.keys(api.actions.actions).forEach((actionName) => {
      Object.keys(api.actions.actions[actionName]).forEach((version) => {
        const action = api.actions.actions[actionName][version];
        if (action.name === route.action) {
          matchedAction = action;
        }
      });
    });
    return matchedAction;
  }

  buildSwaggerPaths() {
    const swaggerPaths: {
      [path: string]: {
        [method: string]: {
          tags: string[];
          summary: string;
          consumes: string[];
          produces: string[];
          parameters: Array<{
            in: string;
            name: string;
            type: string;
            required: boolean;
            default: string | number | boolean | undefined;
          }>;
          responses: typeof responses;
          security: string[];
        };
      };
    } = {};

    const tags: string[] = [];

    for (const [method, routes] of Object.entries(api.routes.routes)) {
      routes.map((route) => {
        const action = this.getLatestAction(route);
        if (!action) return;

        const tag = action.name.split(":")[0]; 
        const formattedPath = route.path
          .replace("/v:apiVersion", "") 
          .replace(/\/:(\w*)/g, "/{$1}"); 

        const inputs: ActionInputs = action.inputs || {};

        swaggerPaths[formattedPath] = swaggerPaths[formattedPath] || {};
        swaggerPaths[formattedPath][method] = {
          tags: [tag],
          summary: action.description || "No description",
          consumes: ["application/json"],
          produces: ["application/json"],
          parameters: action.inputs
            ? Object.keys(action.inputs).sort().map((inputName) => {
                const input = inputs[inputName];
                return {
                  in: route.path.includes(`:${inputName}`) ? "path" : "query",
                  name: inputName,
                  type: input?.type || "string",  
                  required: input?.required || route.path.includes(`:${inputName}`),
                  default: input?.default ?? undefined,
                };
              })
            : [],
          responses,
          security: [],  
        };

        if (!tags.includes(tag)) {
          tags.push(tag); 
        }
      });
    }

    return { swaggerPaths, tags };
  }

  async run() {
    const { swaggerPaths, tags } = this.buildSwaggerPaths();

    const allowedRequestHost = config.web?.allowedRequestHosts?.[0];
    const host = allowedRequestHost
      ? allowedRequestHost.replace("https://", "").replace("http://", "")
      : `localhost:${config.web?.port}`;

    return {
      swagger: SWAGGER_VERSION,
      info: {
        description: parentPackageJSON.description,
        version: parentPackageJSON.version,
        title: parentPackageJSON.name,
        license: { name: parentPackageJSON.license },
      },
      host: host,
      basePath: `/api/${API_VERSION}`,
      schemes: allowedRequestHost ? ["https", "http"] : ["http"],
      paths: swaggerPaths,
      securityDefinitions: {
        ApiKeyAuth: {
          type: "apiKey",
          in: "header",
          name: "Authorization",
          description: "JWT Authorization header",
        },
      },
      externalDocs: {
        description: "Learn more about Actionhero",
        url: "https://www.actionherojs.com",
      },
    };
  }
}
