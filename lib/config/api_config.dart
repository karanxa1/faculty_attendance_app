class ApiConfig {
  // Base URL for API requests
  // For local development, use your computer's IP address instead of localhost
  // so that the mobile device can connect to your local server
  
  // This configuration supports both emulators and physical devices
  // 10.0.2.2 is the special IP for Android emulators to access the host machine
  // For physical devices, replace this with your actual machine's IP address on the network
  // Example: static const String baseUrl = 'http://192.168.1.100:3000';
  
  // For production, use your deployed API URL
  // Example: static const String baseUrl = 'https://your-app-name.vercel.app';
  
  // You can uncomment the appropriate URL based on your testing environment
  // static const String baseUrl = 'http://192.168.1.100:3000'; // For physical device (replace with your IP)
  static const String baseUrl = 'http://10.0.2.2:3000'; // For Android emulator
  
  // API timeout duration
  static const int timeoutSeconds = 30;
}