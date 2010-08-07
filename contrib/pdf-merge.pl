#!/usr/bin/perl

use PDF::API2;

if(2 > scalar @ARGV) {
    print <<"EOT";
Usage: $0 <outfile> <infile1> ... <infileN>

merges serveral pdf files into on ;-)

cheers, 
fredo
EOT
}

my $outfile=shift @ARGV;

my $pdf=PDF::API2->new;

foreach my $in (@ARGV) {
    print STDERR 'loading file $in .';
    my $inpdf=PDF::API2->open($in);
    my $pages=scalar @{$inpdf->{pagestack}};
    foreach my $page (1..$pages) {
        print STDERR "$page.";
        $pdf->importpage($inpdf,$page);
    }
    $inpdf->end();
    print STDERR " done.\n";
}

$pdf->saveas($outfile);
