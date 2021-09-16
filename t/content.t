use Test::More;

use warnings;
use strict;

use PDF::API2;

# Translate

my $pdf = PDF::API2->new(compress => 0);
my $gfx = $pdf->page->graphics();

$gfx->translate(72, 144);
like($pdf->to_string(), qr/1 0 0 1 72 144 cm/, q{translate(72, 144)});

# Rotate

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->rotate(65);
like($pdf->to_string, qr/0.42262 0.90631 -0.90631 0.42262 0 0 cm/, q{rotate(65)});

# Scale

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->scale(1.1, 2.5);
like($pdf->to_string, qr/1.1 0 0 2.5 0 0 cm/, q{scale(1.1, 2.5)});

# Skew

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->skew(15, 25);
like($pdf->to_string, qr/1 0.26795 0.46631 1 0 0 cm/, q{skew(15, 25)});

# Transform

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->transform(translate => [20, 50],
                rotate    => 10,
                scale     => [1.5, 3],
                skew      => [10, -20]);
$gfx->transform(translate => [20, 50],
                rotate    => 10,
                scale     => [1.5, 3],
                skew      => [10, -20]);
like($pdf->to_string, qr/1.3854 0.78142 -1.0586 2.8596 20 50 cm 1.3854 0.78142 -1.0586 2.8596 20 50 cm/, q{transform + transform});

# Relative Transform

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->transform(translate => [20, 50],
                rotate    => 10,
                scale     => [1.5, 3],
                skew      => [10, -20]);
$gfx->transform(translate => [10, 10],
                rotate    => 10,
                scale     => [2, 4],
                skew      => [5, -10],
                relative  => 1);
like($pdf->to_string, qr/1.3854 0.78142 -1.0586 2.8596 20 50 cm 1.7193 4.0475 -5.7318 10.684 30 60 cm/, q{transform + transform(relative)});

# Matrix

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->matrix(1.3854, 0.78142, -1.0586, 2.8596, 20, 50);
like($pdf->to_string, qr/1.3854 0.78142 -1.0586 2.8596 20 50 cm/, q{matrix});

# Save

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->save();
like($pdf->to_string, qr/q/, q{save});

# Restore

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->restore();
like($pdf->to_string, qr/Q/, q{restore});

# Named Fill Color

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->fill_color('blue');
like($pdf->to_string(), qr/0 0 1 rg/, q{fill_color('blue')});

# RGB Fill Color

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->fill_color('#ff0000');
like($pdf->to_string(), qr/1 0 0 rg/, q{fill_color('#ff0000')});

# CMYK Fill Color

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->fillcolor('%ff000000');
like($pdf->to_string, qr/1 0 0 0 k/, q{fill_color('%ff000000')});

# Named Stroke Color

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->stroke_color('blue');
like($pdf->to_string(), qr/0 0 1 RG/, q{stroke_color('blue')});

# RGB Stroke Color

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->stroke_color('#ff0000');
like($pdf->to_string(), qr/1 0 0 RG/, q{stroke_color('#ff0000')});

# CMYK Stroke Color

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->stroke_color('%ff000000');
like($pdf->to_string, qr/1 0 0 0 K/, q{stroke_color('%ff000000')});

# Line Width

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->line_width(8.125);
like($pdf->to_string, qr/8.125 w/, q{line_width(8.125)});

# Line Cap Style

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->line_cap('round');
like($pdf->to_string, qr/1 J/, q{line_cap('round')});

# Line Join Style

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->line_join('bevel');
like($pdf->to_string, qr/2 j/, q{line_join('bevel')});

# Miter Limit

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->miter_limit(3);
like($pdf->to_string, qr/3 M/, q{miter_limit(3)});

# Line Dash (no args)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->line_dash_pattern();
like($pdf->to_string, qr/\[ \] 0 d/, q{line_dash_pattern()});

# Line Dash (1 arg)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->line_dash_pattern(3);
like($pdf->to_string, qr/\[ 3 \] 0 d/, q{line_dash_pattern(3)});

# Line Dash (2 args)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->line_dash_pattern(2, 1);
like($pdf->to_string, qr/\[ 2 1 \] 0 d/, q{line_dash_pattern(2, 1)});

# Flatness Tolerance

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->flatness_tolerance(5);
like($pdf->to_string, qr/5 i/, q{flatness_tolerance(5)});


##
## PATH CONSTRUCTION
##

# Horizontal Line

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->move(72, 144);
$gfx->hline(288);
$gfx->stroke();
like($pdf->to_string, qr/72 144 m 288 144 l S/, q{hline});

# Vertical Line

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->move(72, 144);
$gfx->vline(288);
$gfx->stroke();
like($pdf->to_string, qr/72 144 m 72 288 l S/, q{vline});

# Poly-Line (1 line segment)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->move(72, 144);
$gfx->polyline(216, 288);
$gfx->stroke();
like($pdf->to_string, qr/72 144 m 216 288 l S/, q{polyline, two arguments});

# Poly-Line (2 line segments)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->move(72, 144);
$gfx->polyline(216, 288, 100, 200);
$gfx->stroke();
like($pdf->to_string, qr/72 144 m 216 288 l 100 200 l S/,
     q{polyline, four arguments});

# Rectangle

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->rectangle(100, 200, 125, 250);
$gfx->stroke();
$gfx->rectangle(125, 200, 100, 250);
$gfx->stroke();
like($pdf->to_string, qr/100 200 25 50 re S 100 200 25 50 re S/, q{rectangle});

# Curve

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->move(72, 144);
$gfx->curve(100, 200, 125, 250, 144, 288);
$gfx->stroke();
like($pdf->to_string, qr/72 144 m 100 200 125 250 144 288 c S/, q{curve});

# Spline

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->move(30, 60);
$gfx->spline(90, 120, 150, 180);
$gfx->stroke();
like($pdf->to_string, qr/30 60 m 70 100 110 140 150 180 c S/, q{spline});

# Arc (with move)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->move(72, 144);
$gfx->arc(216, 288, 144, 72, 90, 180, 1);
$gfx->stroke();
like($pdf->to_string, qr/72 144 m 216 360 m 197.09 360 178.36 358.14 160.89 354.52 c 143.42 350.9 127.55 345.6 114.18 338.91 c 100.8 332.23 90.198 324.29 82.961 315.55 c 75.725 306.82 72 297.46 72 288 c S/,
     q{arc, with move});

# Arc (without move)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->move(72, 144);
$gfx->arc(216, 288, 144, 72, 90, 180, 0);
$gfx->stroke();
like($pdf->to_string, qr/72 144 m 197.09 360 178.36 358.14 160.89 354.52 c 143.42 350.9 127.55 345.6 114.18 338.91 c 100.8 332.23 90.198 324.29 82.961 315.55 c 75.725 306.82 72 297.46 72 288 c S/,
     q{arc, without move});

# Close Path

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->move(72, 144);
$gfx->line(216, 288);
$gfx->line(360, 432);
$gfx->close();
$gfx->stroke();
like($pdf->to_string, qr/72 144 m 216 288 l 360 432 l h S/,
     q{close});

# End Path

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->move(72, 144);
$gfx->line(216, 288);
$gfx->end();
like($pdf->to_string, qr/72 144 m 216 288 l n/,
     q{end});

# Ellipse

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->ellipse(144, 216, 108, 36);
$gfx->stroke();

like($pdf->to_string, qr/252 216 m 252 220.73 249.21 225.41 243.78 229.78 c 238.35 234.14 230.4 238.11 220.37 241.46 c 210.34 244.8 198.43 247.45 185.33 249.26 c 172.23 251.07 158.18 252 144 252 c 129.82 252 115.77 251.07 102.67 249.26 c 89.567 247.45 77.661 244.8 67.632 241.46 c 57.604 238.11 49.649 234.14 44.221 229.78 c 38.794 225.41 36 220.73 36 216 c 36 211.27 38.794 206.59 44.221 202.22 c 49.649 197.86 57.604 193.89 67.632 190.54 c 77.661 187.2 89.567 184.55 102.67 182.74 c 115.77 180.93 129.82 180 144 180 c 158.18 180 172.23 180.93 185.33 182.74 c 198.43 184.55 210.34 187.2 220.37 190.54 c 230.4 193.89 238.35 197.86 243.78 202.22 c 249.21 206.59 252 211.27 252 216 c h S/,
     q{ellipse});

# Circle

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->circle(144, 216, 72);
$gfx->stroke();
like($pdf->to_string, qr/216 216 m 216 225.46 214.14 234.82 210.52 243.55 c 206.9 252.29 201.6 260.23 194.91 266.91 c 188.23 273.6 180.29 278.9 171.55 282.52 c 162.82 286.14 153.46 288 144 288 c 134.54 288 125.18 286.14 116.45 282.52 c 107.71 278.9 99.774 273.6 93.088 266.91 c 86.402 260.23 81.099 252.29 77.481 243.55 c 73.862 234.82 72 225.46 72 216 c 72 206.54 73.862 197.18 77.481 188.45 c 81.099 179.71 86.402 171.77 93.088 165.09 c 99.774 158.4 107.71 153.1 116.45 149.48 c 125.18 145.86 134.54 144 144 144 c 153.46 144 162.82 145.86 171.55 149.48 c 180.29 153.1 188.23 158.4 194.91 165.09 c 201.6 171.77 206.9 179.71 210.52 188.45 c 214.14 197.18 216 206.54 216 216 c h S/,
     q{circle});

# Horizontal Scale

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->hscale(105);
like($pdf->to_string, qr/105 Tz/, q{hscale(105)});

# Fill Path

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->fill();
$gfx->close();
$gfx->stroke();
like($pdf->to_string, qr/f h S/, q{fill()});

# Fill Path (even-odd rule)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->fill(rule => 'even-odd');
$gfx->close();
$gfx->stroke();
like($pdf->to_string, qr/f\* h S/, q{fill(1)});

# Fill and Stroke

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->paint();
$gfx->close();
$gfx->stroke();
like($pdf->to_string, qr/B h S/, q{fillstroke()});

# Fill and Stroke (even-odd rule)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->paint(rule => 'even-odd');
$gfx->close();
$gfx->stroke();
like($pdf->to_string, qr/B\* h S/, q{fillstroke(1)});

# Clipping Path

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->clip();
$gfx->close();
$gfx->stroke();
like($pdf->to_string, qr/W h S/, q{clip()});

# Clipping Path (even-odd rule)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->clip(rule => 'even-odd');
$gfx->close();
$gfx->stroke();
like($pdf->to_string, qr/W\* h S/, q{clip(1)});

# Character Spacing

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->character_spacing(2);
like($pdf->to_string, qr/2 Tc/, q{character_spacing(2)});

# Word Spacing

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->word_spacing(2);
like($pdf->to_string, qr/2 Tw/, q{word_spacing(2)});

# Text Leading

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->leading(14);
like($pdf->to_string, qr/14 TL/, q{leading(14)});

# Text Rendering Mode

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->render(4);
like($pdf->to_string, qr/4 Tr/, q{render(4)});

# Text Rise

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->rise(4);
like($pdf->to_string, qr/4 Ts/, q{rise(4)});

# Position

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->position(3, 4);
like($pdf->to_string, qr/3 4 Td/, q{position(3, 4)});

# crlf (neither leading nor font size)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->crlf();
like($pdf->to_string, qr/T\*/, q{crlf});

# crlf (with font size)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();
$gfx->font($pdf->font('Helvetica'), 10);

$gfx->crlf();
like($pdf->to_string, qr/0 -12 Td/, q{crlf with font size});

# crlf (with leading)

$pdf = PDF::API2->new(compress => 0);
$gfx = $pdf->page->graphics();

$gfx->leading(12);
$gfx->crlf();
like($pdf->to_string, qr/12 TL T\*/, q{crlf with leading});

done_testing();
