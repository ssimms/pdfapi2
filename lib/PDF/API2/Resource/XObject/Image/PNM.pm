package PDF::API2::Resource::XObject::Image::PNM;

# For spec details, see man pages pam(5), pbm(5), pgm(5), pnm(5),
# ppm(5), which were pasted into the __END__ of this file in an
# earlier revision.

use base 'PDF::API2::Resource::XObject::Image';

use strict;
no warnings qw[ deprecated recursion uninitialized ];

# VERSION

use IO::File;
use PDF::API2::Util;
use PDF::API2::Basic::PDF::Utils;
use Scalar::Util qw(weaken);

sub new {
    my ($class, $pdf, $file, $name) = @_;
    my $self;

    $class = ref($class) if ref($class);

    $self = $class->SUPER::new($pdf, $name || 'Nx' . pdfkey());
    $pdf->new_obj($self) unless $self->is_obj($pdf);

    $self->{' apipdf'} = $pdf;
    weaken $self->{' apipdf'};

    $self->read_pnm($pdf, $file);

    return $self;
}

# READPPMHEADER
# Originally from Image::PBMLib by Elijah Griffin (28 Feb 2003)
sub readppmheader {
    my $fh = shift();
    my $in = '';
    my $no_comments;
    my %info;
    my $rc;
    $info{'error'} = undef;

    $rc = read($fh, $in, 3);

    if (!defined($rc) or $rc != 3) {
        $info{'error'} = 'Read error or EOF';
        return \%info;
    }

    unless ($in =~ /^P([123456])\s/) {
        $info{'error'} = 'Wrong magic number';
        return \%info;
    }

    $info{'type'} = $1;
    if ($info{'type'} > 3) {
        $info{'raw'} = 1;
    }
    else {
        $info{'raw'} = 0;
    }

    if ($info{'type'} == 1 or $info{'type'} == 4) {
        $info{'max'} = 1;
        $info{'bgp'} = 'b';
    }
    elsif ($info{'type'} == 2 or $info{'type'} == 5) {
        $info{'bgp'} = 'g';
    }
    else {
        $info{'bgp'} = 'p';
    }

    while (1) {
        $rc = read($fh, $in, 1, length($in));
        if (!defined($rc) or $rc != 1) {
            $info{'error'} = 'Read error or EOF';
            return \%info;
        }

        $no_comments = $in;
        $info{'comments'} = '';
        while ($no_comments =~ /#.*\n/) {
            $no_comments =~ s/#(.*\n)/ /;
            $info{'comments'} .= $1;
        }

        if ($info{'bgp'} eq 'b') {
            if ($no_comments =~ /^P\d\s+(\d+)\s+(\d+)\s/) {
                $info{'width'}  = $1;
                $info{'height'} = $2;
                last;
            }
        }
        else {
            if ($no_comments =~ /^P\d\s+(\d+)\s+(\d+)\s+(\d+)\s/) {
                $info{'width'}  = $1;
                $info{'height'} = $2;
                $info{'max'}    = $3;
                last;
            }
        }
    } # while reading header

    $info{'fullheader'} = $in;

    return \%info;
}

sub read_pnm {
    my ($self, $pdf, $file) = @_;

    my ($buf, $t, $s, $line);
    my $bpc;
    my $cs;

    my $fh;
    if (ref($file)) {
        $fh = $file;
    }
    else {
        open $fh, '<', $file or die "$!: $file";
    }
    binmode($fh, ':raw');
    $fh->seek(0, 0);

    my $info = readppmheader($fh);
    if ($info->{'type'} == 4) { # PBM
        $bpc = 1;
        read($fh, $self->{' stream'}, ($info->{'width'} * $info->{'height'} / 8));
        $cs = 'DeviceGray';
        $self->{'Decode'} = PDFArray(PDFNum(1), PDFNum(0));
    }
    elsif ($info->{'type'} == 5) { # PGM
        if ($info->{'max'} == 255) {
            $s = 0;
        }
        else {
            $s = 255 / $info->{'max'};
        }
        $bpc = 8;
        if ($s > 0) {
            for ($line = ($info->{'width'} * $info->{'height'}); $line > 0; $line--) {
                read($fh, $buf, 1);
                $self->{' stream'} .= pack('C', (unpack('C', $buf) * $s));
            }
        }
        else {
            read($fh, $self->{' stream'}, $info->{'width'} * $info->{'height'});
        }
        $cs = 'DeviceGray';
    }
    elsif ($info->{'type'} == 6) { # PPM
        if ($info->{'max'} == 255) {
            $s = 0;
        }
        else {
            $s = 255 / $info->{'max'};
        }
        $bpc = 8;
        if ($s > 0) {
            for ($line = ($info->{'width'} * $info->{'height'}); $line > 0; $line--) {
                read($fh, $buf, 1);
                $self->{' stream'} .= pack('C', (unpack('C', $buf) * $s));
                read($fh, $buf, 1);
                $self->{' stream'} .= pack('C', (unpack('C', $buf) * $s));
                read($fh, $buf, 1);
                $self->{' stream'} .= pack('C', (unpack('C', $buf) * $s));
            }
        }
        else {
            read($fh, $self->{' stream'}, $info->{'width'} * $info->{'height'} * 3);
        }
        $cs = 'DeviceRGB';
    }
    close $fh;

    $self->width($info->{'width'});
    $self->height($info->{'height'});

    $self->bits_per_component($bpc);

    $self->filters('FlateDecode');

    $self->colorspace($cs);

    return $self;
}

1;
