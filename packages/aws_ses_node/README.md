# tekartik_aws_ses_node

Send email through [Amazon SES](https://aws.amazon.com/ses/) from Dart
compiled to JavaScript (dart2js) and run by Node.js (a function, a node
command line), with the `@aws-sdk/client-ses` npm module: text, HTML, cc,
bcc, reply-to and attachments.

## Getting started

Not on pub.dev, add it as a git dependency, and the npm module next to the
generated JavaScript (`npm install @aws-sdk/client-ses`, `node_modules`
deployed with it):

```yaml
dependencies:
  tekartik_aws_ses_node:
    git:
      url: https://github.com/tekartik/amazon_node.dart
      path: packages/aws_ses_node
```

```dart
import 'package:tekartik_aws_ses_node/aws_ses_node.dart';

/// [accessKeyId] and [secretAccessKey] come from the environment or a secret
/// manager, never from the source.
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
      from: 'sender@example.com', // a verified SES identity of that region
      to: ['recipient@example.com'],
      subject: AwsSesContent(data: 'Hello from SES'),
      text: AwsSesContent(data: 'Plain text body.'),
    ),
  );
  return result.messageId;
}
```

## Platforms

* node (dart2js): `awsSes` is the SES entry point.
* Dart VM and browsers: importing compiles, reading `awsSes` throws an
  `UnsupportedError`. Shared code takes an `AwsSes` or an `AwsSesClient`
  typed from `package:tekartik_aws_ses_node/aws_ses_common.dart`.

## How a message is sent

* Without attachment: the SES `SendEmail` command (to, cc, bcc, reply-to,
  the charset of each part).
* With attachments: a raw MIME message built in Dart (UTF-8, base64 parts),
  sent with `SendRawEmail` to every to, cc and bcc recipient (bcc never in
  a header).
* Any failure (credentials, unverified sender, rejected recipient, network)
  is thrown as an `AwsSesException` holding the SES error message.

## Common pitfalls

* SES rules apply: the sender (or its domain) must be verified in the
  client's region, and in the SES sandbox every recipient too.
* Addresses and attachment mime types must not hold a control character
  (CR/LF): the raw path rejects them (`AwsSesException`) instead of letting
  them inject mail headers. Validate addresses coming from users.
* A display name with non ASCII characters (`Équipe <team@example.com>`)
  must be RFC 2047 encoded by the caller.
* Attachments are held in memory and base64 encoded: mind the SES message
  size limit.

Agent skill: [skills/tekartik-aws-ses-node-setup](skills/tekartik-aws-ses-node-setup/SKILL.md).
