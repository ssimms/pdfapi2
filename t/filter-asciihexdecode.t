use Test::More tests => 7;

use warnings;
use strict;

use PDF::API2::Basic::PDF::Filter::ASCIIHexDecode;

my $in = 'This is a test string.';
my $out = '546869732069732061207465737420737472696e672e';

is(PDF::API2::Basic::PDF::Filter::ASCIIHexDecode->outfilt($in),
   $out,
   q{ASCIIHexDecode test string is encoded correctly});

is(PDF::API2::Basic::PDF::Filter::ASCIIHexDecode->infilt($out),
   $in,
   q{ASCIIHexDecode test string is decoded correctly});


# Add the end-of-document marker
$out .= '>';

is(PDF::API2::Basic::PDF::Filter::ASCIIHexDecode->outfilt($in, 1),
   $out,
   q{ASCIIHexDecode test string with EOD marker is encoded correctly});

is(PDF::API2::Basic::PDF::Filter::ASCIIHexDecode->infilt($out),
   $in,
   q{ASCIIHexDecode test string with EOD marker is decoded correctly});


# Ensure the filter is case-insensitive
$out = uc($out);
is(PDF::API2::Basic::PDF::Filter::ASCIIHexDecode->infilt($out),
   $in,
   q{ASCIIHexDecode is case-insensitive});


# Check for death if invalid characters are included
{
    local $@;
    eval { PDF::API2::Basic::PDF::Filter::ASCIIHexDecode->infilt('This is not valid input') };
    ok($@, q{ASCIIHexDecode dies if invalid characters are passed to infilt});
}

# PDF 1.7, section 7.4.2:
# "If the filter encounters the EOD marker after reading an odd number
# of hexadecimal digits, it shall behave as if a 0 (zero) followed the
# last digit"
my $odd_out = 'FF00F>';
my $expected_bytes = '255 0 240';
my $actual_bytes = join(' ', map { ord } split //, PDF::API2::Basic::PDF::Filter::ASCIIHexDecode->infilt($odd_out));
is($actual_bytes,
   $expected_bytes,
   q{ASCIIHexDecode handles odd numbers of characters correctly});
