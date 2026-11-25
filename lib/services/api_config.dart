class ApiConfig {
  ApiConfig._();

  static const origin = 'https://api.fototidy.com';
  static const baseUrl = '$origin/api/v1';

  static const login = '$baseUrl/auth/login';
  static const myPhotos = '$baseUrl/upload-photos/my-photos';
}