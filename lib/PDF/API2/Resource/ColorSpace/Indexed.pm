#=======================================================================
#    ____  ____  _____              _    ____ ___   ____
#   |  _ \|  _ \|  ___|  _   _     / \  |  _ \_ _| |___ \
#   | |_) | | | | |_    (_) (_)   / _ \ | |_) | |    __) |
#   |  __/| |_| |  _|    _   _   / ___ \|  __/| |   / __/
#   |_|   |____/|_|     (_) (_) /_/   \_\_|  |___| |_____|
#
#   A Perl Module Chain to faciliate the Creation and Modification
#   of High-Quality "Portable Document Format (PDF)" Files.
#
#   Copyright 1999-2005 Alfred Reibenschuh <areibens@cpan.org>.
#
#=======================================================================
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU Lesser General Public
#   License as published by the Free Software Foundation; either
#   version 2 of the License, or (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   Lesser General Public License for more details.
#
#   You should have received a copy of the GNU Lesser General Public
#   License along with this library; if not, write to the
#   Free Software Foundation, Inc., 59 Temple Place - Suite 330,
#   Boston, MA 02111-1307, USA.
#
#   $Id$
#
#=======================================================================

package PDF::API2::Resource::ColorSpace::Indexed;

BEGIN {

    use strict;
    use vars qw(@ISA $VERSION);
    use PDF::API2::Resource::ColorSpace;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Util;
    use Math::Trig;

    @ISA = qw( PDF::API2::Resource::ColorSpace );
    ( $VERSION ) = '2.000';

}
no warnings qw[ deprecated recursion uninitialized ];

sub new {
    my ($class,$pdf,$key,%opts)=@_;

    $class = ref $class if ref $class;
    $self=$class->SUPER::new($pdf,$key,%opts);
    $pdf->new_obj($self) unless($self->is_obj($pdf));
    $self->{' apipdf'}=$pdf;

    $self->add_elements(PDFName('Indexed'));
    $self->type('Indexed');
    
    return($self);
}

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $self->{' api'}=$api;

    return($obj);
}

sub enumColors {
    my $self=shift @_;
    my %col=();
    foreach my $n (0..255) {
        my $k='#'.uc(unpack('H*',substr($self->{' csd'}->{' stream'},$n*3,3)));
        $col{$k}=$n unless(defined $col{$k});
    }
    return(%col);
}

sub nameColor {
    my $self=shift @_;
    my $n=shift @_;
    my %col=();
    my $k='#'.uc(unpack('H*',substr($self->{' csd'}->{' stream'},$n*3,3)));
    return($k);
}

sub resolveNearestRGB {
    my $self=shift @_;
    my ($r,$g,$b)=@_; # need to be in 0-255
    my $c=0;
    my $w=768**2;
    foreach my $n (0..255) {
        my @e=unpack('C*',substr($self->{' csd'}->{' stream'},$n*3,3));
        my $d=($e[0]-$r)**2 + ($e[1]-$g)**2 + ($e[2]-$b)**2;
        if($d<$w) { $c=$n; $w=$d; }
    }
    return($c);
}

1;

__END__

} elsif($opts{-type} eq 'Indexed') {

$opts{-base}||='DeviceRGB';
$opts{-whitepoint}||=[ 0.95049, 1, 1.08897 ];
$opts{-blackpoint}||=[ 0, 0, 0 ];
$opts{-gamma}||=[ 2.22218, 2.22218, 2.22218 ];

#       my $csd=PDFDict();
#       $csd->{WhitePoint}=PDFArray(map {PDFNum($_)} @{$opts{-whitepoint}});
#       $csd->{BlackPoint}=PDFArray(map {PDFNum($_)} @{$opts{-blackpoint}});
#       $csd->{Gamma}=PDFArray(map {PDFNum($_)} @{$opts{-gamma}});

my $csd=PDFDict();
$pdf->new_obj($csd);
$csd->{Filter}=PDFArray(PDFName('FlateDecode'));
$self->{' index'}=[];

if(defined $opts{-actfile}) {
} elsif(defined $opts{-acofile}) {
} elsif(defined $opts{-colors}) {
$opts{-maxindex}||=scalar(@{$opts{-colors}})-1;

foreach my $col (@{$opts{-colors}}) {
map { $csd->{' stream'}.=pack('C',$_); } @{$col};
}

foreach my $col (0..$opts{-maxindex}) {
if($opts{-base}=~/RGB/i) {
my $r=(shift(@{$opts{-colors}})||0)/255;
my $g=(shift(@{$opts{-colors}})||0)/255;
my $b=(shift(@{$opts{-colors}})||0)/255;
push(@{$self->{' index'}},[$r,$g,$b]);
} elsif($opts{-base}=~/CMYK/i) {
my $c=(shift(@{$opts{-colors}})||0)/255;
my $m=(shift(@{$opts{-colors}})||0)/255;
my $y=(shift(@{$opts{-colors}})||0)/255;
my $k=(shift(@{$opts{-colors}})||0)/255;
push(@{$self->{' index'}},[$c,$m,$y,$k]);
}
}
} else {
die "unspecified color index table.";
}

    $self->add_elements(PDFName('Indexed'),PDFName($opts{-base}),PDFNum($opts{-maxindex}),$csd);

$self->{' type'}='index-'.(
$opts{-base}=~/RGB/i ? 'rgb' :
$opts{-base}=~/CMYK/i ? 'cmyk' : 'unknown'
);

