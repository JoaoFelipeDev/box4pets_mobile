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
  final String username = 'noreply.box4pets@gmail.com';
  final String password = 'o s f e l v v l w g s d p j z x';
  //o s f e l v v l w g s d p j z x
  final smtpServer = gmail(username, password);
   
    final message = Message()
      ..from = Address(username, 'Box4Pets')
      ..recipients.add(email)
      ..subject = 'Recuperação de Senha'
      ..html = body;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }

  }
}
