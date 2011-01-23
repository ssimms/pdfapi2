use Test::More tests => 3;

use warnings;
use strict;

use PDF::API2;

# Named Color

my $pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;
my $gfx = $pdf->page->gfx();

$gfx->fillcolor('blue');
like($pdf->stringify(), qr/0 0 1 rg/, q{fillcolor('blue')});

# RGB

$pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;
$gfx = $pdf->page->gfx();

$gfx->fillcolor('#ff0000');
like($pdf->stringify(), qr/1 0 0 rg/, q{fillcolor('#ff0000')});

# CMY

$pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;
$gfx = $pdf->page->gfx();

$gfx->fillcolor('%fff000000');
like($pdf->stringify, qr/1 0 0 0 k/, q{fillcolor('%fff000000')});
