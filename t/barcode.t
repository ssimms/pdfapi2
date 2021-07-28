use Test::More tests => 28;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2->new(-compress => 0);

# Check to ensure all barcode types can be loaded

my $xo_codabar = $pdf->xo_codabar(-code => 0);
isa_ok($xo_codabar, q{PDF::API2::Resource::XObject::Form::BarCode::codabar},
       q{xo_codabar loads});

my $xo_code128 = $pdf->xo_code128(-code => 0);
isa_ok($xo_code128, q{PDF::API2::Resource::XObject::Form::BarCode::code128},
       q{xo_code128 loads});

my $xo_2of5int = $pdf->xo_2of5int(-code => 0);
isa_ok($xo_2of5int, q{PDF::API2::Resource::XObject::Form::BarCode::int2of5},
       q{xo_2of5int loads});

my $xo_3of9 = $pdf->xo_3of9(-code => 0);
isa_ok($xo_3of9, q{PDF::API2::Resource::XObject::Form::BarCode::code3of9},
       q{xo_3of9 loads});

my $xo_ean13 = $pdf->xo_ean13(-code => '0123456789012');
isa_ok($xo_ean13, q{PDF::API2::Resource::XObject::Form::BarCode::ean13},
       q{xo_ean13 loads});

# Translate

my $page = $pdf->page();

my $barcode = $pdf->xo_3of9(
    -code => '1',
    -zone => 10,
    -umzn => 0,
    -lmzn => 10,
    -font => $pdf->corefont('Helvetica'),
    -fnsz => 10,
);
$barcode->{'-docompress'} = 0;
delete $barcode->{'Filter'};

my $gfx = $page->gfx();
$gfx->formimage($barcode, 100, 100, 1);

my $string = $pdf->to_string();

like($string, qr{/BBox \[ 0 0 39 20 \]},
     q{Barcode is the expected size});

like($string, qr{0 0 0 rg},
     q{Barcode is black});

like($string, qr{q 1 0 0 1 100 100 cm},
     q{Barcode is in the expected location});

# Encoding

require PDF::API2::Resource::XObject::Form::BarCode::codabar;
is(join('', map { ref($_) ? $_->[0] : $_ } PDF::API2::Resource::XObject::Form::BarCode::codabar->encode('A31234567890123B')),
   'aabbabaa2211111111112211111211212211111111211211211112111211112112112111122111112112111111111221111122111112112122111111ababaaba',
   q{Correctly encoded Codabar barcode});

require PDF::API2::Resource::XObject::Form::BarCode::code128;
is(join('', map { ref($_) ? $_->[0] : $_ } PDF::API2::Resource::XObject::Form::BarCode::code128->encode_128('a', 'TEST')),
   'b1a4a2213311132113213113213311241211b3c1a1b',
   q{Correctly encoded Code 128A barcode});

is(join('', map { ref($_) ? $_->[0] : $_ } PDF::API2::Resource::XObject::Form::BarCode::code128->encode_128('b', 'Test')),
   'b1a2a4213311112214114212124112311321b3c1a1b',
   q{Correctly encoded Code 128B barcode});

is(join('', map { ref($_) ? $_->[0] : $_ } PDF::API2::Resource::XObject::Form::BarCode::code128->encode_128('c', '01234567890')),
   'b1a2c2222122312131113123141122212141114131123122111422b3c1a1b',
   q{Correctly encoded Code 128C barcode});

is(join('', map { ref($_) ? $_->[0] : $_ } PDF::API2::Resource::XObject::Form::BarCode::code128->encode_ean128('00123456780000000001')),
   'b1a2c2411131212222112232131123331121241112212222212222212222212222222122131222b3c1a1b',
   q{Correctly encoded EAN-128 barcode});

require PDF::API2::Resource::XObject::Form::BarCode::code3of9;
is(join('', map { ref($_) ? $_->[0] : $_ } PDF::API2::Resource::XObject::Form::BarCode::code3of9::encode_3of9('TEST')),
   'abaababaa11111212211211122111111211122111111212211abaababaa1',
   q{Correctly encoded Code 39 barcode});

is(join('', map { ref($_) ? $_->[0] : $_ } PDF::API2::Resource::XObject::Form::BarCode::code3of9::encode_3of9('TEST', 1, 0)),
   'abaababaa111112122112111221111112111221111112122112111221111abaababaa1',
   q{Correctly encoded Code 39 barcode (with check digit)});

is(join('', map { ref($_) ? $_->[0] : $_ } PDF::API2::Resource::XObject::Form::BarCode::code3of9::encode_3of9('Test', 0, 1)),
   'abaababaa11111212211121112121121112211111211121211112111221112111212111111212211abaababaa1',
   q{Correctly encoded Code 39 barcode (full ASCII)});

is(join('', map { ref($_) ? $_->[0] : $_ } PDF::API2::Resource::XObject::Form::BarCode::code3of9::encode_3of9('Test', 1, 1)),
   'abaababaa111112122111211121211211122111112111212111121112211121112121111112122112112112111abaababaa1',
   q{Correctly encoded Code 39 barcode (full ASCII and check digit)});

require PDF::API2::Resource::XObject::Form::BarCode::ean13;
my $ean13_codes = {
    '0123456789012' => '07a1a2221212214111132123111141a1a1131212133112321122212122a1a',
    '1123456789011' => '07a1a2221212211411132132141111a1a1131212133112321122212221a1a',
    '2123456789010' => '07a1a2221212211412311123141111a1a1131212133112321122213211a1a',
    '3123456789019' => '07a1a2221212211412311132111141a1a1131212133112321122213112a1a',
    '4123456789018' => '07a1a2221221214111132132141111a1a1131212133112321122211213a1a',
    '5123456789017' => '07a1a2221221211411132123141111a1a1131212133112321122211312a1a',
    '6123456789016' => '07a1a2221221211412311123111141a1a1131212133112321122211114a1a',
    '7123456789015' => '07a1a2221221214112311123141111a1a1131212133112321122211231a1a',
    '8123456789014' => '07a1a2221221214112311132111141a1a1131212133112321122211132a1a',
    '9123456789013' => '07a1a2221221211411132132111141a1a1131212133112321122211411a1a',
};

foreach my $code (sort keys %$ean13_codes) {
    is(join('', map { ref($_) ? $_->[0] : $_ } PDF::API2::Resource::XObject::Form::BarCode::ean13->encode($code)),
       $ean13_codes->{$code},
       q{Correctly encoded EAN 13 barcode with prefix } . substr($code, 0, 1));
}

require PDF::API2::Resource::XObject::Form::BarCode::int2of5;
is(join('', map { ref($_) ? $_->[0] : $_ } PDF::API2::Resource::XObject::Form::BarCode::int2of5->encode('0123456789')),
   'aaaa12112121121222111121121122112111212112122112112211baaa',
   q{Correctly encoded Interleaved 2 of 5 barcode});
