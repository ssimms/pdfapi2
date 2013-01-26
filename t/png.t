use Test::More tests => 2;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;

my $png = $pdf->image_png('t/resources/1x1.png');
isa_ok($png, 'PDF::API2::Resource::XObject::Image::PNG',
       q{$pdf->image_png()});

my $gfx = $pdf->page->gfx();
$gfx->image($png, 72, 144, 216, 288);
like($pdf->stringify(), qr/q 216 0 0 288 72 144 cm \S+ Do Q/,
     q{Add PNG to PDF});
