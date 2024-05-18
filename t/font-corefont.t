use Test::More;
use Test::Exception;

use strict;
use warnings;

use PDF::API2;

my $pdf = PDF::API2->new();

foreach my $font (qw(bankgothic courier courierbold courierboldoblique
                     courieroblique georgia georgiabold georgiabolditalic
                     georgiaitalic helvetica helveticabold helveticaboldoblique
                     helveticaoblique symbol timesbold timesbolditalic
                     timesitalic timesroman trebuchet trebuchetbold
                     trebuchetbolditalic trebuchetitalic verdana verdanabold
                     verdanabolditalic verdanaitalic webdings wingdings
                     zapfdingbats)) {
    lives_ok(sub { $pdf->corefont($font) }, "Load font $font");
}

ok($pdf->is_standard_font('Helvetica'),
   q{Helvetica is a standard font});

ok(!$pdf->is_standard_font('Comic Sans'),
   q{Comic Sans is not a standard font});

require PDF::API2::Resource::Font::CoreFont;
my @names = PDF::API2::Resource::Font::CoreFont->names();
is(scalar(@names), 14,
   q{names() returns 14 elements in array context});

my $arrayref = PDF::API2::Resource::Font::CoreFont->names();
is(ref($arrayref), 'ARRAY',
   q{names() returns an array reference in scalar context});
is(scalar(@$arrayref), 14,
   q{The array reference contains 14 elements});

@names = $pdf->standard_fonts();
is(scalar(@names), 14,
   q{$pdf->standard_fonts() returns an array with 14 elements});

foreach my $name (@names) {
    ok(PDF::API2::Resource::Font::CoreFont->is_standard($name),
       qq{$name is a core font});
}

done_testing();
