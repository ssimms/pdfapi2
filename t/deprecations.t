use Test::More tests => 5;

use strict;
use warnings;

no warnings 'deprecated';

use PDF::API2;
use PDF::API2::Resource::XObject::Image::JPEG;

my $pdf = PDF::API2->new();
my $image = PDF::API2::Resource::XObject::Image::JPEG->new_api($pdf, 't/resources/1x1.jpg');

ok($image, q{new_api still works});


##
## PDF::API2
##

$pdf = PDF::API2->new();
$pdf->page->gfx->fillcolor('blue');
my $pdf_string = $pdf->to_string();

# openScalar
$pdf = PDF::API2->openScalar($pdf_string);
is(ref($pdf), 'PDF::API2',
   q{openScalar still works});

# importpage
my $pdf2 = PDF::API2->new();
my $page = $pdf2->importpage($pdf, 1);
is(ref($page), 'PDF::API2::Page',
   q{importpage still works});

# openpage
$pdf2 = PDF::API2->from_string($pdf_string);
$page = $pdf->openpage(1);
is(ref($page), 'PDF::API2::Page',
   q{openpage still works});

# Invalid input to pageLabel (#40)
{
    $pdf = PDF::API2->new();
    local $SIG{__WARN__} = sub {};
    $pdf->pageLabel(0, { -style => 'arabic' });
    like($pdf->to_string(), qr{/PageLabels << /Nums \[ 0 << /S /D >> \] >>},
         q{pageLabel defaults to decimal if given invalid input});
}
