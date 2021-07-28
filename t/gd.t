use Test::More tests => 2;

use warnings;
use strict;

use PDF::API2;

SKIP: {
    eval { require GD };
    if ($@) {
        skip q{GD not installed; skipping image_gd tests}, 2;
    }

    my $gd = GD::Image->new(1, 1);
    $gd->colorAllocate(0, 0, 0);

    my $pdf = PDF::API2->new(-compress => 0);

    my $img = $pdf->image_gd($gd);
    isa_ok($img, 'PDF::API2::Resource::XObject::Image::GD',
           q{$pdf->image_gif()});

    my $gfx = $pdf->page->gfx();
    $gfx->image($img, 72, 144, 216, 288);
    like($pdf->to_string(), qr/q 216 0 0 288 72 144 cm \S+ Do Q/,
         q{Add GD to PDF});
}
