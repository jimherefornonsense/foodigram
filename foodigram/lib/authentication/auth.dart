import 'package:flutter/material.dart';
import '../screens/signin_screen.dart';
import '../screens/signup_screen.dart';
import 'auth_service.dart';

class Authentication extends StatefulWidget {
  const Authentication({Key? key}) : super(key: key);

  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  PageController authPageController =
      PageController(keepPage: true, initialPage: 0);
  int page = 0;

  // No Internet Connection SnackBar
  SnackBar networkErrorSnackBar = SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.wifi_off,
          size: 15,
          color: Colors.white,
        ),
        SizedBox(
          width: 4,
        ),
        Text("No internet connection. Try again!")
      ],
    ),
  );

  void waitScreenMask(Function futureCallback) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            const Center(child: CircularProgressIndicator()),
        routeSettings: const RouteSettings(name: "waitMask"));

    await futureCallback();

    Navigator.of(context)
        .popUntil((route) => route.settings.name != 'waitMask');
  }

  // Change Page Button Preffixs
  List<String> preffix = [
    "Need an account? ",
    "Have an account? ",
  ];

  // Change Page Button Suffixs
  List<String> suffix = [
    "SignUp",
    "Sign In",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: Text(
                      "Foodiegram",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 50,
                        fontWeight: FontWeight.normal,
                        fontFamily: "Chewy",
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    // PageView To Display Auth Pages
                    child: PageView(
                      controller: authPageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (value) {
                        setState(() {
                          page = value;
                        });
                      },
                      children: [
                        // SignIn Page
                        SignIn(
                          waitScreenMask: waitScreenMask,
                          networkErrorSnackBar: networkErrorSnackBar,
                        ),

                        // SignUp Page
                        SignUp(
                          waitScreenMask: waitScreenMask,
                          networkErrorSnackBar: networkErrorSnackBar,
                        ),
                      ],
                    ),
                  ),
                  // Google sign in
                  Flexible(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Image(
                              image: AssetImage('assets/google.png'),
                              height: 30,
                              width: 30,
                            ),
                            TextButton(
                              onPressed: () => waitScreenMask(
                                  AuthService().signInWithGoogle),
                              child: Text(
                                "Sign in with Google",
                                style: Theme.of(context).textTheme.button,
                              ),
                            )
                          ],
                        ),
                        // Change Page Button
                        GestureDetector(
                          onTap: () {
                            if (authPageController.page == 1) {
                              authPageController.previousPage(
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeInOutCirc,
                              );
                            } else {
                              authPageController.nextPage(
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeInOutCirc,
                              );
                            }
                          },
                          child: RichText(
                            text: TextSpan(
                              text: preffix[page],
                              style: Theme.of(context).textTheme.headline5,
                              children: <TextSpan>[
                                TextSpan(
                                    text: suffix[page],
                                    style: Theme.of(context).textTheme.button),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
