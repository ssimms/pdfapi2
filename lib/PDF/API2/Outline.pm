package PDF::API2::Outline;

use base 'PDF::API2::Basic::PDF::Dict';

use strict;
use warnings;

# VERSION

use Carp qw(croak);
use PDF::API2::Basic::PDF::Utils;
use Scalar::Util qw(weaken);

=head1 NAME

PDF::API2::Outline - Manage PDF outlines (a.k.a. bookmarks)

=head1 METHODS

=over

=item $outline = PDF::API2::Outline->new($api, $parent, $prev)

Returns a new outline object (called from $outlines->outline()).

=cut

sub new {
    my ($class, $api, $parent, $prev) = @_;
    my $self = $class->SUPER::new();
    $self->{'Parent'}  = $parent if defined $parent;
    $self->{'Prev'}    = $prev   if defined $prev;
    $self->{' api'}    = $api;
    weaken $self->{' api'};
    return $self;
}

sub parent {
    my $self = shift();
    $self->{'Parent'} = shift() if defined $_[0];
    return $self->{'Parent'};
}

sub prev {
    my $self = shift();
    $self->{'Prev'} = shift() if defined $_[0];
    return $self->{'Prev'};
}

sub next {
    my $self = shift();
    $self->{'Next'} = shift() if defined $_[0];
    return $self->{'Next'};
}

sub first {
    my $self = shift();
    $self->{'First'} = $self->{' children'}->[0] if defined $self->{' children'} and defined $self->{' children'}->[0];
    return $self->{'First'};
}

sub last {
    my $self = shift();
    $self->{'Last'} = $self->{' children'}->[-1] if defined $self->{' children'} and defined $self->{' children'}->[-1];
    return $self->{'Last'};
}

sub count {
    my $self  = shift();
    my $count = scalar @{$self->{' children'} || []};
    $count += $_->count() for @{$self->{' children'}};
    $self->{'Count'} = PDFNum($self->{' closed'} ? -$count : $count) if $count > 0;
    return $count;
}

sub fix_outline {
    my $self = shift();
    $self->first();
    $self->last();
    $self->count();
}

=item $outline->title($text)

Set the title of the outline.

=cut

sub title {
    my ($self, $text) = @_;
    $self->{'Title'} = PDFStr($text);
    return $self;
}

=item $outline->closed()

Set the status of the outline to closed (i.e. collapsed).

=cut

sub closed {
    my $self = shift();
    $self->{' closed'} = 1;
    return $self;
}

=item $outline->open()

Set the status of the outline to open (i.e. expanded).

=cut

sub open {
    my $self = shift();
    delete $self->{' closed'};
    return $self;
}

=item $child_outline = $parent_outline->outline()

Returns a nested outline.

=cut

sub outline {
    my $self = shift();

    my $child = PDF::API2::Outline->new($self->{' api'}, $self);
    $child->prev($self->{' children'}->[-1]) if defined $self->{' children'};
    $self->{' children'}->[-1]->next($child) if defined $self->{' children'};
    push @{$self->{' children'}}, $child;
    $self->{' api'}->{'pdf'}->new_obj($child) unless $child->is_obj($self->{' api'}->{'pdf'});

    return $child;
}

=item $outline->dest($page_object, %position)

Sets the destination page and optional position of the outline.

%position can be any of the following:

=over

=item -fit => 1

Display the page designated by page, with its contents magnified just enough to
fit the entire page within the window both horizontally and vertically. If the
required horizontal and vertical magnification factors are different, use the
smaller of the two, centering the page within the window in the other dimension.

=item -fith => $top

Display the page designated by page, with the vertical coordinate $top
positioned at the top edge of the window and the contents of the page magnified
just enough to fit the entire width of the page within the window.

=item -fitv => $left

Display the page designated by page, with the horizontal coordinate $left
positioned at the left edge of the window and the contents of the page magnified
just enough to fit the entire height of the page within the window.

=item -fitr => [$left, $bottom, $right, $top]

Display the page designated by page, with its contents magnified just enough to
fit the rectangle specified by the coordinates $left, $bottom, $right, and $top
entirely within the window both horizontally and vertically. If the required
horizontal and vertical magnification factors are different, use the smaller of
the two, centering the rectangle within the window in the other dimension.

=item -fitb => 1

Display the page designated by page, with its contents magnified just enough to
fit its bounding box entirely within the window both horizontally and
vertically. If the required horizontal and vertical magnification factors are
different, use the smaller of the two, centering the bounding box within the
window in the other dimension.

=item -fitbh => $top

Display the page designated by page, with the vertical coordinate $top
positioned at the top edge of the window and the contents of the page magnified
just enough to fit the entire width of its bounding box within the window.

=item -fitbv => $left

Display the page designated by page, with the horizontal coordinate $left
positioned at the left edge of the window and the contents of the page magnified
just enough to fit the entire height of its bounding box within the window.

=item -xyz => [$left, $top, $zoom]

Display the page designated by page, with the coordinates ($left, $top)
positioned at the top-left corner of the window and the contents of the page
magnified by the factor $zoom. A zero (0) value for any of the parameters $left,
$top, or $zoom specifies that the current value of that parameter is to be
retained unchanged.

=back

=item $outline->dest($name)

Connect the outline to a "Named Destination" defined elsewhere.

=cut

sub dest {
    my ($self, $page, %options) = @_;
    delete $self->{'A'};

    if (ref($page)) {
        $options{'-xyz'} = [undef, undef, undef] unless scalar keys %options;
        $self->{'Dest'} = _fit($page, %options);
    }
    else {
        $self->{'Dest'} = PDFStr($page);
    }

    return $self;
}

=item $outline->url($url)

Launch $url when the outline item is activated.

=cut

sub url {
    my ($self, $url) = @_;
    delete $self->{'Dest'};

    $self->{'A'}          = PDFDict();
    $self->{'A'}->{'S'}   = PDFName('URI');
    $self->{'A'}->{'URI'} = PDFStr($url);

    return $self;
}

=item $outline->file($filename)

Launch an application or file when the outline item is activated

=cut

sub file {
    my ($self, $file) = @_;
    delete $self->{'Dest'};

    $self->{'A'}        = PDFDict();
    $self->{'A'}->{'S'} = PDFName('Launch');
    $self->{'A'}->{'F'} = PDFStr($file);

    return $self;
}

=item $outline->pdf_file($filename, $page_number, %position)

Open a PDF file to a particular page number (first page is zero, which is also
the default).  The page can optionally be positioned at a particular place in
the viewport (see dest for details).

=cut

# Deprecated
sub pdfile { return pdf_file(@_) }

sub pdf_file {
    my ($self, $file, $page_number, %options) = @_;
    delete $self->{'Dest'};

    $self->{'A'}        = PDFDict();
    $self->{'A'}->{'S'} = PDFName('GoToR');
    $self->{'A'}->{'F'} = PDFStr($file);
    $self->{'A'}->{'D'} = _fit(PDFNum($page_number // 0), %options);

    return $self;
}

sub _fit {
    my ($destination, %options) = @_;
    if (defined $options{'-fit'}) {
        return PDFArray($destination, PDFName('Fit'));
    }
    elsif (defined $options{'-fith'}) {
        return PDFArray($destination, PDFName('FitH'), PDFNum($options{'-fith'}));
    }
    elsif (defined $options{'-fitb'}) {
        return PDFArray($destination, PDFName('FitB'));
    }
    elsif (defined $options{'-fitbh'}) {
        return PDFArray($destination, PDFName('FitBH'), PDFNum($options{'-fitbh'}));
    }
    elsif (defined $options{'-fitv'}) {
        return PDFArray($destination, PDFName('FitV'), PDFNum($options{'-fitv'}));
    }
    elsif (defined $options{'-fitbv'}) {
        return PDFArray($destination, PDFName('FitBV'), PDFNum($options{'-fitbv'}));
    }
    elsif (defined $options{'-fitr'}) {
        croak "Incorrect number of parameters (expected four) to -fitr" unless scalar @{$options{'-fitr'}} == 4;
        return PDFArray($destination, PDFName('FitR'), map { PDFNum($_) } @{$options{'-fitr'}});
    }
    elsif (defined $options{'-xyz'}) {
        croak "Incorrect number parameters (expected three) to -xyz" unless scalar @{$options{'-xyz'}} == 3;
        return PDFArray($destination, PDFName('XYZ'), map { defined $_ ? PDFNum($_) : PDFNull() } @{$options{'-xyz'}});
    }

    return;
}

sub outobjdeep {
    my $self = shift();
    $self->fix_outline();
    return $self->SUPER::outobjdeep(@_);
}

=back

=cut

1;
