import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/loop_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/root_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MindLoadApp());
}

class MindLoadApp extends StatelessWidget {
  const MindLoadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoopProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'مغز آرام',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('fa', 'IR'),
        supportedLocales: const [Locale('fa', 'IR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const RootScreen(),
      ),
    );
  }
}
