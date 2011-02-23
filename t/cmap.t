use Test::More tests => 1;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2->new();
my $font = $pdf->cjkfont('simplified');

is(ref($font), 'PDF::API2::Resource::CIDFont::CJKFont',
   q{Check that .cmap files are being used});
