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
package PDF::API2::Basic::TTF::Mort::Chain;

=head1 NAME

PDF::API2::Basic::TTF::Mort::Chain

=cut

use strict;
use PDF::API2::Basic::TTF::Utils;
use PDF::API2::Basic::TTF::AATutils;
use PDF::API2::Basic::TTF::Mort::Subtable;

=head2 $t->new

=cut

sub new
{
    my ($class, %parms) = @_;
    my ($self) = {};
    my ($p);

    $class = ref($class) || $class;
    foreach $p (keys %parms)
    { $self->{" $p"} = $parms{$p}; }
    bless $self, $class;
}

=head2 $t->read($fh)

Reads the chain into memory

=cut

sub read
{
    my ($self, $fh) = @_;
    my ($dat);

    my $chainStart = $fh->tell();
    $fh->read($dat, 12);
    my ($defaultFlags, $chainLength, $nFeatureEntries, $nSubtables) = TTF_Unpack("LLSS", $dat);

    my $featureEntries = [];
    foreach (1 .. $nFeatureEntries) {
        $fh->read($dat, 12);
        my ($featureType, $featureSetting, $enableFlags, $disableFlags) = TTF_Unpack("SSLL", $dat);
        push @$featureEntries,    {
                                    'type'        => $featureType,
                                    'setting'    => $featureSetting,
                                    'enable'    => $enableFlags,
                                    'disable'    => $disableFlags
                                };
    }

    my $subtables = [];
    foreach (1 .. $nSubtables) {
        my $subtableStart = $fh->tell();

        $fh->read($dat, 8);
        my ($length, $coverage, $subFeatureFlags) = TTF_Unpack("SSL", $dat);
        my $type = $coverage & 0x0007;

        my $subtable = PDF::API2::Basic::TTF::Mort::Subtable->create($type, $coverage, $subFeatureFlags, $length);
        $subtable->read($fh);
        $subtable->{' PARENT'} = $self;

        push @$subtables, $subtable;
        $fh->seek($subtableStart + $length, IO::File::SEEK_SET);
    }

    $self->{'defaultFlags'} = $defaultFlags;
    $self->{'featureEntries'} = $featureEntries;
    $self->{'subtables'} = $subtables;

    $fh->seek($chainStart + $chainLength, IO::File::SEEK_SET);

    $self;
}

=head2 $t->out($fh)

Writes the table to a file either from memory or by copying

=cut

sub out
{
    my ($self, $fh) = @_;

    my $chainStart = $fh->tell();
    my ($featureEntries, $subtables) = ($_->{'featureEntries'}, $_->{'subtables'});
    $fh->print(TTF_Pack("LLSS", $_->{'defaultFlags'}, 0, scalar @$featureEntries, scalar @$subtables)); # placeholder for length

    foreach (@$featureEntries) {
        $fh->print(TTF_Pack("SSLL", $_->{'type'}, $_->{'setting'}, $_->{'enable'}, $_->{'disable'}));
    }

    foreach (@$subtables) {
        $_->out($fh);
    }

    my $chainLength = $fh->tell() - $chainStart;
    $fh->seek($chainStart + 4, IO::File::SEEK_SET);
    $fh->print(pack("N", $chainLength));
    $fh->seek($chainStart + $chainLength, IO::File::SEEK_SET);
}

=head2 $t->print($fh)

Prints a human-readable representation of the chain

=cut

sub feat
{
    my ($self) = @_;

    my $feat = $self->{' PARENT'}{' PARENT'}{'feat'};
    if (defined $feat) {
        $feat->read;
    }
    else {
        $feat = {};
    }

    return $feat;
}

sub print
{
    my ($self, $fh) = @_;

    $fh->printf("version %f\n", $self->{'version'});

    my $defaultFlags = $self->{'defaultFlags'};
    $fh->printf("chain: defaultFlags = %08x\n", $defaultFlags);

    my $feat = $self->feat();
    my $featureEntries = $self->{'featureEntries'};
    foreach (@$featureEntries) {
        $fh->printf("\tfeature %d, setting %d : enableFlags = %08x, disableFlags = %08x # '%s: %s'\n",
                    $_->{'type'}, $_->{'setting'}, $_->{'enable'}, $_->{'disable'},
                    $feat->settingName($_->{'type'}, $_->{'setting'}));
    }

    my $subtables = $self->{'subtables'};
    foreach (@$subtables) {
        my $type = $_->{'type'};
        my $subFeatureFlags = $_->{'subFeatureFlags'};
        $fh->printf("\n\t%s table, %s, %s, subFeatureFlags = %08x # %s (%s)\n",
                    subtable_type_($type), $_->{'direction'}, $_->{'orientation'}, $subFeatureFlags,
                    "Default " . ((($subFeatureFlags & $defaultFlags) != 0) ? "On" : "Off"),
                    join(", ",
                        map {
                            join(": ", $feat->settingName($_->{'type'}, $_->{'setting'}) )
                        } grep { ($_->{'enable'} & $subFeatureFlags) != 0 } @$featureEntries
                    ) );

        $_->print($fh);
    }
}

sub subtable_type_
{
    my ($val) = @_;
    my ($res);

    my @types =    (
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

1;

=head1 BUGS

None known

=head1 AUTHOR

Jonathan Kew L<Jonathan_Kew@sil.org>. See L<PDF::API2::Basic::TTF::Font> for copyright and
licensing.

=cut

