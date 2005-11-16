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
package PDF::API2::Basic::TTF::Mort::Rearrangement;

=head1 NAME

PDF::API2::Basic::TTF::Mort::Rearrangement

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

    my ($classes, $states) = AAT_read_state_table($fh, 0);
    $self->{'classes'} = $classes;
    $self->{'states'} = $states;

    $self;
}

=head2 $t->pack_sub()

=cut

sub pack_sub
{
    my ($self) = @_;

    return AAT_pack_state_table($self->{'classes'}, $self->{'states'}, 0);
}

=head2 $t->print($fh)

Prints a human-readable representation of the table

=cut

sub print
{
    my ($self, $fh) = @_;

    my $post = $self->post();

    $fh = 'STDOUT' unless defined $fh;

    $self->print_classes($fh);

    $fh->print("\n");
    my $states = $self->{'states'};
    my @verbs = (    "0", "Ax->xA", "xD->Dx", "AxD->DxA",
                    "ABx->xAB", "ABx->xBA", "xCD->CDx", "xCD->DCx",
                    "AxCD->CDxA", "AxCD->DCxA", "ABxD->DxAB", "ABxD->DxBA",
                    "ABxCD->CDxAB", "ABxCD->CDxBA", "ABxCD->DCxAB", "ABxCD->DCxBA");
    foreach (0 .. $#$states) {
        $fh->printf("\t\tState %d:", $_);
        my $state = $states->[$_];
        foreach (@$state) {
            my $flags;
            $flags .= "!" if ($_->{'flags'} & 0x4000);
            $flags .= "<" if ($_->{'flags'} & 0x8000);
            $flags .= ">" if ($_->{'flags'} & 0x2000);
            $fh->printf("\t(%s%d,%s)", $flags, $_->{'nextState'}, $verbs[($_->{'flags'} & 0x000f)]);
        }
        $fh->print("\n");
    }
}

1;

=head1 BUGS

None known

=head1 AUTHOR

Jonathan Kew L<Jonathan_Kew@sil.org>. See L<PDF::API2::Basic::TTF::Font> for copyright and
licensing.

=cut

