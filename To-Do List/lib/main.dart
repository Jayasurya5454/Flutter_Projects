import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: Colors.amber,
        ).copyWith(
          secondary: Colors.deepOrange,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _mailController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            title: 'Todo List',
            name: _nameController.text,
            mailId: _mailController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter a name...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mailController,
                decoration: const InputDecoration(
                  hintText: 'Enter a mail id...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a mail id';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
    required this.name,
    required this.mailId,
  }) : super(key: key);

  final String title;
  final String name;
  final String mailId;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TodoItem> todos = [];
  TextEditingController _todoController = TextEditingController();

  void _addTodo() async {
    if (_todoController.text.isNotEmpty) {
      DateTime? pickedDateTime = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
      );

      if (pickedDateTime != null) {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (pickedTime != null) {
          DateTime userDateTime = DateTime(
            pickedDateTime.year,
            pickedDateTime.month,
            pickedDateTime.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          setState(() {
            todos.add(TodoItem(
              title: _todoController.text,
              isDone: false,
              userDateTime: userDateTime,
            ));
            todos.sort((a, b) => a.userDateTime.compareTo(b.userDateTime));
            _todoController.clear();
          });
        }
      }
    }
  }

  void _removeTodo(int index) {
    setState(() {
      todos.removeAt(index);
    });
  }

  void _toggleDone(int index) {
    setState(() {
      todos[index] = todos[index].copyWith(isDone: !todos[index].isDone);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${widget.name}!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow),
                    Icon(Icons.star, color: Colors.yellow),
                    Icon(Icons.star, color: Colors.yellow),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _todoController,
              decoration: InputDecoration(
                hintText: 'Enter a new todo...',
              ),
              onEditingComplete: _addTodo,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: todos[index].isDone ? Colors.green.shade100 : null,
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: todos[index].isDone,
                              onChanged: (_) => _toggleDone(index),
                            ),
                            Text(
                              todos[index].title,
                              style: TextStyle(
                                fontSize: 18,
                                decoration: todos[index].isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Time: ${_formatTime(todos[index].userDateTime)}',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _removeTodo(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.year}-${time.month}-${time.day} ${time.hour}:${time.minute}';
  }
}

class TodoItem {
  final String title;
  final bool isDone;
  final DateTime userDateTime; // User-specified time and date

  TodoItem({
    required this.title,
    required this.isDone,
    required this.userDateTime,
  });

  TodoItem copyWith({
    String? title,
    bool? isDone,
    DateTime? userDateTime,
  }) {
    return TodoItem(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      userDateTime: userDateTime ?? this.userDateTime,
    );
  }
}
