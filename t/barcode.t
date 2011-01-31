use Test::More tests => 3;

use warnings;
use strict;

use PDF::API2;

# Translate

my $pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;
my $page = $pdf->page();

my $barcode = $pdf->xo_3of9(
    -code => '1',
    -zone => 10,
    -umzn => 0,
    -lmzn => 10,
    -font => $pdf->corefont('Helvetica'),
    -fnsz => 10,
);
$barcode->{'-docompress'} = 0;
delete $barcode->{'Filter'};

my $gfx = $page->gfx();
$gfx->formimage($barcode, 100, 100, 1);

my $string = $pdf->stringify();

like($string, qr{/BBox \[ 0 0 39 20 \]},
     q{Barcode is the expected size});

like($string, qr{0 0 0 rg},
     q{Barcode is black});

like($string, qr{q 1 0 0 1 100 100 cm},
     q{Barcode is in the expected location});
