import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eventhub/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'https://xxxxx.supabase.co',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'anon-key',
  );

  runApp(
    const ProviderScope(
      child: EventHubApp(),
    ),
  );
}
