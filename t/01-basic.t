use Test::More tests => 7;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2->new();

isa_ok($pdf,
       'PDF::API2',
       q{PDF::API2->new() returns a PDF::API2 object});

my $page = $pdf->page();

isa_ok($page,
       'PDF::API2::Page',
       q{$pdf->page() returns a PDF::API2::Page object});

my $gfx = $page->gfx();

isa_ok($gfx,
       'PDF::API2::Content',
       q{$pdf->gfx() returns a PDF::API2::Content object});

my $text = $page->text();

isa_ok($text,
       'PDF::API2::Content::Text',
       q{$pdf->text() returns a PDF::API2::Content::Text object});


is($pdf->pages(),
   1,
   q{$pdf->pages() returns 1 on a one-page PDF});

# Insert a second page
$page = $pdf->page();

is($pdf->pages(),
   2,
   q{$pdf->pages() returns 2 after a second page is added});

# Open a PDF

$pdf = PDF::API2->open('t/resources/sample.pdf');

isa_ok($pdf,
       'PDF::API2',
       q{PDF::API2->open() returns a PDF::API2 object});
