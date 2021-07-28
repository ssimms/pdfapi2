use Test::More tests => 2;

use strict;
use warnings;

use PDF::API2;

# Dash

my $pdf = PDF::API2->new(-compress => 0);
my $egs = $pdf->egstate();
$egs->dash(2, 1);
like($pdf->to_string, qr{<< /Type /ExtGState /D \[ \[ 2 1 \] 0 \] /Name /[\w]+ >>}, 'dash');

# Rendering Intent

$pdf = PDF::API2->new(-compress => 0);
$egs = $pdf->egstate();
$egs->renderingintent('Perceptual');
like($pdf->to_string, qr{<< /Type /ExtGState /Name /[\w]+ /RI /Perceptual >>}, 'renderingintent');
