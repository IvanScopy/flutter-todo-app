import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/utils/database_factory.dart';
import 'core/services/notification_service.dart';
import 'core/services/performance_service.dart';
import 'core/services/analytics_service.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize core services
  await DatabaseFactory.initialize();
  await NotificationService().initialize();
  await PerformanceService().initialize();
  await AnalyticsService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        // darkTheme: AppTheme.darkTheme, // Will implement later
        themeMode: ThemeMode.light,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
