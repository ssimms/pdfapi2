use Test::More;

use strict;
use warnings;

use PDF::API2;

my $pdf = PDF::API2->new(compress => 0);
$pdf->{'pdf'}->header_version('1.3');
$pdf->{'pdf'}->trailer_version('1.5');

is($pdf->version(), '1.5',
   q{version() returns whichever version is largest (1/2)});

$pdf->{'pdf'}->header_version('1.6');

is($pdf->version(), '1.6',
   q{version() returns whichever version is largest (2/2)});

$pdf->version('1.7');

is($pdf->version(), '1.7',
   q{version() is settable});

is($pdf->{'pdf'}->header_version(), '1.7',
   q{version() sets header version});

is($pdf->{'pdf'}->trailer_version(), '1.7',
   q{version() sets trailer version});

my $string = $pdf->to_string();

like($string, qr/%PDF-1.7/,
     q{Expected header version is present});

like($string, qr{/Version /1.7},
     q{Expected trailer version is present});

$pdf = PDF::API2->new(compress => 0);
$pdf->{'pdf'}->header_version('1.3');
$pdf->{'pdf'}->trailer_version('1.4');

my $version = $pdf->{'pdf'}->require_version('1.3');

is($version, '1.4',
   q{require_version returns current version});

$pdf->{'pdf'}->require_version('1.4');

is($pdf->{'pdf'}->header_version(), '1.3',
   q{require_version doesn't increase header version if trailer is sufficient});

$version = $pdf->{'pdf'}->require_version('1.5');

is($pdf->version(), '1.5',
   q{require_version increases version when needed});

is($version, '1.4',
   q{require_version returns the previous version number});

done_testing();
