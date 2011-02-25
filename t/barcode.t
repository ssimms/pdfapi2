use Test::More tests => 8;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;

# Check to ensure all barcode types can be loaded

my $xo_codabar = $pdf->xo_codabar();
isa_ok($xo_codabar, q{PDF::API2::Resource::XObject::Form::BarCode::codabar},
       q{xo_codabar loads});

my $xo_code128 = $pdf->xo_code128();
isa_ok($xo_code128, q{PDF::API2::Resource::XObject::Form::BarCode::code128},
       q{xo_code128 loads});

my $xo_2of5int = $pdf->xo_2of5int();
isa_ok($xo_2of5int, q{PDF::API2::Resource::XObject::Form::BarCode::int2of5},
       q{xo_2of5int loads});

my $xo_3of9 = $pdf->xo_3of9();
isa_ok($xo_3of9, q{PDF::API2::Resource::XObject::Form::BarCode::code3of9},
       q{xo_3of9 loads});

my $xo_ean13 = $pdf->xo_ean13();
isa_ok($xo_ean13, q{PDF::API2::Resource::XObject::Form::BarCode::ean13},
       q{xo_ean13 loads});

# Translate

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
