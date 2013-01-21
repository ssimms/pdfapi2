use Test::More tests => 17;

use strict;
use warnings;

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
