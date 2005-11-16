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

package PDF::API2::Resource::ColorSpace::Separation;

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

=item $cs = PDF::API2::Resource::ColorSpace::Separation->new $pdf, $key, %parameters

Returns a new colorspace object.

=cut

sub new {
    my ($class,$pdf,$key,@opts)=@_;
    my ($name,@clr)=@opts;
    
    $class = ref $class if ref $class;
    $self=$class->SUPER::new($pdf,$key,@opts);
    $pdf->new_obj($self) unless($self->is_obj($pdf));
    $self->{' apipdf'}=$pdf;

    my $fct=PDFDict();

    my $csname='DeviceRGB';
    $clr[0]=lc($clr[0]);
    $self->color(@clr);
    if($clr[0]=~/^[a-z\#\!]+/) {
        # colorname or #! specifier
        # with rgb target colorspace
        # namecolor returns always a RGB
        my ($r,$g,$b)=namecolor($clr[0]);

        $fct->{FunctionType}=PDFNum(0);
        $fct->{Size}=PDFArray(PDFNum(2));
        $fct->{Range}=PDFArray(map {PDFNum($_)} ($r,1,$g,1,$b,1));
        $fct->{Domain}=PDFArray(PDFNum(0),PDFNum(1));
        $fct->{BitsPerSample}=PDFNum(8);
        $fct->{' stream'}="\xff\xff\xff\x00\x00\x00";
    } elsif($clr[0]=~/^[\%]+/) {
        # % specifier
        # with cmyk target colorspace
        my ($c,$m,$y,$k)=namecolor_cmyk($clr[0]);
        $csname='DeviceCMYK';

        $fct->{FunctionType}=PDFNum(0);
        $fct->{Size}=PDFArray(PDFNum(2));
        $fct->{Range}=PDFArray(map {PDFNum($_)} (0,$c,0,$m,0,$y,0,$k));
        $fct->{Domain}=PDFArray(PDFNum(0),PDFNum(1));
        $fct->{BitsPerSample}=PDFNum(8);
        $fct->{' stream'}="\x00\x00\x00\x00\xff\xff\xff\xff";
    } elsif(scalar @clr == 1) {
        # grey color spec.
        while($clr[0]>1) { $clr[0]/=255; }
        # adjusted for 8/16/32bit spec.
        my $g=$clr[0];
        $csname='DeviceGray';

        $fct->{FunctionType}=PDFNum(0);
        $fct->{Size}=PDFArray(PDFNum(2));
        $fct->{Range}=PDFArray(map {PDFNum($_)} (0,$g));
        $fct->{Domain}=PDFArray(PDFNum(0),PDFNum(1));
        $fct->{BitsPerSample}=PDFNum(8);
        $fct->{' stream'}="\xff\x00";
    } elsif(scalar @clr == 3) {
        # legacy rgb color-spec (0 <= x <= 1)
        my ($r,$g,$b)=@clr;

        $fct->{FunctionType}=PDFNum(0);
        $fct->{Size}=PDFArray(PDFNum(2));
        $fct->{Range}=PDFArray(map {PDFNum($_)} ($r,1,$g,1,$b,1));
        $fct->{Domain}=PDFArray(PDFNum(0),PDFNum(1));
        $fct->{BitsPerSample}=PDFNum(8);
        $fct->{' stream'}="\xff\xff\xff\x00\x00\x00";
    } elsif(scalar @clr == 4) {
        # legacy cmyk color-spec (0 <= x <= 1)
        my ($c,$m,$y,$k)=@clr;
        $csname='DeviceCMYK';

        $fct->{FunctionType}=PDFNum(0);
        $fct->{Size}=PDFArray(PDFNum(2));
        $fct->{Range}=PDFArray(map {PDFNum($_)} (0,$c,0,$m,0,$y,0,$k));
        $fct->{Domain}=PDFArray(PDFNum(0),PDFNum(1));
        $fct->{BitsPerSample}=PDFNum(8);
        $fct->{' stream'}="\x00\x00\x00\x00\xff\xff\xff\xff";
    } else {
        die 'invalid color specification.';
    }
    $self->type($csname);
    $pdf->new_obj($fct);
    $self->add_elements(PDFName('Separation'), PDFName($name), PDFName($csname), $fct);
    $self->tintname($name);
    return($self);
}

=item $cs = PDF::API2::Resource::ColorSpace::Separation->new_api $api, $name

Returns a separation color-space object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},pdfkey(),@opts);
    $self->{' api'}=$api;

    return($obj);
}

=item @color = $res->color

Returns the base-color of the Separation-Colorspace.

=cut

sub color {
    my $self=shift @_;
    if(scalar @_ >0 && defined($_[0])) {
        $self->{' color'}=[@_];
    }
    return(@{$self->{' color'}});
}

=item $tintname = $res->tintname $tintname

Returns the tint-name of the Separation-Colorspace.

=cut

sub tintname {
    my $self=shift @_;
    if(scalar @_ >0 && defined($_[0])) {
        $self->{' tintname'}=[@_];
    }
    return(@{$self->{' tintname'}});
}


sub param {
    my $self=shift @_;
    return($_[0]);
}


1;

__END__

=head1 HISTORY

    $Log$
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

    Revision 1.6  2004/07/20 20:28:45  fredo
    added tintname accessor

    Revision 1.5  2004/07/15 14:14:16  fredo
    added type and color accessor

    Revision 1.4  2004/06/15 09:14:52  fredo
    removed cr+lf

    Revision 1.3  2004/06/07 19:44:43  fredo
    cleaned out cr+lf for lf

    Revision 1.2  2004/04/07 10:50:43  fredo
    fixed RGB semantics to match CMYK `tint´ behaviour

    Revision 1.1  2004/04/06 20:57:27  fredo
    separation colorspace promoted to full object

=cut
