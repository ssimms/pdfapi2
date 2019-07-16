use Test::More;

use PDF::API2;

my $pdf = PDF::API2->new();
my $corefont = $pdf->corefont('Helvetica', -encode => 'iso-8859-1')->tounicodemap();
my $block1   = $pdf->corefont('Helvetica', -encode => 'uni1');
my $unifont  = $pdf->unifont($corefont, [$block1, [1]], -encode => 'utf-8');

my $page = $pdf->page();
$page->mediabox('letter');

my $text = $page->text();
$text->font($unifont, 12);

my $reset = $text->{' stream'};

$text->transform(-translate => [100, 100]);
$text->text_center("test");
my $value = $text->{' stream'};
like($value, qr/\[ \d+ \(test\) \] TJ/,
     q{Centered text is offset when it doesn't contain any special characters});

$text->{' stream'} = $reset;
$text->transform(-translate => [100, 100]);
$text->text_center("test\x{151}");
$value = $text->{' stream'};
like($value, qr/\[ \d+ \(test\) \] TJ \/\S+ \d+ Tf \(Q\) Tj/,
     q{Centered text is offset when it contains special characters});

done_testing();
