use Test::More;

use strict;
use warnings;

use PDF::API2;
use PDF::API2::NamedDestination;

my $pdf = PDF::API2->new();
my $page1 = $pdf->page();

my $dest = PDF::API2::NamedDestination->new($pdf, $page1, 'fit');

my $string = $pdf->to_string();
like($string, qr{/D \[ \d+ 0 R /Fit \]},
     q{Basic named destination is recorded in the PDF});

done_testing();
