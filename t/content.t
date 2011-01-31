use Test::More tests => 4;

use warnings;
use strict;

use PDF::API2;

# Translate

my $pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;
my $gfx = $pdf->page->gfx();

$gfx->translate(72, 144);
like($pdf->stringify(), qr/1 0 0 1 72 144 cm/, q{translate(72, 144)});

# Named Color

$pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;
$gfx = $pdf->page->gfx();

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
