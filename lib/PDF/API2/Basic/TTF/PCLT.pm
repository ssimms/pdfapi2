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
package PDF::API2::Basic::TTF::PCLT;

=head1 NAME

PDF::API2::Basic::TTF::PCLT - PCLT TrueType font table

=head1 DESCRIPTION

The PCLT table holds various pieces HP-PCL specific information. Information
here is generally not used by other software, except for the xHeight and
CapHeight which are stored here (if the table exists in a font).

=head1 INSTANCE VARIABLES

Only from table and the standard:

    version
    FontNumber
    Pitch
    xHeight
    Style
    TypeFamily
    CapHeight
    SymbolSet
    Typeface
    CharacterComplement
    FileName
    StrokeWeight
    WidthType
    SerifStyle

Notice that C<Typeface>, C<CharacterComplement> and C<FileName> return arrays
of unsigned characters of the appropriate length

=head1 METHODS

=cut

use strict;
use vars qw(@ISA %fields @field_info);

require PDF::API2::Basic::TTF::Table;
use PDF::API2::Basic::TTF::Utils;

@ISA = qw(PDF::API2::Basic::TTF::Table);
@field_info = (
    'version' => 'f',
    'FontNumber' => 'L',
    'Pitch' => 'S',
    'xHeight' => 'S',
    'Style' => 'S',
    'TypeFamily' => 'S',
    'CapHeight' => 'S',
    'SymbolSet' => 'S',
    'Typeface' => 'C16',
    'CharacterComplement' => 'C8',
    'FileName' => 'C6',
    'StrokeWeight' => 'C',
    'WidthType' => 'C',
    'SerifStyle' => 'c');

sub init
{
    my ($k, $v, $c, $i);
    for ($i = 0; $i < $#field_info; $i += 2)
    {
        ($k, $v, $c) = TTF_Init_Fields($field_info[$i], $c, $field_info[$i + 1]);
        next unless defined $k && $k ne "";
        $fields{$k} = $v;
    }
}


=head2 $t->read

Reads the table into memory thanks to some utility functions

=cut

sub read
{
    my ($self) = @_;
    my ($dat);

    $self->SUPER::read || return $self;

    init unless defined $fields{'xHeight'};
    $self->{' INFILE'}->read($dat, 54);

    TTF_Read_Fields($self, $dat, \%fields);
    $self;
}


=head2 $t->out($fh)

Writes the table to a file either from memory or by copying.

=cut

sub out
{
    my ($self, $fh) = @_;

    return $self->SUPER::out($fh) unless $self->{' read'};
    $fh->print(TTF_Out_Fields($self, \%fields, 54));
}

1;

=head1 BUGS

None known

=head1 AUTHOR

Martin Hosken Martin_Hosken@sil.org. See L<PDF::API2::Basic::TTF::Font> for copyright and
licensing.

=cut

