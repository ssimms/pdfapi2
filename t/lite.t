use Test::More tests => 1;

use warnings;
use strict;

use PDF::API2::Lite;

my $pdf = PDF::API2::Lite->new();

# RT #58386
my $egstate = $pdf->create_egs();
is(ref($egstate), 'PDF::API2::Resource::ExtGState',
   q{create_egs returns an extended graphics state object instead of dying});
