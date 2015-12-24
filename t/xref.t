#!perl
use warnings;
use strict;
use Test::More tests => 8;
use Data::Dumper;
use PDF::API2;
use File::Temp;
use File::Spec;

my $outdir = File::Temp->newdir(CLEANUP => 1);

foreach my $input ('HowToArgueEffectively.pdf', 'xref-test.pdf') {
    my $pdf = eval {
        PDF::API2->open(File::Spec->catfile(qw/t resources/, $input));
    };
    isa_ok($pdf, 'PDF::API2', qq{doc $input containing an XRef stream}) or diag $@;

    my $file = $pdf->{pdf};
    my $pass = 1;

    while (my($id, $xref) = each %{$file->{' xref'}}) {
        # skip free objects.
        if (@$xref == 3 and $xref->[2] eq 'f') {
            next;
        }
        my $obj = $file->read_objnum($id, $xref->[1]);
        unless (ref($obj)) {
            diag "$id => $xref->[1] not found";
            $pass = 0;
            last;
        }
    }
    my $page = 0;
    my $out = PDF::API2->new;
    while ($pdf->openpage(++$page)) {
        diag "Page $page ok";
        my $xo = $out->importPageIntoForm($pdf, $page);
        my $outpage = $out->page;
        my $gfx = $outpage->gfx;
        $gfx->formimage($xo, 30, 30);
    }
    my $outfile = File::Spec->catfile($outdir, $input);
    $out->saveas($outfile);
    ok ($page, "Found $page pages");
    ok (-f $outfile, "File saved as $outfile");
    ok($pass, "all XRef for $input entries point to an object");
}


