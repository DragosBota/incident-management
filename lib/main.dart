import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/supabase_config.dart';


Future<void> main() async {
  // Ensures that plugin services are initialized before
  // running any asynchronous startup code.
  WidgetsFlutterBinding.ensureInitialized();

  // Loads environment variables from the `.env` file.
  await dotenv.load(fileName: '.env');

  // Initializes the Supabase client with project credentials.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Launches the root application widget.
  runApp(const IncidentManagementApp());
}