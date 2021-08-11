#!/usr/bin/perl

use strict;
use warnings;

use PDF::API2;

unless (scalar @ARGV >= 3) {
    print qq{Usage: $0 <input1.pdf> <input2.pdf> ... <output.pdf>

Combine all pages from the input PDF files into a single output PDF file.
};
    exit;
}

my $output_file = pop(@ARGV);

my $output_pdf = PDF::API2->new();

foreach my $input_file (@ARGV) {
    print "Loading $input_file:";
    my $input_pdf = PDF::API2->open($input_file);
    foreach my $page_number (1 .. $input_pdf->pages()) {
        print " $page_number,";
        $output_pdf->import_page($input_pdf, $page_number);
    }
    $input_pdf->close();
    print " Done.\n\n";
}

print "Writing $output_file\n";
$output_pdf->save($output_file);
