import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import '../authentication/auth_service.dart';

class SignUp extends StatefulWidget {
  const SignUp({
    Key? key,
    required this.waitScreenMask,
    required this.networkErrorSnackBar,
  }) : super(key: key);

  final Function(Function futureCallback) waitScreenMask;
  final SnackBar networkErrorSnackBar;

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController emailTextField = TextEditingController();
  final TextEditingController passwordTextField = TextEditingController();
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();

  // Map For Displaying Erorr Messages
  Map<String, String> errorMessage = {
    "email": "",
    "password": "",
    "network": "",
  };

  Future<void> signupProcessing() async {
    await AuthService()
        .signUp(emailTextField.text, passwordTextField.text)
        .then((value) {
      if (value["network"]!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(widget.networkErrorSnackBar);
      }
      setState(() {
        errorMessage = value;
      });
      _signUpFormKey.currentState!.validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
        key: _signUpFormKey,
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
              height: 20,
            ),
            TextFormField(
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.visiblePassword,
              cursorColor: Theme.of(context).colorScheme.secondary,
              obscureText: true,
              style: Theme.of(context).textTheme.headline5,
              decoration: const InputDecoration(labelText: "Rewrite Password"),
              validator: (rewritePassword) {
                if (rewritePassword == null || rewritePassword.isEmpty) {
                  return "Please rewrite your password";
                } else if (passwordTextField.text != rewritePassword) {
                  return "Password does not match";
                } else if (errorMessage["password"]!.isNotEmpty) {
                  return errorMessage["password"];
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),

            // Sign Up Button
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                child: const Text("Sign Up"),
                onPressed: () async {
                  setState(() {
                    errorMessage["email"] = "";
                    errorMessage["netwrok"] = "";
                    errorMessage["password"] = "";
                  });

                  // 1. Check Form Validation
                  // 2. Set State "loading" = true
                  // 3. Call "signUp" Future inside AuthService()
                  // 4. Catch NetworkError - Show SnackBar
                  // 5. Set State "errorMessage" = value
                  // 6. Check Form Validation Again
                  // 7. If Valid => Home

                  if (_signUpFormKey.currentState!.validate()) {
                    widget.waitScreenMask(signupProcessing);
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
