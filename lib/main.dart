import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'services/cart_service.dart';
import 'services/favorites_service.dart';
import 'pages/main_layout.dart';
import 'pages/category_products_page.dart';
import 'providers/app_state.dart';
import 'models/category_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure web-specific settings
  setUrlStrategy(PathUrlStrategy());
  
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
            // Initialize products immediately
            appState.addDummyProducts();
            return appState;
          },
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
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
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
        onGenerateRoute: (settings) {
          // Remove any query parameters from the route name
          final uri = Uri.parse(settings.name ?? '/');
          final path = uri.path;
          
          if (path == '/') {
            return MaterialPageRoute(builder: (context) => const MainLayout());
          }
          
          if (settings.name == '/category') {
            final CategoryModel category = settings.arguments as CategoryModel;
            return MaterialPageRoute(
              builder: (context) => CategoryProductsPage(category: category),
            );
          }
          return null;
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const MainLayout());
        },
      ),
    );
  }
}
