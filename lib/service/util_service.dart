import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class UtilService {
  String formatDateTime(DateTime dateTime) {
    initializeDateFormatting();

    DateFormat dateFormat = DateFormat.yMd('pt_BR');

    return dateFormat.format(dateTime);
  }

  Future sendEmail({required String email, required String body}) async {
    final String username = dotenv.env['SMTP_USER'] ?? '';
    final String password = dotenv.env['SMTP_PASSWORD'] ?? '';
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Box4Pets')
      ..recipients.add(email)
      ..subject = 'Recuperação de Senha'
      ..html = body;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
