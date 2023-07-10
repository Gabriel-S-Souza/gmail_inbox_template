import 'dart:developer';
import 'dart:convert' show utf8, base64;
import 'package:googleapis/gmail/v1.dart';
import 'package:intl/intl.dart';

class EmailModel {
  String sender;
  String subject;
  String body;

  EmailModel({
    required this.sender,
    required this.subject,
    required this.body,
  });

  factory EmailModel.fromMessage(Message message) {
    return EmailModel(
      sender: _getSender(message),
      subject: _getSubject(message),
      body: _getBodyEmail(message),
    );
  }

  static String _getBody(List<MessagePart> partes) {
    final List<String> allParts = [];

    for (var parte in partes) {
      if (parte.mimeType == 'text/plain') {
        final base64Body =
            parte.body?.data ?? base64.encode(utf8.encode('Nenhum corpo em text/plain encontrado'));
        final decodedBody = utf8.decode(base64.decode(base64Body));
        allParts.add(decodedBody);
      }
    }

    return allParts.join('\n');
  }

  static String _getBodyRaw(String raw) {
    final decodedBody = utf8.decode(base64.decode(raw));

    String decodedBodyHtml = '';
    RegExp regex = RegExp(r'<body[^>]*>([\s\S]*)<\/body>');
    Match? match = regex.firstMatch(decodedBody);
    decodedBodyHtml = match?.group(1) ?? '';

    // RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    final String parsedstring1 = Bidi.stripHtmlIfNeeded(decodedBodyHtml);

    log('decodedBodyHtml: $parsedstring1');

    return parsedstring1.isEmpty
        ? 'Nenhum corpo encontrado' //
        : parsedstring1;
  }

  static String _getBodyEmail(Message message) {
    final parts = message.payload?.parts;
    if (parts == null) {
      log('parts is null');
      return 'Corpo não encontrado';
    }

    return _getBody(parts);
  }

  static String _getBodyEmailRaw(Message message) {
    final raw = message.raw;
    if (raw == null) {
      log('raw is null');
      return 'Corpo não encontrado';
    }

    return _getBodyRaw(raw);
  }

  static String _getSender(Message message) {
    final headers = message.payload?.headers;
    if (headers == null) {
      log('Headers is null');
      return 'Remetente não encontrado';
    }

    String sender = '??';

    for (var header in headers) {
      if (header.name?.toLowerCase() == 'from') {
        sender = header.value ?? 'Remetente vazio';
      }
    }

    return sender;
  }

  static String _getSubject(Message message) {
    final headers = message.payload?.headers;
    if (headers == null) {
      log('Headers is null');
      return 'Assunto não encontrado';
    }

    String subject = '??';

    for (var header in headers) {
      if (header.name?.toLowerCase() == 'subject') {
        subject = header.value ?? 'Assunto vazio';
      }
    }

    return subject;
  }
}
