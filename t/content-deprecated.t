use Test::More;

use warnings;
use strict;

use PDF::API2;

# Transform

my $pdf = PDF::API2->new(compress => 0);
my $gfx = $pdf->page->gfx();

$gfx->transform(-translate => [20, 50],
                -rotate    => 10,
                -scale     => [1.5, 3],
                -skew      => [10, -20]);
$gfx->transform(-translate => [20, 50],
                -rotate    => 10,
                -scale     => [1.5, 3],
                -skew      => [10, -20]);
like($pdf->to_string, qr/1.3854 0.78142 -1.0586 2.8596 20 50 cm 1.3854 0.78142 -1.0586 2.8596 20 50 cm/, q{transform + transform});

# Relative Transform

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->transform(-translate => [20, 50],
                -rotate    => 10,
                -scale     => [1.5, 3],
                -skew      => [10, -20]);
$gfx->transform_rel(-translate => [10, 10],
                    -rotate    => 10,
                    -scale     => [2, 4],
                    -skew      => [5, -10]);
like($pdf->to_string, qr/1.3854 0.78142 -1.0586 2.8596 20 50 cm 1.7193 4.0475 -5.7318 10.684 30 60 cm/, q{transform + transform_rel});

# Fill Color

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->fillcolor('blue');
like($pdf->to_string(), qr/0 0 1 rg/, q{fillcolor('blue')});

# Stroke Color

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->strokecolor('blue');
like($pdf->to_string(), qr/0 0 1 RG/, q{strokecolor('blue')});

# Line Width

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->linewidth(8.125);
like($pdf->to_string, qr/8.125 w/, q{linewidth(8.125)});

# Line Cap Style

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->linecap(1);
like($pdf->to_string, qr/1 J/, q{linecap(1)});

# Line Join Style

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->linejoin(1);
like($pdf->to_string, qr/1 j/, q{linejoin(1)});

# Miter Limit

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->miterlimit(3);
like($pdf->to_string, qr/3 M/, q{miterlimit(3)});

# Miter Limit (deprecated typo)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->meterlimit(3);
like($pdf->to_string, qr/3 M/, q{meterlimit(3)});

# Line Dash

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->linedash(3);
like($pdf->to_string, qr/\[ 3 \] 0 d/, q{linedash(3)});

# Flatness Tolerance

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->flatness(5);
like($pdf->to_string, qr/5 i/, q{flatness(5)});


##
## PATH CONSTRUCTION
##

# Poly-Line (4 args, 1 line segment)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->poly(72, 144, 216, 288);
$gfx->stroke();
like($pdf->to_string, qr/72 144 m 216 288 l S/, q{poly, four arguments});

# Poly-Line (6 args, 2 line segments)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->poly(72, 144, 216, 288, 100, 200);
$gfx->stroke();
like($pdf->to_string, qr/72 144 m 216 288 l 100 200 l S/, q{poly, six arguments});

# Rectangle

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->rect(100, 200, 25, 50);
$gfx->stroke();
$gfx->rect(100, 200, 25, -50);
$gfx->stroke();
$gfx->rect(200, 300, 50, 75, 400, 800, 10, 15);
$gfx->stroke();
like($pdf->to_string, qr/100 200 25 50 re S 100 200 25 -50 re S 200 300 50 75 re 400 800 10 15 re S/, q{rect});

# XY Rectangle

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->rectxy(100, 200, 125, 250);
$gfx->stroke();
$gfx->rectxy(100, 200, 125, 150);
$gfx->stroke();
like($pdf->to_string, qr/100 200 25 50 re S 100 200 25 -50 re S/, q{rectxy});

# Bogen (with move)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->bogen(72, 72, 216, 72, 72, 1);
$gfx->stroke();
like($pdf->to_string, qr/72 72 m 72 81.455 73.862 90.818 77.481 99.553 c 81.099 108.29 86.402 116.23 93.088 122.91 c 99.774 129.6 107.71 134.9 116.45 138.52 c 125.18 142.14 134.54 144 144 144 c 153.46 144 162.82 142.14 171.55 138.52 c 180.29 134.9 188.23 129.6 194.91 122.91 c 201.6 116.23 206.9 108.29 210.52 99.553 c 214.14 90.818 216 81.455 216 72 c S/,
     q{bogen, with move});

# Bogen (without move)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->move(72, 72);
$gfx->bogen(72, 72, 216, 72, 72, 0);
$gfx->stroke();
like($pdf->to_string, qr/72 72 m 72 81.455 73.862 90.818 77.481 99.553 c 81.099 108.29 86.402 116.23 93.088 122.91 c 99.774 129.6 107.71 134.9 116.45 138.52 c 125.18 142.14 134.54 144 144 144 c 153.46 144 162.82 142.14 171.55 138.52 c 180.29 134.9 188.23 129.6 194.91 122.91 c 201.6 116.23 206.9 108.29 210.52 99.553 c 214.14 90.818 216 81.455 216 72 c S/,
     q{bogen, without move});

# Bogen (with move, outer)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->move(72, 72);
$gfx->bogen(72, 72, 144, 144, 72, 0, 1);
$gfx->stroke();
like($pdf->to_string, qr/72 72 m 64.919 72 57.876 73.045 51.1 75.1 c 44.323 77.156 37.887 80.2 31.999 84.134 c 26.111 88.068 20.836 92.85 16.343 98.324 c 11.851 103.8 8.1906 109.9 5.4807 116.45 c 2.7707 122.99 1.0408 129.9 0.3467 136.94 c -0.3474 143.99 0.00195 151.1 1.3835 158.05 c 2.765 164.99 5.1635 171.7 8.5017 177.94 c 11.84 184.19 16.081 189.9 21.088 194.91 c 26.096 199.92 31.814 204.16 38.059 207.5 c 44.305 210.84 51.008 213.24 57.953 214.62 c 64.899 216 72.01 216.35 79.057 215.65 c 86.105 214.96 93.011 213.23 99.553 210.52 c 106.1 207.81 112.2 204.15 117.68 199.66 c 123.15 195.16 127.93 189.89 131.87 184 c 135.8 178.11 138.84 171.68 140.9 164.9 c 142.96 158.12 144 151.08 144 144 c S/,
     q{bogen, without move, with outer});

# Bogen (without move, inner, reverse)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->move(72, 72);
$gfx->bogen(72, 72, 144, 144, 72, 0, 0, 1);
$gfx->stroke();
like($pdf->to_string, qr/72 72 m 81.455 72 90.818 73.862 99.553 77.481 c 108.29 81.099 116.23 86.402 122.91 93.088 c 129.6 99.774 134.9 107.71 138.52 116.45 c 142.14 125.18 144 134.54 144 144 c S/,
     q{bogen, without move, without outer, with reverse});

# End Path

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->move(72, 144);
$gfx->line(216, 288);
$gfx->endpath();
like($pdf->to_string, qr/72 144 m 216 288 l n/,
     q{endpath});

# Horizontal Scale (deprecated)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->hspace(105);
like($pdf->to_string, qr/105 Tz/, q{hspace(105)});

# Fill Path (even-odd rule)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->fill(1);
$gfx->close();
$gfx->stroke();
like($pdf->to_string, qr/f\* h S/, q{fill(1)});

# Fill and Stroke

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->fillstroke();
$gfx->close();
$gfx->stroke();
like($pdf->to_string, qr/B h S/, q{fillstroke()});

# Fill and Stroke (even-odd rule)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->fillstroke(1);
$gfx->close();
$gfx->stroke();
like($pdf->to_string, qr/B\* h S/, q{fillstroke(1)});

# Clipping Path (even-odd rule)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->clip(1);
$gfx->close();
$gfx->stroke();
like($pdf->to_string, qr/W\* h S/, q{clip(1)});

# Character Spacing

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->charspace(2);
like($pdf->to_string, qr/2 Tc/, q{charspace(2)});

# Word Spacing

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->wordspace(2);
like($pdf->to_string, qr/2 Tw/, q{wordspace(2)});

# Text Leading

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->lead(14);
like($pdf->to_string, qr/14 TL/, q{lead(14) (deprecated)});

# distance

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->distance(3, 4);
like($pdf->to_string, qr/3 4 Td/, q{distance(3, 4)});

# cr

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->cr();
$gfx->cr(12.5);
$gfx->cr(0);
like($pdf->to_string, qr/T\* 0 12.5 Td 0 0 Td/, q{cr});

# nl

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->gfx();

$gfx->nl();
like($pdf->to_string, qr/T\*/, q{nl});

done_testing();
