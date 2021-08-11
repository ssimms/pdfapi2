use Test::More tests => 6;

use strict;
use warnings;

use PDF::API2;
use PDF::API2::Basic::PDF::Array;

my $pdf = PDF::API2->new(-compress => 0);
my $page = $pdf->page();

# Text annotation

my $annotation = $page->annotation();
$annotation->text('This is an annotation', -rect => [ 72, 144, 172, 244 ]);

my $string = $pdf->to_string();
like($string,
     qr{/Annot /Subtype /Text /Border \[ 0 0 0 \] /Contents \(This is an annotation\) /Rect \[ 72 144 172 244 \]},
     q{Text Annotation in a rectangle});

# Link annotation

$pdf        = PDF::API2->new();
$page       = $pdf->page();
$annotation = $page->annotation();

my $page2 = $pdf->page();
$annotation->link($page2);

$string = $pdf->to_string();
like($string,
    qr{/Annot /Subtype /Link /A << /D \[ \d+ 0 R /XYZ null null null \] /S /GoTo >>},
    q{Link Annotation});

# URL annotation

$pdf        = PDF::API2->new();
$page       = $pdf->page();
$annotation = $page->annotation();

$annotation->url('http://perl.org');

$string = $pdf->to_string();
like($string,
    qr{/Annot /Subtype /Link /A << /S /URI /URI \(http://perl.org\) >>},
    q{URL Annotation});

# File annotation

$pdf        = PDF::API2->new();
$page       = $pdf->page();
$annotation = $page->annotation();

$annotation->file('test.pdf');

$string = $pdf->to_string();
like($string,
    qr{/Annot /Subtype /Link /A << /F \(test.pdf\) /S /Launch >>},
    q{File Annotation});

# PDF File annotation

$pdf        = PDF::API2->new();
$page       = $pdf->page();
$annotation = $page->annotation();

$annotation->pdf_file('test.pdf', 2);

$string = $pdf->to_string();
like($string,
    qr{/Annot /Subtype /Link /A << /D \[ 2 /XYZ null null null \] /F \(test.pdf\) /S /GoToR >>},
    q{File Annotation});

# [RT #118352] Crash if $page->annotation is called on a page with an
# existing Annots array stored in an indirect object

$pdf = PDF::API2->new();
$page = $pdf->page();

my $array = PDF::API2::Basic::PDF::Array->new();
$pdf->{'pdf'}->new_obj($array);

$page->{'Annots'} = $array;
$string = $pdf->to_string();

$pdf = PDF::API2->from_string($string);
$page = $pdf->open_page(1);
$annotation = $page->annotation();

$annotation->text('This is an annotation', -rect => [ 72, 144, 172, 244 ]);

$string = $pdf->to_string();
like($string,
     qr{/Annot /Subtype /Text /Border \[ 0 0 0 \] /Contents \(This is an annotation\) /Rect \[ 72 144 172 244 \]},
     q{Add an annotation to an existing annotations array stored in an indirect object});

