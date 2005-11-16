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

package PDF::API2::Resource::Pattern;

BEGIN {

    use strict;
    use vars qw(@ISA $VERSION);
    use PDF::API2::Basic::PDF::Array;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Util;
    use Math::Trig;

    @ISA = qw(PDF::API2::Resource);

    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$

}
no warnings qw[ deprecated recursion uninitialized ];

=item $cs = PDF::API2::Resource::Pattern->new $pdf, $key, %parameters

Returns a new pattern object. base class for all patterns.

=cut

sub new {
    my ($class,$pdf,$key,%opts)=@_;

    $class = ref $class if ref $class;
    $self=$class->SUPER::new($pdf,$key || pdfkey());
    $pdf->new_obj($self) unless($self->is_obj($pdf));
    $self->{Type}=PDFName('Pattern');
    $self->{' apipdf'}=$pdf;

    return($self);
}

=item $cs = PDF::API2::Resource::Pattern->new_api $api, $name

Returns a pattern object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $self->{' api'}=$api;

    return($obj);
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
    Revision 1.1  2005/11/16 01:19:25  areibens
    genesis

    Revision 1.6  2005/06/17 19:44:03  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.5  2005/06/17 18:53:34  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.4  2005/03/14 22:01:06  fredo
    upd 2005

    Revision 1.3  2004/12/16 00:30:53  fredo
    added no warn for recursion

    Revision 1.2  2004/06/22 00:38:44  fredo
    fixed ISA

    Revision 1.1  2004/06/21 22:33:37  fredo
    added basic pattern/shading handling


=cut
