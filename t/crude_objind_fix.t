use Test::More tests => 2;

use warnings;
use strict;

use PDF::API2;

my $pdf = PDF::API2::Basic::PDF::File->new;

# I don't know enough to make a good example, but this reproduces the issue
# I've had in a real PDF:

my $page = PDF::API2::Basic::PDF::Pages->new($pdf,  PDF::API2::Basic::PDF::Objind->new);
$page->{Parent} = PDF::API2::Basic::PDF::Objind->new;
my $rv;
eval{$rv = $page->find_prop("something")};
ok( ! $@, 'Did not explode') or diag($@);
ok( ! $rv, 'Did opt get anything back');
