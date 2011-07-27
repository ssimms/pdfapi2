use Test::More tests => 1;

use warnings;
use strict;

use PDF::API2;

# Translate

my $pdf = PDF::API2->new();
$pdf->{forcecompress} = 0;
my $page = $pdf->page();

my $annotation = $page->annotation();
$annotation->text('This is an annotation', -rect => [ 72, 144, 172, 244 ]);

# Note: Annotation currently uses UTF-8 whenever possible, which is
# why the Contents section doesn't just have the simple text.  I think
# it would be better to only use UTF-8 when necessary.
like($pdf->stringify(),
     qr{/Annot /Subtype /Text /Rect \[ 72 144 172 244 \] /Contents <FEFF005400680069007300200069007300200061006E00200061006E006E006F0074006100740069006F006E>},
     q{Text Annotation in a rectangle});
