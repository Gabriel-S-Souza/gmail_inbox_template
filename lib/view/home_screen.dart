import 'package:flutter/material.dart';
import 'package:gmail_inbox_template/google_service.dart';
import 'package:gmail_inbox_template/email_model.dart';
import 'package:gmail_inbox_template/view/details_screen.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final GoogleService googleService;
  const HomeScreen({super.key, required this.googleService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GoogleService googleService;
  List<EmailModel>? messages;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    googleService = widget.googleService;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        isLoading = true;
      });
      messages = await googleService.getInbox();
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
              Row(
                children: [
                  Text(
                    'Bem vindo, ${widget.googleService.currentUser?.displayName}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 20,
                        ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        '${widget.googleService.currentUser?.photoUrl}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.googleService.currentUser?.email}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Suas newsletters  ',
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
              if (messages != null && messages!.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: messages!.length,
                    itemBuilder: (context, index) {
                      final message = messages![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DetailsScreen(
                                  googleService: googleService,
                                  emailId: message.id,
                                ),
                              ),
                            );
                          },
                          child: Card(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer
                                  .withBlue(78)
                                  .withOpacity(0.5),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Remetente: ',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            message.sender,
                                            style: Theme.of(context).textTheme.bodySmall,
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
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            message.subject,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      );
                    },
                  ),
                ),
              if (messages == null || messages!.isEmpty)
                Center(
                  child: messages == null ? const SizedBox() : const Text('Nenhuma mensagem'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
