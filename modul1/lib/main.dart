import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

// Titik masuk aplikasi.
// Menggunakan GetMaterialApp agar routing dan dependency injection
// dari paket GetX bisa langsung dipakai.
void main() {
  runApp(
    GetMaterialApp(
      title: "Aplikasi",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
