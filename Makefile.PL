#!perl
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

require 5.008;

use ExtUtils::MakeMaker;

my $versionfile = "lib/PDF/API2/Version.pm";

require "$versionfile";

my %makehash=( 
    NAME            => "PDF::API2", 
    AUTHOR          => "areibens\@cpan.org", 
    ABSTRACT        => "TheNextGen PDF Create/Modify API", 
    dist            => { 
        ZIP         => "zip ", 
        ZIPFLAGS    => " -v -o -r -9 ",
        COMPRESS    => "gzip -9 -f ", 
    }, 
    MAN1PODS        => {}, 
    MAN3PODS        => {}, 
    PREREQ_PM       => { 'Compress::Zlib' => 1.0, }, 
    VERSION_FROM    => $versionfile,
    BINARY_LOCATION => q|PDF-API2-|.$PDF::API2::Version::CVersion{vPerl}.q|.ppm.tar.gz|,
);

WriteMakefile( %makehash );

print STDERR $PDF::API2::Version::CVersion{vTeX}."\n";

exit;

sub MY::postamble{
    my $y=qq|ppmdist: pm_to_blib ppd dist\n|;
    $y.=qq|\t\$(MKPATH) \$(DISTNAME)-\$(VERSION)-PPM\n|;
    $y.=qq|\t\$(TAR) \$(TARFLAGS) \$(DISTNAME)-\$(VERSION)-PPM/\$(DISTNAME)-\$(VERSION).ppm.tar blib\n|;
    $y.=qq|\t\$(COMPRESS) \$(DISTNAME)-\$(VERSION)-PPM/\$(DISTNAME)-\$(VERSION).ppm.tar\n|;
    $y.=qq|\t\$(CP) \$(DISTNAME).ppd \$(DISTNAME)-\$(VERSION)-PPM/\$(DISTNAME).ppd\n|;
    $y.=qq|\t\$(ZIP) \$(ZIPFLAGS) \$(DISTNAME)-\$(VERSION).\$(OSNAME)-\$(OSVERS).ppm.zip \$(DISTNAME)-\$(VERSION)-PPM/\$(DISTNAME)-\$(VERSION).ppm.tar.gz \$(DISTNAME)-\$(VERSION)-PPM/\$(DISTNAME).ppd\n|;
    $y.=qq|\t\$(RM_RF) \$(DISTNAME)-\$(VERSION)-PPM\n|;
    $y.=qq|\n|;
    return($y);
}

__END__
