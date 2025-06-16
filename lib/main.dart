import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/home/cubit/hike_cubit.dart';
import 'data/repositories/firebase_hike_repository.dart';
import 'locator.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'presentation/auth/screen/login_screen.dart';
import 'data/repositories/user_repository_impl.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/repositories/hike_repository_impl.dart';
import 'domain/repositories/hike_repository.dart';
import 'domain/repositories/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env").timeout(const Duration(seconds: 5));
  } catch (e) {
    print("Dotenv load failed: $e");
  }
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 10));
  } catch (e) {
    print("Firebase init failed: $e");
  }
  await init();
  
  final userRepository = UserRepositoryImpl();
  final hikeRepository = HikeRepositoryImpl();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<UserRepository>.value(value: userRepository),
        Provider<HikeRepository>.value(value: hikeRepository),
      ],
      child: BlocProvider(
        create: (_) => HikeCubit(FirebaseHikeRepository()),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userRepository = Provider.of<UserRepository>(context);
    final hikeRepository = Provider.of<HikeRepository>(context);
    
    return MaterialApp(
      title: 'Roveeee',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.generateRoute,
      home: LoginScreen(userRepository: userRepository),
      theme: AppTheme.lightTheme,
    );
  }
}
