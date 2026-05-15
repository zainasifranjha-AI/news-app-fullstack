import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'core/theme/news_theme.dart';
import 'core/theme_mode_holder.dart';
import 'screens/admin_login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('en', timeago.EnMessages());
  runApp(const NewsAppRoot());
}

class NewsAppRoot extends StatelessWidget {
  const NewsAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: globalThemeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: NewsTheme.light,
          darkTheme: NewsTheme.dark,
          home: const AdminLoginScreen(),
        );
      },
    );
  }
}
