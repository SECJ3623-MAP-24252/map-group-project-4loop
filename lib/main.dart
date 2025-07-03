import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/pharmacy_viewmodel.dart';
import 'viewmodels/inventory_viewmodel.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/notification_viewmodel.dart';
import 'viewmodels/analytics_viewmodel.dart';
import 'viewmodels/audit_logs_viewmodel.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/auth/reset_password_screen.dart';
import 'views/pharmacy/pharmacy_profile_screen.dart';
import 'views/pharmacy/invite_staff_screen.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/inventory/inventory_screen.dart';
import 'views/inventory/analytics_screen.dart';
import 'views/inventory/audit_logs_screen.dart';
import 'views/pharmacy/profile_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);
  runApp(const AppTrackerApp());
}

class AppTrackerApp extends StatelessWidget {
  const AppTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProxyProvider<AuthViewModel, PharmacyViewModel>(
          create: (context) => PharmacyViewModel(''),
          update: (context, auth, previous) =>
              PharmacyViewModel(auth.user?.pharmacyId ?? ''),
        ),
        ChangeNotifierProxyProvider<AuthViewModel, InventoryViewModel>(
          create: (context) => InventoryViewModel(''),
          update: (context, auth, previous) =>
              InventoryViewModel(auth.user?.pharmacyId ?? ''),
        ),
        ChangeNotifierProxyProvider<AuthViewModel, ChatViewModel>(
          create: (context) => ChatViewModel(null),
          update: (context, auth, previous) => ChatViewModel(auth.user),
        ),
        ChangeNotifierProxyProvider<AuthViewModel, AnalyticsViewModel>(
          create: (context) => AnalyticsViewModel(''),
          update: (context, auth, previous) =>
              AnalyticsViewModel(auth.user?.pharmacyId ?? ''),
        ),
        ChangeNotifierProxyProvider<AuthViewModel, AuditLogsViewModel>(
          create: (context) => AuditLogsViewModel(''),
          update: (context, auth, previous) =>
              AuditLogsViewModel(auth.user?.pharmacyId ?? ''),
        ),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
      ],
      child: MaterialApp(
        title: 'AppTracker',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: Color(0xFFF8FAFB),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 1,
            iconTheme: IconThemeData(color: Colors.teal),
            titleTextStyle: TextStyle(
              color: Colors.teal[800],
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          textTheme: TextTheme(
            titleLarge:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[900]),
            bodyMedium: TextStyle(color: Colors.black87),
          ),
          cardTheme: CardTheme(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey[500],
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
        ),
        navigatorKey: navigatorKey,
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/reset-password': (context) => ResetPasswordScreen(),
          '/dashboard': (context) => DashboardScreen(),
          '/pharmacy-profile': (context) => PharmacyProfileScreen(),
          '/invite-staff': (context) => InviteStaffScreen(),
          '/inventory': (context) => InventoryScreen(),
          '/profile': (context) => ProfileScreen(),
          '/analytics': (context) => AnalyticsScreen(),
          '/audit-logs': (context) => AuditLogsScreen(),
        },
      ),
    );
  }
}
