use warnings;
use strict;

use PDF::API2;

# Large rgba png files

my $pdf = PDF::API2->new();
my $page = $pdf->page();
my $png = $pdf->image_png('t/resources/test-rgba.png');
$page->mediabox(840,600);
my $gfx=$page->gfx; 
$gfx->image($png,134,106,510,281); 
$pdf->saveas('t/resources/test-rgba.pdf'); 
