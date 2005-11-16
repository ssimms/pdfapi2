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
package PDF::API2::Basic::PDF::Pages;

use strict;
use vars qw(@ISA);
@ISA = qw(PDF::API2::Basic::PDF::Dict);
no warnings qw[ deprecated recursion uninitialized ];

use PDF::API2::Basic::PDF::Dict;
use PDF::API2::Basic::PDF::Utils;

=head1 NAME

PDF::API2::Basic::PDF::Pages - a PDF pages hierarchical element. Inherits from L<PDF::API2::Basic::PDF::Dict>

=head1 DESCRIPTION

A Pages object is the parent to other pages objects or to page objects
themselves.

=head1 METHODS

=head2 PDF::API2::Basic::PDF::Pages->new($pdfs,$parent)

This creates a new Pages object. Notice that $parent here is not the
file context for the object but the parent pages object for this
pages. If we are using this class to create a root node, then $parent
should point to the file context, which is identified by not having a
Type of Pages.  $pdfs is the file object (or objects) in which to
create the new Pages object.

=cut

sub new
{
    my ($class, $pdfs, $parent) = @_;
    my ($self);

    $class = ref $class if ref $class;
    $self = $class->SUPER::new($pdfs, $parent);
    $self->{'Type'} = PDFName("Pages");
    $self->{'Parent'} = $parent if defined $parent;
    $self->{'Count'} = PDFNum(0);
    $self->{'Kids'} = PDF::API2::Basic::PDF::Array->new;
    $self->{' outto'} = ref $pdfs eq 'ARRAY' ? $pdfs : [$pdfs];
    $self->out_obj(1);

    $self;
}


=head2 $p->out_obj($isnew)

Tells all the files that this thing is destined for that they should output this
object come time to output. If this object has no parent, then it must be the
root. So set as the root for the files in question and tell it to be output too.
If $isnew is set, then call new_obj rather than out_obj to create as a new
object in the file.

=cut

sub out_obj
{
    my ($self, $isnew) = @_;

    foreach (@{$self->{' outto'}})
    {
        if ($isnew)
        { $_->new_obj($self); }
        else
        { $_->out_obj($self); }

        unless (defined $self->{'Parent'})
        {
            $_->{'Root'}{'Pages'} = $self;
            $_->out_obj($_->{'Root'});
        }
    }
    $self;
}

=head2 $p->add_page($page, $index)

Appends a page to this pages object. This subroutine only handles adding pages
at the end of the list. But it does at least make sure there is only 8 entries
in any pages list, and keep track of all the counts etc.

$index, if set, specifies the page number that the page should be inserted
before. If 0, the page is appended to the file. If -ve then counts from the end.

=cut

sub add_page
{
    my ($self, $page, $index) = @_;
    my ($p, $nt, $s, @path, $c, $m);
    $index ||= 0;           # keep perl -w happy :(

    for ($p = $self; defined $p->{'Parent'}; $p = $p->{'Parent'})
    { }

    if (!defined $index or $index <= 0)
    {
        @path = ([$p, ($#{$p->{'Kids'}{' val'}}) x 2]);
        for ($s = $p->{'Kids'}{' val'}[-1]; defined $s && $s->realise->{'Type'}{'val'} eq 'Pages'; $s = $s->{'Kids'}{' val'}[-1])
        { unshift (@path, [$s, ($#{$s->{'Kids'}{' val'}}) x 2]); }
    } else
    {
        @path = ([$p, 0, $#{$p->{'Kids'}{' val'}}]);
        for ($s = $p->{'Kids'}{' val'}[0]; defined $s && $s->realise->{'Type'}{'val'} eq 'Pages'; $s = $s->{'Kids'}{' val'}[0])
        { unshift (@path, [$s, 0, $#{$s->{'Kids'}{' val'}}]); }
    }

    unless (defined $s)
    {
        $p->{'Kids'}->add_elements($page);
        $p->{'Count'}{'val'} = 1;
        $page->{'Parent'} = $p;
        return $self;
    }

    ($p, $c, $m) = @{$path[0]};

    $c++ if ($index == 0);

    $index++ if ($index < 0);
    while ($index < 0)
    {
        ($p, $c, $m) = @{$path[0]};
        while (--$c < 0)
        {
            shift(@path);
            return undef if (scalar @path == 0);
            ($p, $c, $m) = @{$path[0]};
        }
        $path[0] = [$p, $c, $m];
        for ($s = $p->{'Kids'}{' val'}[$c]; defined $s && $s->realise->{'Type'}{'val'} eq 'Pages'; $s = $s->{'Kids'}{' val'}[-1])
        { unshift (@path, [$s, ($#{$s->{'Kids'}{' val'}}) x 2]); }
        $index++;
    }

    $index-- if ($index > 0);
    while ($index > 0)
    {
        ($p, $c, $m) = @{$path[0]};
        while (++$c > $m)
        {
            shift(@path);
            return undef if (scalar @path == 0);
            ($p, $c, $m) = @{$path[0]};
        }
        $path[0] = [$p, $c, $m];
        for ($s = $p->{'Kids'}{' val'}[$c]; defined $s && $s->realise->{'Type'}{'val'} eq 'Pages'; $s = $s->{'Kids'}{' val'}[0])
        { unshift (@path, [$s, 0, $#{$s->{'Kids'}{' val'}}]); }
        $index--;
    }

    while (scalar @path > 1 && $m >= 7 && ($c == 0 || $c > $m))
    {
        shift(@path);
        if ($c > $m)
        {
            ($p, $c, $m) = @{$path[0]};
            $c++;
        } else
        { ($p, $c, $m) = @{$path[0]}; }
    }

    if ($#path <= 0 && $m >= 7)
    {
        $nt = {%$p};
        delete $nt->{' uid'};
        bless $nt, ref $p;
        $nt->{'Kids'} = PDFArray();
        $nt->{'Count'} = PDFNum($p->{'Count'}{'val'});
        $nt->{' outto'} = $page->{' outto'} unless defined $nt->{' outto'};
        $nt->out_obj(1);

        $p->{'Parent'} = $nt;
        $nt->{'Count'}{'val'} = $p->{'Count'}{'val'};
        $nt->{'Kids'}->add_elements($p);
        $p = $nt;
    }

    if ($p ne $s->{'Parent'})
    {
        $nt = $p->new($p->{' outto'} || $page->{' outto'}, $p);
    if($c >= scalar @{$p->{'Kids'}{' val'}}) {
            push(@{$p->{'Kids'}{' val'}},$nt);
    } else {
        splice(@{$p->{'Kids'}{' val'}}, $c, 0, $nt);
    }
        $p->{' outto'} = $page->{' outto'} unless defined $p->{' outto'};
        $p->out_obj;
        $p = $nt;
        unshift(@path, [$p, 0, 1]);
        $c = 0; $m = 1;
    }
    splice(@{$p->{'Kids'}{' val'}}, $c, 0, $page);
    $page->{'Parent'} = $p;
    $p->{' outto'} = $page->{' outto'} unless defined $p->{' outto'};
    $p->out_obj;

    for (; defined $p->{'Parent'}; $p = $p->{'Parent'})
    {
        $p->{'Count'}{'val'}++;
        $p->{' outto'} = $page->{' outto'} unless defined $p->{' outto'};
        $p->out_obj;
    }
    $p->{'Count'}{'val'}++;
    $p->{' outto'} = $page->{' outto'} unless defined $p->{' outto'};
    $p->out_obj;
    $self;
}


=head2 $p->find_prop($key)

Searches up through the inheritance tree to find a property.

=cut

sub find_prop
{
    my ($self, $prop) = @_;

    if (defined $self->{$prop})
    {
        if (ref $self->{$prop} && $self->{$prop}->isa("PDF::API2::Basic::PDF::Objind"))
        { return $self->{$prop}->realise; }
        else
        { return $self->{$prop}; }
    } elsif (defined $self->{'Parent'})
    { return $self->{'Parent'}->find_prop($prop); }
    return undef;
}


=head2 $p->add_font($pdf, $font)

Creates or edits the resource dictionary at this level in the hierarchy. If
the font is already supported even through the hierarchy, then it is not added.

=cut

sub add_font
{
    my ($self, $font, $pdf) = @_;
    my ($name) = $font->{'Name'}->val;
    my ($dict) = $self->find_prop('Resources');
    my ($rdict);

    return $self if ($dict ne "" && defined $dict->{'Font'} && defined $dict->{'Font'}{$name});
    unless (defined $self->{'Resources'})
    {
        $dict = $dict ne "" ? $dict->copy($pdf) : PDFDict();
        $self->{'Resources'} = $dict;
    }
    else
    { $dict = $self->{'Resources'}; }
    $dict->{'Font'} = PDFDict() unless defined $self->{'Resources'}{'Font'};
    $rdict = $dict->{'Font'}->val;
    $rdict->{$name} = $font unless ($rdict->{$name});
    if (ref $dict ne 'HASH' && $dict->is_obj($pdf))
    { $pdf->out_obj($dict); }
    if (ref $rdict ne 'HASH' && $rdict->is_obj($pdf))
    { $pdf->out_obj($rdict); }
    $self;
}


=head2 $p->bbox($xmin, $ymin, $xmax, $ymax, [$param])

Specifies the bounding box for this and all child pages. If the values are
identical to those inherited then no change is made. $param specifies the attribute
name so that other 'bounding box'es can be set with this method.

=cut

sub bbox
{
    my ($self, @bbox) = @_;
    my ($str) = $bbox[4] || 'MediaBox';
    my ($inh) = $self->find_prop($str);
    my ($test, $i, $e);

    if ($inh ne "")
    {
        $test = 1; $i = 0;
        foreach $e ($inh->elementsof)
        { $test &= $e->val == $bbox[$i++]; }
        return $self if $test && $i == 4;
    }

    $inh = PDF::API2::Basic::PDF::Array->new;
    foreach $e (@bbox[0..3])
    { $inh->add_elements(PDFNum($e)); }
    $self->{$str} = $inh;
    $self;
}


=head2 $p->proc_set(@entries)

Ensures that the current resource contains all the entries in the proc_sets
listed. If necessary it creates a local resource dictionary to achieve this.

=cut

sub proc_set
{
    my ($self, @entries) = @_;
    my (@temp) = @entries;
    my ($dict, $e);

    $dict = $self->find_prop('Resource');
    if ($dict ne "" && defined $dict->{'ProcSet'})
    {
        foreach $e ($dict->{'ProcSet'}->elementsof)
        { @temp = grep($_ ne $e, @temp); }
        return $self if (scalar @temp == 0);
        @entries = @temp if defined $self->{'Resources'};
    }

    unless (defined $self->{'Resources'})
    { $self->{'Resources'} = $dict ne "" ? $dict->copy : PDFDict(); }

    $self->{'Resources'}{'ProcSet'} = PDFArray() unless defined $self->{'ProcSet'};

    foreach $e (@entries)
    { $self->{'Resources'}{'ProcSet'}->add_elements(PDFName($e)); }
    $self;
}

sub empty
{
    my ($self) = @_;
    my ($parent) = $self->{'Parent'} if defined ($self->{'Parent'});

    $self->SUPER::empty;
    $self->{'Parent'} = $parent if defined $parent;
    $self;
}

1;
__END__

