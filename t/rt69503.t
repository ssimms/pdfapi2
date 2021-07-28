use Test::More tests => 2;

use strict;
use warnings;

use PDF::API2;

# -firstpage as page number (original bug report)

my $pdf = PDF::API2->new();
my $page1 = $pdf->page();
my $page2 = $pdf->page();

$pdf->preferences(-firstpage => [2, -fit => 1]);

my $output = $pdf->to_string();

like($output,
     qr/OpenAction \[ 2 \/Fit \]/,
     q{-firstpage accepts a page number});

# -firstpage as page object (regression)

$pdf = PDF::API2->new();
$page1 = $pdf->page();
$page2 = $pdf->page();

$pdf->preferences(-firstpage => [$page2, -fit => 1]);

$output = $pdf->to_string();

like($output,
     qr/OpenAction \[ \d+ 0 R \/Fit \]/,
     q{-firstpage accepts a page object});
