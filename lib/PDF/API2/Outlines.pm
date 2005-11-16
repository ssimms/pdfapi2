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

package PDF::API2::Outlines;

BEGIN {

    use strict;
    use vars qw(@ISA $VERSION);

    use PDF::API2::Outline;
    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;

    @ISA = qw(PDF::API2::Outline);

    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$

}

no warnings qw[ deprecated recursion uninitialized ];

=head1 $otls = PDF::API2::Outlines->new $api

Returns a new outlines object (called from $pdf->outlines).

=cut

sub new {
    my ($class,$api)=@_;
    my $self = $class->SUPER::new($api);
    $self->{Type}=PDFName('Outlines');

    return($self);
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 1.1  2005/11/16 01:19:24  areibens
    genesis

    Revision 1.10  2005/06/17 19:43:47  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.9  2005/06/17 18:53:33  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.8  2005/03/14 22:01:05  fredo
    upd 2005

    Revision 1.7  2004/12/16 00:30:52  fredo
    added no warn for recursion

    Revision 1.6  2004/06/15 09:11:38  fredo
    removed cr+lf

    Revision 1.5  2004/06/07 19:44:12  fredo
    cleaned out cr+lf for lf

    Revision 1.4  2003/12/08 13:05:19  Administrator
    corrected to proper licencing statement

    Revision 1.3  2003/11/30 17:16:39  Administrator
    merged into default


=cut
