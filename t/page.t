use Test::More tests => 24;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2->new();
my $page = $pdf->page();

$page->mediabox(720, 1440);
my @mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'Mediabox LLX');
is($mediabox[1], 0, 'Mediabox LLY');
is($mediabox[2], 720, 'Mediabox URX');
is($mediabox[3], 1440, 'Mediabox URY');

$page->mediabox('LEDGER');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'Mediabox LLX');
is($mediabox[1], 0, 'Mediabox LLY');
is($mediabox[2], 1224, 'Mediabox URX');
is($mediabox[3], 792, 'Mediabox URY');

$page->cropbox(10, 20);
my @cropbox = $page->get_cropbox();
is($cropbox[0], 0, 'Cropbox LLX');
is($cropbox[1], 0, 'Cropbox LLY');
is($cropbox[2], 10, 'Cropbox URX');
is($cropbox[3], 20, 'Cropbox URY');

$page->bleedbox(30, 40);
my @bleedbox = $page->get_bleedbox();
is($bleedbox[0], 0, 'Bleedbox LLX');
is($bleedbox[1], 0, 'Bleedbox LLY');
is($bleedbox[2], 30, 'Bleedbox URX');
is($bleedbox[3], 40, 'Bleedbox URY');

$page->trimbox(50, 60);
my @trimbox = $page->get_trimbox();
is($trimbox[0], 0, 'Trimbox LLX');
is($trimbox[1], 0, 'Trimbox LLY');
is($trimbox[2], 50, 'Trimbox URX');
is($trimbox[3], 60, 'Trimbox URY');

$page->artbox(70, 80);
my @artbox = $page->get_artbox();
is($artbox[0], 0, 'Artbox LLX');
is($artbox[1], 0, 'Artbox LLY');
is($artbox[2], 70, 'Artbox URX');
is($artbox[3], 80, 'Artbox URY');
