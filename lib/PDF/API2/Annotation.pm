package PDF::API2::Annotation;

use base 'PDF::API2::Basic::PDF::Dict';

use strict;
use warnings;

# VERSION

use PDF::API2::Basic::PDF::Utils;

=head1 NAME

PDF::API2::Annotation - Add annotations to a PDF

=head1 METHODS

=over

=item $annotation = PDF::API2::Annotation->new()

Returns an annotation object (called from $page->annotation()).

=cut

sub new {
    my $class = shift();
    my $self = $class->SUPER::new();
    $self->{'Type'}   = PDFName('Annot');
    $self->{'Border'} = PDFArray(PDFNum(0), PDFNum(0), PDFNum(0));
    return $self;
}

=item $annotation->link($page, %options)

Link the annotation to another page in this PDF.

Accepts options -rect, -border, and any of the options listed under dest().

=cut

sub link {
    my ($self, $page, %options) = @_;
    $self->{'Subtype'} = PDFName('Link');
    if (ref($page)) {
        $self->{'A'} = PDFDict();
        $self->{'A'}->{'S'} = PDFName('GoTo');
    }
    $self->dest($page, %options);
    $self->rect(@{$options{'-rect'}})     if defined $options{'-rect'};
    $self->border(@{$options{'-border'}}) if defined $options{'-border'};
    return $self;
}

=item $annotation->url($url, %options)

Launch $url when the annotation is selected.

Accepts options -rect and -border.

=cut

sub url {
    my ($self, $url, %options) = @_;
    $self->{'Subtype'}  = PDFName('Link');
    $self->{'A'}        = PDFDict();
    $self->{'A'}->{'S'} = PDFName('URI');
    if (is_utf8($url)) {
        # URI must be 7-bit ascii
        utf8::downgrade($url);
    }
    $self->{'A'}->{'URI'} = PDFStr($url);
    $self->rect(@{$options{'-rect'}})     if defined $options{'-rect'};
    $self->border(@{$options{'-border'}}) if defined $options{'-border'};
    return $self;
}

=item $annotation->file($filename, %options)

Open $filename when the annotation is selected.

Accepts options -rect and -border.

=cut

sub file {
    my ($self, $url, %options) = @_;
    $self->{'Subtype'}  = PDFName('Link');
    $self->{'A'}        = PDFDict();
    $self->{'A'}->{'S'} = PDFName('Launch');
    if (is_utf8($url)) {
        # URI must be 7-bit ascii
        utf8::downgrade($url);
    }
    $self->{'A'}->{'F'} = PDFStr($url);
    $self->rect(@{$options{'-rect'}})     if defined $options{'-rect'};
    $self->border(@{$options{'-border'}}) if defined $options{'-border'};
    return $self;
}

=item $annotation->pdf_file($filename, $page_number, %options)

Open the PDF file located at $filename to the specified page number.

Accepts options -rect, -border, and any of the options listed under dest().

=cut

# Deprecated
sub pdfile { return pdf_file(@_) }

sub pdf_file {
    my ($self, $url, $page_number, %options) = @_;
    $self->{'Subtype'}  = PDFName('Link');
    $self->{'A'}        = PDFDict();
    $self->{'A'}->{'S'} = PDFName('GoToR');
    if (is_utf8($url)) {
        # URI must be 7-bit ascii
        utf8::downgrade($url);
    }
    $self->{'A'}->{'F'} = PDFStr($url);
    $self->dest(PDFNum($page_number), %options);
    $self->rect(@{$options{'-rect'}})     if defined $options{'-rect'};
    $self->border(@{$options{'-border'}}) if defined $options{'-border'};
    return $self;
}

=item $annotation->text($text, %options)

Define the annotation as a text note with the specified content.

Accepts options -rect and -open.

=cut

sub text {
    my ($self, $text, %options) = @_;
    $self->{'Subtype'} = PDFName('Text');
    $self->content($text);
    $self->rect(@{$options{'-rect'}}) if defined $options{'-rect'};
    $self->open($options{'-open'})    if defined $options{'-open'};
    return $self;
}

=item $annotation->movie($filename, $content_type, %options)

Embed and link to the movie located at $filename with the specified MIME type.

Accepts a -rect option.

=cut

sub movie {
    my ($self, $file, $content_type, %options) = @_;
    $self->{'Subtype'}      = PDFName('Movie');
    $self->{'A'}            = PDFBool(1);
    $self->{'Movie'}        = PDFDict();
    $self->{'Movie'}->{'F'} = PDFDict();

    $self->{' apipdf'}->new_obj($self->{'Movie'}->{'F'});
    my $f = $self->{'Movie'}->{'F'};
    $f->{'Type'}          = PDFName('EmbeddedFile');
    $f->{'Subtype'}       = PDFName($content_type);
    $f->{' streamfile'} = $file;

    $self->rect(@{$options{'-rect'}}) if defined $options{'-rect'};
    return $self;
}

=item $annotation->rect($llx, $lly, $urx, $ury)

Define the rectangle around the annotation.

=cut

sub rect {
    my ($self, @coordinates) = @_;
    die "Incorrect number of parameters (expected four) for rectangle" unless scalar @coordinates == 4;
    $self->{'Rect'} = PDFArray(map { PDFNum($_) } $coordinates[0], $coordinates[1], $coordinates[2], $coordinates[3]);
    return $self;
}

=item $annotation->border($horizontal_corner_radius, $vertical_corner_radius, $width)

Define the border style.  Defaults to 0, 0, 1.

=cut

sub border {
    my ($self, @attributes) = @_;
    die "Incorrect number of parameters (expected three) for border" unless scalar @attributes == 3;
    $self->{'Border'} = PDFArray(map { PDFNum($_) } $attributes[0], $attributes[1], $attributes[2]);
    return $self;
}

=item $annotation->content(@lines)

Define the text content of the annotation, if applicable.

=cut

sub content {
    my ($self, @lines) = @_;
    my $text = join("\n", @lines);
    $self->{'Contents'} = PDFStr($text);
    return $self;
}

sub name {
    my ($self, $name) = @_;
    $self->{'Name'} = PDFName($name);
    return $self;
}

=item $annotation->open($boolean)

Display the annotation either open or closed, if applicable.

=cut

sub open {
    my ($self, $value) = @_;
    $self->{'Open'} = PDFBool($value ? 1 : 0);
    return $self;
}

=item $annotation->dest( $page, -fit => 1 )

Display the page designated by page, with its contents magnified just enough to
fit the entire page within the window both horizontally and vertically. If the
required horizontal and vertical magnification factors are different, use the
smaller of the two, centering the page within the window in the other dimension.

=item $annotation->dest( $page, -fith => $top )

Display the page designated by page, with the vertical coordinate top positioned
at the top edge of the window and the contents of the page magnified just enough
to fit the entire width of the page within the window.

=item $annotation->dest( $page, -fitv => $left )

Display the page designated by page, with the horizontal coordinate left positioned
at the left edge of the window and the contents of the page magnified just enough
to fit the entire height of the page within the window.

=item $annotation->dest( $page, -fitr => [ $left, $bottom, $right, $top ] )

Display the page designated by page, with its contents magnified just enough to
fit the rectangle specified by the coordinates left, bottom, right, and top
entirely within the window both horizontally and vertically. If the required
horizontal and vertical magnification factors are different, use the smaller of
the two, centering the rectangle within the window in the other dimension.

=item $annotation->dest( $page, -fitb => 1 )

(PDF 1.1) Display the page designated by page, with its contents magnified just
enough to fit its bounding box entirely within the window both horizontally and
vertically. If the required horizontal and vertical magnification factors are
different, use the smaller of the two, centering the bounding box within the
window in the other dimension.

=item $annotation->dest( $page, -fitbh => $top )

(PDF 1.1) Display the page designated by page, with the vertical coordinate top
positioned at the top edge of the window and the contents of the page magnified
just enough to fit the entire width of its bounding box within the window.

=item $annotation->dest( $page, -fitbv => $left )

(PDF 1.1) Display the page designated by page, with the horizontal coordinate
left positioned at the left edge of the window and the contents of the page
magnified just enough to fit the entire height of its bounding box within the
window.

=item $annotation->dest( $page, -xyz => [ $left, $top, $zoom ] )

Display the page designated by page, with the coordinates (left, top) positioned
at the top-left corner of the window and the contents of the page magnified by
the factor zoom. A zero (0) value for any of the parameters left, top, or zoom
specifies that the current value of that parameter is to be retained unchanged.

=item $annotation->dest( $name )

(PDF 1.2) Connect the Annotation to a "Named Destination" defined elsewhere.

=cut

sub dest {
    my ($self, $page, %options) = @_;

    if (ref($page)) {
        $options{'-xyz'} = [undef, undef, undef] unless scalar keys %options;

        $self->{'A'} ||= PDFDict();

        if (defined $options{'-fit'}) {
            $self->{'A'}->{'D'} = PDFArray($page, PDFName('Fit'));
        }
        elsif (defined $options{'-fith'}) {
            $self->{'A'}->{'D'} = PDFArray($page, PDFName('FitH'), PDFNum($options{'-fith'}));
        }
        elsif (defined $options{'-fitb'}) {
            $self->{'A'}->{'D'} = PDFArray($page, PDFName('FitB'));
        }
        elsif (defined $options{'-fitbh'}) {
            $self->{'A'}->{'D'} = PDFArray($page, PDFName('FitBH'), PDFNum($options{'-fitbh'}));
        }
        elsif (defined $options{'-fitv'}) {
            $self->{'A'}->{'D'} = PDFArray($page, PDFName('FitV'), PDFNum($options{'-fitv'}));
        }
        elsif (defined $options{'-fitbv'}) {
            $self->{'A'}->{'D'} = PDFArray($page, PDFName('FitBV'), PDFNum($options{'-fitbv'}));
        }
        elsif (defined $options{'-fitr'}) {
            die "insufficient parameters to ->dest( page, -fitr => [] ) " unless scalar @{$options{'-fitr'}} == 4;
            $self->{'A'}->{'D'} = PDFArray($page, PDFName('FitR'), map { PDFNum($_) } @{$options{'-fitr'}});
        }
        elsif (defined $options{'-xyz'}) {
            die "insufficient parameters to ->dest( page, -xyz => [] ) " unless scalar @{$options{'-xyz'}} == 3;
            $self->{'A'}->{'D'} = PDFArray($page, PDFName('XYZ'), map { defined $_ ? PDFNum($_) : PDFNull() } @{$options{'-xyz'}});
        }
    }
    else {
        $self->{'Dest'} = PDFStr($page);
    }

    return $self;
}

=back

=cut

1;
