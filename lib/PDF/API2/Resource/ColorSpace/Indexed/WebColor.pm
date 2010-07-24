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

package PDF::API2::Resource::ColorSpace::Indexed::WebColor;

BEGIN {

    use strict;
    use vars qw(@ISA $VERSION);
    use PDF::API2::Resource::ColorSpace::Indexed;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Util;
    use POSIX;

    @ISA = qw( PDF::API2::Resource::ColorSpace::Indexed );

    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$

}
no warnings qw[ deprecated recursion uninitialized ];

=item $cs = PDF::API2::Resource::ColorSpace::Indexed::WebColor->new $pdf

Returns a new colorspace object created from the web color palette.

=cut

sub new {
    my ($class,$pdf)=@_;

    $class = ref $class if ref $class;
    $self=$class->SUPER::new($pdf,pdfkey());
    $pdf->new_obj($self) unless($self->is_obj($pdf));
    $self->{' apipdf'}=$pdf;
    my $csd=PDFDict();
    $pdf->new_obj($csd);
    $csd->{Filter}=PDFArray(PDFName('ASCIIHexDecode'));

    $csd->{WhitePoint}=PDFArray(map {PDFNum($_)} (0.95049, 1, 1.08897));
    $csd->{BlackPoint}=PDFArray(map {PDFNum($_)} (0, 0, 0));
    $csd->{Gamma}=PDFArray(map {PDFNum($_)} (2.22218, 2.22218, 2.22218));

    $csd->{' stream'}='';

    my %cc=();

    foreach my $r (0,0x33,0x66,0x99,0xCC,0xFF) {
        foreach my $g (0,0x33,0x66,0x99,0xCC,0xFF) {
            foreach my $b (0,0x33,0x66,0x99,0xCC,0xFF) {
                $csd->{' stream'}.=pack('CCC',$r,$g,$b);
                $cc{sprintf('%02X%02X%02X',$r,$g,$b)}=1;
            }
        }
    } # 0-215

    foreach my $r (0,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0xAA,0xBB,0xCC,0xDD,0xEE,0xFF) {
        $csd->{' stream'}.=pack('CCC',$r,$r,$r);
    } # 216-231
    foreach my $r (0,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0xAA,0xBB,0xCC,0xDD,0xEE,0xFF) {
        $csd->{' stream'}.=pack('CCC',map { $_*255 } namecolor('!'.sprintf('%02X',$r).'FFFF'));
    } # 232-247
    foreach my $r (0,0x22,0x44,0x66,0x88,0xAA,0xCC,0xEE) {
        $csd->{' stream'}.=pack('CCC',map { $_*255 } namecolor('!'.sprintf('%02X',$r).'FF99'));
    } # 232-247

    $csd->{' stream'}.="\x00" x 768;
    $csd->{' stream'}=substr($csd->{' stream'},0,768);

    $self->add_elements(PDFName('DeviceRGB'),PDFNum(255),$csd);
    $self->{' csd'}=$csd;

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

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=cut
