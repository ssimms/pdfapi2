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
package PDF::API2::Basic::TTF::Mort::Noncontextual;

=head1 NAME

PDF::API2::Basic::TTF::Mort::Noncontextual

=head1 METHODS

=cut

use strict;
use vars qw(@ISA);
use PDF::API2::Basic::TTF::Utils;
use PDF::API2::Basic::TTF::AATutils;

@ISA = qw(PDF::API2::Basic::TTF::Mort::Subtable);

sub new
{
    my ($class, $direction, $orientation, $subFeatureFlags) = @_;
    my ($self) = {
                    'direction'            => $direction,
                    'orientation'        => $orientation,
                    'subFeatureFlags'    => $subFeatureFlags
                };

    $class = ref($class) || $class;
    bless $self, $class;
}

=head2 $t->read

Reads the table into memory

=cut

sub read
{
    my ($self, $fh) = @_;
    my ($dat);

    my ($format, $lookup) = AAT_read_lookup($fh, 2, $self->{'length'} - 8, undef);
    $self->{'format'} = $format;
    $self->{'lookup'} = $lookup;

    $self;
}

=head2 $t->pack_sub($fh)

=cut

sub pack_sub
{
    my ($self) = @_;

    return AAT_pack_lookup($self->{'format'}, $self->{'lookup'}, 2, undef);
}

=head2 $t->print($fh)

Prints a human-readable representation of the table

=cut

sub print
{
    my ($self, $fh) = @_;

    my $post = $self->post();

    $fh = 'STDOUT' unless defined $fh;

    my $lookup = $self->{'lookup'};
    $fh->printf("\t\tLookup format %d\n", $self->{'format'});
    if (defined $lookup) {
        foreach (sort { $a <=> $b } keys %$lookup) {
            $fh->printf("\t\t\t%d [%s] -> %d [%s])\n", $_, $post->{'VAL'}[$_], $lookup->{$_}, $post->{'VAL'}[$lookup->{$_}]);
        }
    }
}

1;

=head1 BUGS

None known

=head1 AUTHOR

Jonathan Kew L<Jonathan_Kew@sil.org>. See L<PDF::API2::Basic::TTF::Font> for copyright and
licensing.

=cut

