use Test::More tests => 4;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;

my $tiff = $pdf->image_tiff('t/resources/1x1.tif');
isa_ok($tiff, 'PDF::API2::Resource::XObject::Image::TIFF',
       q{$pdf->image_tiff()});

my $gfx = $pdf->page->gfx();
$gfx->image($tiff, 72, 144, 216, 288);
like($pdf->stringify(), qr/q 216 0 0 288 72 144 cm \S+ Do Q/,
     q{Add TIFF to PDF});

$pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;

my $lzw_tiff = $pdf->image_tiff('t/resources/1x1-lzw.tif');
isa_ok($lzw_tiff, 'PDF::API2::Resource::XObject::Image::TIFF',
       q{$pdf->image_tiff(), LZW compression});

$gfx = $pdf->page->gfx();
$gfx->image($lzw_tiff, 72, 360, 216, 432);

like($pdf->stringify(), qr/q 216 0 0 432 72 360 cm \S+ Do Q/,
     q{Add TIFF to PDF});
