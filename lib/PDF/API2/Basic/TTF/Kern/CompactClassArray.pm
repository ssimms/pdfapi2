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
#   Copyright Jonathan Kew L<Jonathan_Kew@sil.org>.
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
package PDF::API2::Basic::TTF::Kern::CompactClassArray;

=head1 NAME

PDF::API2::Basic::TTF::Kern::CompactClassArray

=head1 METHODS

=cut

use strict;
use vars qw(@ISA);
use PDF::API2::Basic::TTF::Utils;
use PDF::API2::Basic::TTF::AATutils;

@ISA = qw(PDF::API2::Basic::TTF::Kern::Subtable);

sub new
{
    my ($class) = @_;
    my ($self) = {};

    $class = ref($class) || $class;
    bless $self, $class;
}

=head2 $t->read

Reads the table into memory

=cut

sub read
{
    my ($self, $fh) = @_;

    die "incomplete";

    $self;
}

=head2 $t->out($fh)

Writes the table to a file

=cut

sub out_sub
{
    my ($self, $fh) = @_;

    die "incomplete";

    $self;
}

=head2 $t->print($fh)

Prints a human-readable representation of the table

=cut

sub print
{
    my ($self, $fh) = @_;

    my $post = $self->post();

    $fh = 'STDOUT' unless defined $fh;

    die "incomplete";
}


sub type
{
    return 'kernCompactClassArray';
}


1;

=head1 BUGS

None known

=head1 AUTHOR

Jonathan Kew L<Jonathan_Kew@sil.org>. See L<PDF::API2::Basic::TTF::Font> for copyright and
licensing.

=cut

