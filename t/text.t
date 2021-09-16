use Test::More tests => 26;

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

$pdf = PDF::API2->new(-compress => 0);
$text = $pdf->page->text();
$font = $pdf->corefont('Helvetica');
$text->font($font, 12);

$width = $text->text('Test Text');
like($pdf->to_string(), qr/\(Test Text\) Tj/,
     q{Basic text call});
is($width, '50.016',
   q{Basic text call has expected width});

# text with indent

$pdf = PDF::API2->new(-compress => 0);
$text = $pdf->page->text();
$font = $pdf->corefont('Helvetica');
$text->font($font, 12);

$width = $text->text('Test Text', -indent => 72);
like($pdf->to_string(), qr/\[ -6000 \(Test Text\) \] TJ/,
     q{text with indent});
is($width, '50.016',
   q{text with indent has expected width});

# text_right

$pdf = PDF::API2->new(-compress => 0);
$text = $pdf->page->text();
$font = $pdf->corefont('Helvetica');
$text->font($font, 12);

$width = $text->text_right('Test Text');
like($pdf->to_string(), qr/\[ 4168 \(Test Text\) \] TJ/,
     q{text_right});

# text_center

$pdf = PDF::API2->new(-compress => 0);
$text = $pdf->page->text();
$font = $pdf->corefont('Helvetica');
$text->font($font, 12);

$width = $text->text_center('Test Text');
like($pdf->to_string(), qr/\[ 2084 \(Test Text\) \] TJ/,
     q{text_center});

# text_justified

$pdf = PDF::API2->new(-compress => 0);
$text = $pdf->page->text();
$font = $pdf->corefont('Helvetica');
$text->font($font, 12);

$width = $text->text_justified('Test Text', 72);
like($pdf->to_string(), qr/21.984 Tw \(Test Text\) Tj 0 Tw/,
     q{text_justified});

# paragraph

$pdf = PDF::API2->new(-compress => 0);
$text = $pdf->page->text();
$font = $pdf->corefont('Helvetica');
$text->font($font, 12);
$text->leading(15);

my $leftover = $text->paragraph(('aaa ' x 30), 144, 72);
like($pdf->to_string(), qr/15 TL (\((aaa ){5}aaa\) Tj T\* ){4}\s*ET/,
     q{paragraph});
is($leftover, 'aaa aaa aaa aaa aaa aaa',
   q{paragraph has expected leftover});

# paragraph, align right

$pdf = PDF::API2->new(-compress => 0);
$text = $pdf->page->text();
$font = $pdf->corefont('Helvetica');
$text->font($font, 12);
$text->leading(15);

$text->paragraph(('aaa ' x 10), 144, 72, -align => 'right');
like($pdf->to_string(),
     qr/\[ 11398 \((aaa ){5}aaa\) \] TJ T\* \[ 7506 \(aaa aaa aaa aaa\) \] TJ T\*/,
     q{paragraph, align right});

# paragraph, align center

$pdf = PDF::API2->new(-compress => 0);
$text = $pdf->page->text();
$font = $pdf->corefont('Helvetica');
$text->font($font, 12);
$text->leading(15);

$text->paragraph(('aaa ' x 10), 144, 72, -align => 'center');
like($pdf->to_string(),
     qr/\[ 5699 \((aaa ){5}aaa\) \] TJ T\* \[ 3753 \(aaa aaa aaa aaa\) \] TJ T\*/,
     q{paragraph, align center});

# paragraph, justified left

$pdf = PDF::API2->new(-compress => 0);
$text = $pdf->page->text();
$font = $pdf->corefont('Helvetica');
$text->font($font, 12);
$text->leading(15);

$text->paragraph(('aaa ' x 10), 144, 72, -align => 'justified');
like($pdf->to_string(),
     qr/1.4448 Tw \((aaa ){5}aaa\) Tj 0 Tw T\* \(aaa aaa aaa aaa\) Tj T\*/,
     q{paragraph, justified, last line left});

# paragraph, justified right

$pdf = PDF::API2->new(-compress => 0);
$text = $pdf->page->text();
$font = $pdf->corefont('Helvetica');
$text->font($font, 12);
$text->leading(15);

$text->paragraph(('aaa ' x 10), 144, 72, -align => 'justified',
                 '-align-last' => 'right');
like($pdf->to_string(),
     qr/1.4448 Tw \((aaa ){5}aaa\) Tj 0 Tw T\* \[ 7506 \((aaa ){3}aaa\) \] TJ T\*/,
     q{paragraph, justified, last line right});

# paragraph, justified center

$pdf = PDF::API2->new(-compress => 0);
$text = $pdf->page->text();
$font = $pdf->corefont('Helvetica');
$text->font($font, 12);
$text->leading(15);

$text->paragraph(('aaa ' x 10), 144, 72, -align => 'justified',
                 '-align-last' => 'center');
like($pdf->to_string(),
     qr/1.4448 Tw \((aaa ){5}aaa\) Tj 0 Tw T\* \[ 3753 \((aaa ){3}aaa\) \] TJ T\*/,
     q{paragraph, justified, last line center});

# paragraph, justified, last line justified

$pdf = PDF::API2->new(-compress => 0);
$text = $pdf->page->text();
$font = $pdf->corefont('Helvetica');
$text->font($font, 12);
$text->leading(15);

$text->paragraph(('aaa ' x 10), 144, 72, -align => 'justified',
                 '-align-last' => 'justified');
like($pdf->to_string(),
     qr/1.4448 Tw \((aaa ){5}aaa\) Tj 0 Tw T\* 17.976 Tw \((aaa ){3}aaa\) Tj 0 Tw/,
     q{paragraph, justified, last line justified});

# paragraphs (formerly "section")

$pdf = PDF::API2->new(-compress => 0);
$text = $pdf->page->text();
$font = $pdf->corefont('Helvetica');
$text->font($font, 12);
$text->leading(15);

my $input = 'aaa ' x 10 . "\n\n" . 'bbb ' x 10;
$leftover = $text->paragraphs($input, 144, 72);
like($pdf->to_string(), qr/15 TL \((aaa ){5}aaa\) Tj T\* \((aaa ){3}aaa\) Tj T\* T\* \((bbb ){5}bbb\) Tj T\*\s+ET/,
     q{paragraphs});
is($leftover, 'bbb bbb bbb bbb',
   q{paragraphs has expected leftover});
