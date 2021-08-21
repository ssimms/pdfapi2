use Test::More tests => 9;

use warnings;
use strict;

use PDF::API2;

# Filename

my $pdf = PDF::API2->new(-compress => 0);

my $png = $pdf->image_png('t/resources/1x1.png');
isa_ok($png, 'PDF::API2::Resource::XObject::Image::PNG',
       q{$pdf->image_png(filename)});

is($png->width(), 1,
   q{Image from filename has a width});

my $gfx = $pdf->page->gfx();
$gfx->image($png, 72, 144, 216, 288);
like($pdf->to_string(), qr/q 216 0 0 288 72 144 cm \S+ Do Q/,
     q{Add PNG to PDF});

# RGBA PNG file

$pdf = PDF::API2->new();

$png = $pdf->image_png('t/resources/test-rgba.png');
isa_ok($png, 'PDF::API2::Resource::XObject::Image::PNG',
       q{$pdf->image_png(filename)});

my $page = $pdf->page();
$page->mediabox(840,600);
$gfx=$page->gfx;
$gfx->image($png,134,106,510,281);
my $rgba1_pdf_string = $pdf->to_string();

# RGBA PNG file Pure Perl

$ENV{'PDFAPI2_PNG_PP'} = 1;
$pdf = PDF::API2->new();
my $png2 = $pdf->image_png('t/resources/test-rgba.png');
isa_ok($png2, 'PDF::API2::Resource::XObject::Image::PNG',
       q{$pdf->image_png(filename)});

my $page2 = $pdf->page();
$page2->mediabox(840,600);
my $gfx2=$page2->gfx;
$gfx2->image($png2,134,106,510,281);
my $rgba2_pdf_string = $pdf->to_string();
delete $ENV{'PDFAPI2_PNG_PP'};

is(substr($rgba1_pdf_string, 0, 512), substr($rgba2_pdf_string, 0, 512),
     q{XS and pure perl PDFs are the same});

# Filehandle

$pdf = PDF::API2->new();
open my $fh, '<', 't/resources/1x1.png';
$png = $pdf->image($fh);
isa_ok($png, 'PDF::API2::Resource::XObject::Image::PNG',
       q{$pdf->image(filehandle)});

is($png->width(), 1,
   q{Image from filehandle has a width});

close $fh;

# Missing file

$pdf = PDF::API2->new();
eval { $pdf->image_png('t/resources/this.file.does.not.exist') };
ok($@, q{Fail fast if the requested file doesn't exist});
