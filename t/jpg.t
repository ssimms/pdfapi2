use Test::More tests => 2;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;

my $jpg = $pdf->image_jpeg('t/resources/1x1.jpg');
isa_ok($jpg, 'PDF::API2::Resource::XObject::Image::JPEG',
       q{$pdf->image_jpg()});

my $gfx = $pdf->page->gfx();
$gfx->image($jpg, 72, 144, 216, 288);
like($pdf->stringify(), qr/q 216 0 0 288 72 144 cm \S+ Do Q/,
     q{Add JPG to PDF});
