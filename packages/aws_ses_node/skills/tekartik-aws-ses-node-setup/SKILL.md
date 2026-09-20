---
name: tekartik-aws-ses-node-setup
description: >-
  Use when Dart code compiled to javascript with dart2js and run by nodejs must
  send email through Amazon SES with tekartik_aws_ses_node: the awsSes getter,
  awsSes.sesClient(region:, credentials: AwsCredentials(accessKeyId,
  secretAccessKey)), AwsSesClient.sendMail, AwsSesMessage (from, to, cc, bcc,
  replyTo, subject, text, html, attachments), AwsSesContent (data, charset,
  charsetUtf8), AwsSesAttachment (mimeType, filename, content),
  AwsSesSendMailResult.messageId, AwsSesException, the
  package:tekartik_aws_ses_node/aws_ses_node.dart and aws_ses_common.dart
  imports, and the @aws-sdk/client-ses npm module.
---

# Sending email with SES on nodejs (tekartik_aws_ses_node)

`tekartik_aws_ses_node` wraps the `@aws-sdk/client-ses` npm module in a small
Dart API: one `AwsSes` entry point, a client per region and credentials, and
`sendMail` for text, HTML and attachments. It only runs in javascript
compiled with dart2js and executed by nodejs (a lambda, a Function Compute
function, a node CLI).

## Guidelines

* Dependency (git, not published on pub.dev):
  ```yaml
  dependencies:
    tekartik_aws_ses_node:
      git:
        url: https://github.com/tekartik/amazon_node.dart
        path: packages/aws_ses_node
  dev_dependencies:
    build_runner: '>=2.15.0'
    build_web_compilers: '>=4.4.19'
    tekartik_build_node:
      git:
        url: https://github.com/tekartik/build_node.dart
        path: packages/build_node
  ```
  And the node module: `"@aws-sdk/client-ses"` in `package.json`, then
  `npm install`. `node_modules` must be deployed next to the generated
  `index.js`; the module is `require`d at load time.
* Imports:
  * `package:tekartik_aws_ses_node/aws_ses_node.dart` - everything: the
    `awsSes` getter plus `AwsSes`, `AwsSesClient`, `AwsSesMessage`,
    `AwsSesContent`, `AwsSesAttachment`, `AwsSesSendMailResult`,
    `AwsCredentials` and `AwsSesException`. Use this one on node.
  * `package:tekartik_aws_ses_node/aws_ses_common.dart` - the platform free
    subset only (`AwsSes`, `AwsSesClient`, `AwsSesMessage`, `AwsSesContent`,
    `AwsSesSendMailResult`, `AwsCredentials`), for shared code that receives
    an `AwsSes` rather than reaching for `awsSes`. It does **not** export
    `AwsSesAttachment` nor `AwsSesException`.
  * Importing both in one file is redundant: `aws_ses_node.dart` re-exports
    the common types.
  * `src/aws_ses_node_js.dart` and `src/bindings.dart` are the raw
    `dart:js_interop` bindings, marked `@Deprecated('Internal js API')`.
    Never import them.
* `awsSes` is resolved by conditional import: importing is safe on any
  platform, but reading it off javascript throws
  `UnsupportedError('awsSes only for node')`. Keep the access in node only
  entry points, and pass the resulting `AwsSes` or `AwsSesClient` down to
  shared code typed against `aws_ses_common.dart`.
* Build a client once per region and reuse it:
  `awsSes.sesClient(region: 'eu-west-1', credentials: AwsCredentials(accessKeyId: ..., secretAccessKey: ...))`.
  Read the key and the secret from the function environment or a secret
  manager: never hard code them, never commit them.
* `client.sendMail(AwsSesMessage(...))` returns an `AwsSesSendMailResult`
  whose `messageId` is the SES message id, `null` when SES did not return
  one. Any failure (bad credentials, unverified sender, rejected recipient,
  network) is rethrown as `AwsSesException`, whose only payload is a
  `message` string built from the native error: log it, do not try to branch
  on an error code.
* `AwsSesMessage(from:, subject:, to:, cc:, bcc:, replyTo:, text:, html:,
  attachments:)`. `from` and `subject` are required; everything else is
  optional and nullable. `subject`, `text` and `html` are `AwsSesContent`
  (`AwsSesContent(data: 'text')`, `charset` defaults to
  `AwsSesContent.charsetUtf8`). Give `text`, `html` or both.
* Two very different code paths, depending on `attachments`:
  * No attachment: the SES `SendEmail` command, with `ToAddresses`,
    `CcAddresses`, `BccAddresses`, `ReplyToAddresses` and the per part
    `charset`.
  * One attachment or more: a raw MIME `multipart/mixed` message built in
    Dart and sent with `SendRawEmail`. In that path the SES destinations are
    **only** `message.to`: `cc` and `bcc` are written as headers but are not
    passed as destinations, so they may not be delivered. Put every real
    recipient in `to` when sending attachments, or send a second message.
    The raw path also always encodes in UTF-8, ignoring a custom `charset`.
* `AwsSesAttachment(mimeType: 'application/pdf', filename: 'report.pdf',
  content: Uint8List)`. The bytes are base64 encoded into the MIME body, so
  the whole message is held in memory: keep attachments small and mind the
  SES message size limit.
* SES rules still apply: the `from` address (or its domain) must be verified
  in that region, and in the SES sandbox every recipient must be verified
  too. A region mismatch between the verified identity and `sesClient`'s
  `region` fails as an `AwsSesException`.
* Tests: `dart_test.yaml` declares `platforms: [ node, vm ]`. Type level
  tests run anywhere; anything touching `awsSes` must be `@TestOn('node')`
  and skipped when no credentials are configured. Compile and run with
  `nodePackageRunTest('.')` from
  `package:tekartik_build_node/build_node.dart`, after `npm install`.

## Examples

### Send a plain text email from a node entry point

```dart
import 'package:tekartik_aws_ses_node/aws_ses_node.dart';

/// [accessKeyId] and [secretAccessKey] come from the function environment
/// or a secret manager, never from a literal in the source.
Future<String?> sendHello({
  required String accessKeyId,
  required String secretAccessKey,
}) async {
  var client = awsSes.sesClient(
    region: 'eu-west-1',
    credentials: AwsCredentials(
      accessKeyId: accessKeyId,
      secretAccessKey: secretAccessKey,
    ),
  );
  var result = await client.sendMail(
    AwsSesMessage(
      from: 'sender@example.com', // verified SES identity
      to: ['recipient@example.com'],
      subject: AwsSesContent(data: 'Hello from SES'),
      text: AwsSesContent(data: 'Plain text body.'),
    ),
  );
  return result.messageId;
}
```

### HTML body with an attachment (raw MIME path)

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:tekartik_aws_ses_node/aws_ses_node.dart';

Future<void> sendReport(AwsSesClient client, List<String> recipients) async {
  // With attachments only `to` is used as SES destination: put every
  // recipient there, cc/bcc would only be headers.
  var result = await client.sendMail(
    AwsSesMessage(
      from: 'reports@example.com',
      to: recipients,
      replyTo: ['support@example.com'],
      subject: AwsSesContent(data: 'Monthly report'),
      text: AwsSesContent(data: 'Please find the report attached.'),
      html: AwsSesContent(
        data: '<h1>Report</h1><p>Please find the report attached.</p>',
      ),
      attachments: [
        AwsSesAttachment(
          mimeType: 'text/csv',
          filename: 'report.csv',
          content: Uint8List.fromList(utf8.encode('day,count\n1,42\n')),
        ),
      ],
    ),
  );
  print('sent ${result.messageId}');
}
```

### Shared code typed against the common API

```dart
// No node import here: this file compiles on any platform.
import 'package:tekartik_aws_ses_node/aws_ses_common.dart';

/// A tiny mailer that shared code can hold; the node entry point builds it
/// with `awsSes.sesClient(...)`.
class Mailer {
  final AwsSesClient client;
  final String from;

  Mailer(this.client, {required this.from});

  Future<String?> sendText({
    required List<String> to,
    required String subject,
    required String body,
  }) async {
    var result = await client.sendMail(
      AwsSesMessage(
        from: from,
        to: to,
        subject: AwsSesContent(data: subject),
        text: AwsSesContent(data: body),
      ),
    );
    return result.messageId;
  }
}
```

### Handle failures

```dart
import 'package:tekartik_aws_ses_node/aws_ses_node.dart';

Future<bool> trySend(AwsSesClient client, AwsSesMessage message) async {
  try {
    var result = await client.sendMail(message);
    // messageId is null when SES answered without one.
    return result.messageId != null;
  } on AwsSesException catch (e) {
    // Only a message string: unverified sender, bad credentials, throttling...
    print('SES send failed: ${e.message}');
    return false;
  }
}
```

### Node only test, skipped without credentials

```dart
@TestOn('node')
library;

import 'package:tekartik_aws_ses_node/aws_ses_node.dart';
import 'package:test/test.dart';

/// Set these from the environment in your own runner.
const accessKeyId = String.fromEnvironment('awsAccessKeyId');
const secretAccessKey = String.fromEnvironment('awsSecretAccessKey');

void main() {
  var configured = accessKeyId.isNotEmpty && secretAccessKey.isNotEmpty;
  group('aws_ses_node', () {
    test('sesClient', () {
      var client = awsSes.sesClient(
        region: 'eu-west-1',
        credentials: AwsCredentials(
          accessKeyId: accessKeyId,
          secretAccessKey: secretAccessKey,
        ),
      );
      expect(client, isNotNull);
    });
  }, skip: !configured);
}
```

## Common mistakes

* Reading `awsSes` in code that also runs on the Dart VM or the browser: it
  throws `UnsupportedError`. Pass an `AwsSes`/`AwsSesClient` around instead,
  typed from `aws_ses_common.dart`.
* Relying on `cc` or `bcc` when the message has attachments: only `to` is
  used as SES destination on the raw MIME path.
* Forgetting `npm install @aws-sdk/client-ses`, or deploying without
  `node_modules`.
* Hard coding the access key and secret in the source.
* Sending from an address that is not a verified SES identity in that
  region, or to unverified recipients while the account is in the sandbox.
* Importing `src/bindings.dart` or `src/aws_ses_node_js.dart`: they are
  deprecated internal js interop.
