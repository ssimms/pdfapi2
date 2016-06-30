#!perl

use strict;
use warnings;
use Test::More tests => 1;
use PDF::API2;
use PDF::API2::Basic::PDF::Dict;
$PDF::API2::Basic::PDF::Dict::mincache = 0;
my $target_file = 't/resources/xetex.pdf';
my $pdf = PDF::API2->open($target_file);
ok ($pdf, "$target_file read correctly (no crash)");
$pdf->end;
