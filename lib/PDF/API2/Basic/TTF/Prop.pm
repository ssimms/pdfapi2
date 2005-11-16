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
#   Copyright Jonathan Kew L<Jonathan_Kew@sil.org>
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
package PDF::API2::Basic::TTF::Prop;

=head1 NAME

PDF::API2::Basic::TTF::Prop - Glyph Properties table in a font

=head1 DESCRIPTION

=head1 INSTANCE VARIABLES

=item version

=item default

=item lookup

Hash of property values keyed by glyph number

=item lookupFormat

=head1 METHODS

=cut

use strict;
use vars qw(@ISA);
use PDF::API2::Basic::TTF::Utils;
use PDF::API2::Basic::TTF::AATutils;
use PDF::API2::Basic::TTF::Segarr;

@ISA = qw(PDF::API2::Basic::TTF::Table);

=head2 $t->read

Reads the table into memory

=cut

sub read
{
    my ($self) = @_;
    my ($dat, $fh);
    my ($version, $lookupPresent, $default);

    $self->SUPER::read or return $self;

    $fh = $self->{' INFILE'};
    $fh->read($dat, 8);
    ($version, $lookupPresent, $default) = TTF_Unpack("fSS", $dat);

    if ($lookupPresent) {
        my ($format, $lookup) = AAT_read_lookup($fh, 2, $self->{' LENGTH'} - 8, $default);
        $self->{'lookup'} = $lookup;
        $self->{'format'} = $format;
    }

    $self->{'version'} = $version;
    $self->{'default'} = $default;

    $self;
}


=head2 $t->out($fh)

Writes the table to a file either from memory or by copying

=cut

sub out
{
    my ($self, $fh) = @_;
    my ($default, $lookup);

    return $self->SUPER::out($fh) unless $self->{' read'};

    $default = $self->{'default'};
    $lookup = $self->{'lookup'};
    $fh->print(TTF_Pack("fSS", $self->{'version'}, (defined $lookup ? 1 : 0), $default));

    AAT_write_lookup($fh, $self->{'format'}, $lookup, 2, $default) if (defined $lookup);
}

=head2 $t->print($fh)

Prints a human-readable representation of the table

=cut

sub print
{
    my ($self, $fh) = @_;
    my ($lookup);

    $self->read;

    $fh = 'STDOUT' unless defined $fh;

    $fh->printf("version %f\ndefault %04x # %s\n", $self->{'version'}, $self->{'default'}, meaning_($self->{'default'}));
    $lookup = $self->{'lookup'};
    if (defined $lookup) {
        $fh->printf("format %d\n", $self->{'format'});
        foreach (sort { $a <=> $b } keys %$lookup) {
            $fh->printf("\t%d -> %04x # %s\n", $_, $lookup->{$_}, meaning_($lookup->{$_}));
        }
    }
}

sub meaning_
{
    my ($val) = @_;
    my ($res);

    my @types = (
        "Strong left-to-right",
        "Strong right-to-left",
        "Arabic letter",
        "European number",
        "European number separator",
        "European number terminator",
        "Arabic number",
        "Common number separator",
        "Block separator",
        "Segment separator",
        "Whitespace",
        "Other neutral");
    $res = $types[$val & 0x001f] or ("Undefined [" . ($val & 0x001f) . "]");

    $res .= ", floater" if $val & 0x8000;
    $res .= ", hang left" if $val & 0x4000;
    $res .= ", hang right" if $val & 0x2000;
    $res .= ", attaches on right" if $val & 0x0080;
    $res .= ", pair" if $val & 0x1000;
    my $pairOffset = ($val & 0x0f00) >> 8;
    $pairOffset = $pairOffset - 16 if $pairOffset > 7;
    $res .= $pairOffset > 0 ? " +" . $pairOffset : $pairOffset < 0 ? " " . $pairOffset : "";

    $res;
}

1;


=head1 BUGS

None known

=head1 AUTHOR

Jonathan Kew L<Jonathan_Kew@sil.org>. See L<PDF::API2::Basic::TTF::Font> for copyright and
licensing.

=cut

