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

=head1 SYNOPSIS

    # Get/create the top-level outline tree
    my $outlines = $pdf->outlines();

    # Add an entry
    my $outline = $outlines->outline();
    $outline->title("First Page");
    $outline->destination($pdf->open_page(1));

=head1 METHODS

=cut

sub new {
    my ($class, $api, $parent, $prev) = @_;
    my $self = $class->SUPER::new();
    $self->{'Parent'} = $parent if defined $parent;
    $self->{'Prev'}   = $prev   if defined $prev;
    $self->{' api'}   = $api;
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
    if (defined $self->{' children'} and defined $self->{' children'}->[0]) {
        $self->{'First'} = $self->{' children'}->[0];
    }
    return $self->{'First'};
}

sub last {
    my $self = shift();
    if (defined $self->{' children'} and defined $self->{' children'}->[-1]) {
        $self->{'Last'} = $self->{' children'}->[-1];
    }
    return $self->{'Last'};
}

sub count {
    my $self = shift();

    # Set count to the number of descendant items that will be visible when the
    # current item is open.
    my $count = 0;
    if ($self->has_children()) {
        $count += @{$self->{' children'}};
        foreach my $child (@{$self->{' children'}}) {
            next unless $child->has_children();
            next unless $child->is_open();
            $count += $child->count();
        }
    }

    if ($count) {
        $self->{'Count'} = PDFNum($self->is_open() ? $count : -$count);
    }

    return $count;
}

sub has_children {
    my $self = shift();
    return unless $self->{' children'};
    return @{$self->{' children'}} > 0;
}

=head2 outline

    $child_outline = $parent_outline->outline();

Add an entry at the end of the current outline.

=cut

sub outline {
    my $self = shift();

    my $child = PDF::API2::Outline->new($self->{' api'}, $self);
    $child->prev($self->{' children'}->[-1]) if defined $self->{' children'};
    $self->{' children'}->[-1]->next($child) if defined $self->{' children'};
    push @{$self->{' children'}}, $child;
    unless ($child->is_obj($self->{' api'}->{'pdf'})) {
        $self->{' api'}->{'pdf'}->new_obj($child);
    }

    return $child;
}

=head2 title

    # Get
    my $title = $outline->title();

    # Set
    $outline = $outline->title($text);

Get/set the title of the outline item.

=cut

sub title {
    my $self = shift();

    # Get
    unless (@_) {
        return unless $self->{'Title'};
        return $self->{'Title'}->val();
    }

    # Set
    my $text = shift();
    $self->{'Title'} = PDFStr($text);
    return $self;
}

=head2 destination

    $outline = $outline->destination($destination, $location, @args);

Set the destination page and optional position of the outline.  C<$location> and
C<@args> are as defined in L<PDF::API2::NamedDestination/"destination">.

C<$destination> can optionally be the name of a named destination defined
elsewhere.

=cut

sub _destination {
    require PDF::API2::NamedDestination;
    return PDF::API2::NamedDestination::_destination(@_);
}

sub destination {
    my ($self, $destination, $location, @args) = @_;

    # Remove an existing action dictionary
    delete $self->{'A'};

    if (ref($destination)) {
        # Page Destination
        $self->{'Dest'} = _destination($destination, $location, @args);
    }
    else {
        # Named Destination
        $self->{'Dest'} = PDFStr($destination);
    }

    return $self;
}

# Deprecated: Use destination with the indicated changes
sub dest {
    my ($self, $destination, $location, @args) = @_;

    # Replace -fit => 1 or -fitb => 1 with just the location
    if (defined $location) {
        @args = () if $location eq '-fit' or $location eq '-fitb';
    }

    # Convert args from arrayref to array
    @args = @{$args[0]} if @args and ref($args[0]) eq 'ARRAY';

    # Remove hyphen prefix from location
    $location =~ s/^-// if defined $location;

    return $self->destination($destination, $location, @args);
}

=head2 is_open

    # Get
    my $boolean = $outline->is_open();

    # Set
    my $outline = $outline->is_open($boolean);

Get/set whether the outline is expanded or collapsed.

=cut

sub is_open {
    my $self = shift();

    # Get
    unless (@_) {
        my $count = $self->count();
        return unless $count;
        return $self->count() > 0;
    }

    # Set
    my $is_open = shift();
    if ($is_open) {
        delete $self->{' closed'};
    }
    else {
        $self->{' closed'} = 1;
    }

    return $self;
}

# Deprecated
sub open {
    my $self = shift();
    return $self->is_open(1);
}

# Deprecated
sub closed {
    my $self = shift();
    return $self->is_open(0);
}

=head2 uri

    $outline = $outline->uri($uri);

Launch a URI -- typically a web page -- when the outline item is activated.

=cut

# Deprecated (renamed)
sub url { return uri(@_) }

sub uri {
    my ($self, $uri) = @_;
    delete $self->{'Dest'};

    $self->{'A'}          = PDFDict();
    $self->{'A'}->{'S'}   = PDFName('URI');
    $self->{'A'}->{'URI'} = PDFStr($uri);

    return $self;
}

=head2 launch

    $outline->launch($file);

Launch an application or file when the outline item is activated.

=cut

# Deprecated (renamed)
sub file { return launch(@_) }

sub launch {
    my ($self, $file) = @_;
    delete $self->{'Dest'};

    $self->{'A'}        = PDFDict();
    $self->{'A'}->{'S'} = PDFName('Launch');
    $self->{'A'}->{'F'} = PDFStr($file);

    return $self;
}

=head2 pdf

    $outline = $outline->pdf($filename, $page_number, $location, @args);

Open another PDF file to a particular page number (first page is zero, which is
also the default).  The page can optionally be positioned at a particular
location if C<$location> and C<@args> are set -- see
L<PDF::API2::NamedDestination/"destination"> for possible settings.

=cut

# Deprecated (renamed)
sub pdfile { return pdf_file(@_) }

# Deprecated; use pdf instead, with the indicated changes
sub pdf_file {
    my ($self, $file, $page_number, $location, @args);

    # Replace -fit => 1 or -fitb => 1 with just the location
    if (defined $location) {
        @args = () if $location eq '-fit' or $location eq '-fitb';
    }

    # Convert args from arrayref to array
    @args = @{$args[0]} if @args and ref($args[0]) eq 'ARRAY';

    # Remove hyphen prefix from location
    $location =~ s/^-// if defined $location;

    return $self->pdf($file, $page_number, $location, @args);
}

sub pdf {
    my ($self, $file, $page_number, $location, @args) = @_;
    $page_number //= 0;
    delete $self->{'Dest'};

    $self->{'A'}        = PDFDict();
    $self->{'A'}->{'S'} = PDFName('GoToR');
    $self->{'A'}->{'F'} = PDFStr($file);

    $self->{'A'}->{'D'} = _destination(PDFNum($page_number), $location, @args);

    return $self;
}

sub fix_outline {
    my $self = shift();
    $self->first();
    $self->last();
    $self->count();
}

sub outobjdeep {
    my $self = shift();
    $self->fix_outline();
    return $self->SUPER::outobjdeep(@_);
}

1;
