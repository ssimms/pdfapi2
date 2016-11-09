use Test::More tests => 3;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2->open('t/resources/sample-xrefstm-index.pdf');

isa_ok($pdf,
       'PDF::API2',
       q{PDF::API2->open() on a PDF with a cross-reference stream using an Index returns a PDF::API2 object});

my $object = $pdf->{'pdf'}->read_objnum(9, 0);

ok($object,
   q{Read the high object from an indexed object stream});

$object = $pdf->{'pdf'}->read_objnum(12, 0);

ok($object,
   q{Read the low object from an indexed object stream});
