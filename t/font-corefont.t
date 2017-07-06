use Test::More;

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
    my $font = $pdf->corefont($font);
}

ok(1, 'All core fonts loaded successfully');

done_testing();
