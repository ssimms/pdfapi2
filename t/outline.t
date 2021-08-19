use Test::More;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2->new(-compress => 0);
my $page1 = $pdf->page();
my $page2 = $pdf->page();

my $outlines = $pdf->outlines();
my $outline = $outlines->outline();
$outline->title('Test Outline');
$outline->dest($page2);

like($pdf->to_string, qr{/Dest \[ 6 0 R /XYZ null null null \] /Parent 7 0 R /Title \(Test Outline\)},
     q{Basic outline test});

$pdf = PDF::API2->new(compress => 0);
$page1 = $pdf->page();
$page2 = $pdf->page();
$outlines = $pdf->outlines();
$outline = $outlines->outline();
$outline->title('Test Outline');
$outline->dest($page2);

is($outlines->count(), 1,
   q{Outline tree has one entry});

$outline->delete();
is($outlines->count(), 0,
   q{Outline tree has no entries after sole entry is deleted});

ok(!$outlines->has_children(),
   q{has_children returns false when the sole item is deleted});

my $a = $outlines->outline();
my $b = $outlines->outline();
my $c = $outlines->outline();

$a->title('Test Outline');

is($outlines->count(), 3,
   q{Outline tree has three entries});

is($outlines->first(), $a,
   q{$outlines->first() returns the first item});

is($outlines->first->next(), $b,
   q{$outlines->first->next() returns the second item});

is($outlines->last(), $c,
   q{$outlines->last() returns the final item});

is($outlines->last->prev(), $b,
   q{$outlines->last->prev() returns the second item});

my $d = $a->outline();

is($outlines->count(), 4,
   q{Outline count includes grandchild});

my $e = $d->outline();

is($outlines->count(), 5,
   q{Outline count includes great-grandchild});

$d->is_open(0);

is($outlines->count(), 4,
   q{Outline count doesn't include children of closed children});

is($d->count(), 1,
   q{$outline->count() is still positive when closed});

$d->count();
is($d->{'Count'}->val(), -1,
   q{... but the Count key is negative when closed});

$pdf = PDF::API2->from_string($pdf->to_string());
$outlines = $pdf->outlines();

is($outlines->count(), 4,
   q{Opened PDF returns expected item count});

ok($outlines->first->is_open(),
   q{Opened PDF returns expected is_open result for open item});

ok(!$outlines->first->first->is_open(),
   q{Opened PDF returns expected is_open result for closed item});

is($outlines->first->title(), 'Test Outline',
   q{$outline->title() returns expected value from opened PDF});

done_testing();
