use Test::More tests => 2;
my $test_count = 2;

use warnings;
use strict;

use PDF::API2;

my @possible_locations = (
    '/usr/share/fonts/truetype/ttf-dejavu/DejaVuSans.ttf',
    '/var/lib/defoma/gs.d/dirs/fonts/DejaVuSans.ttf',
);

my ($font_file) = grep { -f && -r } @possible_locations;

SKIP: {
    skip "Skipping synthetic font tests... DejaVu Sans font not found", $test_count
        unless $font_file;

    my $pdf = PDF::API2->new();
    my $ttf = $pdf->ttfont($font_file);
    my $font = $pdf->synfont($ttf);

    # Do something with the font to see if it appears to have opened
    # properly.
    ok($font->glyphNum() > 0,
       q{Able to read a count of glyphs (>0) from a TrueType font});

    like($font->{'Name'}->val(), qr/^SynDe/,
         q{Font has the expected name});
}
