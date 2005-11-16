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

package PDF::API2::Win32;

    use vars qw($VERSION);
    ( $VERSION ) = '$Revision$' =~ /Revision: (\S+)\s/; # $Date$

    no warnings qw[ deprecated recursion uninitialized ];

package PDF::API2;

use vars qw( $wf );
use Win32::TieRegistry;

no warnings qw[ recursion uninitialized ];

$wf={};

$Registry->Delimiter("/");

my $fontdir = $Registry->{"HKEY_CURRENT_USER/Software/Microsoft/Windows/CurrentVersion/Explorer/Shell Folders"}->{Fonts};

my $subKey = $Registry->{"HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows NT/CurrentVersion/Fonts/"};

foreach my $k (sort keys %{$subKey}) {
    next unless($subKey->{$k}=~/\.[ot]tf$/i);
    my $kk=lc($k);
    $kk=~s|^/||;
    $kk=~s|\s+\(truetype\).*$||g;
    $kk=~s|\s+\(opentype\).*$||g;
    $kk=~s/[^a-z0-9]+//g;

    $wf->{$kk}={};

    $wf->{$kk}->{display}=$k;
    $wf->{$kk}->{display}=~s|^/||;

    if(-e "$fontdir/$subKey->{$k}") {
        $wf->{$kk}->{ttfile}="$fontdir/$subKey->{$k}";
    } else {
        $wf->{$kk}->{ttfile}=$subKey->{$k};
    }
}

$subKey = $Registry->{"HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows NT/CurrentVersion/Type 1 Installer/Type 1 Fonts/"};

foreach my $k (sort keys %{$subKey}) {
    my $kk=lc($k);
    $kk=~s|^/||;
    $kk=~s/[^a-z0-9]+//g;

    $wf->{$kk}={};

    $wf->{$kk}->{display}=$k;
    $wf->{$kk}->{display}=~s|^/||;

    my $t;
    ($t,$wf->{$kk}->{pfmfile},$wf->{$kk}->{pfbfile})=split(/\0/,$subKey->{$k});

    if(-e "$fontdir/$wf->{$kk}->{pfmfile}") {
        $wf->{$kk}->{pfmfile}="$fontdir/".$wf->{$kk}->{pfmfile};
        $wf->{$kk}->{pfbfile}="$fontdir/".$wf->{$kk}->{pfbfile};
    }
}

sub enumwinfonts {
    my $self=shift @_;
    return(map { $_ => $wf->{$_}->{display} } keys %{$wf});
}

sub winfont {
    my $self=shift @_;
    my $key=lc(shift @_);
    $key=~s/[^a-z0-9]+//g;

    return(undef) unless(defined $wf && defined $wf->{$key});

    if(defined $wf->{$key}->{ttfile}) {
        return($self->ttfont($wf->{$key}->{ttfile}, @_));
    } else {
        return($self->psfont($wf->{$key}->{pfbfile}, -pfmfile => $wf->{$key}->{pfmfile}, @_));
    }
}

1;

__END__

=head1 HISTORY

    $Log$
    Revision 1.2  2005/11/16 01:27:48  areibens
    genesis2

    Revision 1.1  2005/11/16 01:19:24  areibens
    genesis

    Revision 1.9  2005/03/14 22:01:06  fredo
    upd 2005

    Revision 1.8  2004/12/29 01:45:41  fredo
    fixed no warn for recursion

    Revision 1.7  2004/12/16 00:30:52  fredo
    added no warn for recursion

    Revision 1.6  2004/06/15 09:11:38  fredo
    removed cr+lf

    Revision 1.5  2004/06/07 19:44:13  fredo
    cleaned out cr+lf for lf

    Revision 1.4  2003/12/08 13:05:20  Administrator
    corrected to proper licencing statement

    Revision 1.3  2003/11/30 17:21:13  Administrator
    merged into default

    Revision 1.2.2.1  2003/11/30 16:56:22  Administrator
    merged into default

    Revision 1.2  2003/11/29 23:31:21  Administrator
    added CVS id/log


=cut