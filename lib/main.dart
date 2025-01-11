import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/cart_service.dart';
import 'services/favorites_service.dart';
import 'pages/main_layout.dart';
import 'pages/category_products_page.dart';
import 'providers/app_state.dart';
import 'models/category_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
        ChangeNotifierProvider<CartService>(
          create: (context) => CartService(prefs)
        ),
        ChangeNotifierProvider<FavoritesService>(
          create: (context) => FavoritesService(prefs)
        ),
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
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', ''),
        ],
        locale: const Locale('ar', ''),
        home: const MainLayout(),
        onGenerateRoute: (settings) {
          if (settings.name == '/category') {
            final CategoryModel category = settings.arguments as CategoryModel;
            return MaterialPageRoute(
              builder: (context) => CategoryProductsPage(category: category),
            );
          }
          return null;
        },
      ),
    );
  }
}
