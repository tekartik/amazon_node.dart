import 'dart:convert';
import 'dart:typed_data';

import 'package:tekartik_aws_ses_node/src/ses_common.dart';
import 'package:tekartik_aws_ses_node/src/ses_raw_mime.dart';
import 'package:test/test.dart';

AwsSesMessage _message({
  String? text = 'Hello',
  String? html = '<p>Hello</p>',
  String filename = 'report.pdf',
  int attachmentSize = 100,
}) => AwsSesMessage(
  from: 'from@example.com',
  to: ['to@example.com'],
  cc: ['cc@example.com'],
  bcc: ['bcc@example.com'],
  subject: AwsSesContent(data: 'Subject'),
  text: text == null ? null : AwsSesContent(data: text),
  html: html == null ? null : AwsSesContent(data: html),
  attachments: [
    AwsSesAttachment(
      mimeType: 'application/pdf',
      filename: filename,
      content: Uint8List.fromList(
        List.generate(attachmentSize, (i) => i % 256),
      ),
    ),
  ],
);

void main() {
  group('ses raw mime', () {
    test('destinations', () {
      expect(sesRawMailDestinations(_message()), [
        'to@example.com',
        'cc@example.com',
        'bcc@example.com',
      ]);
    });
    test('headers', () {
      var mime = sesRawMailMimeMessage(_message(), boundary: 'b');
      var headers = mime.substring(0, mime.indexOf('\r\n\r\n')).split('\r\n');
      expect(headers, [
        'From: from@example.com',
        'To: to@example.com',
        'Cc: cc@example.com',
        'Subject: Subject',
        'MIME-Version: 1.0',
        'Content-Type: multipart/mixed; boundary="b-mixed"',
      ]);
      // Bcc never in the message
      expect(mime, isNot(contains('bcc@example.com')));
    });
    test('structure', () {
      var mime = sesRawMailMimeMessage(_message(), boundary: 'b');
      // CRLF only
      expect(mime.replaceAll('\r\n', ''), isNot(contains('\n')));
      var lines = mime.split('\r\n');
      expect(lines.where((line) => line.startsWith('--')), [
        '--b-mixed',
        '--b-alt',
        '--b-alt',
        '--b-alt--',
        '--b-mixed',
        '--b-mixed--',
      ]);
      expect(
        mime,
        contains(
          '--b-mixed\r\n'
          'Content-Type: multipart/alternative; boundary="b-alt"\r\n',
        ),
      );
      expect(
        mime,
        contains(
          'Content-Type: application/pdf; name="report.pdf"\r\n'
          'Content-Disposition: attachment; filename="report.pdf"\r\n',
        ),
      );
    });
    test('single body', () {
      var mime = sesRawMailMimeMessage(_message(html: null), boundary: 'b');
      expect(mime, isNot(contains('multipart/alternative')));
      expect(mime, contains('--b-mixed\r\nContent-Type: text/plain'));
    });
    test('long body lines wrapped', () {
      var text = 'é' * 2000;
      var mime = sesRawMailMimeMessage(
        _message(text: text, html: null, attachmentSize: 3000),
        boundary: 'b',
      );
      var lines = mime.split('\r\n');
      expect(lines.every((line) => line.length <= 76), isTrue);
      // Body content back
      var start = lines.indexOf('Content-Type: text/plain; charset=UTF-8') + 3;
      var end = lines.indexOf('--b-mixed', start);
      expect(utf8.decode(base64Decode(lines.sublist(start, end).join())), text);
    });
    test('non ascii filename and subject', () {
      var message = _message(filename: 'récap été.pdf');
      message = AwsSesMessage(
        from: message.from,
        to: message.to,
        subject: AwsSesContent(data: 'Résumé ${'é' * 40}'),
        text: message.text,
        attachments: message.attachments,
      );
      var mime = sesRawMailMimeMessage(message, boundary: 'b');
      var encodedName =
          '=?utf-8?B?${base64Encode(utf8.encode('récap été.pdf'))}?=';
      expect(mime, contains('name="$encodedName"'));
      expect(mime, contains('filename="$encodedName"'));
      var subjectLines = mime
          .split('\r\n')
          .skipWhile((line) => !line.startsWith('Subject: '))
          .takeWhile((line) => !line.startsWith('MIME-Version'))
          .toList();
      expect(subjectLines.length, greaterThan(1));
      var words = subjectLines
          .map((line) => line.replaceFirst('Subject: ', '').trim())
          .toList();
      expect(words.every((word) => word.length <= 75), isTrue);
      var decoded = words
          .map(
            (word) =>
                utf8.decode(base64Decode(word.substring(10, word.length - 2))),
          )
          .join();
      expect(decoded, 'Résumé ${'é' * 40}');
    });
  });
}
