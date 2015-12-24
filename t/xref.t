use Test::More tests => 2;

use warnings;
use strict;

use PDF::API2;

my $pdf = eval {
    PDF::API2->open('t/resources/HowToArgueEffectively.pdf');
};

isa_ok($pdf, 'PDF::API2', q{doc containing an XRef stream});

my $file = $pdf->{pdf};
my $pass = 1;

while (my($id, $xref) = each %{$file->{' xref'}}) {
    my $obj = $file->read_objnum($id, $xref->[1]);

    unless (ref($obj)) {
        $pass = 0;
        last;
    }
}

ok($pass, 'all XRef entries point to an object');

