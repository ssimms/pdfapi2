use Test::More;

use strict;
use warnings;

use PDF::API2;

my $value = 'D:2006';
ok(PDF::API2::_is_date($value), $value);

$value = 'D:200601';
ok(PDF::API2::_is_date($value), $value);

$value = 'D:20061';
ok(!PDF::API2::_is_date($value),
   qq{$value (missing leading zero)});

$value = 'D:200613';
ok(!PDF::API2::_is_date($value),
   qq{$value (invalid month)});

$value = 'D:20060102';
ok(PDF::API2::_is_date($value), $value);

$value = 'D:2006012';
ok(!PDF::API2::_is_date($value),
   qq{$value (missing leading zero)});

$value = 'D:20060132';
ok(!PDF::API2::_is_date($value),
   qq{$value (invalid day)});

$value = 'D:2006010215';
ok(PDF::API2::_is_date($value), $value);

$value = 'D:200601023';
ok(!PDF::API2::_is_date($value),
   qq{$value (missing leading zero)});

$value = 'D:2006010225';
ok(!PDF::API2::_is_date($value),
   qq{$value (invalid hour)});

$value = 'D:200601021504';
ok(PDF::API2::_is_date($value), $value);

$value = 'D:20060102154';
ok(!PDF::API2::_is_date($value),
   qq{$value (missing leading zero)});

$value = 'D:200601021561';
ok(!PDF::API2::_is_date($value),
   qq{$value (invalid minute)});

$value = 'D:20060102150405';
ok(PDF::API2::_is_date($value), $value);

$value = 'D:2006010215045';
ok(!PDF::API2::_is_date($value),
   qq{$value (missing leading zero)});

$value = 'D:20060102150461';
ok(!PDF::API2::_is_date($value),
   qq{$value (invalid second)});

$value = 'D:20060102150405Z';
ok(PDF::API2::_is_date($value), $value);

$value = 'D:20060102150405-07';
ok(PDF::API2::_is_date($value), $value);

$value = 'D:20060102150405+07';
ok(PDF::API2::_is_date($value), $value);

$value = q{D:20060102150405-07'};
ok(PDF::API2::_is_date($value), $value);

$value = q{D:20060102150405-7'};
ok(!PDF::API2::_is_date($value),
   qq{$value (missing leading zero)});

$value = q{D:20060102150405-25};
ok(!PDF::API2::_is_date($value),
   qq{$value (invalid offset hour)});

$value = q{D:20060102150405+25'};
ok(!PDF::API2::_is_date($value),
   qq{$value (invalid offset hour)});

$value = q{D:20060102150405-07'00};
ok(PDF::API2::_is_date($value), $value);

$value = q{D:20060102150405+07'00};
ok(PDF::API2::_is_date($value), $value);

$value = q{D:20060102150405-07'00'};
ok(PDF::API2::_is_date($value),
   qq{$value (Adobe specification compatibility)});

$value = q{D:20060102150405+07'00'};
ok(PDF::API2::_is_date($value),
   qq{$value (Adobe specification compatibility)});

$value = q{D:20060102150405-071'};
ok(!PDF::API2::_is_date($value),
   qq{$value (missing leading zero)});

$value = q{D:20060102150405-0761};
ok(!PDF::API2::_is_date($value),
   qq{$value (invalid offset second)});

$value = q{D:20060102150405-0700};
ok(!PDF::API2::_is_date($value),
   qq{$value (apostrophe required between offset hour and minute)});

$value = q{D:20060102150405-0700'};
ok(!PDF::API2::_is_date($value),
   qq{$value (apostrophe required between offset hour and minute)});

done_testing();
