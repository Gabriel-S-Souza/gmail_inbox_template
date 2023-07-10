import 'package:flutter/material.dart';
import 'package:gmail_inbox_template/view/login_screen.dart';

import '../email_model.dart';
import '../google_service.dart';

class DetailsScreen extends StatefulWidget {
  final GoogleService googleService;
  final String emailId;
  const DetailsScreen({super.key, required this.googleService, required this.emailId});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final GoogleService googleService;
  late EmailModel message;
  bool isLoading = false;

  get _voidEmailModel => EmailModel(
        id: '',
        sender: '',
        subject: '',
        body: 'Email não encontrado, tente novamente.',
      );

  @override
  void initState() {
    super.initState();
    message = _voidEmailModel;
    googleService = widget.googleService;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        isLoading = true;
      });
      message = await googleService.getEmail(widget.emailId) ?? _voidEmailModel;
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
        actions: [
          IconButton(
            onPressed: () async {
              await googleService.logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 16.0, right: 8.0, bottom: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  'Newsletter  ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (isLoading)
                const Flexible(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              const SizedBox(height: 8),
              if (!isLoading && !message.isEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Remetente: ',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            Flexible(
                              child: Text(
                                message.sender,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assunto: ',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            Flexible(
                              child: Text(
                                message.subject,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Corpo: ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: SingleChildScrollView(
                            child: Text(
                              message.body.trim(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: message.body.length > 1000 ? 40 : 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // if (message.isEmpty)
              //   const Center(
              //     child: Text('Email não encontrado, tente novamente.'),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
