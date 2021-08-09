use Test::More;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2->new();
my $page = $pdf->page();
my @box;

# Global Boxes (deprecated names)

$pdf->mediabox(100, 200);
my @mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'Global Mediabox LLX');
is($mediabox[1], 0, 'Global Mediabox LLY');
is($mediabox[2], 100, 'Global Mediabox URX');
is($mediabox[3], 200, 'Global Mediabox URY');

$pdf->cropbox(200, 300);
my @cropbox = $page->get_cropbox();
is($cropbox[0], 0, 'Global Cropbox LLX');
is($cropbox[1], 0, 'Global Cropbox LLY');
is($cropbox[2], 200, 'Global Cropbox URX');
is($cropbox[3], 300, 'Global Cropbox URY');

$pdf->bleedbox(200, 300);
my @bleedbox = $page->get_bleedbox();
is($bleedbox[0], 0, 'Global Bleedbox LLX');
is($bleedbox[1], 0, 'Global Bleedbox LLY');
is($bleedbox[2], 200, 'Global Bleedbox URX');
is($bleedbox[3], 300, 'Global Bleedbox URY');

$pdf->trimbox(200, 300);
my @trimbox = $page->get_trimbox();
is($trimbox[0], 0, 'Global Trimbox LLX');
is($trimbox[1], 0, 'Global Trimbox LLY');
is($trimbox[2], 200, 'Global Trimbox URX');
is($trimbox[3], 300, 'Global Trimbox URY');

$pdf->artbox(200, 300);
my @artbox = $page->get_artbox();
is($artbox[0], 0, 'Global Artbox LLX');
is($artbox[1], 0, 'Global Artbox LLY');
is($artbox[2], 200, 'Global Artbox URX');
is($artbox[3], 300, 'Global Artbox URY');

# Page Size

$page->size('letter');
@box = $page->_bounding_box('MediaBox');
is($box[0],   0, q{$page->size('letter') X1});
is($box[1],   0, q{$page->size('letter') Y1});
is($box[2], 612, q{$page->size('letter') X2});
is($box[3], 792, q{$page->size('letter') Y2});

# Page Boundaries

$page->boundaries(media => 'letter');
@box = $page->_bounding_box('MediaBox');
is($box[0],   0, q{$page->boundaries(media => 'letter') X1});
is($box[1],   0, q{$page->boundaries(media => 'letter') Y1});
is($box[2], 612, q{$page->boundaries(media => 'letter') X2});
is($box[3], 792, q{$page->boundaries(media => 'letter') Y2});

$page->boundaries(media => '12x18', trim  => 0.5 * 72);

@box = $page->_bounding_box('MediaBox');
is($box[0], 0,       q{$page->boundaries(media => '12x18') X1});
is($box[1], 0,       q{$page->boundaries(media => '12x18') Y1});
is($box[2], 12 * 72, q{$page->boundaries(media => '12x18') X2});
is($box[3], 18 * 72, q{$page->boundaries(media => '12x18') Y2});

@box = $page->_bounding_box('TrimBox');
is($box[0],   36, q{Single-argument trim X1});
is($box[1],   36, q{Single-argument trim Y1});
is($box[2],  828, q{Single-argument trim X2});
is($box[3], 1260, q{Single-argument trim Y2});

# Default Page Size

$pdf->default_page_size('letter');
@box = $pdf->_bounding_box('MediaBox');
is($box[0],   0, q{$pdf->default_page_size('letter') X1});
is($box[1],   0, q{$pdf->default_page_size('letter') Y1});
is($box[2], 612, q{$pdf->default_page_size('letter') X2});
is($box[3], 792, q{$pdf->default_page_size('letter') Y2});

# Default Page Boundaries

$pdf->default_page_boundaries(media => 'letter');
@box = $pdf->_bounding_box('MediaBox');
is($box[0],   0, q{$page->boundaries(media => 'letter') X1});
is($box[1],   0, q{$page->boundaries(media => 'letter') Y1});
is($box[2], 612, q{$page->boundaries(media => 'letter') X2});
is($box[3], 792, q{$page->boundaries(media => 'letter') Y2});

$pdf->default_page_boundaries(media => '12x18', trim  => 0.5 * 72);

@box = $pdf->_bounding_box('MediaBox');
is($box[0], 0,       q{$page->boundaries(media => '12x18') X1});
is($box[1], 0,       q{$page->boundaries(media => '12x18') Y1});
is($box[2], 12 * 72, q{$page->boundaries(media => '12x18') X2});
is($box[3], 18 * 72, q{$page->boundaries(media => '12x18') Y2});

@box = $pdf->_bounding_box('TrimBox');
is($box[0],   36, q{Single-argument trim X1});
is($box[1],   36, q{Single-argument trim Y1});
is($box[2],  828, q{Single-argument trim X2});
is($box[3], 1260, q{Single-argument trim Y2});

# Page-Specific Boxes (deprecated names)

$page->mediabox(720, 1440);
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'Mediabox LLX');
is($mediabox[1], 0, 'Mediabox LLY');
is($mediabox[2], 720, 'Mediabox URX');
is($mediabox[3], 1440, 'Mediabox URY');

$page->mediabox('LEDGER');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'Mediabox LLX (ledger)');
is($mediabox[1], 0, 'Mediabox LLY (ledger)');
is($mediabox[2], 1224, 'Mediabox URX (ledger)');
is($mediabox[3], 792, 'Mediabox URY (ledger)');

$page->mediabox('non-existent');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'Mediabox LLX (unknown named type)');
is($mediabox[1], 0, 'Mediabox LLY (unknown named type)');
is($mediabox[2], 612, 'Mediabox URX (unknown named type)');
is($mediabox[3], 792, 'Mediabox URY (unknown named type)');

$page->mediabox(1, 2, 3, 4);
@mediabox = $page->get_mediabox();
is($mediabox[0], 1, 'Mediabox LLX (offset)');
is($mediabox[1], 2, 'Mediabox LLY (offset)');
is($mediabox[2], 3, 'Mediabox URX (offset)');
is($mediabox[3], 4, 'Mediabox URY (offset)');

$page->cropbox(10, 20);
@cropbox = $page->get_cropbox();
is($cropbox[0], 0, 'Cropbox LLX');
is($cropbox[1], 0, 'Cropbox LLY');
is($cropbox[2], 10, 'Cropbox URX');
is($cropbox[3], 20, 'Cropbox URY');

$page->bleedbox(30, 40);
@bleedbox = $page->get_bleedbox();
is($bleedbox[0], 0, 'Bleedbox LLX');
is($bleedbox[1], 0, 'Bleedbox LLY');
is($bleedbox[2], 30, 'Bleedbox URX');
is($bleedbox[3], 40, 'Bleedbox URY');

$page->trimbox(50, 60);
@trimbox = $page->get_trimbox();
is($trimbox[0], 0, 'Trimbox LLX');
is($trimbox[1], 0, 'Trimbox LLY');
is($trimbox[2], 50, 'Trimbox URX');
is($trimbox[3], 60, 'Trimbox URY');

$page->artbox(70, 80);
@artbox = $page->get_artbox();
is($artbox[0], 0, 'Artbox LLX');
is($artbox[1], 0, 'Artbox LLY');
is($artbox[2], 70, 'Artbox URX');
is($artbox[3], 80, 'Artbox URY');

done_testing();
