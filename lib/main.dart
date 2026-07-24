import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nakeel_demo/controller/AuthProvider.dart';
import 'package:nakeel_demo/controller/add_palm_controller.dart';
import 'package:nakeel_demo/controller/add_user_controller.dart';
import 'package:nakeel_demo/controller/farms_controller.dart';
import 'package:nakeel_demo/controller/main_provider.dart';
import 'package:nakeel_demo/controller/network_provider.dart';
import 'package:nakeel_demo/controller/palms_controller.dart';
import 'package:nakeel_demo/controller/users_list_controller.dart';
import 'package:nakeel_demo/routes/add_user.dart';
import 'package:nakeel_demo/routes/control_panel.dart';
import 'package:nakeel_demo/routes/login_screen.dart';
import 'package:nakeel_demo/routes/home_screen.dart';
import 'package:nakeel_demo/routes/add_farm_screen.dart';
import 'package:nakeel_demo/routes/add_palm_screen.dart';
import 'package:nakeel_demo/routes/manage_farms.dart';
import 'package:nakeel_demo/routes/no_internet.dart';
import 'package:nakeel_demo/routes/palms_grid_screen.dart';
import 'package:nakeel_demo/routes/palms_list_screen.dart';
import 'package:nakeel_demo/routes/splash_screen.dart';
import 'package:nakeel_demo/routes/users_list_screen.dart';
import 'package:nakeel_demo/services/shared_prefs_helper.dart';
import 'package:nakeel_demo/theme/theme_data.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  await SharedPrefsHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NetworkProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => MainProvider()),
        ChangeNotifierProvider(create: (context) => AddUserController()),
        ChangeNotifierProvider(create: (context) => UsersListController()),
        ChangeNotifierProvider(create: (context) => FarmsController()),
        ChangeNotifierProvider(create: (context) => AddPalmController()),
        ChangeNotifierProvider(create: (context) => PalmsController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nakeel App',
        theme: lightTheme,
        home: SplashScreen(),
        routes: {
          SplashScreen.routeName: (context) => SplashScreen(),
          NoInternet.routeName: (context) => NoInternet(),
          LoginScreen.routeName: (context) => LoginScreen(),
          HomeScreen.routeName: (context) => HomeScreen(),
          ControlPanel.routeName: (context) => ControlPanel(),
          AddFarmScreen.routeName: (context) => AddFarmScreen(),
          UsersListScreen.routeName: (context) => UsersListScreen(),
          AddPalmScreen.routeName: (context) => AddPalmScreen(),
          ManageFarms.routeName: (context) => ManageFarms(),
          AddUser.routeName: (context) => AddUser(),
          PalmsGridScreen.routeName: (context) => PalmsGridScreen(),
          PalmsListScreen.routeName: (context) => PalmsListScreen(),
        },
      ),
    );
  }
}

//rename setAppName --value "ادارة مزرعة النخيل"
