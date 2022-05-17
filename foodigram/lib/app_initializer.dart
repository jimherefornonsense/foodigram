import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodigram/screens/loading_screen.dart';
import 'package:foodigram/screens/new_post_screen.dart';
import 'package:foodigram/screens/post_detail_screen.dart';
import 'package:foodigram/screens/update_post_screen.dart';
import 'package:foodigram/theme.dart';
import 'package:provider/provider.dart';
import 'authentication/auth.dart';
import 'data_center.dart';
import 'screens/lobby_screen.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late DataCenter _dataCenter;
  late StreamSubscription<User?> _authListener;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _dataCenter = Provider.of<DataCenter>(context, listen: false);
    initAuthListener();
  }

  void initAuthListener() {
    _authListener = _dataCenter.authService.authStateChanges().listen((user) {
      if (user == null) {
        _navigatorKey.currentState!
            .pushNamedAndRemoveUntil('auth', ModalRoute.withName('/'));
      } else {
        _dataCenter.fetchPosts();
        _navigatorKey.currentState!
            .pushNamedAndRemoveUntil('lobby', ModalRoute.withName('/'));
      }
    });
  }

  @override
  void dispose() {
    _authListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: customTheme(),
      initialRoute:
          _dataCenter.authService.currentUser() != null ? 'lobby' : 'auth',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'auth':
            return MaterialPageRoute(
                settings: const RouteSettings(name: 'auth'),
                builder: (_) => const Authentication());
          case 'lobby':
            return MaterialPageRoute(
                settings: const RouteSettings(name: 'lobby'),
                builder: (_) => const Lobby());
          case 'new-post':
            return MaterialPageRoute(
                settings: const RouteSettings(name: 'new-post'),
                builder: (_) => const NewPost());
          case 'update-post':
            final args = settings.arguments as UpdatePostArg;
            return MaterialPageRoute(
                settings: const RouteSettings(name: 'update-post'),
                builder: (_) => UpdatePost(postIndex: args.postIndex));
          case 'post-detail':
            final args = settings.arguments as PostDetailArg;
            return MaterialPageRoute(
                settings: const RouteSettings(name: 'post-detail'),
                builder: (_) => PostDetail(startingPage: args.startingPage));
          default:
            return MaterialPageRoute(builder: (_) => const Loading());
          // case: ''
        }
      },
    );
  }
}
