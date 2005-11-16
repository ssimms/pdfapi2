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
package PDF::API2::Basic::TTF::Mort::Subtable;

=head1 NAME

PDF::API2::Basic::TTF::Mort::Subtable

=head1 METHODS

=cut

use strict;
use PDF::API2::Basic::TTF::Utils;
use PDF::API2::Basic::TTF::AATutils;

require PDF::API2::Basic::TTF::Mort::Rearrangement;
require PDF::API2::Basic::TTF::Mort::Contextual;
require PDF::API2::Basic::TTF::Mort::Ligature;
require PDF::API2::Basic::TTF::Mort::Noncontextual;
require PDF::API2::Basic::TTF::Mort::Insertion;

sub new
{
    my ($class) = @_;
    my ($self) = {};

    $class = ref($class) || $class;

    bless $self, $class;
}

sub create
{
    my ($class, $type, $coverage, $subFeatureFlags, $length) = @_;

    $class = ref($class) || $class;

    my $subclass;
    if ($type == 0) {
        $subclass = 'PDF::API2::Basic::TTF::Mort::Rearrangement';
    }
    elsif ($type == 1) {
        $subclass = 'PDF::API2::Basic::TTF::Mort::Contextual';
    }
    elsif ($type == 2) {
        $subclass = 'PDF::API2::Basic::TTF::Mort::Ligature';
    }
    elsif ($type == 4) {
        $subclass = 'PDF::API2::Basic::TTF::Mort::Noncontextual';
    }
    elsif ($type == 5) {
        $subclass = 'PDF::API2::Basic::TTF::Mort::Insertion';
    }

    my ($self) = $subclass->new(
            (($coverage & 0x4000) ? 'RL' : 'LR'),
            (($coverage & 0x2000) ? 'VH' : ($coverage & 0x8000) ? 'V' : 'H'),
            $subFeatureFlags
        );

    $self->{'type'} = $type;
    $self->{'length'} = $length;

    $self;
}

=head2 $t->out($fh)

Writes the table to a file

=cut

sub out
{
    my ($self, $fh) = @_;

    my ($subtableStart) = $fh->tell();
    my ($type) = $self->{'type'};
    my ($coverage) = $type;
    $coverage += 0x4000 if $self->{'direction'} eq 'RL';
    $coverage += 0x2000 if $self->{'orientation'} eq 'VH';
    $coverage += 0x8000 if $self->{'orientation'} eq 'V';

    $fh->print(TTF_Pack("SSL", 0, $coverage, $self->{'subFeatureFlags'}));    # placeholder for length

    my ($dat) = $self->pack_sub();
    $fh->print($dat);

    my ($length) = $fh->tell() - $subtableStart;
    my ($padBytes) = (4 - ($length & 3)) & 3;
    $fh->print(pack("C*", (0) x $padBytes));
    $length += $padBytes;
    $fh->seek($subtableStart, IO::File::SEEK_SET);
    $fh->print(pack("n", $length));
    $fh->seek($subtableStart + $length, IO::File::SEEK_SET);
}

=head2 $t->print($fh)

Prints a human-readable representation of the table

=cut

sub post
{
    my ($self) = @_;

    my ($post) = $self->{' PARENT'}{' PARENT'}{' PARENT'}{'post'};
    if (defined $post) {
        $post->read;
    }
    else {
        $post = {};
    }

    return $post;
}

sub feat
{
    my ($self) = @_;

    return $self->{' PARENT'}->feat();
}

sub print
{
    my ($self, $fh) = @_;

    my ($feat) = $self->feat();
    my ($post) = $self->post();

    $fh = 'STDOUT' unless defined $fh;

    my ($type) = $self->{'type'};
    my ($subFeatureFlags) = $self->{'subFeatureFlags'};
    my ($defaultFlags) = $self->{' PARENT'}{'defaultFlags'};
    my ($featureEntries) = $self->{' PARENT'}{'featureEntries'};
    $fh->printf("\n\t%s table, %s, %s, subFeatureFlags = %08x # %s (%s)\n",
                subtable_type_($type), $_->{'direction'}, $_->{'orientation'}, $subFeatureFlags,
                "Default " . ((($subFeatureFlags & $defaultFlags) != 0) ? "On" : "Off"),
                join(", ",
                    map {
                        join(": ", $feat->settingName($_->{'type'}, $_->{'setting'}) )
                    } grep { ($_->{'enable'} & $subFeatureFlags) != 0 } @$featureEntries
                ) );
}

sub subtable_type_
{
    my ($val) = @_;
    my ($res);

    my (@types) =    (
                        'Rearrangement',
                        'Contextual',
                        'Ligature',
                        undef,
                        'Non-contextual',
                        'Insertion',
                    );
    $res = $types[$val] or ('Undefined (' . $val . ')');

    $res;
}

=head2 $t->print_classes($fh)

Prints a human-readable representation of the table

=cut

sub print_classes
{
    my ($self, $fh) = @_;

    my ($post) = $self->post();

    my ($classes) = $self->{'classes'};
    foreach (0 .. $#$classes) {
        my $class = $classes->[$_];
        if (defined $class) {
            $fh->printf("\t\tClass %d:\t%s\n", $_, join(", ", map { $_ . " [" . $post->{'VAL'}[$_] . "]" } @$class));
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

