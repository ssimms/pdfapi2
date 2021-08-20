use Test::More;

use strict;
use warnings;

use PDF::API2;

my $pdf = PDF::API2->new();

like($pdf->producer(), qr/PDF::API2/,
     q{Producer is set on PDF creation});

$pdf->producer('Test');

is($pdf->producer(), 'Test',
   q{Producer can be changed});

$pdf->producer(undef);

ok(!$pdf->producer(),
   q{Producer can be cleared});

$pdf->created('D:20000101000000Z');

like($pdf->to_string(),
     qr{/CreationDate \(D:20000101000000Z\)},
     q{CreationDate is correctly encoded});

done_testing();
