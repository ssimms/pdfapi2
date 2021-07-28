use Test::More (tests => 1);

use PDF::API2;

my $pdf = PDF::API2->open('t/resources/sample.pdf');

ok($pdf->to_string(),
   q{open() followed by to_string() doesn't crash});
