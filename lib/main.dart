import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/supabase_service.dart';
import 'services/cart_service.dart';
import 'services/favorites_service.dart';
import 'pages/main_layout.dart';
import 'providers/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final appState = AppState();
            appState.addDummyProducts(); // إضافة بيانات تجريبية
            return appState;
          }
        ),
        Provider<CartService>(create: (context) => CartService(prefs)),
        Provider<FavoritesService>(create: (context) => FavoritesService(prefs)),
      ],
      child: MaterialApp(
        title: 'عمر ماركت',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6E58A8),
            primary: const Color(0xFF6E58A8),
          ),
          useMaterial3: true,
          fontFamily: 'Cairo',
        ),
        locale: const Locale('ar', 'EG'),
        supportedLocales: const [
          Locale('ar', 'EG'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const MainLayout(),
      ),
    );
  }
}
