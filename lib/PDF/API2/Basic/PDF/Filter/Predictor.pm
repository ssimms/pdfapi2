package PDF::API2::Basic::PDF::Filter::Predictor;

our $VERSION = '2.023.1'; # VERSION

use base 'PDF::API2::Basic::PDF::Filter';

use strict;
no warnings qw[ deprecated recursion uninitialized ];

use PDF::API2::Basic::PDF::Utils;
use POSIX qw(ceil floor);

# This does not behave like the other filters, as it needs access to the
# source object.
sub new {
    my ($class, $obj) = @_;

    my $self = {object => $obj};
    bless $self, $class;
}

sub outfilt {
    my ($self) = @_;

    die 'The "outfilt" method is not implemented';
}

sub infilt {
    my ($self) = @_;

    # Decompress.
    my $obj = $self->{object};
    $obj->read_stream if $obj->{' nofilt'};

    my $param     = $obj->{DecodeParms};
    my $predictor = defined $param->{Predictor} ? $param->{Predictor}->val : 0;

    return $obj->{' stream'} unless $predictor > 1;

    # Then de-predict.
    if ($predictor == 2) {
        $self->_depredict_tiff;
    } elsif ($predictor >= 10 && $predictor <= 15) {
        $self->_depredict_png;
    } else {
        die "Invalid predictor: $predictor";
    }

    delete $param->{Alpha};
    delete $param->{Height};

    return $obj->{' stream'};
}

sub _paeth_predictor {
    my ($a, $b, $c)=@_;
    my $p = $a + $b - $c;
    my $pa = abs($p - $a);
    my $pb = abs($p - $b);
    my $pc = abs($p - $c);
    if(($pa <= $pb) && ($pa <= $pc)) {
        return $a;
    } elsif($pb <= $pc) {
        return $b;
    } else {
        return $c;
    }
}

sub _depredict_png {
    my ($self) = @_;

    my $obj = $self->{object};

    my $param  = $obj->{DecodeParms};
    my $stream = $obj->{' stream'};

    $param->{Alpha}            = PDFNum(0) unless $param->{Alpha};
    $param->{BitsPerComponent} = PDFNum(8) unless $param->{BitsPerComponent};
    $param->{Colors}           = PDFNum(1) unless $param->{Colors};
    $param->{Columns}          = PDFNum(1) unless $param->{Columns};
    $param->{Height}           = PDFNum(0) unless $param->{Height};

    my $alpha   = $param->{Alpha}->val;
    my $bpc     = $param->{BitsPerComponent}->val;
    my $colors  = $param->{Colors}->val;
    my $columns = $param->{Columns}->val;
    my $height  = $param->{Height}->val;

    my $comp     = $colors + $alpha;
    my $bpp      = ceil($bpc * $comp / 8);
    my $scanline = 1 + ceil($bpp * $columns);

    my $prev='';
    my $clearstream='';
    my $lastrow=($height||(length($stream)/$scanline))-1;
    foreach my $n (0..$lastrow) {
        # print STDERR "line $n:";
        my $line=substr($stream,$n*$scanline,$scanline);
        my $filter=vec($line,0,8);
        my $clear='';
        $line=substr($line,1);
        # print STDERR " filter=$filter";
        if($filter==0) {
            $clear=$line;
        } elsif($filter==1) {
            foreach my $x (0..length($line)-1) {
                vec($clear,$x,8)=(vec($line,$x,8)+vec($clear,$x-$bpp,8))%256;
            }
        } elsif($filter==2) {
            foreach my $x (0..length($line)-1) {
                vec($clear,$x,8)=(vec($line,$x,8)+vec($prev,$x,8))%256;
            }
        } elsif($filter==3) {
            foreach my $x (0..length($line)-1) {
                vec($clear,$x,8)=(vec($line,$x,8)+floor((vec($clear,$x-$bpp,8)+vec($prev,$x,8))/2))%256;
            }
        } elsif($filter==4) {
            # die "paeth/png filter not supported.";
            foreach my $x (0..length($line)-1) {
                vec($clear,$x,8)=(vec($line,$x,8)+_paeth_predictor(vec($clear,$x-$bpp,8),vec($prev,$x,8),vec($prev,$x-$bpp,8)))%256;
            }
        }
        $prev=$clear;
        foreach my $x (0..($columns*$comp)-1) {
            vec($clearstream,($n*$columns*$comp)+$x,$bpc)=vec($clear,$x,$bpc);
        #    print STDERR "".vec($clear,$x,$bpc).",";
        }
        # print STDERR "\n";
    }

    $obj->{' stream'} = $clearstream;
}

sub _depredict_tiff {
    my ($self) = @_;

    die "The TIFF predictor logic has not been implemented";
}

1;

