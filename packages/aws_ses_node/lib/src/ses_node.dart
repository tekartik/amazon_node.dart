import 'dart:js_util';

import 'aws_node_js.dart';
import 'bindings.dart' as js;

/// Aws credentials.
class AwsCredentials {
  final String accessKeyId;
  final String secretAccessKey;

  AwsCredentials({required this.accessKeyId, required this.secretAccessKey});
}

/// AWS SES.
class AwsSes {
  final js.AwsSdkClientSes awsSdkClientSesJs;

  /// Create new SES client.
  AwsSesClient sesClient(
      {required String region, required AwsCredentials credentials}) {
    return AwsSesClient(
        this,
        awsSdkClientSesJs.sesClient(js.AwsSesClientOptions(
            region: region,
            credentials: js.AwsCredentials(
                accessKeyId: credentials.accessKeyId,
                secretAccessKey: credentials.secretAccessKey))));
  }

  AwsSes(this.awsSdkClientSesJs);
}

class AwsSesException implements Exception {
  final String message;

  AwsSesException(this.message);

  @override
  String toString() => 'AwsSesException($message)';
}

/// Client
class AwsSesClient {
  final AwsSes awsSes;
  final js.AwsSesClient awsSesClientJs;

  AwsSesClient(this.awsSes, this.awsSesClientJs);

  Future<AwsSesSendMailResult> sendMail(AwsSesMessage message) async {
    try {
      var commandJs = awsSes.awsSdkClientSesJs.sendMailCommand(
          js.AwsSesSendMailOptions(
              Destination: js.AwsSesDestination(
                  ToAddresses: message.to,
                  CcAddresses: message.cc,
                  BccAddresses: message.bcc),
              Message: js.AwsSesMessage(
                  Body: js.AwsSesMessageBody(
                      Html: message.html?.toJs(), Text: message.text?.toJs()),
                  Subject: message.subject.toJs()),
              Source: message.from,
              ReplyToAddresses: message.replyTo));
      var resultJs = (await promiseToFuture(awsSesClientJs.send(commandJs)))
          as js.AwsSesSendMailResult;
      return AwsSesSendMailResult(messageId: resultJs.MessageId);
    } catch (e) {
      throw AwsSesException(e.toString());
    }
  }
}

class AwsSesMessage {
  final String from;
  final List<String>? to;
  final List<String>? cc;
  final List<String>? bcc;
  final List<String>? replyTo;
  final AwsSesContent subject;
  final AwsSesContent? text;
  final AwsSesContent? html;

  AwsSesMessage({
    required this.from,
    this.to,
    this.cc,
    this.bcc,
    required this.subject,
    this.text,
    this.html,
    this.replyTo,
  });
}

class AwsSesContent {
  static const String charsetUtf8 = 'UTF-8';
  final String charset;
  final String data;

  AwsSesContent({this.charset = charsetUtf8, required this.data});
}

extension _AwsSesContextExtPrv on AwsSesContent {
  js.AwsSesMessageContent toJs() {
    return js.AwsSesMessageContent(Charset: charset, Data: data);
  }
}

class AwsSesSendMailResult {
  /// Non null means success.
  final String? messageId;

  AwsSesSendMailResult({required this.messageId});

  @override
  String toString() => 'AwsSesSendMailResult($messageId)';
}

/// Global AWS SES instance.
final awsSes = AwsSes(awsClientSesNodeJs);
