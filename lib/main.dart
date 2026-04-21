import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/app_config.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(const GSXApp());
}

class GSXApp extends StatelessWidget {
  const GSXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Check if user is already logged in
      initialRoute: Supabase.instance.client.auth.currentSession != null 
          ? AppConfig.homeRoute 
          : AppConfig.loginRoute,
      routes: {
        AppConfig.loginRoute: (context) => const LoginScreen(),
        AppConfig.registerRoute: (context) => const RegisterScreen(),
        AppConfig.homeRoute: (context) => const HomeScreen(),
      },
    );
  }
}
