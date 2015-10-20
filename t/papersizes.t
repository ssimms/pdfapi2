use Test::More tests => 116;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2->new();
my $page = $pdf->page();

my @mediabox;

# test named page sizes in Resource/PaperSizes.pm
# add additional tests if more sizes uncommented or added in that file
$page->mediabox('4a');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (4a)');
is($mediabox[1], 0, 'PaperSizes LLY (4a)');
is($mediabox[2], 4760, 'PaperSizes URX (4a)');
is($mediabox[3], 6716, 'PaperSizes URY (4a)');

$page->mediabox('2a');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (2a)');
is($mediabox[1], 0, 'PaperSizes LLY (2a)');
is($mediabox[2], 3368, 'PaperSizes URX (2a)');
is($mediabox[3], 4760, 'PaperSizes URY (2a)');

$page->mediabox('4a0');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (4a0)');
is($mediabox[1], 0, 'PaperSizes LLY (4a0)');
is($mediabox[2], 4760, 'PaperSizes URX (4a0)');
is($mediabox[3], 6716, 'PaperSizes URY (4a0)');

$page->mediabox('2a0');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (2a0)');
is($mediabox[1], 0, 'PaperSizes LLY (2a0)');
is($mediabox[2], 3368, 'PaperSizes URX (2a0)');
is($mediabox[3], 4760, 'PaperSizes URY (2a0)');

$page->mediabox('a0');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (a0)');
is($mediabox[1], 0, 'PaperSizes LLY (a0)');
is($mediabox[2], 2380, 'PaperSizes URX (a0)');
is($mediabox[3], 3368, 'PaperSizes URY (a0)');

$page->mediabox('a1');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (a1)');
is($mediabox[1], 0, 'PaperSizes LLY (a1)');
is($mediabox[2], 1684, 'PaperSizes URX (a1)');
is($mediabox[3], 2380, 'PaperSizes URY (a1)');

$page->mediabox('a2');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (a2)');
is($mediabox[1], 0, 'PaperSizes LLY (a2)');
is($mediabox[2], 1190, 'PaperSizes URX (a2)');
is($mediabox[3], 1684, 'PaperSizes URY (a2)');

$page->mediabox('a3');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (a3)');
is($mediabox[1], 0, 'PaperSizes LLY (a3)');
is($mediabox[2], 842, 'PaperSizes URX (a3)');
is($mediabox[3], 1190, 'PaperSizes URY (a3)');

$page->mediabox('a4');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (a4)');
is($mediabox[1], 0, 'PaperSizes LLY (a4)');
is($mediabox[2], 595, 'PaperSizes URX (a4)');
is($mediabox[3], 842, 'PaperSizes URY (a4)');

$page->mediabox('a5');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (a5)');
is($mediabox[1], 0, 'PaperSizes LLY (a5)');
is($mediabox[2], 421, 'PaperSizes URX (a5)');
is($mediabox[3], 595, 'PaperSizes URY (a5)');

$page->mediabox('a6');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (a6)');
is($mediabox[1], 0, 'PaperSizes LLY (a6)');
is($mediabox[2], 297, 'PaperSizes URX (a6)');
is($mediabox[3], 421, 'PaperSizes URY (a6)');

$page->mediabox('4b');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (4b)');
is($mediabox[1], 0, 'PaperSizes LLY (4b)');
is($mediabox[2], 5656, 'PaperSizes URX (4b)');
is($mediabox[3], 8000, 'PaperSizes URY (4b)');

$page->mediabox('2b');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (2b)');
is($mediabox[1], 0, 'PaperSizes LLY (2b)');
is($mediabox[2], 4000, 'PaperSizes URX (2b)');
is($mediabox[3], 5656, 'PaperSizes URY (2b)');

$page->mediabox('4b0');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (4b0)');
is($mediabox[1], 0, 'PaperSizes LLY (4b0)');
is($mediabox[2], 5656, 'PaperSizes URX (4b0)');
is($mediabox[3], 8000, 'PaperSizes URY (4b0)');

$page->mediabox('2b0');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (2b0)');
is($mediabox[1], 0, 'PaperSizes LLY (2b0)');
is($mediabox[2], 4000, 'PaperSizes URX (2b0)');
is($mediabox[3], 5656, 'PaperSizes URY (2b0)');

$page->mediabox('b0');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (b0)');
is($mediabox[1], 0, 'PaperSizes LLY (b0)');
is($mediabox[2], 2828, 'PaperSizes URX (b0)');
is($mediabox[3], 4000, 'PaperSizes URY (b0)');

$page->mediabox('b1');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (b1)');
is($mediabox[1], 0, 'PaperSizes LLY (b1)');
is($mediabox[2], 2000, 'PaperSizes URX (b1)');
is($mediabox[3], 2828, 'PaperSizes URY (b1)');

$page->mediabox('b2');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (b2)');
is($mediabox[1], 0, 'PaperSizes LLY (b2)');
is($mediabox[2], 1414, 'PaperSizes URX (b2)');
is($mediabox[3], 2000, 'PaperSizes URY (b2)');

$page->mediabox('b3');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (b3)');
is($mediabox[1], 0, 'PaperSizes LLY (b3)');
is($mediabox[2], 1000, 'PaperSizes URX (b3)');
is($mediabox[3], 1414, 'PaperSizes URY (b3)');

$page->mediabox('b4');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (b4)');
is($mediabox[1], 0, 'PaperSizes LLY (b4)');
is($mediabox[2], 707, 'PaperSizes URX (b4)');
is($mediabox[3], 1000, 'PaperSizes URY (b4)');

$page->mediabox('b5');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (b5)');
is($mediabox[1], 0, 'PaperSizes LLY (b5)');
is($mediabox[2], 500, 'PaperSizes URX (b5)');
is($mediabox[3], 707, 'PaperSizes URY (b5)');

$page->mediabox('b6');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (b6)');
is($mediabox[1], 0, 'PaperSizes LLY (b6)');
is($mediabox[2], 353, 'PaperSizes URX (b6)');
is($mediabox[3], 500, 'PaperSizes URY (b6)');

$page->mediabox('letter');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (letter)');
is($mediabox[1], 0, 'PaperSizes LLY (letter)');
is($mediabox[2], 612, 'PaperSizes URX (letter)');
is($mediabox[3], 792, 'PaperSizes URY (letter)');

$page->mediabox('broadsheet');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (broadsheet)');
is($mediabox[1], 0, 'PaperSizes LLY (broadsheet)');
is($mediabox[2], 1296, 'PaperSizes URX (broadsheet)');
is($mediabox[3], 1584, 'PaperSizes URY (broadsheet)');

$page->mediabox('ledger');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (ledger)');
is($mediabox[1], 0, 'PaperSizes LLY (ledger)');
is($mediabox[2], 1224, 'PaperSizes URX (ledger)');
is($mediabox[3], 792, 'PaperSizes URY (ledger)');

$page->mediabox('tabloid');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (tabloid)');
is($mediabox[1], 0, 'PaperSizes LLY (tabloid)');
is($mediabox[2], 792, 'PaperSizes URX (tabloid)');
is($mediabox[3], 1224, 'PaperSizes URY (tabloid)');

$page->mediabox('legal');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (legal)');
is($mediabox[1], 0, 'PaperSizes LLY (legal)');
is($mediabox[2], 612, 'PaperSizes URX (legal)');
is($mediabox[3], 1008, 'PaperSizes URY (legal)');

$page->mediabox('executive');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (executive)');
is($mediabox[1], 0, 'PaperSizes LLY (executive)');
is($mediabox[2], 522, 'PaperSizes URX (executive)');
is($mediabox[3], 756, 'PaperSizes URY (executive)');

$page->mediabox('36x36');
@mediabox = $page->get_mediabox();
is($mediabox[0], 0, 'PaperSizes LLX (36x36)');
is($mediabox[1], 0, 'PaperSizes LLY (36x36)');
is($mediabox[2], 2592, 'PaperSizes URX (36x36)');
is($mediabox[3], 2592, 'PaperSizes URY (36x36)');
