use Test::More tests => 1;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;
my $page1 = $pdf->page();
my $page2 = $pdf->page();

my $outlines = $pdf->outlines();
my $outline = $outlines->outline();
$outline->title('Test Outline');
$outline->dest($page2);

like($pdf->stringify, qr{/Dest \[ 6 0 R /XYZ null null null \] /Title \(Test Outline\) /Parent 7 0 R},
     q{Basic outline test});
