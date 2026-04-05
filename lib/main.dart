import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/voice_state.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = VoiceState();
  await state.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: const AzureVoiceMicroApp(),
    ),
  );
}

class AzureVoiceMicroApp extends StatelessWidget {
  const AzureVoiceMicroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azure Voice Micro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
