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

package PDF::API2::Resource::ColorSpace::Indexed::Hue;

BEGIN {

    use strict;
    use PDF::API2::Resource::ColorSpace::Indexed;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Util;
    use POSIX;

    use vars qw(@ISA $VERSION);

    @ISA = qw( PDF::API2::Resource::ColorSpace::Indexed );

    ( $VERSION ) = '2.000';

}
no warnings qw[ deprecated recursion uninitialized ];

sub new {
    my ($class,$pdf)=@_;

    $class = ref $class if ref $class;
    $self=$class->SUPER::new($pdf,pdfkey());
    $pdf->new_obj($self) unless($self->is_obj($pdf));
    $self->{' apipdf'}=$pdf;
    my $csd=PDFDict();
    $pdf->new_obj($csd);
    $csd->{Filter}=PDFArray(PDFName('FlateDecode'));

    ## $csd->{WhitePoint}=PDFArray(map { PDFNum($_) } (0.95049, 1, 1.08897));
    ## $csd->{BlackPoint}=PDFArray(map { PDFNum($_) } (0, 0, 0));
    ## $csd->{Gamma}=PDFArray(map { PDFNum($_) } (2.22218, 2.22218, 2.22218));

    $csd->{' stream'}='';

    my %cc=();

    foreach my $s (4,3,2,1) {
        foreach my $v (4,3) {
            foreach my $r (0..31) {
                $csd->{' stream'}.=pack('CCC',map { $_*255 } namecolor('!'.sprintf('%02X',$r*255/31).sprintf('%02X',$s*255/4).sprintf('%02X',$v*255/4)));
            }
        }
    }

    $csd->{' stream'}.="\x00" x 768;
    $csd->{' stream'}=substr($csd->{' stream'},0,768);

    $self->add_elements(PDFName('DeviceRGB'),PDFNum(255),$csd);
    $self->{' csd'}=$csd;

    return($self);
}

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $self->{' api'}=$api;

    return($obj);
}

1;
