use Test::More tests => 16;

use warnings;
use strict;

use File::Temp qw(tempfile);
use PDF::API2;

my $pdf = PDF::API2->new();

$pdf->info(Producer => 'PDF::API2 Test Suite');
my %info = $pdf->info();
is($info{'Producer'}, 'PDF::API2 Test Suite', 'Check info string');

my $gfx = $pdf->page->gfx();
$gfx->fillcolor('blue');

my $new = PDF::API2->open_scalar($pdf->stringify());
%info = $new->info();
is($info{'Producer'}, 'PDF::API2 Test Suite', 'Check info string after save and reload');

##
## import_page
##

$pdf = $new;
$new = PDF::API2->new();
my $form = $new->importPageIntoForm($pdf, 1);
delete $form->{'Filter'};
my $string = $new->stringify();
like($string, qr/0 0 1 rg/,
     q{Page imported by import_page contains content from original});

# Add a second page with a different page size

$new = PDF::API2->open_scalar($string, );
my $page = $pdf->page();
my $font = $pdf->corefont('Helvetica');
$page->mediabox(0, 0, 72, 144);
my $text = $page->text();
$text->font($font, 12);
$text->text('This is a test');
$pdf = PDF::API2->open_scalar($pdf->stringify());
$form = $new->importPageIntoForm($pdf, 2);
delete $form->{'Filter'};

is(($form->bbox())[2], 72,
   q{Form bounding box is set from imported page});

$string = $new->stringify();

like($string, qr/\(This is a test\)/,
     q{Second imported page contains text});


# Page Numbering

$pdf = PDF::API2->new();
$pdf->pageLabel(0, { -style => 'Roman' });

like($pdf->stringify(), qr{/PageLabels << /Nums \[ 0 << /S /R >> \] >>},
     q{Page Numbering: Upper-case Roman Numerals});

$pdf = PDF::API2->new();
$pdf->pageLabel(0, { -style => 'roman' });
like($pdf->stringify(), qr{/PageLabels << /Nums \[ 0 << /S /r >> \] >>},
     q{Page Numbering: Upper-case Roman Numerals});

$pdf = PDF::API2->new();
$pdf->pageLabel(0, { -style => 'Alpha' });
like($pdf->stringify(), qr{/PageLabels << /Nums \[ 0 << /S /A >> \] >>},
     q{Page Numbering: Upper-case Alphabet Characters});

$pdf = PDF::API2->new();
$pdf->pageLabel(0, { -style => 'alpha' });
like($pdf->stringify(), qr{/PageLabels << /Nums \[ 0 << /S /a >> \] >>},
     q{Page Numbering: Lower-case Alphabet Characters});

$pdf = PDF::API2->new();
$pdf->pageLabel(0, { -style => 'decimal' });
like($pdf->stringify(), qr{/PageLabels << /Nums \[ 0 << /S /D >> \] >>},
     q{Page Numbering: Decimal Characters});

$pdf = PDF::API2->new();
$pdf->pageLabel(0, { -start => 11 });
like($pdf->stringify(), qr{/PageLabels << /Nums \[ 0 << /S /D /St 11 >> \] >>},
     q{Page Numbering: Decimal Characters (implicit), starting at 11});

$pdf = PDF::API2->new();
$pdf->pageLabel(0, { -prefix => 'Test' });
like($pdf->stringify(), qr{/PageLabels << /Nums \[ 0 << /P \(Test\) /S /D >> \] >>},
     q{Page Numbering: Decimal Characters (implicit), with prefix});


##
## stringify
##

$pdf = PDF::API2->new(-compress => 0);
$gfx = $pdf->page->gfx();
$gfx->fillcolor('blue');

$string = $pdf->stringify();
like($string, qr/0 0 1 rg/,
     q{Stringify of newly-created PDF contains expected content});

my ($fh, $filename) = tempfile();
print $fh $string;
close $fh;

$pdf = PDF::API2->open($filename);
$string = $pdf->stringify();
like($string, qr/0 0 1 rg/,
     q{Stringify of newly-opened PDF contains expected content});

##
## saveas with same filename
##

$pdf = PDF::API2->new(-compress => 0);
$gfx = $pdf->page->gfx();
$gfx->fillcolor('blue');

($fh, $filename) = tempfile();
print $fh $pdf->stringify();
close $fh;

$pdf = PDF::API2->open($filename, -compress => 0);
$gfx = $pdf->page->gfx();
$gfx->fillcolor('red');
$pdf->saveas($filename);

$pdf = PDF::API2->open($filename, -compress => 0);
$string = $pdf->stringify();
like($string, qr/0 0 1 rg/,
     q{saveas($opened_filename) contains original content});
like($string, qr/1 0 0 rg/,
     q{saveas($opened_filename) contains new content});

