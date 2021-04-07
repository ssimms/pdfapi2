use Test::More tests => 42;

use strict;
use warnings;
use utf8;

use PDF::API2::Basic::PDF::String;

my $string;

$string = PDF::API2::Basic::PDF::String->from_pdf('(Test)');
is($string->val(),
   'Test',
   q{Basic literal string test});

is($string->as_pdf(),
   '(Test)',
   q{Basic literal string output});

$string = PDF::API2::Basic::PDF::String->from_pdf('<54657374>');
is(length($string->val()),
   4,
   q{Basic hexadecimal string length test});

is($string->val(),
   'Test',
   q{Basic hexadecimal string test});

is($string->as_pdf(),
   '<54657374>',
   q{Basic hexadecimal string output});

# PDF Spec 1.7 Section 7.3.4.2 Examples

$string = PDF::API2::Basic::PDF::String->from_pdf("(Strings may contain newlines\nand such)");
is($string->val(),
   "Strings may contain newlines\nand such",
   q{PDF 1.7 section 7.3.4.2 Example 1 (1/3)});

my $input = q|Strings may contain balanced parentheses ( ) and
special characters (*!&}^% and so on).|;
$string = PDF::API2::Basic::PDF::String->from_pdf('(' . $input . ')');
is($string->val(),
   $input,
   q{PDF 1.7 section 7.3.4.2 Example 1 (2/3)});

$string = PDF::API2::Basic::PDF::String->from_pdf('()');
is($string->val(),
   '',
   q{PDF 1.7 section 7.3.4.2 Example 1 (3/3)});

$input = q|These \
two strings \
are the same.|;

$string = PDF::API2::Basic::PDF::String->from_pdf($input);
is($string->val(),
   'These two strings are the same.',
   q{PDF 1.7 section 7.3.4.2 Example 2 (end-of-line backslash)});

$string = PDF::API2::Basic::PDF::String->from_pdf("(Test line\015)");
is($string->val(),
   "Test line\012",
   q{PDF 1.7 section 7.3.4.2 Example 3 (end-of-line character conversion) 1/3});

$string = PDF::API2::Basic::PDF::String->from_pdf("(Test line\015\012)");
is($string->val(),
   "Test line\012",
   q{PDF 1.7 section 7.3.4.2 Example 3 (end-of-line character conversion) 2/3});

$string = PDF::API2::Basic::PDF::String->from_pdf("(Test line\012)");
is($string->val(),
   "Test line\012",
   q{PDF 1.7 section 7.3.4.2 Example 3 (end-of-line character conversion) 3/3});


# PDF Spec 1.7 Section 7.3.4.3 Hexadecimal Strings

$string = PDF::API2::Basic::PDF::String->from_pdf('<5 550>');
is($string->val(),
   'UP',
   q{PDF 1.7 section 7.3.4.3 Example 1 (whitespace is ignored)});

$string = PDF::API2::Basic::PDF::String->from_pdf('<555>');
is($string->val(),
   'UP',
   q{PDF 1.7 section 7.3.4.3 Example 2 (odd number of hex digits)});


# Escape Characters

$string = PDF::API2::Basic::PDF::String->from_pdf('(\n)');
is($string->val(),
   "\x0A",
   q{Escape Character: \n});
is($string->as_pdf(),
   '(\n)',
   q{Escape Character: \n (output)});

$string = PDF::API2::Basic::PDF::String->from_pdf('(\r)');
is($string->val(),
   "\x0D",
   q{Escape Character: \r});
is($string->as_pdf(),
   '(\r)',
   q{Escape Character: \r (output)});

$string = PDF::API2::Basic::PDF::String->from_pdf('(\t)');
is($string->val(),
   "\x09",
   q{Escape Character: \t});
is($string->as_pdf(),
   '(\t)',
   q{Escape Character: \t (output)});

$string = PDF::API2::Basic::PDF::String->from_pdf('(\b)');
is($string->val(),
   "\x08",
   q{Escape Character: \b});
is($string->as_pdf(),
   '(\b)',
   q{Escape Character: \b (output)});

$string = PDF::API2::Basic::PDF::String->from_pdf('(\f)');
is($string->val(),
   "\x0C",
   q{Escape Character: \f});
is($string->as_pdf(),
   '(\f)',
   q{Escape Character: \f (output)});

$string = PDF::API2::Basic::PDF::String->from_pdf('(\()');
is($string->val(),
   '(',
   q{Escape Character: \(});
is($string->as_pdf(),
   '(\()',
   q{Escape Character: \( (output)});

$string = PDF::API2::Basic::PDF::String->from_pdf('(\))');
is($string->val(),
   ')',
   q{Escape Character: \)});
is($string->as_pdf(),
   '(\))',
   q{Escape Character: \) (output)});

$string = PDF::API2::Basic::PDF::String->from_pdf('(\\)');
is($string->val(),
   "\\",
   q{Escape Character: \\});
is($string->as_pdf(),
   "(\\\\)",
   q{Escape Character: \\ (output)});

$string = PDF::API2::Basic::PDF::String->from_pdf("(a\\\x0Ab)");
is($string->val(),
   'ab',
   q{Backslash followed by an EOL marker (LF) is ignored});

$string = PDF::API2::Basic::PDF::String->from_pdf("(a\\\x0Db)");
is($string->val(),
   'ab',
   q{Backslash followed by an EOL marker (CR) is ignored});

$string = PDF::API2::Basic::PDF::String->from_pdf("(a\\\x0D\x0Ab)");
is($string->val(),
   'ab',
   q{Backslash followed by an EOL marker (CRLF) is ignored});

$string = PDF::API2::Basic::PDF::String->from_pdf("(\\0053)");
is($string->val(),
   "\x05" . '3',
   q{Escape Character: 3-digit octal followed by a digit is interpreted as two characters});

$string = PDF::API2::Basic::PDF::String->from_pdf("(\\053)");
is($string->val(),
   '+',
   q{Escape Character: 3-digit octal});

$string = PDF::API2::Basic::PDF::String->from_pdf("(\\53)");
is($string->val(),
   '+',
   q{Escape Character: 2-digit octal});

$string = PDF::API2::Basic::PDF::String->from_pdf("(\\5)");
is($string->val(),
   "\x05",
   q{Escape Character: 1-digit octal});


use PDF::API2::Basic::PDF::Utils;
$string = PDFStr('ΠΔΦ');
is($string->as_pdf(),
   '<FEFF03A0039403A6>',
   q{A string with the utf8 flag set is automatically encoded as UCS-16BE});


# RT 63918
$string = PDF::API2::Basic::PDF::String->from_pdf('(3\000f' . "\x5c\x5c" . '3\000f)');
is($string->val(),
   "3\x00f\\3\x00f",
   q{[RT #63918] Incorrect handling of literal backslashes 1/2 (input)});
is($string->as_pdf(),
   '<3300665C330066>',
   q{[RT #63918] Incorrect handling of literal backslashes 1/2 (output)});

$string = PDF::API2::Basic::PDF::String->from_pdf('(\000\000\000' . "\x5c\x5c" . '\000\000\000\000)');
is($string->as_pdf(),
   '<0000005C00000000>',
   q{[RT #63918] Incorrect handling of literal backslashes 2/2});


# RT 134957
$string = PDFStr("\x00\n\x00");
is($string->as_pdf(),
   '<000A00>',
   q{\n in a string containing non-printable characters is hex-encoded});
