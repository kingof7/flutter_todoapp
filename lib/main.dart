import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'models/todo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final DatabaseService _db = DatabaseService();
  final TextEditingController _textController = TextEditingController();
  List<Todo> _todoItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await _db.connect();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    print('Loading todos...');
    setState(() => _isLoading = true);
    final todosData = await _db.getTodos();
    print('Loaded todos data: $todosData');
    setState(() {
      _todoItems = todosData.map((map) => Todo.fromMap(map)).toList();
      print('Updated todo items: ${_todoItems.map((t) => '${t.task}: ${t.isDone}').toList()}');
      _isLoading = false;
    });
  }

  Future<void> _addTodo() async {
    if (_textController.text.isEmpty) return;

    try {
      await _db.addTodo(_textController.text);
      _textController.clear();
      await _loadTodos();  // 할 일 목록 새로고침
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('할 일을 추가하는데 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _toggleTodoItem(Todo todo) async {
    if (todo.id == null) return;
    
    try {
      // Update local state without reloading entire list
      setState(() {
        final index = _todoItems.indexWhere((item) => item.id == todo.id);
        if (index != -1) {
          _todoItems[index] = Todo(
            id: todo.id,
            task: todo.task,
            isDone: !todo.isDone,
          );
        }
      });

      // Update server in background
      await _db.toggleTodo(todo.id!);
    } catch (e) {
      print('Error toggling todo: $e');
      // Revert only the affected item on error
      setState(() {
        final index = _todoItems.indexWhere((item) => item.id == todo.id);
        if (index != -1) {
          _todoItems[index] = todo;
        }
      });
    }
  }

  Future<void> _removeTodoItem(Todo todo) async {
    if (todo.id == null) return;
    await _db.deleteTodo(todo.id!);
    _loadTodos();
  }

  void _showUserProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('내 정보'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 16),
              const Text(
                '사용자 이름',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('user@example.com'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '사용자 이름',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('내 정보'),
              onTap: () {
                Navigator.pop(context);
                _showUserProfile(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('설정'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 설정 페이지 구현
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            hintText: '할 일을 입력하세요',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              _addTodo();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTodo,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _todoItems.length,
                    itemBuilder: (context, index) {
                      final todo = _todoItems[index];
                      return ListTile(
                        leading: Checkbox(
                          value: todo.isDone,
                          onChanged: (bool? value) => _toggleTodoItem(todo),
                        ),
                        title: Text(
                          todo.task,
                          style: TextStyle(
                            decoration: todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                            color: todo.isDone ? Colors.grey : Colors.black,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeTodoItem(todo),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _db.close();
    super.dispose();
  }
}

class Todo {
  int? id;
  String task;
  bool isDone;

  Todo({this.id, required this.task, this.isDone = false});

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      task: map['task'] ?? '',
      isDone: map['isDone'] == 1,
    );
  }
}
