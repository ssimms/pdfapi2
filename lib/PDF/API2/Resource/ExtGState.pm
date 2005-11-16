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

package PDF::API2::Resource::ExtGState;

BEGIN {

    use strict;
    use PDF::API2::Resource;
    use PDF::API2::Basic::PDF::Utils;
    use Math::Trig;
    use PDF::API2::Util;
    use vars qw(@ISA $VERSION);

    @ISA = qw(PDF::API2::Resource);

    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$

}
no warnings qw[ deprecated recursion uninitialized ];

=item $egs = PDF::API2::Resource::ExtGState->new @parameters

Returns a new extgstate object (called from $pdf->extgstate).

=cut

sub new {
    my ($class,$pdf,$key)=@_;
    my $self = $class->SUPER::new($pdf,$key);
    $self->{Type}=PDFName('ExtGState');
    return($self);
}

=item $font = PDF::API2::Resource::ExtGState->new_api $api, $name

Returns a egstate-font object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $self->{' api'}=$api;

    return($obj);
}

=item $egs->strokeadjust $boolean

=cut

sub strokeadjust {
    my ($self,$var)=@_;
    $self->{SA}=PDFBool($var);
    return($self);
}

=item $egs->strokeoverprint $boolean

=cut

sub strokeoverprint {
    my ($self,$var)=@_;
    $self->{OP}=PDFBool($var);
    return($self);
}

=item $egs->filloverprint $boolean

=cut

sub filloverprint {
    my ($self,$var)=@_;
    $self->{op}=PDFBool($var);
    return($self);
}

=item $egs->overprintmode $num

=cut

sub overprintmode {
    my ($self,$var)=@_;
    $self->{OPM}=PDFNum($var);
    return($self);
}

=item $egs->blackgeneration $obj

=cut

sub blackgeneration {
    my ($self,$obj)=@_;
    $self->{BG}=$obj;
    return($self);
}

=item $egs->blackgeneration2 $obj

=cut

sub blackgeneration2 {
    my ($self,$obj)=@_;
    $self->{BG2}=$obj;
    return($self);
}

=item $egs->undercolorremoval $obj

=cut

sub undercolorremoval {
    my ($self,$obj)=@_;
    $self->{UCR}=$obj;
    return($self);
}

=item $egs->undercolorremoval2 $obj

=cut

sub undercolorremoval2 {
    my ($self,$obj)=@_;
    $self->{UCR2}=$obj;
    return($self);
}

=item $egs->transfer $obj

=cut

sub transfer {
    my ($self,$obj)=@_;
    $self->{TR}=$obj;
    return($self);
}

=item $egs->transfer2 $obj

=cut

sub transfer2 {
    my ($self,$obj)=@_;
    $self->{TR2}=$obj;
    return($self);
}

=item $egs->halftone $obj

=cut

sub halftone {
    my ($self,$obj)=@_;
    $self->{HT}=$obj;
    return($self);
}

=item $egs->halftonephase $obj

=cut

sub halftonephase {
    my ($self,$obj)=@_;
    $self->{HTP}=$obj;
    return($self);
}

=item $egs->smoothness $num

=cut

sub smoothness {
    my ($self,$var)=@_;
    $self->{SM}=PDFNum($var);
    return($self);
}

=item $egs->font $font, $size

=cut

sub font {
    my ($self,$font,$size)=@_;
    $self->{Font}=PDFArray(PDFName($font->{' apiname'}),PDFNum($size));
    return($self);
}

=item $egs->linewidth $size

=cut

sub linewidth {
    my ($self,$var)=@_;
    $self->{LW}=PDFNum($var);
    return($self);
}

=item $egs->linecap $cap

=cut

sub linecap {
    my ($self,$var)=@_;
    $self->{LC}=PDFNum($var);
    return($self);
}

=item $egs->linejoin $join

=cut

sub linejoin {
    my ($self,$var)=@_;
    $self->{LJ}=PDFNum($var);
    return($self);
}

=item $egs->meterlimit $limit

=cut

sub meterlimit {
    my ($self,$var)=@_;
    $self->{ML}=PDFNum($var);
    return($self);
}

=item $egs->dash @dash

=cut

sub dash {
    my ($self,@dash)=@_;
    $self->{ML}=PDFArray( map { PDFNum($_); } @dash );
    return($self);
}

=item $egs->flatness $flat

=cut

sub flatness {
    my ($self,$var)=@_;
    $self->{FL}=PDFNum($var);
    return($self);
}

=item $egs->renderingintent $intentName

=cut

sub renderingintent {
    my ($self,$var)=@_;
    $self->{FL}=PDFName($var);
    return($self);
}

=item $egs->strokealpha $alpha

The current stroking alpha constant, specifying the
constant shape or constant opacity value to be used
for stroking operations in the transparent imaging model.

=cut

sub strokealpha {
    my ($self,$var)=@_;
    $self->{CA}=PDFNum($var);
    return($self);
}

=item $egs->fillalpha $alpha

Same as strokealpha, but for nonstroking operations.

=cut

sub fillalpha {
    my ($self,$var)=@_;
    $self->{ca}=PDFNum($var);
    return($self);
}

=item $egs->blendmode $blendname

=item $egs->blendmode $blendfunctionobj

The current blend mode to be used in the transparent
imaging model.

=cut

sub blendmode {
    my ($self,$var)=@_;
    if(ref($var)) {
        $self->{BM}=$var;
    } else {
        $self->{BM}=PDFName($var);
    }
    return($self);
}

=item $egs->alphaisshape $boolean

The alpha source flag (alpha is shape), specifying
whether the current soft mask and alpha constant
are to be interpreted as shape values (true) or
opacity values (false).

=cut

sub alphaisshape {
    my ($self,$var)=@_;
    $self->{AIS}=PDFBool($var);
    return($self);
}

=item $egs->textknockout $boolean

The text knockout flag, which determines the behavior
of overlapping glyphs within a text object in the
transparent imaging model.

=cut

sub textknockout {
    my ($self,$var)=@_;
    $self->{TK}=PDFBool($var);
    return($self);
}

=item $egs->transparency $t

The graphics tranparency , with 0 being fully opaque and 1 being fully transparent.
This is a convenience method setting proper values for strokeaplha and fillalpha.

=cut

sub transparency {
    my ($self,$var)=@_;
    $self->strokealpha(1-$var);
    $self->fillalpha(1-$var);
    return($self);
}

=item $egs->opacity $op

The graphics opacity , with 1 being fully opaque and 0 being fully transparent.
This is a convenience method setting proper values for strokeaplha and fillalpha.

=cut

sub opacity {
    my ($self,$var)=@_;
    $self->strokealpha($var);
    $self->fillalpha($var);
    return($self);
}

sub outobjdeep {
    my ($self, @opts) = @_;
    foreach my $k (qw/ api apipdf /) {
        $self->{" $k"}=undef;
        delete($self->{" $k"});
    }
    $self->SUPER::outobjdeep(@opts);
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 1.2  2005/11/16 01:27:48  areibens
    genesis2

    Revision 1.1  2005/11/16 01:19:25  areibens
    genesis

    Revision 1.10  2005/06/17 19:44:03  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.9  2005/06/17 18:53:34  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.8  2005/03/14 22:01:06  fredo
    upd 2005

    Revision 1.7  2004/12/16 00:30:53  fredo
    added no warn for recursion

    Revision 1.6  2004/06/15 09:14:41  fredo
    removed cr+lf

    Revision 1.5  2004/06/07 19:44:36  fredo
    cleaned out cr+lf for lf

    Revision 1.4  2003/12/08 13:05:33  Administrator
    corrected to proper licencing statement

    Revision 1.3  2003/11/30 17:28:55  Administrator
    merged into default

    Revision 1.2.2.1  2003/11/30 16:56:35  Administrator
    merged into default

    Revision 1.2  2003/11/30 11:44:49  Administrator
    added CVS id/log


=cut
