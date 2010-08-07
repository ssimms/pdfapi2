use Test::More tests => 1;

use PDF::API2;

my $pdf = PDF::API2->new();
my $font = $pdf->ttfont('lib/PDF/API2/fonts/DejaVuSans.ttf');

# Do something with the font to see if it appears to have opened
# properly.
is($font->glyphNum(),
   5333,
   q{Importing a specific TTF font and checking glyphNum returns the expected number});
