import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:gmail_inbox_template/email_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class GoogleService {
  final GoogleSignIn googleSignin = GoogleSignIn(scopes: [GmailApi.gmailReadonlyScope]);
  GoogleSignInAccount? currentUser;

  Future<GoogleSignInAccount?> googleLogin() async {
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
        final messagesWithBody = await Future.wait(messages.sublist(0, 10).map((message) async {
          final messageInfo = await gmailApi.users.messages.get('me', message.id!, format: 'full');
          return messageInfo;
        }));
        // lookMessageInfos(messagesWithBody);
        return messagesWithBody.map((message) => EmailModel.fromMessage(message)).toList();
      } else {
        log('No messages found.');
      }
    } catch (e) {
      throw 'Erro ao obter a caixa de entrada do Gmail: $e';
    }
    return null;
  }

  void lookMessageInfos(List<Message> mensagens) {
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
