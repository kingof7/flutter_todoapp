import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final String baseUrl = 'http://localhost:8080/api'; // Node.js 서버 주소

  Future<void> connect() async {
    try {
      // HTTP 기반이므로 별도의 연결이 필요 없음
      print('HTTP service initialized');
    } catch (e) {
      print('Failed to initialize HTTP service: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getTodos() async {
    try {
      print('Fetching todos...');
      final response = await http.get(Uri.parse('$baseUrl/todos'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Fetched ${data.length} todos');
        return data.map((item) => {
          'id': item['id'],
          'task': item['task'],
          'is_done': item['is_done'],  // Changed to pass through the Y/N value
        }).toList();
      } else {
        throw Exception('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to get todos: $e');
      return [];
    }
  }

  Future<void> addTodo(String task) async {
    try {
      print('Adding new todo: $task');
      final response = await http.post(
        Uri.parse('$baseUrl/todos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'task': task}),
      );
      
      if (response.statusCode != 201) {
        throw Exception('Failed to add todo: ${response.statusCode}');
      }
      print('Todo added successfully');
    } catch (e) {
      print('Failed to add todo: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> toggleTodo(int id) async {
    try {
      print('Toggling todo with id: $id');
      final response = await http.put(
        Uri.parse('$baseUrl/todos/$id/toggle'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Toggle response: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to toggle todo: ${response.statusCode}');
      }
      
      final updatedTodo = json.decode(response.body);
      print('Todo toggled successfully: $updatedTodo');
      return updatedTodo;
    } catch (e) {
      print('Failed to toggle todo: $e');
      rethrow;
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      print('Deleting todo with id: $id');
      final response = await http.delete(
        Uri.parse('$baseUrl/todos/$id'),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete todo: ${response.statusCode}');
      }
      print('Todo deleted successfully');
    } catch (e) {
      print('Failed to delete todo: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    // HTTP 클라이언트는 별도의 종료가 필요 없음
  }
}
