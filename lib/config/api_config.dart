class ApiConfig {
  // Base URL for API requests
  // For local development, use your computer's IP address instead of localhost
  // so that the mobile device can connect to your local server
  // Example: static const String baseUrl = 'http://192.168.1.100:3000';
  
  // For production, use your deployed API URL
  // Example: static const String baseUrl = 'https://your-app-name.vercel.app';
  
  // Default to localhost for emulator testing
  static const String baseUrl = 'http://10.0.2.2:3000';
  
  // API timeout duration
  static const int timeoutSeconds = 30;
}