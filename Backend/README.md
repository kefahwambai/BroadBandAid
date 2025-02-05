## BROADBANDAID - API

This is a **Actionhero node backend** that intelligently manages ISP plans, troubleshoots internet connectivity issues, and notifies users about their data usage and potential plan upgrades. 

## Project Overview

The tool serves to:

- Diagnose and solve internet connectivity issues.
- Manage ISP plans and notify users about their data usage.
- Predict potential connectivity issues or plan usage limits using AI/ML models.


### Features:

### 1. Automated Troubleshooting
- Run diagnostic tests (ping tests, signal strength assessments, usage analysis).
- Provide solutions for internet issues and suggest further actions if necessary.

### 2. Plan Limit Management
- Track user data usage and compare it with the data cap of their ISP plan.
- Notify users when they are approaching or exceeding their data plan limit.
- Recommend plan upgrades based on usage patterns.

### 3. AI/ML Integration
- Implement small machine learning models to enhance diagnostic and recommendation processes.
- Predict when a user is likely to exceed their plan limit or encounter connectivity issues.


## Requirements

Before running the project, ensure you have the following installed:

- [Node.js](http://nodejs.org/): Ensure you have the latest stable version installed.
- [TypeScript](https://www.typescriptlang.org/): Actionhero supports TypeScript for better developer experience.
- [NPM](https://www.npmjs.com/): The Node.js package manager is required to install dependencies.

## Setup and Installation

Follow these steps to install and set up the project:

1. **Clone the repository**:

   ```bash
   git clone https://github.com/kefahwambai/BroadBandAid
   cd Backend

2. Install dependencies: Install the required dependencies by running:

   ```bash
    npm install

This will install all the necessary dependencies specified in the package.json file.

3. Configure the environment: 

Create a .env file in the root of your project directory, and fill in the necessary configuration values. Example configuration:

    
    POSTGRES_USERNAME=your-username
    POSTGRES_PASSWORD=your-password
    DB_NAME=your-database-name
    DB_HOST=your-database-host
    DB_PORT=5432
    NODE_ENV=development

### Seed Data

To quickly populate the database with sample data, you can use the seed files provided in the project. This is especially useful when you're setting up the application for the first time or testing it with predefined data.

## To Seed the Database:

1.Ensure you have the necessary environment variables configured (e.g., database credentials, etc.).

2 Run the seed command:

   npx sequelize-cli db:seed:all

This will run all the seed files and populate the database with the sample plan data.

3. Verify the data:

You can verify the seeded data by checking the relevant tables in your database or by hitting some of the API endpoints that depend on the data (/api/plan).

## To Run:

1. Start the Actionhero server in development mode:
  
   npm run dev

This will compile TypeScript and start the Actionhero server. The server will be available on the port specified in the configuration (PORT has to be set at localhost:8081 to avoid conflict with the flutter appilcation).


## API Documentation:

    The API endpoints are automatically documented using Swagger. You can access the API documentation at the following URL:

    http://localhost:8081/api/swagger

## API Endpoints

Here are some of the key API endpoints your project might include:
1. Diagnostic Tests

    Endpoint: GET /api/diagnostic

    Description: Runs diagnostic tests (ping, signal strength, usage analysis).

    Example Request:
    bash
    Copy

    GET http://localhost:8081/api/diagnostic?userId=123

    Example Response:
    json
    Copy

    {
      "connectivity": {
        "ping": "20ms",
        "signalStrength": "-50dBm"
      },
      "usage": {
        "usagePercentage": "75%",
        "recommendation": "Your usage is normal."
      }
    }

2. Fetch User Plan Details

    Endpoint: GET /api/user-plan

    Description: Fetches the user's current ISP plan details.

    Example Request:
    bash
    Copy

    GET http://localhost:8081/api/user-plan?userId=123

    Example Response:
    json
    Copy

    {
      "plan": {
        "name": "Basic Plan",
        "dataLimit": "100GB",
        "price": "KSH 2000",
        "timeLimit": "720hr"
      }
    }

3. Upgrade Plan

    Endpoint: POST /api/upgrade-plan

    Description: Upgrades the user's ISP plan.

    Example Request:
    bash
    Copy

    POST http://localhost:8081/api/upgrade-plan
    Body: {
      "userId": "123",
      "planId": "456"
    }

    Example Response:
    json
    Copy

    {
      "success": true,
      "message": "Plan upgraded successfully."
    }

4. Simulate Data Usage

    Endpoint: POST /api/simulateUsage

    Description: Simulates data usage for testing purposes.

    Example Request:
    bash
    Copy

    POST http://localhost:8081/api/simulateUsage
    Body: {
      "userId": "123",
      "planDataLimit": "1000"
    }

    Example Response:
    json
    Copy

    {
      "usage": {
        "usagePercentage": "85%",
        "recommendation": "You are approaching your data limit."
      }
    }

