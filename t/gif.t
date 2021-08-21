use Test::More tests => 6;

use warnings;
use strict;

use PDF::API2;

# Filename

my $pdf = PDF::API2->new(-compress => 0);

my $gif = $pdf->image_gif('t/resources/1x1.gif');
isa_ok($gif, 'PDF::API2::Resource::XObject::Image::GIF',
       q{$pdf->image_gif(filename)});

is($gif->width(), 1,
   q{Image from filename has a width});

my $gfx = $pdf->page->gfx();
$gfx->image($gif, 72, 144, 216, 288);
like($pdf->to_string(), qr/q 216 0 0 288 72 144 cm \S+ Do Q/,
     q{Add GIF to PDF});

# Filehandle

$pdf = PDF::API2->new();
open my $fh, '<', 't/resources/1x1.gif';
$gif = $pdf->image($fh);
isa_ok($gif, 'PDF::API2::Resource::XObject::Image::GIF',
       q{$pdf->image(filehandle)});

is($gif->width(), 1,
   q{Image from filehandle has a width});

close $fh;

# Missing file

$pdf = PDF::API2->new();
eval { $pdf->image_gif('t/resources/this.file.does.not.exist') };
ok($@, q{Fail fast if the requested file doesn't exist});
