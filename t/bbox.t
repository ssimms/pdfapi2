use Test::More;

use strict;
use warnings;

use PDF::API2;

my $pdf = PDF::API2->new();

ok(!$pdf->mediabox(),
    q{No global media box on a new PDF});

$pdf->mediabox('letter');

is(join(',', $pdf->mediabox()),
   '0,0,612,792',
   q{Global media box can be read after being set});

my $string = $pdf->to_string();

like($string, qr{/MediaBox \[ 0 0 612 792 \]},
    q{Global media box is recorded in the PDF});

done_testing();
