import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/data/data_sources/local/mock_data_source.dart';
import 'package:taskflow/presentation/providers/comment_provider.dart';
import 'package:taskflow/presentation/providers/notifications_provider.dart';
import 'package:taskflow/presentation/providers/task_provider.dart';
import 'package:taskflow/data/repositories/task_flowrepository.dart';
import 'package:taskflow/presentation/providers/project_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/splash_screen.dart';

void main() {
  final dataSource = MockDataSource();

  final repository = TaskFlowRepository(dataSource: dataSource);

  runApp(
    MultiProvider(
      providers: [
        Provider<MockDataSource>.value(value: dataSource),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProjectProvider(repository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(repository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) => CommentProvider(repository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(repository: repository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskFlow',
      home: const SplashScreen(),
    );
  }
}
