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
    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$

}
no warnings qw[ deprecated recursion uninitialized ];

=item $cs = PDF::API2::Resource::ColorSpace::Indexed->new $pdf, $key, %parameters

Returns a new colorspace object.

=cut

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

=item $cs = PDF::API2::Resource::ColorSpace::Indexed->new_api $api, $name

Returns a indexed color-space object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

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

=head1 HISTORY

    $Log$
    Revision 2.0  2005/11/16 02:18:14  areibens
    revision workaround for SF cvs import not to screw up CPAN

    Revision 1.2  2005/11/16 01:27:50  areibens
    genesis2

    Revision 1.1  2005/11/16 01:19:27  areibens
    genesis

    Revision 1.10  2005/06/17 19:44:03  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.9  2005/06/17 18:53:34  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.8  2005/03/14 22:01:27  fredo
    upd 2005

    Revision 1.7  2004/12/16 00:30:53  fredo
    added no warn for recursion

    Revision 1.6  2004/07/15 14:13:46  fredo
    added type accessor

    Revision 1.5  2004/06/15 09:14:52  fredo
    removed cr+lf

    Revision 1.4  2004/06/07 19:44:43  fredo
    cleaned out cr+lf for lf

    Revision 1.3  2003/12/08 13:06:01  Administrator
    corrected to proper licencing statement

    Revision 1.2  2003/11/30 17:32:48  Administrator
    merged into default

    Revision 1.1.1.1.2.2  2003/11/30 16:57:02  Administrator
    merged into default

    Revision 1.1.1.1.2.1  2003/11/30 14:29:03  Administrator
    added CVS id/log


=cut

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

