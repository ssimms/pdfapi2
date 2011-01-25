#=======================================================================
#
#   THIS IS A REUSED PERL MODULE, FOR PROPER LICENCING TERMS SEE BELOW:
#
#   Copyright Martin Hosken <Martin_Hosken@sil.org>
#
#   No warranty or expression of effectiveness, least of all regarding
#   anyone's safety, is implied in this software or documentation.
#
#   This specific module is licensed under the Perl Artistic License.
#
#=======================================================================
package PDF::API2::Basic::PDF::Dict;

use base 'PDF::API2::Basic::PDF::Objind';

use strict;
no warnings qw[ deprecated recursion uninitialized ];

our $mincache;
our $tempbase;
our $cr = '(?:\015|\012|(?:\015\012))';

use PDF::API2::Basic::PDF::Filter;
use PDF::API2::Basic::PDF::Name;

BEGIN
{
    my $temp_dir = -d '/tmp' ? '/tmp' : $ENV{TMP} || $ENV{TEMP};
    $tempbase = sprintf("%s/%d-%d-0000", $temp_dir, $$, time());
    $mincache = 32768;
}

=head1 NAME

PDF::API2::Basic::PDF::Dict - PDF Dictionaries and Streams. Inherits from L<PDF::Objind>

=head1 INSTANCE VARIABLES

There are various special instance variables which are used to look after,
particularly, streams. Each begins with a space:

=over

=item stream

Holds the stream contents for output

=item streamfile

Holds the stream contents in an external file rather than in memory. This is
not the same as a PDF file stream. The data is stored in its unfiltered form.

=item streamloc

If both ' stream' and ' streamfile' are empty, this indicates where in the
source PDF the stream starts.

=back

=head1 METHODS

=cut

sub new
{
    my ($class, @opts) = @_;
    my ($self);

    $class = ref $class if ref $class;
    $self = $class->SUPER::new(@_);
    $self->{' realised'} = 1;
    return $self;
}


=head2 $d->outobjdeep($fh)

Outputs the contents of the dictionary to a PDF file. This is a recursive call.

It also outputs a stream if the dictionary has a stream element. If this occurs
then this method will calculate the length of the stream and insert it into the
stream's dictionary.

=cut

sub outobjdeep
{
    my ($self, $fh, $pdf, %opts) = @_;
    my ($key, $val, $f, @filts);
    my ($loc, $str, %specs, $len);

    if (defined $self->{' stream'} or defined $self->{' streamfile'} or defined $self->{' streamloc'})
    {
        if($self->{'Filter'} && $self->{' nofilt'})
        {
            $self->{Length}||= PDF::API2::Basic::PDF::Number->new(length($self->{' stream'}));
        }
        elsif($self->{'Filter'} || !defined $self->{' stream'})
        {
            $self->{'Length'} = PDF::API2::Basic::PDF::Number->new(0) unless (defined $self->{'Length'});
            $pdf->new_obj($self->{'Length'}) unless ($self->{'Length'}->is_obj($pdf));
        } 
        else 
        {
            $self->{'Length'} = PDF::API2::Basic::PDF::Number->new(length($self->{' stream'}));
            ## $self->{'Length'} = PDF::API2::Basic::PDF::Number->new(length($self->{' stream'}) + 1);
            ## this old code seams to burp acro6, lets see what breaks next -- fredo
        }
    }

    $fh->print("<< ");
    foreach ('Type', 'Subtype')
    {
        $specs{$_} = 1;
        if (defined $self->{$_})
        {
            $fh->print('/'.PDF::API2::Basic::PDF::Name::string_to_name($_).' ');
            $self->{$_}->outobj($fh, $pdf, %opts);
            $fh->print(" ");
        }
    }
    while (($key, $val) = each %{$self})
    {
        next if ($key =~ m/^[\s\-]/o || $specs{$key});
        next if (($val || '') eq '');
        $key = PDF::API2::Basic::PDF::Name::string_to_name ($key, $pdf);
        $fh->print("/$key ");
        $val->outobj($fh, $pdf, %opts);
        $fh->print(" ");
    }
    $fh->print('>>');

    #now handle the stream (if any)
    if (defined $self->{' streamloc'} && !defined $self->{' stream'})
    {                                   # read a stream if infile
        $loc = $fh->tell;
        $self->read_stream;
        $fh->seek($loc, 0);
    }

    if (!$self->{' nofilt'}
            && (defined $self->{' stream'} || defined $self->{' streamfile'})
            && defined $self->{'Filter'})
    {
        my ($hasflate) = -1;
        my ($temp, $i, $temp1);

        for ($i = 0; $i < scalar @{$self->{'Filter'}{' val'}}; $i++)
        {
            $temp = $self->{'Filter'}{' val'}[$i]->val;
            if ($temp eq 'LZWDecode')               # hack to get around LZW patent
            {
                if ($hasflate < -1)
                {
                    $hasflate = $i;
                    next;
                }
                $temp = 'FlateDecode';
                $self->{'Filter'}{' val'}[$i]{'val'} = $temp;      # !!!
            } elsif ($temp eq 'FlateDecode')
            { $hasflate = -2; }
            $temp1 = "PDF::API2::Basic::PDF::$temp";
            push (@filts, $temp1->new);
        }
        splice(@{$self->{'Filter'}{' val'}}, $hasflate, 1) if ($hasflate > -1);
    }

    if (defined $self->{' stream'}) {

        $fh->print(" stream\n");
        $loc = $fh->tell;
        $str = $self->{' stream'};
        unless ($self->{' nofilt'})
        {
            foreach $f (reverse @filts)
            { $str = $f->outfilt($str, 1); }
        }
        $fh->print($str);
        ## $fh->print("\n"); # newline goes into endstream

    } elsif (defined $self->{' streamfile'}) {

        open(DICTFH, $self->{' streamfile'}) || die "Unable to open $self->{' streamfile'}";
        binmode(DICTFH,':raw');

        $fh->print(" stream\n");
        $loc = $fh->tell;
        while (read(DICTFH, $str, 4096))
        {
            unless ($self->{' nofilt'})
            {
                foreach $f (reverse @filts)
                { $str = $f->outfilt($str, 0); }
            }
            $fh->print($str);
        }
        close(DICTFH);
        unless ($self->{' nofilt'})
        {
            $str = '';
            foreach $f (reverse @filts)
            { $str = $f->outfilt($str, 1); }
            $fh->print($str);
        }
        ## $fh->print("\n"); # newline goes into endstream
    }

    if (defined $self->{' stream'} or defined $self->{' streamfile'})
    {
        $len = $fh->tell - $loc;
        if ($self->{'Length'}{'val'} != $len)
        {
            $self->{'Length'}{'val'} = $len;
            $pdf->out_obj($self->{'Length'}) if ($self->{'Length'}->is_obj($pdf));
        }

        $fh->print("\nendstream"); # next is endobj which has the final cr
    }

}

=head2 $d->read_stream($force_memory)

Reads in a stream from a PDF file. If the stream is greater than
C<PDF::Dict::mincache> (defaults to 32768) bytes to be stored, then
the default action is to create a file for it somewhere and to use that
file as a data cache. If $force_memory is set, this caching will not
occur and the data will all be stored in the $self->{' stream'}
variable.

=cut

sub read_stream
{
    my ($self, $force_memory) = @_;
    my ($fh) = $self->{' streamsrc'};
    my (@filts, $f, $last, $i, $dat);
    my ($len) = $self->{'Length'}->val;

    $self->{' stream'} = '';

    if (defined $self->{'Filter'})
    {
        foreach $f ($self->{'Filter'}->elementsof)
        {
            my ($temp) = "PDF::API2::Basic::PDF::" . $f->val;
            push(@filts, $temp->new());
        }
    }

    $last = 0;
    if (defined $self->{' streamfile'})
    {
        unlink ($self->{' streamfile'});
        $self->{' streamfile'} = undef;
    }
    seek ($fh, $self->{' streamloc'}, 0);
    for ($i = 0; $i < $len; $i += 4096)
    {
        if ($i + 4096 > $len)
        {
            $last = 1;
            read($fh, $dat, $len - $i);
        }
        else
        { read($fh, $dat, 4096); }

        foreach $f (@filts)
        { $dat = $f->infilt($dat, $last); }
        if (!$force_memory && !defined $self->{' streamfile'} && ((length($dat) * 2) > $mincache))
        {
            open (DICTFH, ">$tempbase") || next;
            binmode(DICTFH,':raw');
            $self->{' streamfile'} = $tempbase;
            $tempbase =~ s/-(\d+)$/"-" . ($1 + 1)/oe;        # prepare for next use
            print DICTFH $self->{' stream'};
            undef $self->{' stream'};
        }
        if (defined $self->{' streamfile'})
        { print DICTFH $dat; }
        else
        { $self->{' stream'} .= $dat; }
    }

    close DICTFH if (defined $self->{' streamfile'});
    $self->{' nofilt'} = 0;
    $self;
}

=head2 $d->val

Returns the dictionary, which is itself.

=cut

sub val
{ $_[0]; }

1;
