import { RoutesConfig } from "actionhero";

const namespace = "routes";

declare module "actionhero" {
  export interface ActionheroConfigInterface {
    [namespace]: ReturnType<(typeof DEFAULT)[typeof namespace]>;
  }
}

export const DEFAULT: { [namespace]: () => RoutesConfig } = {
  [namespace]: () => {
    return {
      get: [
        { path: "/plans", action: "getIspPlans" },
        { path: "/user", action: "userFetch" },
        {path: "/user-plan", action: "getIspPlan"},
        { path: "/users", action: "userList" },
        { path: "/usage", action: "usage" },
        { path: "/diagnostic", action: "diagnostics" },
        { path: "/swagger", action: "swagger" },
      ],

      post: [
        { path: '/user-signup', action: "userAdd" },
        { path: '/user-login', action: "userLogin" },
        { path: "/diagnostic", action: "diagnostics" },
        { path: "/simulateUsage", action: "simulateUsage" },
      
      ],

      put: [
        { path: '/update-plan', action: 'updatePlan' },
      ]

      /* ---------------------
      For web clients (http and https) you can define an optional RESTful mapping to help route requests to actions.
      If the client doesn't specify and action in a param, and the base route isn't a named action, the action will attempt to be discerned from this routes.js file.

      Learn more here: https://www.actionherojs.com/tutorials/web-server#Routes

      examples:

      get: [
        { path: '/users', action: 'usersList' }, // (GET) /api/users
        { path: '/search/:term/limit/:limit/offset/:offset', action: 'search' }, // (GET) /api/search/car/limit/10/offset/100
      ],

      post: [
        { path: '/login/:userID(^\\d{3}$)', action: 'login' } // (POST) /api/login/123
      ],

      all: [
        { path: '/user/:userID', action: 'user', matchTrailingPathParts: true } // (*) /api/user/123, api/user/123/stuff
      ]

      ---------------------- */
    };
  },
};
