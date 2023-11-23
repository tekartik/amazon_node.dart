@JS()
library;
// ignore_for_file: non_constant_identifier_names

import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS()
@anonymous
@staticInterop
abstract class AwsSdkClientSes {}

@JS()
@anonymous
@staticInterop
class AwsCredentials {
  // Must have an unnamed factory constructor with named arguments.
  external factory AwsCredentials({String accessKeyId, String secretAccessKey});
}

@JS()
@anonymous
@staticInterop
class AwsSesClientOptions {
  // Must have an unnamed factory constructor with named arguments.
  external factory AwsSesClientOptions(
      {String region, AwsCredentials credentials});
}

extension AwsSesClientOptionsExt on AwsSesClientOptions {
  external String get region;
}

@JS()
@anonymous
@staticInterop
abstract class AwsSesClient {}

extension AwsSesClientExt on AwsSesClient {
  external Object send(AwsSesSendMailCommand command);
}

@JS()
@anonymous
@staticInterop
class AwsSesSendMailResult {}

extension AwsSesSendMailResultExt on AwsSesSendMailResult {
  external String get MessageId;
}

@JS()
@anonymous
@staticInterop
abstract class AwsSesSendMailCommand {}

extension AwsSdkClientSesExt on AwsSdkClientSes {
  external Object get SESClient;
  external Object get SendEmailCommand;

  AwsSesClient sesClient(AwsSesClientOptions options) {
    return callConstructor(SESClient, [options]);
  }

  AwsSesSendMailCommand sendMailCommand(AwsSesSendMailOptions options) {
    return callConstructor(SendEmailCommand, [options]);
  }
}

@JS()
@anonymous
@staticInterop
class AwsSesDestination {
  // Must have an unnamed factory constructor with named arguments.
  external factory AwsSesDestination(
      {List<String>? ToAddresses,
      List<String>? CcAddresses,
      List<String>? BccAddresses});
}

@JS()
@anonymous
@staticInterop
class AwsSesMessage {
  // Must have an unnamed factory constructor with named arguments.
  external factory AwsSesMessage(
      {AwsSesMessageBody Body, AwsSesMessageContent Subject});
}

@JS()
@anonymous
@staticInterop
class AwsSesMessageBody {
  // Must have an unnamed factory constructor with named arguments.
  external factory AwsSesMessageBody(
      {AwsSesMessageContent? Html, AwsSesMessageContent? Text});
}

@JS()
@anonymous
@staticInterop
class AwsSesMessageContent {
  // Must have an unnamed factory constructor with named arguments.
  external factory AwsSesMessageContent({String Charset, String Data});
}

@JS()
@anonymous
@staticInterop
class AwsSesSendMailOptions {
  // Must have an unnamed factory constructor with named arguments.
  external factory AwsSesSendMailOptions(
      {AwsSesDestination Destination,
      AwsSesMessage Message,
      String Source,
      List<String>? ReplyToAddresses});
}

//  Destination: {
//       /* required */
//       CcAddresses: [
//         /* more items */
//       ],
//       ToAddresses: [
//         toAddress,
//         /* more To-email addresses */
//       ],
//     },
//     Message: {
//       /* required */
//       Body: {
//         /* required */
//         Html: {
//           Charset: "UTF-8",
//           Data: "HTML_FORMAT_BODY",
//         },
//         Text: {
//           Charset: "UTF-8",
//           Data: "TEXT_FORMAT_BODY",
//         },
//       },
//       Subject: {
//         Charset: "UTF-8",
//         Data: "EMAIL_SUBJECT",
//       },
//     },
//     Source: fromAddress,
//     ReplyToAddresses: [
//       /* more items */
//     ],
