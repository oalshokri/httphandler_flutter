import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/profile/links/providers/links_provider.dart';
import 'features/profile/profile_view.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LinkProvider>(
          create: (_) => LinkProvider(),
        ),
      ],
      child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Betweener',
          home: ProfileView()),
    );
  }
}
