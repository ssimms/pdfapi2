use Test::More tests => 3;

use strict;
use warnings;

use PDF::API2;

my $pdf = PDF::API2->new();
$pdf->preferences(-simplex => 1);
like($pdf->to_string(), qr{/ViewerPreferences << [^>]*?/Duplex /Simplex}, q{Duplex => Simplex});

$pdf = PDF::API2->new();
$pdf->preferences(-duplexfliplongedge => 1);
like($pdf->to_string(), qr{/ViewerPreferences << [^>]*?/Duplex /DuplexFlipLongEdge}, q{Duplex => DuplexFlipLongEdge});

$pdf = PDF::API2->new();
$pdf->preferences(-duplexflipshortedge => 1);
like($pdf->to_string(), qr{/ViewerPreferences << [^>]*?/Duplex /DuplexFlipShortEdge}, q{Duplex => DuplexFlipShortEdge});
