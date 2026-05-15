import 'package:pharmapack/core/routes/app_router.dart';
import 'package:pharmapack/core/theme/app_theme.dart';
import 'package:pharmapack/features/auth/presentation/bloc/auth_bloc.dart'; // <-- IMPORT AJOUTÉ
import 'package:pharmapack/features/auth/presentation/pages/splash_page.dart';
import 'package:pharmapack/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmapack/core/connection/auth_interceptor.dart';
import 'package:pharmapack/features/pharmacie/presentation/bloc/home/home_bloc.dart'; // <-- IMPORT AJOUTÉ
import 'package:pharmapack/features/pharmacie/presentation/bloc/produit/produit_bloc.dart';
import 'package:pharmapack/features/pharmacie/presentation/bloc/commande/commande_bloc.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<HomeBloc>()),
        BlocProvider(create: (_) => di.sl<ProduitBloc>()),
        BlocProvider(create: (_) => di.sl<CommandeBloc>()),
      ],
      child: MaterialApp(
        navigatorKey: AuthInterceptor.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Pharma Pack',
        theme: AppTheme.light(),
        home: const SplashPage(),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
