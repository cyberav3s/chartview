// API Client - network layer stub
// In production, configure Dio with base URL, interceptors, auth headers

class ApiClient {
  static const String baseUrl = 'https://api.example.com/v1';
  
  // Placeholder for actual Dio implementation
  Future<dynamic> get(String endpoint) async {
    throw UnimplementedError('Configure real API endpoint');
  }
  
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    throw UnimplementedError('Configure real API endpoint');
  }
}
