import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/data/services/supabase_service.dart';
import 'app/data/providers/auth_provider.dart';
import 'app/data/providers/instrument_provider.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase Service
  await Get.putAsync(() => SupabaseService().init());

  // Initialize Providers
  Get.put(AuthProvider());
  Get.put(InstrumentProvider());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Get.find<AuthProvider>();

    return GetMaterialApp(
      title: 'Instruments CRUD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: authProvider.isAuthenticated ? Routes.HOME : Routes.LOGIN,
      getPages: AppPages.routes,
    );
  }
}
