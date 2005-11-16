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
package PDF::API2::Basic::TTF::Mort;

=head1 NAME

PDF::API2::Basic::TTF::Mort - Glyph Metamorphosis table in a font

=head1 METHODS

=cut

use strict;
use vars qw(@ISA);
use PDF::API2::Basic::TTF::Utils;
use PDF::API2::Basic::TTF::AATutils;
use PDF::API2::Basic::TTF::Mort::Chain;

@ISA = qw(PDF::API2::Basic::TTF::Table);

=head2 $t->read

Reads the table into memory

=cut

sub read
{
    my ($self) = @_;
    my ($dat, $fh, $numChains);

    $self->SUPER::read or return $self;

    $fh = $self->{' INFILE'};

    $fh->read($dat, 8);
    ($self->{'version'}, $numChains) = TTF_Unpack("fL", $dat);

    my $chains = [];
    foreach (1 .. $numChains) {
        my $chain = new PDF::API2::Basic::TTF::Mort::Chain->new;
        $chain->read($fh);
        $chain->{' PARENT'} = $self;
        push @$chains, $chain;
    }

    $self->{'chains'} = $chains;

    $self;
}

=head2 $t->out($fh)

Writes the table to a file either from memory or by copying

=cut

sub out
{
    my ($self, $fh) = @_;

    return $self->SUPER::out($fh) unless $self->{' read'};

    my $chains = $self->{'chains'};
    $fh->print(TTF_Pack("fL", $self->{'version'}, scalar @$chains));

    foreach (@$chains) {
        $_->out($fh);
    }
}

=head2 $t->print($fh)

Prints a human-readable representation of the table

=cut

sub print
{
    my ($self, $fh) = @_;

    $self->read unless $self->{' read'};
    my $feat = $self->{' PARENT'}->{'feat'};
    $feat->read;
    my $post = $self->{' PARENT'}->{'post'};
    $post->read;

    $fh = 'STDOUT' unless defined $fh;

    $fh->printf("version %f\n", $self->{'version'});

    my $chains = $self->{'chains'};
    foreach (@$chains) {
        $_->print($fh);
    }
}

1;

=head1 BUGS

None known

=head1 AUTHOR

Jonathan Kew L<Jonathan_Kew@sil.org>. See L<PDF::API2::Basic::TTF::Font> for copyright and
licensing.

=cut

