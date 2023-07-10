import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:gmail_inbox_template/email_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class GoogleService {
  final GoogleSignIn googleSignin = GoogleSignIn(scopes: [GmailApi.gmailReadonlyScope]);
  GoogleSignInAccount? currentUser;

  Future<GoogleSignInAccount?> login() async {
    if (await googleSignin.isSignedIn()) {
      log('User signed in');
      currentUser = await googleSignin.signInSilently();
      return currentUser;
    }

    final googleUser = await googleSignin.signIn();
    if (googleUser == null) {
      log('Google user is null');
      return null;
    }

    final googleAuth = await googleUser.authentication;

    final credentials = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credentials);

    currentUser = googleUser;
    return currentUser;
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      final googleUser = await googleSignin.signInSilently();
      if (googleUser == null) {
        log('google user is null');
        return null;
      }

      currentUser = googleUser;
      return googleUser;
    } catch (e) {
      throw 'Erro ao fazer login silencioso: $e';
    }
  }

  Future<List<EmailModel>?> getInbox() async {
    var httpClient = await googleSignin.authenticatedClient();
    assert(httpClient != null, 'http client is null');

    final gmailApi = GmailApi(httpClient!);

    try {
      final response = await gmailApi.users.messages.list(
        'me',
        q: 'newsletter',
      );
      final messages = response.messages;

      if (messages != null && messages.isNotEmpty) {
        final fechetMessages = messages.length > 30 ? messages.sublist(0, 30) : messages;
        final messagesWithBody = await Future.wait(fechetMessages.map((message) async {
          final messageInfo = await gmailApi.users.messages.get(
            'me',
            message.id!,
            format: 'metadata',
          );
          return messageInfo;
        }));
        // lookMessageInfos(messagesWithBody);
        return messagesWithBody.map((message) => EmailModel.fromMessageMetadata(message)).toList();
      } else {
        log('No messages found.');
      }
    } catch (e) {
      throw 'Erro ao obter a caixa de entrada do Gmail: $e';
    }
    return null;
  }

  Future<EmailModel>? getEmail(String emailId) async {
    try {
      var httpClient = await googleSignin.authenticatedClient();
      assert(httpClient != null, 'http client is null');
      final gmailApi = GmailApi(httpClient!);
      final message = await gmailApi.users.messages.get(
        'me',
        emailId,
        format: 'full',
      );
      return EmailModel.fromMessage(message);
    } catch (e) {
      throw 'Erro ao obter a caixa de entrada do Gmail: $e';
    }
  }

  void _lookMessageInfos(List<Message> mensagens) {
    for (var mensagem in mensagens) {
      log('Mensagem: ${mensagem.toJson()}}');
    }
  }

  Future<void> logout() async {
    await googleSignin.signOut();
    await FirebaseAuth.instance.signOut();
    currentUser = null;
  }
}
