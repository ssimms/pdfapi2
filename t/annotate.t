use Test::More tests => 2;

use strict;
use warnings;

use PDF::API2;
use PDF::API2::Basic::PDF::Array;

my $pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;
my $page = $pdf->page();

my $annotation = $page->annotation();
$annotation->text('This is an annotation', -rect => [ 72, 144, 172, 244 ]);

my $string = $pdf->stringify();
like($string,
     qr{/Annot /Subtype /Text /Border \[ 0 0 0 \] /Contents \(This is an annotation\) /Rect \[ 72 144 172 244 \]},
     q{Text Annotation in a rectangle});

# [RT #118352] Crash if $page->annotation is called on a page with an
# existing Annots array stored in an indirect object

$pdf = PDF::API2->new();
$page = $pdf->page();

my $array = PDF::API2::Basic::PDF::Array->new();
$pdf->{'pdf'}->new_obj($array);

$page->{'Annots'} = $array;
$page->update();
$string = $pdf->stringify();

$pdf = PDF::API2->open_scalar($string);
$page = $pdf->openpage(1);
$annotation = $page->annotation();

$annotation->text('This is an annotation', -rect => [ 72, 144, 172, 244 ]);

$string = $pdf->stringify();
like($string,
     qr{/Annot /Subtype /Text /Border \[ 0 0 0 \] /Contents \(This is an annotation\) /Rect \[ 72 144 172 244 \]},
     q{Add an annotation to an existing annotations array stored in an indirect object});
