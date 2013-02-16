use Test::More tests => 4;

use warnings;
use strict;

use PDF::API2::Basic::PDF::Filter::RunLengthDecode;

my $in = '--- Look at this test string. ---';
my $out = "\xfe-\x01 L\xffo\x16k at this test string. \xfe-";
my $filter = bless {}, 'PDF::API2::Basic::PDF::Filter::RunLengthDecode';

is($filter->outfilt($in),
   $out,
   q{RunLengthDecode test string is encoded correctly});

is($filter->infilt($out),
   $in,
   q{RunLengthDecode test string is decoded correctly});


# Add the end-of-document marker
$out .= "\x80";

is($filter->outfilt($in, 1),
   $out,
   q{RunLengthDecode test string with EOD marker is encoded correctly});

is($filter->infilt($out),
   $in,
   q{RunLengthDecode test string with EOD marker is decoded correctly});
