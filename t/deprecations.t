use Test::More tests => 1;

use strict;
use warnings;

no warnings 'deprecated';

use PDF::API2;
use PDF::API2::Resource::XObject::Image::JPEG;

my $pdf = PDF::API2->new();
my $image = PDF::API2::Resource::XObject::Image::JPEG->new_api($pdf, 't/resources/1x1.jpg');

ok($image, q{new_api still works});
