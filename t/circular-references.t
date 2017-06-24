use Test::More tests => 1;

use PDF::API2;
use Test::Memory::Cycle;

# RT #56681: Devel::Cycle throws spurious warnings since 5.12
local $SIG{'__WARN__'} = sub { warn $_[0] unless $_[0] =~ /Unhandled type: GLOB/ };

my $pdf = PDF::API2->open('t/resources/sample.pdf');

memory_cycle_ok($pdf,
                q{Open sample.pdf});
