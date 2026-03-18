import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/task_repository_impl.dart';
import 'presentation/screens/main_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load environment variables from .env asset
  await dotenv.load(fileName: '.env');

  // 2. Initialise Supabase with credentials from .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 3. Instantiate repository (manual Dependency Injection)
  final taskRepository = TaskRepositoryImpl();

  runApp(ToDoApp(taskRepository: taskRepository));
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key, required this.taskRepository});

  final TaskRepositoryImpl taskRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: MainScaffold(repository: taskRepository),
    );
  }
}
