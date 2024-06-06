import 'package:js/js_util.dart';

import 'bindings_legacy.dart' as js;
import 'ses_common.dart';
export 'platform_legacy/platform.dart' show awsSes;

/// AWS SES.
class AwsSesNode implements AwsSes {
  final js.AwsSdkClientSes awsSdkClientSesJs;

  /// Create new SES client.
  @override
  AwsSesClient sesClient(
      {required String region, required AwsCredentials credentials}) {
    return AwsSesClientNode(
        this,
        awsSdkClientSesJs.sesClient(js.AwsSesClientOptions(
            region: region,
            credentials: js.AwsCredentials(
                accessKeyId: credentials.accessKeyId,
                secretAccessKey: credentials.secretAccessKey))));
  }

  AwsSesNode(this.awsSdkClientSesJs);
}

/// Client
class AwsSesClientNode implements AwsSesClient {
  final AwsSesNode awsSes;
  final js.AwsSesClient awsSesClientJs;

  AwsSesClientNode(this.awsSes, this.awsSesClientJs);

  @override
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

extension _AwsSesContextExtPrv on AwsSesContent {
  js.AwsSesMessageContent toJs() {
    return js.AwsSesMessageContent(Charset: charset, Data: data);
  }
}
