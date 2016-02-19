use Test::More tests => 4;

use warnings;
use strict;

use PDF::API2::Basic::PDF::Filter::ASCII85Decode;

my $filter = PDF::API2::Basic::PDF::Filter::ASCII85Decode->new();

my $in = 'BT /F1 24 Tf 100 700 Td (Hello World)Tj ET';
my $out = q{6<#'\7PQ#@1a#b0+>GQ(+?(u.+B2ko-qIocCi:FtDfTZ).9(%)78s~>};

is($filter->outfilt($in, 1),
   $out,
   q{ASCII85Decode test string is encoded correctly});

is($filter->infilt($out, 1),
   $in,
   q{ASCII85Decode test string is decoded correctly});

$in = 'BT /F1 24 Tf 100 700 Td (Hello Worlds!)Tj ET';
$out = q{6<#'\7PQ#@1a#b0+>GQ(+?(u.+B2ko-qIocCi:FtDfTZ)F!2u3C*5rE~>};

is($in,
   $filter->infilt($filter->outfilt($in, 1), 1),
   q{ASCII85Decode test string encodes and decodes without changing the string (multiple of four bytes)});

is($filter->outfilt($in, 1),
   $out,
   q{ASCII85Decode test string is encoded correctly (multiple of four bytes)});
