import 'dart:convert';

import 'ses_common.dart';

const _crlf = '\r\n';

/// Max base64 line length (RFC 2045).
const _base64LineLength = 76;

/// Max input bytes per RFC 2047 encoded word (base64 of 45 bytes is 60 chars,
/// the encoded word stays under 75 chars).
const _encodedWordMaxBytes = 45;

/// Envelope destinations of a raw mail: every to, cc and bcc recipient (bcc
/// recipients only appear here, never in a header).
List<String> sesRawMailDestinations(AwsSesMessage message) => [
  ...?message.to,
  ...?message.cc,
  ...?message.bcc,
];

/// Raw MIME message (CRLF line endings) of [message] with its attachments.
///
/// [boundary] is the multipart boundary prefix, it must not appear in the
/// content (base64 content never contains `=_`).
String sesRawMailMimeMessage(
  AwsSesMessage message, {
  required String boundary,
}) {
  var mixedBoundary = '$boundary-mixed';
  var alternativeBoundary = '$boundary-alt';
  var sb = StringBuffer();
  void writeLine([String line = '']) {
    sb.write(line);
    sb.write(_crlf);
  }

  writeLine('From: ${message.from}');
  if (message.to?.isNotEmpty ?? false) {
    writeLine('To: ${message.to!.join(', ')}');
  }
  if (message.cc?.isNotEmpty ?? false) {
    writeLine('Cc: ${message.cc!.join(', ')}');
  }
  if (message.replyTo?.isNotEmpty ?? false) {
    writeLine('Reply-To: ${message.replyTo!.join(', ')}');
  }
  writeLine('Subject: ${_encodedWords(message.subject.data).join('$_crlf ')}');
  writeLine('MIME-Version: 1.0');
  writeLine('Content-Type: multipart/mixed; boundary="$mixedBoundary"');
  writeLine();

  void writeBase64(List<int> bytes) {
    var base64Text = base64Encode(bytes);
    for (var i = 0; i < base64Text.length; i += _base64LineLength) {
      var end = i + _base64LineLength;
      if (end > base64Text.length) {
        end = base64Text.length;
      }
      writeLine(base64Text.substring(i, end));
    }
  }

  void writeBodyPart(String subtype, String data) {
    writeLine('Content-Type: text/$subtype; charset=UTF-8');
    writeLine('Content-Transfer-Encoding: base64');
    writeLine();
    writeBase64(utf8.encode(data));
  }

  // Bodies, alternatives of each other when there are both
  var text = message.text;
  var html = message.html;
  if (text != null && html != null) {
    writeLine('--$mixedBoundary');
    writeLine(
      'Content-Type: multipart/alternative; boundary="$alternativeBoundary"',
    );
    writeLine();
    writeLine('--$alternativeBoundary');
    writeBodyPart('plain', text.data);
    writeLine('--$alternativeBoundary');
    writeBodyPart('html', html.data);
    writeLine('--$alternativeBoundary--');
  } else if (text != null) {
    writeLine('--$mixedBoundary');
    writeBodyPart('plain', text.data);
  } else if (html != null) {
    writeLine('--$mixedBoundary');
    writeBodyPart('html', html.data);
  }

  // Attachments
  for (var attachment in message.attachments ?? const <AwsSesAttachment>[]) {
    var filename = _parameterValue(attachment.filename);
    writeLine('--$mixedBoundary');
    writeLine('Content-Type: ${attachment.mimeType}; name=$filename');
    writeLine('Content-Disposition: attachment; filename=$filename');
    writeLine('Content-Transfer-Encoding: base64');
    writeLine();
    writeBase64(attachment.content);
  }
  writeLine('--$mixedBoundary--');
  return sb.toString();
}

bool _isPrintableAscii(String text) =>
    text.codeUnits.every((unit) => unit >= 0x20 && unit < 0x7f);

/// RFC 2047 encoded words of [text] (as is when it is printable ascii).
List<String> _encodedWords(String text) {
  if (_isPrintableAscii(text)) {
    return [text];
  }
  var words = <String>[];
  var bytes = <int>[];
  void flush() {
    if (bytes.isNotEmpty) {
      words.add('=?utf-8?B?${base64Encode(bytes)}?=');
      bytes = <int>[];
    }
  }

  // Never split a character between two words
  for (var rune in text.runes) {
    var runeBytes = utf8.encode(String.fromCharCode(rune));
    if (bytes.length + runeBytes.length > _encodedWordMaxBytes) {
      flush();
    }
    bytes.addAll(runeBytes);
  }
  flush();
  return words;
}

/// Quoted header parameter value, RFC 2047 encoded when not ascii.
String _parameterValue(String value) {
  if (_isPrintableAscii(value)) {
    return '"${value.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';
  }
  return '"${_encodedWords(value).join(' ')}"';
}
