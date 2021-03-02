use Test::More tests => 13;

use warnings;
use strict;

use PDF::API2;

# advancewidth

my $pdf = PDF::API2->new();
my $page = $pdf->page();
my $text = $page->text();
my $font = $pdf->corefont('Helvetica');

$text->font($font, 12);
$text->text('Test Text');

my $width = $text->advancewidth('Test Text');
is($width, '50.016', 'Advance Width Check');

$text->charspace(2);
is($text->charspace(), 2, 'Charspace is set');
$width = $text->advancewidth('Test Text');
is($width, '66.016', 'Advance width check with charspace added');

$width = $text->advancewidth('Test Text', charspace => 0);
is($width, '50.016', 'Advance width check with charspace overridden to 0');

$text->wordspace(4);
is($text->wordspace(), 4, 'Wordspace is set');
$width = $text->advancewidth('Test Text');
is($width, '70.016', 'Advance width check with wordspace added');

$width = $text->advancewidth('Test Text', wordspace => 0);
is($width, '66.016', 'Advance width check with wordspace overridden to 0');

# Check for death if text() is called without font()
$text = $page->text();
{
    local $@;
    eval { $text->text('This should die because no font has been set') };
    like($@,
         qr{Can't add text without first setting a font and font size},
         q{Call to text without a set font returns an informative error});

    # Call font(), but without setting a font size
    eval { $text->font($font); };
    like($@,
         qr{A font size is required},
         q{Call to text without a set font size returns an informative error});
}

# text

$pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;
$text = $pdf->page->text();
$font = $pdf->corefont('Helvetica');
$text->font($font, 12);

$width = $text->text('Test Text');
like($pdf->stringify(), qr/\(Test Text\) Tj/,
     q{Basic text call});
is($width, '50.016',
   q{Basic text call has expected width});

# text with indent

$pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;
$text = $pdf->page->text();
$font = $pdf->corefont('Helvetica');
$text->font($font, 12);

$width = $text->text('Test Text', -indent => 72);
like($pdf->stringify(), qr/\[ -6000 \(Test Text\) \] TJ/,
     q{text with indent});
is($width, '50.016',
   q{text with indent has expected width});
