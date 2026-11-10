/// Send email with Amazon SES on node (dart2js): `awsSes`, plus every SES
/// type (attachments, `AwsSesException`). Safe to import elsewhere, where
/// reading `awsSes` throws an `UnsupportedError`.
library;

export 'src/platform/platform.dart' show awsSes;
export 'src/ses_common.dart';
