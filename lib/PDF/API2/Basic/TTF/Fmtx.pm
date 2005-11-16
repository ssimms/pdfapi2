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
package PDF::API2::Basic::TTF::Fmtx;

=head1 NAME

PDF::API2::Basic::TTF::Fmtx - Font Metrics table

=head1 DESCRIPTION

This is a simple table with just standards specified instance variables

=head1 INSTANCE VARIABLES

    version
    glyphIndex
    horizontalBefore
    horizontalAfter
    horizontalCaretHead
    horizontalCaretBase
    verticalBefore
    verticalAfter
    verticalCaretHead
    verticalCaretBase

=head1 METHODS

=cut

use strict;
use vars qw(@ISA %fields @field_info);

require PDF::API2::Basic::TTF::Table;
use PDF::API2::Basic::TTF::Utils;

@ISA = qw(PDF::API2::Basic::TTF::Table);
@field_info = (
    'version' => 'f',
    'glyphIndex' => 'L',
    'horizontalBefore' => 'c',
    'horizontalAfter' => 'c',
    'horizontalCaretHead' => 'c',
    'horizontalCaretBase' => 'c',
    'verticalBefore' => 'c',
    'verticalAfter' => 'c',
    'verticalCaretHead' => 'c',
    'verticalCaretBase' => 'c');

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

Reads the table into memory as instance variables

=cut

sub read
{
    my ($self) = @_;
    my ($dat);

    $self->SUPER::read or return $self;
    init unless defined $fields{'glyphIndex'};
    $self->{' INFILE'}->read($dat, 16);

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

    $fh->print(TTF_Out_Fields($self, \%fields, 16));
    $self;
}


1;


=head1 BUGS

None known

=head1 AUTHOR

Jonathan Kew L<Jonathan_Kew@sil.org>. See L<PDF::API2::Basic::TTF::Font> for copyright and
licensing.

=cut
