use Test::More tests => 1;

use PDF::API2;

my $pfb_file = '/usr/share/fonts/type1/gsfonts/a010013l.pfb';
my $pfm_file = '/usr/share/fonts/type1/gsfonts/a010013l.pfm';

SKIP: {
    skip "Skipping Type1 tests... URW Gothic L Book font not found", 1
        unless (-f $pfb_file and -r $pfb_file and -f $pfm_file and -r $pfm_file);

    my $pdf = PDF::API2->new();
    my $font = $pdf->psfont($pfb_file, -pfmfile => $pfm_file);

    # Do something with the font to see if it appears to have opened
    # properly.
    ok($font->glyphNum() > 0,
       q{Able to read a count of glyphs (>0) from a Type1 font});
}
