/// The platform free SES types (`AwsSes`, `AwsSesClient`, `AwsSesMessage`,
/// `AwsSesContent`, `AwsSesSendMailResult`, `AwsCredentials`), for shared
/// code receiving an `AwsSes` or an `AwsSesClient`.
library;

export 'src/ses_common.dart'
    show
        AwsSesClient,
        AwsSesSendMailResult,
        AwsSesContent,
        AwsSesMessage,
        AwsSes,
        AwsCredentials;
