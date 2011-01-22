use Test::More tests => 2;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2->new();

$pdf->info(Producer => 'PDF::API2 Test Suite');
my %info = $pdf->info();
is($info{'Producer'}, 'PDF::API2 Test Suite', 'Check info string');

my $new = PDF::API2->openScalar($pdf->stringify());
%info = $new->info();
is($info{'Producer'}, 'PDF::API2 Test Suite', 'Check info string after save and reload');
