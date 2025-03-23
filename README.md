# Faculty Attendance App

## Overview
This Flutter application allows faculty members to manage student attendance for their classes. Faculty can view their assigned classes, take attendance, and generate attendance reports.

## Setup Instructions

### API Configuration
The app is configured to connect to a backend API. By default, it's set up to work with an Android emulator using the special IP address `10.0.2.2` which maps to the host machine's localhost.

#### For Physical Devices
If you're running the app on a physical device, you need to modify the API configuration to use your computer's actual IP address:

1. Open `lib/config/api_config.dart`
2. Comment out the line: `static const String baseUrl = 'http://10.0.2.2:3000';`
3. Uncomment and update the line: `// static const String baseUrl = 'http://192.168.1.100:3000';` with your computer's actual IP address

```dart
// Example:
// static const String baseUrl = 'http://10.0.2.2:3000'; // For Android emulator
static const String baseUrl = 'http://192.168.1.100:3000'; // Replace with your actual IP
```

### Running the App
1. Make sure your backend server is running on port 3000
2. Run the app using `flutter run`

## Features
- Faculty login authentication
- View assigned classes
- Take attendance for a class
- Mark students present/absent
- Generate attendance reports
- View attendance statistics

## Troubleshooting

### Connection Issues
- Verify that your backend server is running
- Check that the IP address in `api_config.dart` is correct for your environment
- Ensure your device is on the same network as your development machine
- Check that your firewall isn't blocking connections to port 3000

### Authentication Issues
- If you're getting authentication errors, try logging out and logging back in
- Verify that your backend server is properly validating tokens

## Dependencies
- Flutter SDK
- provider: ^6.0.3
- http: ^0.13.4
- shared_preferences: ^2.0.15
- intl: ^0.17.0