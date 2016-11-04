use Test::More tests => 4;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2->open('t/resources/sample-xrefstm.pdf');

isa_ok($pdf,
       'PDF::API2',
       q{PDF::API2->open() on a PDF with a cross-reference stream returns a PDF::API2 object});

my $object = $pdf->{'pdf'}->read_objnum(9, 0);

ok($object,
   q{Read an object from an object stream});

my ($key) = grep { $_ =~ /^Helv/ } keys %$object;
ok($key,
   q{The compressed object contains an expected key});

$object = $pdf->{'pdf'}->read_objnum(11, 0);

ok($object,
   q{Read a number from an object stream});
