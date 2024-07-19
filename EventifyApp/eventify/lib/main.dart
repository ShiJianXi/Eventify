import 'package:eventify/app_state.dart';
import 'package:eventify/chat.dart';
import 'package:eventify/event_listing_page.dart';
import 'package:eventify/provider/firebase_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const App()),
  ));
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'sign-in',
          builder: (context, state) {
            return SignInScreen(
              actions: [
                ForgotPasswordAction(((context, email) {
                  final uri = Uri(
                    path: '/sign-in/forgot-password',
                    queryParameters: <String, String?>{
                      'email': email,
                    },
                  );
                  context.push(uri.toString());
                })),
                AuthStateChangeAction(((context, state) {
                  final user = switch (state) {
                    SignedIn state => state.user,
                    UserCreated state => state.credential.user,
                    _ => null
                  };
                  if (user == null) {
                    return;
                  }
                  if (state is UserCreated) {
                    user.updateDisplayName(user.email!.split('@')[0]);
                  }
                  if (!user.emailVerified) {
                    user.sendEmailVerification();
                    const snackBar = SnackBar(
                        content: Text(
                            'Please check your email to verify your email address'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                  context.pushReplacement('/');
                })),
              ],
              headerBuilder: (context, constraints, _) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/eventify.png',
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          routes: [
            GoRoute(
              path: 'forgot-password',
              builder: (context, state) {
                final arguments = state.uri.queryParameters;
                return ForgotPasswordScreen(
                  email: arguments['email'],
                  headerMaxExtent: 200,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) {
            return ProfileScreen(
              providers: const [],
              actions: [
                SignedOutAction((context) {
                  context.pushReplacement('/');
                }),
              ],
            );
          },
        ),
        GoRoute(
          path: 'event_listing',
          builder: (context, state) => const EventListingPage(),
        ),
        GoRoute(
          path: 'chat',
          builder: (context, state) => const ChatPage(),
        ),
      ],
    ),
  ],
);

final navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FirebaseProvider(),
      child: MaterialApp.router(
        title: '',
        theme: ThemeData(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
              minimumSize: const Size.fromHeight(52),
              backgroundColor: Colors.yellow,
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),
          buttonTheme: Theme.of(context).buttonTheme.copyWith(
                highlightColor: Colors.deepPurple,
              ),
          primarySwatch: Colors.deepPurple,
          textTheme: GoogleFonts.robotoTextTheme(
            Theme.of(context).textTheme,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) => ChangeNotifierProvider(
  //       create: (_) => FirebaseProvider(),
  //       child: MaterialApp(
  //         navigatorKey: navigatorKey,
  //         debugShowCheckedModeBanner: false,
  //         theme: ThemeData(
  //             elevatedButtonTheme: ElevatedButtonThemeData(
  //               style: ElevatedButton.styleFrom(
  //                   textStyle: const TextStyle(fontSize: 20),
  //                   minimumSize: const Size.fromHeight(52),
  //                   backgroundColor: Colors.yellow),
  //             ),
  //             appBarTheme: const AppBarTheme(
  //               backgroundColor: Colors.transparent,
  //               elevation: 0,
  //               titleTextStyle: TextStyle(
  //                 color: Colors.black,
  //                 fontSize: 35,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             )),
  //         home: const ChatPage(),
  //       ),
  //     );
  // Widget build(BuildContext context) {
  //   return MaterialApp.router(
  //     title: '',
  //     theme: ThemeData(
  //       buttonTheme: Theme.of(context).buttonTheme.copyWith(
  //             highlightColor: Colors.deepPurple,
  //           ),
  //       primarySwatch: Colors.deepPurple,
  //       textTheme: GoogleFonts.robotoTextTheme(
  //         Theme.of(context).textTheme,
  //       ),
  //       visualDensity: VisualDensity.adaptivePlatformDensity,
  //       useMaterial3: true,
  //     ),
  //     routerConfig: _router,
  //     //home: const HomePage(),
  //   );
  // }
}
