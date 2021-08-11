use Test::More tests => 1;

use strict;
use warnings;

use PDF::API2;

# Create a PDF with an empty page
my $empty_page_pdf = PDF::API2->new();
my $page = $empty_page_pdf->page();
$page->mediabox('Letter');

# Save and reopen the PDF
$empty_page_pdf = PDF::API2->from_string($empty_page_pdf->to_string());

my $container_pdf = PDF::API2->new();

# This dies through version 2.025.
eval {
    $container_pdf->importPageIntoForm($empty_page_pdf, 1);
};
ok(!$@, q{Calling importPageIntoForm using an empty page doesn't result in a crash});
