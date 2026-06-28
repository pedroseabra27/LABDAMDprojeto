import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AuthService {
  final ApiService apiService;
  
  AuthService(this.apiService);

  Future<Map<String, dynamic>> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('${apiService.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // data contém { token, usuario: { id, nome, email, tipo } }
      apiService.setToken(data['token']);
      return data;
    } else {
      throw Exception('E-mail ou senha inválidos.');
    }
  }

  Future<Map<String, dynamic>> register(String nome, String email, String senha, String tipo) async {
    final response = await http.post(
      Uri.parse('${apiService.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'email': email, 'senha': senha, 'tipo': tipo}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao criar conta. E-mail pode já estar em uso.');
    }
  }

  void logout() {
    apiService.clearToken();
  }
}
