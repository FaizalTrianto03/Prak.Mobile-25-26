import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/values/app_strings.dart';
import 'app/data/services/local_storage_service.dart';
import 'app/data/services/supabase_service.dart';
import 'app/data/providers/auth_provider.dart';
import 'app/data/providers/note_provider.dart';
import 'app/data/providers/todo_provider.dart';
import 'app/data/providers/theme_provider.dart';
import 'app/data/services/storage_service.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    // Initialize Supabase Service
    await Get.putAsync(() => SupabaseService().init());

    // Initialize Providers
    Get.put(AuthProvider());
    Get.put(NoteProvider());
    Get.put(StorageService());
    await Get.putAsync(() => LocalStorageService().init());
    Get.put(TodoProvider());
    final themeProvider = Get.put(ThemeProvider());
    await themeProvider.init();

    if (kDebugMode) {
      debugPrint('✅ All services initialized successfully');
    }

    runApp(const MyApp());
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ Error during initialization:');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
    }

    // Show error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red[50],
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Initialization Error',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      e.toString(),
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Restart app
                      SystemChannels.platform.invokeMethod(
                        'SystemNavigator.pop',
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Restart App'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Get.find<AuthProvider>();
    final themeProvider = Get.find<ThemeProvider>();

    return Obx(() {
      // Update system UI overlay style based on theme
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: themeProvider.isDarkMode
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarColor: themeProvider.isDarkMode
              ? const Color(0xFF000000)
              : Colors.white,
          systemNavigationBarIconBrightness: themeProvider.isDarkMode
              ? Brightness.light
              : Brightness.dark,
        ),
      );

      return GetMaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        initialRoute: authProvider.isAuthenticated ? Routes.HOME : Routes.LOGIN,
        getPages: AppPages.routes,
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
      );
    });
  }
}
