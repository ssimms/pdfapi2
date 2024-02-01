#!/usr/bin/perl -w

use strict;
use warnings;

# use Carp 'verbose'; local $SIG{__DIE__} = sub { Carp::confess(@_) }; # use Data::Dumper;

use PDF::API2;

print qq{Usage: perl $0 ; xdg-open utf8-special-characters.pdf 

Prints a sample string using a number of fonts to illustrate some traps of pdf fonts.
Assumes /usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf exists to provide UTF8 characters. 
};

my ( $pdf, $page, $text, $font, $ttfont, $font_file, $top, $down );

$pdf = PDF::API2->new();

# Add a blank page
$page = $pdf->page();
$top  = 600;
$down = 40;
$text = $page->text();
$font = $pdf->corefont( 'Helvetica-Bold', -encode => 'utf8' )
  ;    # but core fonts don't really have much utf8 !
$text->font( $font, 12 );
$text->translate( 10, $top );
$text->text("In core font: US: a b c; accents: á é í; ES: ñ Ñ ¿;");
$top = $top - .5 * $down;
$text->translate( 10, $top );
$text->text("  DE: ä ö; RU: ѐ Ѡ; GR: α β ; Mono: iI lL zero=0 one=1");

$top       = $top - $down;
$font_file = '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf';
if ( -e $font_file ) {
    $ttfont = $pdf->ttfont($font_file);
    $text->font( $ttfont, 12 );
    $text->translate( 10, $top );
    $text->text(
"In true type font Dejavu Sans: US: a b c; accents: á é í; ES: ñ Ñ ¿;"
    );
    $top = $top - .5 * $down;
    $text->translate( 10, $top );
    $text->text(
        "  DE: ä ö; RU: ѐ Ѡ; GR: α β ; Mono: iI lL zero=0 one=1'");
}

$top       = $top - $down;
$font_file = '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf';
if ( -e $font_file ) {
    use utf8;
    $ttfont = $pdf->ttfont($font_file);
    $text->font( $ttfont, 12 );
    $text->translate( 10, $top );
    $text->text(
"In true type font with 'use utf8;': US: a b c; accents: á é í; ES: ñ Ñ ¿;"
    );
    $top = $top - .5 * $down;
    $text->translate( 10, $top );
    $text->text(
        "  DE: ä ö; RU: ѐ Ѡ; GR: α β ; Mono: iI lL zero=0 one=1'");
}

# Save the PDF
$pdf->saveas('utf8-special-characters.pdf');

exit;
