# BroadBandAid

BroadBandAid is a Flutter application designed to help users manage their internet service provider (ISP) plans, track data usage, perform diagnostics, and upgrade their plans as needed. The app integrates seamlessly with a backend API to provide real-time information, such as usage statistics and available plans.

## Features

- **User Dashboard**: Displays user-specific data, including usage percentage, current plan details, and balance due.
- **Data Usage Tracking**: Real-time data usage statistics are simulated and displayed, with warnings when usage exceeds 80%.
- **Plan Upgrade**: Users can upgrade their ISP plan directly from the app.
- **Diagnostics**: Run diagnostics to troubleshoot internet connectivity issues (e.g., ping tests, signal strength, network congestion analysis).
- **Authentication**: Secure JWT authentication for user login.
- **Responsive Design**: Mobile-responsive user interface using Material Design for a sleek and easy-to-navigate experience.

## Getting Started

To get started with BroadBandAid, clone the repository and follow the instructions below.

### Prerequisites

- Flutter SDK installed on your local machine.
- A working backend API (either locally or hosted) for data fetching and processing.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/kefahwambai/BroadBandAid
   cd broad_band_aid

2. Install the Flutter dependencies:

    ```bash
    flutter pub get

3. Set up the backend API to provide the necessary endpoints for the app:

    /api/usage: Fetch user data usage information.
    /api/user-plan: Fetch details of the user's current ISP plan.
    /api/diagnostic: Run diagnostics for internet health.
    /api/simulateUsage: Simulate data usage for testing purposes.

4. Start the Flutter app:

    ```bash
    flutter run
