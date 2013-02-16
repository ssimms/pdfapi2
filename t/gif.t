use Test::More tests => 2;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;

my $gif = $pdf->image_gif('t/resources/1x1.gif');
isa_ok($gif, 'PDF::API2::Resource::XObject::Image::GIF',
       q{$pdf->image_gif()});

my $gfx = $pdf->page->gfx();
$gfx->image($gif, 72, 144, 216, 288);
like($pdf->stringify(), qr/q 216 0 0 288 72 144 cm \S+ Do Q/,
     q{Add GIF to PDF});
