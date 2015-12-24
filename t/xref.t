#!perl
use warnings;
use strict;
use Test::More tests => 4;
use PDF::API2;

foreach my $input ('HowToArgueEffectively.pdf', 'xref-test.pdf') {
    my $pdf = eval {
        PDF::API2->open("t/resources/$input");
    };
    isa_ok($pdf, 'PDF::API2', qq{doc $input containing an XRef stream}) or diag $@;

    my $file = $pdf->{pdf};
    my $pass = 1;

    while (my($id, $xref) = each %{$file->{' xref'}}) {
        my $obj = $file->read_objnum($id, $xref->[1]);
        unless (ref($obj)) {
            $pass = 0;
            last;
        }
    }
    ok($pass, "all XRef for $input entries point to an object");
}


