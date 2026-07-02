import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/auth_service.dart';
import 'data/favorite_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await AuthService().loadSavedSession();
  if (AuthService().isLoggedIn) {
    FavoriteService().loadFavorites();
  }

  runApp(const KostMapApp());
}

class KostMapApp extends StatelessWidget {
  const KostMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KostMap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainNavigator(),
    );
  }
}
