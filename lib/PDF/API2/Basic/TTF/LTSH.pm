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
package PDF::API2::Basic::TTF::LTSH;

=head1 NAME

PDF::API2::Basic::TTF::LTSH - Linear Threshold table

=head1 DESCRIPTION

Holds the linear threshold for each glyph. This is the ppem value at which a
glyph's metrics become linear. The value is set to 1 if a glyph's metrics are
always linear.

=head1 INSTANCE VARIABLES

=over 4

=item glyphs

An array of ppem values. One value per glyph

=back

=head1 METHODS

=cut

use strict;
use vars qw(@ISA);
use PDF::API2::Basic::TTF::Table;

@ISA = qw(PDF::API2::Basic::TTF::Table);

=head2 $t->read

Reads the table

=cut

sub read
{
    my ($self) = @_;
    my ($fh) = $self->{' INFILE'};
    my ($numg, $dat);

    $self->SUPER::read or return $self;

    $fh->read($dat, 4);
    ($self->{'Version'}, $numg) = unpack("nn", $dat);
    $self->{'Num'} = $numg;

    $fh->read($dat, $numg);
    $self->{'glyphs'} = [unpack("C$numg", $dat)];
    $self;
}


=head2 $t->out($fh)

Outputs the LTSH to the given fh.

=cut

sub out
{
    my ($self, $fh) = @_;
    my ($numg) = $self->{' PARENT'}{'maxp'}{'numGlyphs'};

    return $self->SUPER::out($fh) unless ($self->{' read'});

    $fh->print(pack("nn", 0, $numg));
    $fh->print(pack("C$numg", @{$self->{'glyphs'}}));
    $self;
}


1;

=head1 BUGS

None known

=head1 AUTHOR

Martin Hosken Martin_Hosken@sil.org. See L<PDF::API2::Basic::TTF::Font> for copyright and
licensing.

=cut

