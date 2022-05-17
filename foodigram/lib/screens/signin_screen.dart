import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import '../authentication/auth_service.dart';

class SignIn extends StatefulWidget {
  const SignIn({
    Key? key,
    required this.waitScreenMask,
    required this.networkErrorSnackBar,
  }) : super(key: key);

  final Function(Function futureCallback) waitScreenMask;
  final SnackBar networkErrorSnackBar;

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailTextField = TextEditingController();
  final TextEditingController passwordTextField = TextEditingController();
  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();

  // Map For Displaying Erorr Messages
  Map<String, String> errorMessage = {
    "email": "",
    "password": "",
    "network": "",
  };

  Future<void> signinProcessing() async {
    await AuthService()
        .signIn(emailTextField.text, passwordTextField.text)
        .then((value) {
      if (value["network"]!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(widget.networkErrorSnackBar);
      }
      setState(() {
        errorMessage = value;
      });
      _signInFormKey.currentState!.validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
        key: _signInFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 3,
            ),
            TextFormField(
              controller: emailTextField,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.emailAddress,
              cursorColor: Theme.of(context).colorScheme.secondary,
              obscureText: false,
              style: Theme.of(context).textTheme.headline5,
              decoration: const InputDecoration(labelText: "Email"),
              validator: (email) {
                if (email == null || email.isEmpty) {
                  return "Please enter an email adress";
                } else if (!EmailValidator.validate(email)) {
                  return "Invalid email adress";
                } else if (errorMessage["email"]!.isNotEmpty) {
                  return errorMessage["email"];
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: passwordTextField,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.visiblePassword,
              cursorColor: Theme.of(context).colorScheme.secondary,
              obscureText: true,
              style: Theme.of(context).textTheme.headline5,
              decoration: const InputDecoration(labelText: "Password"),
              validator: (password) {
                if (password == null || password.isEmpty) {
                  return "Please enter a password";
                } else if (errorMessage["password"]!.isNotEmpty) {
                  return errorMessage["password"];
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10,
            ),

            const SizedBox(
              height: 20,
            ),

            // Sign In Button
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                child: const Text("Sign In"),
                onPressed: () async {
                  setState(() {
                    errorMessage["email"] = "";
                    errorMessage["netwrok"] = "";
                    errorMessage["password"] = "";
                  });

                  // 1. Check Form Validation
                  // 2. Set State "loading" = true
                  // 3. Call "signIn" Future inside AuthService()
                  // 4. Catch NetworkError - Show SnackBar
                  // 5. Set State "errorMessage" = value
                  // 6. Check Form Validation Again
                  // 7. If Valid => Home

                  if (_signInFormKey.currentState!.validate()) {
                    widget.waitScreenMask(signinProcessing);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
