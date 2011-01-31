use Test::More tests => 1;

use PDF::API2;

my @possible_locations = (
    '/usr/share/fonts/truetype/ttf-dejavu/DejaVuSans.ttf',
    '/var/lib/defoma/gs.d/dirs/fonts/DejaVuSans.ttf',
);

my ($font_file) = grep { -f && -r } @possible_locations;

SKIP: {
    skip "Skipping TTF tests... DejaVu Sans font not found", 1
        unless $font_file;

    my $pdf = PDF::API2->new();
    my $font = $pdf->ttfont($font_file);

    # Do something with the font to see if it appears to have opened
    # properly.
    ok($font->glyphNum() > 0,
       q{Able to read a count of glyphs (>0) from a TrueType font});
}
