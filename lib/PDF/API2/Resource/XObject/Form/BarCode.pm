package PDF::API2::Resource::XObject::Form::BarCode;

# VERSION

use base 'PDF::API2::Resource::XObject::Form::Hybrid';

use PDF::API2::Util;
use PDF::API2::Basic::PDF::Utils;

no warnings qw[ deprecated recursion uninitialized ];

=head1 NAME

PDF::API2::Resource::XObject::Form::BarCode - Base class for one-dimensional barcodes

=head1 METHODS

=over

=item $barcode = PDF::API2::Resource::XObject::Form::BarCode->new($pdf, %options)

Creates a barcode form resource.

=cut

sub new {
    my ($class, $pdf, %options) = @_;
    my $self = $class->SUPER::new($pdf);

    $self->{' bfont'} = $options{'-font'};

    $self->{' umzn'} = $options{'-umzn'} || 0;    # (u)pper (m)ending (z)o(n)e
    $self->{' lmzn'} = $options{'-lmzn'} || 0;    # (l)ower (m)ending (z)o(n)e
    $self->{' zone'} = $options{'-zone'} || 0;
    $self->{' quzn'} = $options{'-quzn'} || 0;    # (qu)iet (z)o(n)e
    $self->{' ofwt'} = $options{'-ofwt'} || 0.01; # (o)ver(f)low (w)id(t)h
    $self->{' fnsz'} = $options{'-fnsz'};         # (f)o(n)t(s)i(z)e
    $self->{' spcr'} = $options{'-spcr'} || '';

    return $self;
}

# Deprecated (rolled into new)
sub new_api { my $self = shift(); return $self->new(@_); }

my %bar_widths=(
     0 => 0,
     1 => 1, 'a' => 1, 'A' => 1,
     2 => 2, 'b' => 2, 'B' => 2,
     3 => 3, 'c' => 3, 'C' => 3,
     4 => 4, 'd' => 4, 'D' => 4,
     5 => 5, 'e' => 5, 'E' => 5,
     6 => 6, 'f' => 6, 'F' => 6,
     7 => 7, 'g' => 7, 'G' => 7,
     8 => 8, 'h' => 8, 'H' => 8,
     9 => 9, 'i' => 9, 'I' => 9,
);

sub encode {
    my ($self, $string) = @_;
    my @bars = map { [ $self->encode_string($_), $_ ] } split //, $string;
    return @bars;
}

sub encode_string {
    my ($self, $string) = @_;

    my $bar;
    foreach my $character (split //, $string) {
        $bar .= $self->encode_char($character);
    }
    return $bar;
}

sub drawbar {
    my $self = shift();
    my @bar = @{shift()};
    my $bartext = shift();

    my $x = $self->{' quzn'};
    my ($code, $str, $f, $t, $l, $h, $xo);
    $self->fillcolor('black');
    $self->strokecolor('black');

    my $bw = 1;
    foreach my $b (@bar) {
        if (ref($b)) {
            ($code, $str) = @{$b};
        }
        else {
            $code = $b;
            $str = undef;
        }

        $xo = 0;
        foreach my $c (split //, $code) {
            my $w = $bar_widths{$c};
            $xo += $w / 2;
            if ($c =~ /[0-9]/) {
                $l = $self->{' quzn'} + $self->{' lmzn'};
                $h = $self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'};
                $t = $self->{' quzn'};
                $f = $self->{' fnsz'} || $self->{' lmzn'};
            }
            elsif ($c =~ /[a-z]/) {
                $l = $self->{' quzn'};
                $h = $self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'};
                $t = $self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'};
                $f = $self->{' fnsz'} || $self->{' umzn'};
            }
            elsif ($c =~ /[A-Z]/) {
                $l = $self->{' quzn'};
                $h = $self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'};
                $f = $self->{' fnsz'} || $self->{' umzn'};
                $t = $self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'} - $f;
            }
            else {
                $l = $self->{' quzn'} + $self->{' lmzn'};
                $h = $self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'};
                $t = $self->{' quzn'};
                $f = $self->{' fnsz'} || $self->{' lmzn'};
            }

            if ($bw) {
                unless ($c eq '0') {
                    $self->linewidth($w - $self->{' ofwt'});
                    $self->move($x + $xo, $l);
                    $self->line($x + $xo, $h);
                    $self->stroke();
                }
                $bw = 0;
            }
            else {
                $bw = 1;
            }
            $xo += $w / 2;
        }

        if (defined($str) and $self->{' lmzn'}) {
            $str = join($self->{' spcr'}, split //, $str);
            $self->textstart();
            $self->translate($x + ($xo / 2), $t);
            $self->font($self->{' bfont'}, $f);
            $self->text_center($str);
            $self->textend();
        }
        $x += $xo;
    }
    if (defined $bartext) {
        $f = $self->{' fnsz'} || $self->{' lmzn'};
        $t = $self->{' quzn'} - $f;
        $self->textstart();
        $self->translate(($self->{' quzn'} + $x) / 2, $t);
        $self->font($self->{' bfont'}, $f);
        $self->text_center($bartext);
        $self->textend();
    }
    $self->{' w'} = $self->{' quzn'} + $x;
    $self->{' h'} = 2 * $self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'};
    $self->{'BBox'} = PDFArray(PDFNum(0), PDFNum(0), PDFNum($self->{' w'}), PDFNum($self->{' h'}));
}

=item $width = $barcode->width()

=cut

sub width {
    my $self = shift();
    return $self->{' w'};
}

=item $height = $barcode->height()

=cut

sub height {
    my $self = shift();
    return $self->{' h'};
}

=back

=cut

1;
