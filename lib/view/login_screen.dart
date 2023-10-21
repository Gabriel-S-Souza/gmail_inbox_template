import 'package:flutter/material.dart';
import 'package:gmail_inbox_template/google_service.dart';
import 'package:gmail_inbox_template/view/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleService googleService = GoogleService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        isLoading = true;
      });
      final response = await googleService.signInSilently();
      if (response != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HomeScreen(googleService: googleService),
          ),
        );
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Gmail Inbox Template'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Login',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Flexible(
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : FilledButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          final response = await googleService.login();
                          if (response != null && mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(googleService: googleService),
                              ),
                            );
                          }
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/google_logo.png',
                              height: 18.0,
                              width: 18.0,
                            ),
                            const SizedBox(width: 8.0),
                            const Text('Login com o Google'),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
