use Test::More tests => 10;

use warnings;
use strict;

use PDF::API2::Lite;

my $pdf = PDF::API2::Lite->new();

isa_ok($pdf,'PDF::API2::Lite');

# check return values for methods without arguments
isa_ok($pdf->page,'PDF::API2::Lite');

# check return value for method requireing aruments
isa_ok($pdf->mediabox(100,100),'PDF::API2::Lite');

# testing serializing (stringify)
# this destroys something so further tests needs a refresh
# this method also contains some code which is never executed?
my $str = $pdf->saveas('-');
my  @lines = split/\x0a/ , $str;

is($lines[0],"%PDF-1.4","PDF default version is 1.4 for PDF::API2::Lite");
is($lines[-1],"%%EOF","correct ending eof sequence");


$pdf = PDF::API2::Lite->new();

my $font;
$font = $pdf->corefont('Times-Roman');
isa_ok($font,'PDF::API2::Resource::Font::CoreFont');
$font = $pdf->corefont('Times-Bold');
isa_ok($font,'PDF::API2::Resource::Font::CoreFont');
$font = $pdf->corefont('Helvetica');
isa_ok($font,'PDF::API2::Resource::Font::CoreFont');
$font = $pdf->corefont('ZapfDingbats');
isa_ok($font,'PDF::API2::Resource::Font::CoreFont');

$pdf = PDF::API2::Lite->new();
# RT #58386
my $egstate = $pdf->create_egs();
is(ref($egstate), 'PDF::API2::Resource::ExtGState',
   q{create_egs returns an extended graphics state object instead of dying});
