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
#=======================================================================
#
#   THIS IS A REUSED PERL MODULE, FOR PROPER LICENCING TERMS SEE BELOW:
#
#
#   Copyright Martin Hosken <Martin_Hosken@sil.org>
#
#   No warranty or expression of effectiveness, least of all regarding
#   anyone's safety, is implied in this software or documentation.
#
#   This specific module is licensed under the Perl Artistic License.
#
#
#   $Id$
#
#=======================================================================

package PDF::API2::Basic::TTF::Win32;

# use strict;
# use vars qw($HKEY_LOCAL_MACHINE);

use Win32::Registry;
use Win32;
use File::Spec;
use PDF::API2::Basic::TTF::Font;


sub findfonts
{
    my ($sub) = @_;
    my ($font_key) = 'SOFTWARE\Microsoft\Windows' . (Win32::IsWinNT() ? ' NT' : '') . '\CurrentVersion\Fonts';
    my ($regFont, $list, $l, $font, $file);

# get entry from registry for a font of this name
    $::HKEY_LOCAL_MACHINE->Open($font_key, $regFont);
    $regFont->GetValues($list);

    foreach $l (sort keys %{$list})
    {
        my ($fname) = $list->{$l}[0];
        next unless ($fname =~ s/\(TrueType\)$//o);
        $file = File::Spec->rel2abs($list->{$l}[2], "$ENV{'windir'}/fonts");
        $font = PDF::API2::Basic::TTF::Font->open($file) || next;
        &{$sub}($font, $fname);
        $font->release;
    }
}

1;

__END__