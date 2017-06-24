use Test::More (tests => 1);

use PDF::API2;

my $pdf = PDF::API2->open('t/resources/sample.pdf');

ok($pdf->stringify(),
   q{open() followed by saveas() doesn't crash});
