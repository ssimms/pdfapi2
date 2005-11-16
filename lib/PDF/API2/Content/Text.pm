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
package PDF::API2::Content::Text;

BEGIN {

    use strict;
    use vars qw(@ISA $VERSION);

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Content;

    @ISA = qw(PDF::API2::Content);

    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$

}
no warnings qw[ deprecated recursion uninitialized ];

=head1 $txt = PDF::API2::Content::Text->new @parameters

Returns a new text content object (called from $page->text).

=cut

sub new {
  my ($class)=@_;
  my $self = $class->SUPER::new(@_);
  $self->textstart;
  return($self);
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 2.0  2005/11/16 02:16:04  areibens
    revision workaround for SF cvs import not to screw up CPAN

    Revision 1.2  2005/11/16 01:27:48  areibens
    genesis2

    Revision 1.1  2005/11/16 01:19:25  areibens
    genesis

    Revision 1.10  2005/06/17 19:44:02  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.9  2005/06/17 18:53:33  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.8  2005/03/14 22:01:06  fredo
    upd 2005

    Revision 1.7  2004/12/16 00:30:53  fredo
    added no warn for recursion

    Revision 1.6  2004/06/15 09:14:41  fredo
    removed cr+lf

    Revision 1.5  2004/06/07 19:44:36  fredo
    cleaned out cr+lf for lf

    Revision 1.4  2003/12/08 13:05:32  Administrator
    corrected to proper licencing statement

    Revision 1.3  2003/11/30 17:24:34  Administrator
    merged into default

    Revision 1.2.2.1  2003/11/30 16:56:34  Administrator
    merged into default

    Revision 1.2  2003/11/29 23:12:16  Administrator
    addedd CVS Id/Log


=cut
