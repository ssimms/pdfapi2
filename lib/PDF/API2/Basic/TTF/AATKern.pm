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
package PDF::API2::Basic::TTF::AATKern;

=head1 NAME

PDF::API2::Basic::TTF::AATKern

=head1 METHODS

=cut

use strict;
use vars qw(@ISA);
use PDF::API2::Basic::TTF::Utils;
use PDF::API2::Basic::TTF::AATutils;
use PDF::API2::Basic::TTF::Kern::Subtable;

@ISA = qw(PDF::API2::Basic::TTF::Table);

=head2 $t->read

Reads the table into memory

=cut

sub read
{
    my ($self) = @_;

    $self->SUPER::read or return $self;

    my ($dat, $fh, $numSubtables);
    $fh = $self->{' INFILE'};

    $fh->read($dat, 8);
    ($self->{'version'}, $numSubtables) = TTF_Unpack("fL", $dat);

    my $subtables = [];
    foreach (1 .. $numSubtables) {
        my $subtableStart = $fh->tell();

        $fh->read($dat, 8);
        my ($length, $coverage, $tupleIndex) = TTF_Unpack("LSS", $dat);
        my $type = $coverage & 0x00ff;

        my $subtable = PDF::API2::Basic::TTF::Kern::Subtable->create($type, $coverage, $length);
        $subtable->read($fh);

        $subtable->{'tupleIndex'} = $tupleIndex if $subtable->{'variation'};
        $subtable->{' PARENT'} = $self;
        push @$subtables, $subtable;
    }

    $self->{'subtables'} = $subtables;

    $self;
}

=head2 $t->out($fh)

Writes the table to a file either from memory or by copying

=cut

sub out
{
    my ($self, $fh) = @_;

    return $self->SUPER::out($fh) unless $self->{' read'};

    my $subtables = $self->{'subtables'};
    $fh->print(TTF_Pack("fL", $self->{'version'}, scalar @$subtables));

    foreach (@$subtables) {
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

    $fh = 'STDOUT' unless defined $fh;

    $fh->printf("version %f\n", $self->{'version'});

    my $subtables = $self->{'subtables'};
    foreach (@$subtables) {
        $_->print($fh);
    }
}

sub dumpXML
{
    my ($self, $fh) = @_;
    $self->read unless $self->{' read'};

    my $post = $self->{' PARENT'}->{'post'};
    $post->read;

    $fh = 'STDOUT' unless defined $fh;
    $fh->printf("<kern version=\"%f\">\n", $self->{'version'});

    my $subtables = $self->{'subtables'};
    foreach (@$subtables) {
        $fh->printf("<%s", $_->type);
        $fh->printf(" vertical=\"1\"") if $_->{'vertical'};
        $fh->printf(" crossStream=\"1\"") if $_->{'crossStream'};
        $fh->printf(" variation=\"1\"") if $_->{'variation'};
        $fh->printf(" tupleIndex=\"%s\"", $_->{'tupleIndex'}) if exists $_->{'tupleIndex'};
        $fh->printf(">\n");

        $_->dumpXML($fh);

        $fh->printf("</%s>\n", $_->type);
    }

    $fh->printf("</kern>\n");
}

1;

=head1 BUGS

None known

=head1 AUTHOR

Jonathan Kew L<Jonathan_Kew@sil.org>. See L<PDF::API2::Basic::TTF::Font> for copyright and
licensing.

=cut

