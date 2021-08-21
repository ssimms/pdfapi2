package PDF::API2;

use strict;
no warnings qw[ deprecated recursion uninitialized ];

# VERSION

use Carp;
use Encode qw(:all);
use English;
use FileHandle;

use PDF::API2::Basic::PDF::Utils;
use PDF::API2::Util;

use PDF::API2::Basic::PDF::File;
use PDF::API2::Basic::PDF::Pages;
use PDF::API2::Page;

use PDF::API2::Resource::XObject::Form::Hybrid;

use PDF::API2::Resource::ExtGState;
use PDF::API2::Resource::Pattern;
use PDF::API2::Resource::Shading;

use PDF::API2::NamedDestination;

use Scalar::Util qw(weaken);

my @font_path = __PACKAGE__->set_font_path('/usr/share/fonts',
                                           '/usr/local/share/fonts',
                                           'c:/windows/fonts');

=head1 NAME

PDF::API2 - Create, modify, and examine PDF files

=head1 SYNOPSIS

    use PDF::API2;

    # Create a blank PDF file
    $pdf = PDF::API2->new();

    # Open an existing PDF file
    $pdf = PDF::API2->open('some.pdf');

    # Add a blank page
    $page = $pdf->page();

    # Retrieve an existing page
    $page = $pdf->open_page($page_number);

    # Set the page size
    $page->size('Letter');

    # Add a built-in font to the PDF
    $font = $pdf->font('Helvetica-Bold');

    # Add an external TrueType font to the PDF
    $font = $pdf->font('/path/to/font.ttf');

    # Add some text to the page
    $text = $page->text();
    $text->font($font, 20);
    $text->translate(200, 700);
    $text->text('Hello World!');

    # Save the PDF
    $pdf->save('/path/to/new.pdf');

=head1 INPUT/OUTPUT METHODS

=head2 new

    my $pdf = PDF::API2->new(%options);

Create a new PDF.

The following options are available:

=over

=item * file

If you will be saving the PDF to disk and already know the filename, you can
include it here to open the file for writing immediately.  C<file> may also be
a filehandle.

=item * compress

By default, most of the PDF will be compressed to save space.  To turn this off
(generally only useful for testing or debugging), set C<compress> to 0.

=back

=cut

sub new {
    my ($class, %options) = @_;

    my $self = {};
    bless $self, $class;
    $self->{'pdf'} = PDF::API2::Basic::PDF::File->new();

    $self->{'pdf'}->{' version'} = '1.4';
    $self->{'pages'} = PDF::API2::Basic::PDF::Pages->new($self->{'pdf'});
    $self->{'pages'}->proc_set(qw(PDF Text ImageB ImageC ImageI));
    $self->{'pages'}->{'Resources'} ||= PDFDict();
    $self->{'pdf'}->new_obj($self->{'pages'}->{'Resources'}) unless $self->{'pages'}->{'Resources'}->is_obj($self->{'pdf'});
    $self->{'catalog'} = $self->{'pdf'}->{'Root'};
    weaken $self->{'catalog'};
    $self->{'fonts'} = {};
    $self->{'pagestack'} = [];

    # -compress is deprecated (remove the hyphen)
    if (exists $options{'-compress'}) {
        $options{'compress'} //= delete $options{'-compress'};
    }

    if (exists $options{'compress'}) {
        $self->{'forcecompress'} = $options{'compress'} ? 1 : 0;
    }
    else {
        $self->{'forcecompress'} = 1;
    }
    $self->preferences(%options);

    # -file is deprecated (remove the hyphen)
    $options{'file'} //= $options{'-file'} if $options{'-file'};

    if ($options{'file'}) {
        $self->{'pdf'}->create_file($options{'file'});
        $self->{'partial_save'} = 1;
    }

    # Deprecated; used by info and infoMetaAttributes but not their replacements
    $self->{'infoMeta'} = [qw(Author CreationDate ModDate Creator Producer Title
                              Subject Keywords)];

    my $version = eval { $PDF::API2::VERSION } || 'Development Version';
    $self->producer("PDF::API2 $version ($OSNAME)");

    return $self;
}

=head2 open

    my $pdf = PDF::API2->open('/path/to/file.pdf', %options);

Open an existing PDF file.

The following option is available:

=over

=item * compress

By default, most of the PDF will be compressed to save space.  To turn this off
(generally only useful for testing or debugging), set C<compress> to 0.

=back

=cut

sub open {
    my ($class, $file, %options) = @_;
    croak "File '$file' does not exist" unless -f $file;
    croak "File '$file' is not readable" unless -r $file;

    my $self = {};
    bless $self, $class;
    foreach my $parameter (keys %options) {
        $self->default($parameter, $options{$parameter});
    }

    my $is_writable = -w $file;
    $self->{'pdf'} = PDF::API2::Basic::PDF::File->open($file, $is_writable);
    _open_common($self, %options);
    $self->{'pdf'}->{' fname'} = $file;
    $self->{'opened_readonly'} = 1 unless $is_writable;

    return $self;
}

sub _open_common {
    my ($self, %options) = @_;

    $self->{'pdf'}->{'Root'}->realise();
    $self->{'pdf'}->{' version'} ||= '1.3';

    $self->{'pages'} = $self->{'pdf'}->{'Root'}->{'Pages'}->realise();
    weaken $self->{'pages'};
    my @pages = proc_pages($self->{'pdf'}, $self->{'pages'});
    $self->{'pagestack'} = [sort { $a->{' pnum'} <=> $b->{' pnum'} } @pages];
    weaken $self->{'pagestack'}->[$_] for (0 .. scalar @{$self->{'pagestack'}});

    $self->{'catalog'} = $self->{'pdf'}->{'Root'};
    weaken $self->{'catalog'};

    $self->{'opened'} = 1;

    # -compress is deprecated (remove the hyphen)
    if (exists $options{'-compress'}) {
        $options{'compress'} //= delete $options{'-compress'};
    }

    if (exists $options{'compress'}) {
        $self->{'forcecompress'} = $options{'compress'} ? 1 : 0;
    }
    else {
        $self->{'forcecompress'} = 1;
    }
    $self->{'fonts'} = {};
    $self->{'infoMeta'} = [qw(Author CreationDate ModDate Creator Producer Title Subject Keywords)];
    return $self;
}

=head2 save

    $pdf->save('/path/to/file.pdf');

Write the PDF to disk and close the file.  A filename is optional if one was
specified while opening or creating the PDF.

As a side effect, the document structure is removed from memory when the file is
saved, so it will no longer be usable.

=cut

# Deprecated (renamed)
sub saveas { return save(@_) } ## no critic

sub save {
    my ($self, $file) = @_;

    if ($self->{'partial_save'} and not $file) {
        $self->{'pdf'}->close_file();
    }
    elsif ($self->{'opened_scalar'}) {
        croak 'A filename argument is required' unless $file;
        $self->{'pdf'}->append_file();
        my $fh;
        CORE::open($fh, '>', $file) or die "Unable to open $file for writing: $!";
        binmode($fh, ':raw');
        print $fh ${$self->{'content_ref'}};
        CORE::close($fh);
    }
    else {
        croak 'A filename argument is required' unless $file;
        unless ($self->{'pdf'}->{' fname'}) {
            $self->{'pdf'}->out_file($file);
        }
        elsif ($self->{'pdf'}->{' fname'} eq $file) {
            croak "File is read-only" if $self->{'opened_readonly'};
            $self->{'pdf'}->close_file();
        }
        else {
            $self->{'pdf'}->clone_file($file);
            $self->{'pdf'}->close_file();
        }
    }

    # This can be eliminated once we're confident that circular references are
    # no longer an issue.  See t/circular-references.t.
    $self->close();

    return;
}

# Deprecated (use save instead)
#
# This method allows for objects to be written to disk in advance of finally
# saving and closing the file.  Otherwise, it's no different than just calling
# save when all changes have been made.  There's no memory advantage since
# ship_out doesn't remove objects from memory.
sub finishobjects {
    my ($self, @objs) = @_;

    if ($self->{'partial_save'}) {
        $self->{'pdf'}->ship_out(@objs);
    }

    return;
}

# Deprecated (use save instead)
sub update {
    my $self = shift();
    croak "File is read-only" if $self->{'opened_readonly'};
    $self->{'pdf'}->close_file();
    return;
}

=head2 close

    $pdf->close();

Close an open file (if relevant) and remove the object structure from memory.

PDF::API2 contains circular references, so this call is necessary in
long-running processes to keep from running out of memory.

This will be called automatically when you save or stringify a PDF.
You should only need to call it explicitly if you are reading PDF
files and not writing them.

=cut

# Deprecated (renamed)
sub release { return $_[0]->close() }
sub end     { return $_[0]->close() }

sub close {
    my $self = shift();
    $self->{'pdf'}->release() if defined $self->{'pdf'};

    foreach my $key (keys %$self) {
        $self->{$key} = undef;
        delete $self->{$key};
    }

    return;
}

=head2 from_string

    my $pdf = PDF::API2->from_string($pdf_string, %options);

Read a PDF document contained in a string.

The following option is available:

=over

=item * compress

By default, most of the PDF will be compressed to save space.  To turn this off
(generally only useful for testing or debugging), set C<compress> to 0.

=back

=cut

# Deprecated (renamed)
sub openScalar  { return from_string(@_); } ## no critic
sub open_scalar { return from_string(@_); } ## no critic

sub from_string {
    my ($class, $content, %options) = @_;

    my $self = {};
    bless $self, $class;
    foreach my $parameter (keys %options) {
        $self->default($parameter, $options{$parameter});
    }

    $self->{'content_ref'} = \$content;
    my $fh;
    CORE::open($fh, '+<', \$content) or die "Can't begin scalar IO";

    $self->{'pdf'} = PDF::API2::Basic::PDF::File->open($fh, 1);
    _open_common($self, %options);
    $self->{'opened_scalar'} = 1;

    return $self;
}

=head2 to_string

    my $string = $pdf->to_string();

Return the PDF document as a string.

As a side effect, the document structure is removed from memory when the string
is created, so it will no longer be usable.

=cut

# Maintainer's note: The object is being destroyed because it contains
# (contained?) circular references that would otherwise result in memory not
# being freed if the object merely goes out of scope.  If possible, the circular
# references should be eliminated so that to_string doesn't need to be
# destructive.  See t/circular-references.t.
#
# I've opted not to just require a separate call to close() because it would
# likely introduce memory leaks in many existing programs that use this module.

# Deprecated (renamed)
sub stringify { return to_string(@_) } ## no critic

sub to_string {
    my $self = shift();

    my $string = '';
    if ($self->{'opened_scalar'}) {
        $self->{'pdf'}->append_file();
        $string = ${$self->{'content_ref'}};
    }
    elsif ($self->{'opened'}) {
        my $fh = FileHandle->new();
        CORE::open($fh, '>', \$string) || die "Can't begin scalar IO";
        $self->{'pdf'}->clone_file($fh);
        $self->{'pdf'}->close_file();
        $fh->close();
    }
    else {
        my $fh = FileHandle->new();
        CORE::open($fh, '>', \$string) || die "Can't begin scalar IO";
        $self->{'pdf'}->out_file($fh);
        $fh->close();
    }

    # This can be eliminated once we're confident that circular references are
    # no longer an issue.  See t/circular-references.t.
    $self->close();

    return $string;
}

=head1 METADATA METHODS

=head2 title

    $title = $pdf->title();
    $pdf = $pdf->title($title);

Get/set/clear the document's title.

=cut

sub title {
    my $self = shift();
    return $self->info_metadata('Title', @_);
}

=head2 author

    $author = $pdf->author();
    $pdf = $pdf->author($author);

Get/set/clear the name of the person who created the document.

=cut

sub author {
    my $self = shift();
    return $self->info_metadata('Author', @_);
}

=head2 subject

    $subject = $pdf->subject();
    $pdf = $pdf->subject($subject);

Get/set/clear the subject of the document.

=cut

sub subject {
    my $self = shift();
    return $self->info_metadata('Subject', @_);
}

=head2 keywords

    $keywords = $pdf->keywords();
    $pdf = $pdf->keywords($keywords);

Get/set/clear a space-separated string of keywords associated with the document.

=cut

sub keywords {
    my $self = shift();
    return $self->info_metadata('Keywords', @_);
}

=head2 creator

    $creator = $pdf->creator();
    $pdf = $pdf->creator($creator);

Get/set/clear the name of the product that created the document prior to its
conversion to PDF.

=cut

sub creator {
    my $self = shift();
    return $self->info_metadata('Creator', @_);
}

=head2 producer

    $producer = $pdf->producer();
    $pdf = $pdf->producer($producer);

Get/set/clear the name of the product that converted the original document to
PDF.

PDF::API2 fills in this field when creating a PDF.

=cut

sub producer {
    my $self = shift();
    return $self->info_metadata('Producer', @_);
}

=head2 created

    $date = $pdf->created();
    $pdf = $pdf->created($date);

Get/set/clear the document's creation date.

The date format is C<D:YYYYMMDDHHmmSSOHH'mm>, where C<D:> is a static prefix
identifying the string as a PDF date.  The date may be truncated at any point
after the year.  C<O> is one of C<+>, C<->, or C<Z>, with the following C<HH'mm>
representing an offset from UTC.

When setting the date, C<D:> will be prepended automatically if omitted.

=cut

sub created {
    my $self = shift();
    return $self->info_metadata('CreationDate', @_);
}

=head2 modified

    $date = $pdf->modified();
    $pdf = $pdf->modified($date);

Get/set/clear the document's modification date.  The date format is as described
in C<created> above.

=cut

sub modified {
    my $self = shift();
    return $self->info_metadata('ModDate', @_);
}

sub _is_date {
    my $value = shift();

    # PDF 1.7 section 7.9.4 describes the required date format.  Other than the
    # D: prefix and the year, all components are optional but must be present if
    # a later component is present.  No provision is made in the specification
    # for leap seconds, etc.
    return unless $value =~ /^D:([0-9]{4})        # D:YYYY (required)
                             (?:([01][0-9])       # Month (01-12)
                             (?:([0123][0-9])     # Day (01-31)
                             (?:([012][0-9])      # Hour (00-23)
                             (?:([012345][0-9])   # Minute (00-59)
                             (?:([012345][0-9])   # Second (00-59)
                             (?:([Z+-])           # UT Offset Direction
                             (?:([012][0-9])      # UT Offset Hours
                             (?:\'([012345][0-9]) # UT Offset Minutes
                             )?)?)?)?)?)?)?)?$/x;
    my ($year, $month, $day, $hour, $minute, $second, $od, $oh, $om)
        = ($1, $2, $3, $4, $5, $6, $7, $8, $9);

    # Do some basic validation to catch accidental date formatting issues.
    # Complete date validation is out of scope.
    if (defined $month) {
        return unless $month >= 1 and $month <= 12;
    }
    if (defined $day) {
        return unless $day >= 1 and $day <= 31;
    }
    if (defined $hour) {
        return unless $hour <= 23;
    }
    if (defined $minute) {
        return unless $minute <= 59;
    }
    if (defined $second) {
        return unless $second <= 59;
    }
    if (defined $od) {
        return if $od eq 'Z' and defined($oh);
    }
    if (defined $oh) {
        return unless $oh <= 23;
    }
    if (defined $om) {
        return unless $om <= 59;
    }

    return 1;
}

=head2 info_metadata

    # Get all keys and values
    %info = $pdf->info_metadata();

    # Get the value of one key
    $value = $pdf->info_metadata($key);

    # Set the value of one key
    $pdf = $pdf->info_metadata($key, $value);

Get/set/clear a key in the document's information dictionary.  The standard keys
(title, author, etc.) have their own accessors, so this is primarily intended
for interacting with custom metadata.

Pass C<undef> as the value in order to remove the key from the dictionary.

=cut

sub info_metadata {
    my $self = shift();
    my $field = shift();

    # Return a hash of the Info table if called without arguments
    unless (defined $field) {
        return unless exists $self->{'pdf'}->{'Info'};
        $self->{'pdf'}->{'Info'}->realise();
        my %info;
        foreach my $key (keys %{$self->{'pdf'}->{'Info'}}) {
            next if $key =~ /^ /;
            next unless defined $self->{'pdf'}->{'Info'}->{$key};
            $info{$key} = $self->{'pdf'}->{'Info'}->{$key}->val();
        }
        return %info;
    }

    # Set
    if (@_) {
        my $value = shift();
        $value = undef if defined($value) and not length($value);

        if ($field eq 'CreationDate' or $field eq 'ModDate') {
            if (defined ($value)) {
                $value = 'D:' . $value unless $value =~ /^D:/;
                croak "Invalid date string: $value" unless _is_date($value);
            }
        }

        unless (exists $self->{'pdf'}->{'Info'}) {
            return $self unless defined $value;
            $self->{'pdf'}->{'Info'} = PDFDict();
            $self->{'pdf'}->new_obj($self->{'pdf'}->{'Info'});
        }
        else {
            $self->{'pdf'}->{'Info'}->realise();
        }

        if (defined $value) {
            $self->{'pdf'}->{'Info'}->{$field} = PDFStr($value);
        }
        else {
            delete $self->{'pdf'}->{'Info'}->{$field};
        }

        return $self;
    }

    # Get
    return unless $self->{'pdf'}->{'Info'};
    $self->{'pdf'}->{'Info'}->realise();
    return unless $self->{'pdf'}->{'Info'}->{$field};
    return $self->{'pdf'}->{'Info'}->{$field}->val();
}

# Deprecated; replace with individual accessors or info_metadata
sub info {
    my ($self, %opt) = @_;

    if (not defined($self->{'pdf'}->{'Info'})) {
        $self->{'pdf'}->{'Info'} = PDFDict();
        $self->{'pdf'}->new_obj($self->{'pdf'}->{'Info'});
    }
    else {
        $self->{'pdf'}->{'Info'}->realise();
    }

    # Maintenance Note: Since we're not shifting at the beginning of
    # this sub, this "if" will always be true
    if (scalar @_) {
        foreach my $k (@{$self->{'infoMeta'}}) {
            next unless defined $opt{$k};
            $self->{'pdf'}->{'Info'}->{$k} = PDFStr($opt{$k} || 'NONE');
        }
        $self->{'pdf'}->out_obj($self->{'pdf'}->{'Info'});
    }

    if (defined $self->{'pdf'}->{'Info'}) {
        %opt = ();
        foreach my $k (@{$self->{'infoMeta'}}) {
            next unless defined $self->{'pdf'}->{'Info'}->{$k};
            $opt{$k} = $self->{'pdf'}->{'Info'}->{$k}->val();
            if (   (unpack('n', $opt{$k}) == 0xfffe)
                or (unpack('n', $opt{$k}) == 0xfeff))
            {
                $opt{$k} = decode('UTF-16', $self->{'pdf'}->{'Info'}->{$k}->val());
            }
        }
    }

    return %opt;
}

# Deprecated; replace with info_metadata
sub infoMetaAttributes {
    my ($self, @attr) = @_;

    if (scalar @attr) {
        my %at = map { $_ => 1 } @{$self->{'infoMeta'}}, @attr;
        @{$self->{'infoMeta'}} = keys %at;
    }

    return @{$self->{'infoMeta'}};
}

=head2 xml_metadata

    $xml = $pdf->xml_metadata();
    $pdf = $pdf->xml_metadata($xml);

Get/set the document's XML metadata stream.

=cut

# Deprecated (renamed, changed set return value for consistency)
sub xmpMetadata {
    my $self = shift();
    if (@_) {
        my $value = shift();
        $self->xml_metadata($value);
        return $value;
    }

    return $self->xml_metadata();
}

sub xml_metadata {
    my ($self, $value) = @_;

    if (not defined($self->{'catalog'}->{'Metadata'})) {
        $self->{'catalog'}->{'Metadata'} = PDFDict();
        $self->{'catalog'}->{'Metadata'}->{'Type'} = PDFName('Metadata');
        $self->{'catalog'}->{'Metadata'}->{'Subtype'} = PDFName('XML');
        $self->{'pdf'}->new_obj($self->{'catalog'}->{'Metadata'});
    }
    else {
        $self->{'catalog'}->{'Metadata'}->realise();
        $self->{'catalog'}->{'Metadata'}->{' stream'} = unfilter($self->{'catalog'}->{'Metadata'}->{'Filter'}, $self->{'catalog'}->{'Metadata'}->{' stream'});
        delete $self->{'catalog'}->{'Metadata'}->{' nofilt'};
        delete $self->{'catalog'}->{'Metadata'}->{'Filter'};
    }

    my $md = $self->{'catalog'}->{'Metadata'};

    if (defined $value) {
        $md->{' stream'} = $value;
        delete $md->{'Filter'};
        delete $md->{' nofilt'};
        $self->{'pdf'}->out_obj($md);
        $self->{'pdf'}->out_obj($self->{'catalog'});
    }

    return $md->{' stream'};
}

=head2 version

    $version = $pdf->version($new_version);

Get/set the PDF version (e.g. 1.4).

=cut

sub version {
    my $self = shift();
    return $self->{'pdf'}->version(@_);
}

=head2 is_encrypted

    $boolean = $pdf->is_encrypted();

Returns true if the opened PDF is encrypted.

=cut

# Deprecated (renamed)
sub isEncrypted { return is_encrypted(@_) }

sub is_encrypted {
    my $self = shift();
    return defined($self->{'pdf'}->{'Encrypt'}) ? 1 : 0;
}

=head1 VIEWER METHODS

=head2 open_action

    $pdf = $pdf->open_action($page, $location, @args);

Set the destination in the PDF that should be displayed when the document is
opened.

C<$page> may be either a page number or a page object.  The other parameters are
as described in L<PDF::API2::NamedDestination>.

=cut

sub open_action {
    my ($self, $page, @args) = @_;

    # $page can be either a page number or a page object
    $page = PDFNum($page) unless ref($page);

    require PDF::API2::NamedDestination;
    my $array = PDF::API2::NamedDestination::_destination($page, @args);
    $self->{'catalog'}->{'OpenAction'} = $array;
    $self->{'pdf'}->out_obj($self->{'catalog'});
    return $self;
}

=head2 page_layout

    $layout = $pdf->page_layout();
    $pdf = $pdf->page_layout($layout);

Get/set the page layout that should be used when the PDF is opened.

C<$layout> is one of the following:

=over

=item * single_page (or undef)

Display one page at a time.

=item * one_column

Display the pages in one column (a.k.a. continuous).

=item * two_column_left

Display the pages in two columns, with odd-numbered pages on the left.

=item * two_column_right

Display the pages in two columns, with odd-numbered pages on the right.

=item * two_page_left

Display two pages at a time, with odd-numbered pages on the left.

=item * two_page_right

Display two pages at a time, with odd-numbered pages on the right.

=back

=cut

sub page_layout {
    my $self = shift();

    unless (@_) {
        return 'single_page' unless $self->{'catalog'}->{'PageLayout'};
        my $layout = $self->{'catalog'}->{'PageLayout'}->val();
        return 'single_page' if $layout eq 'SinglePage';
        return 'one_column' if $layout eq 'OneColumn';
        return 'two_column_left' if $layout eq 'TwoColumnLeft';
        return 'two_column_right' if $layout eq 'TwoColumnRight';
        return 'two_page_left'  if $layout eq 'TwoPageLeft';
        return 'two_page_right' if $layout eq 'TwoPageRight';
        warn "Unknown page layout: $layout";
        return $layout;
    }

    my $name = shift() // 'single_page';
    my $layout = ($name eq 'single_page'      ? 'SinglePage'     :
                  $name eq 'one_column'       ? 'OneColumn'      :
                  $name eq 'two_column_left'  ? 'TwoColumnLeft'  :
                  $name eq 'two_column_right' ? 'TwoColumnRight' :
                  $name eq 'two_page_left'    ? 'TwoPageLeft'    :
                  $name eq 'two_page_right'   ? 'TwoPageRight'   : '');

    croak "Invalid page layout: $name" unless $layout;
    $self->{'catalog'}->{'PageMode'} = PDFName($layout);
    $self->{'pdf'}->out_obj($self->{'catalog'});
    return $self;
}

=head2 page_mode

    # Get
    $mode = $pdf->page_mode();

    # Set
    $pdf = $pdf->page_mode($mode);

Get/set the page mode, which describes how the PDF should be displayed when
opened.

C<$mode> is one of the following:

=over

=item * none (or undef)

Neither outlines nor thumbnails should be displayed.

=item * outlines

Show the document outline.

=item * thumbnails

Show the page thumbnails.

=item * full_screen

Open in full-screen mode, with no menu bar, window controls, or any other window
visible.

=item * optional_content

Show the optional content group panel.

=item * attachments

Show the attachments panel.

=back

=cut

sub page_mode {
    my $self = shift();

    unless (@_) {
        return 'none' unless $self->{'catalog'}->{'PageMode'};
        my $mode = $self->{'catalog'}->{'PageMode'}->val();
        return 'none'             if $mode eq 'UseNone';
        return 'outlines'         if $mode eq 'UseOutlines';
        return 'thumbnails'       if $mode eq 'UseThumbs';
        return 'full_screen'      if $mode eq 'FullScreen';
        return 'optional_content' if $mode eq 'UseOC';
        return 'attachments'      if $mode eq 'UseAttachments';
        warn "Unknown page mode: $mode";
        return $mode;
    }

    my $name = shift() // 'none';
    my $mode = ($name eq 'none'             ? 'UseNone'        :
                $name eq 'outlines'         ? 'UseOutlines'    :
                $name eq 'thumbnails'       ? 'UseThumbs'      :
                $name eq 'full_screen'      ? 'FullScreen'     :
                $name eq 'optional_content' ? 'UseOC'          :
                $name eq 'attachments'      ? 'UseAttachments' : '');

    croak "Invalid page mode: $name" unless $mode;
    $self->{'catalog'}->{'PageMode'} = PDFName($mode);
    $self->{'pdf'}->out_obj($self->{'catalog'});
    return $self;
}

=head2 viewer_preferences

    # Get
    %preferences = $pdf->viewer_preferences();

    # Set
    $pdf = $pdf->viewer_preferences(%preferences);

Get or set PDF viewer preferences, as described in
L<PDF::API2::ViewerPreferences>.

=cut

sub viewer_preferences {
    my $self = shift();
    require PDF::API2::ViewerPreferences;
    my $prefs = PDF::API2::ViewerPreferences->new($self);
    unless (@_) {
        return $prefs->get_preferences();
    }
    return $prefs->set_preferences(@_);
}

# Deprecated; the various preferences have been split out into their own methods
sub preferences {
    my ($self, %options) = @_;

    # Page Mode Options
    if ($options{'-fullscreen'}) {
        $self->page_mode('full_screen');
    }
    elsif ($options{'-thumbs'}) {
        $self->page_mode('thumbnails');
    }
    elsif ($options{'-outlines'}) {
        $self->page_mode('outlines');
    }
    else {
        $self->page_mode('none');
    }

    # Page Layout Options
    if ($options{'-singlepage'}) {
        $self->page_layout('single_page');
    }
    elsif ($options{'-onecolumn'}) {
        $self->page_layout('one_column');
    }
    elsif ($options{'-twocolumnleft'}) {
        $self->page_layout('two_column_left');
    }
    elsif ($options{'-twocolumnright'}) {
        $self->page_layout('two_column_right');
    }
    else {
        $self->page_layout('single_page');
    }

    # Viewer Preferences
    if ($options{'-hidetoolbar'}) {
        $self->viewer_preferences(hide_toolbar => 1);
    }
    if ($options{'-hidemenubar'}) {
        $self->viewer_preferences(hide_menubar => 1);
    }
    if ($options{'-hidewindowui'}) {
        $self->viewer_preferences(hide_window_ui => 1);
    }
    if ($options{'-fitwindow'}) {
        $self->viewer_preferences(fit_window => 1);
    }
    if ($options{'-centerwindow'}) {
        $self->viewer_preferences(center_window => 1);
    }
    if ($options{'-displaytitle'}) {
        $self->viewer_preferences(display_doc_title => 1);
    }
    if ($options{'-righttoleft'}) {
        $self->viewer_preferences(direction => 'r2l');
    }

    if ($options{'-afterfullscreenthumbs'}) {
        $self->viewer_preferences(non_full_screen_page_mode => 'thumbnails');
    }
    elsif ($options{'-afterfullscreenoutlines'}) {
        $self->viewer_preferences(non_full_screen_page_mode => 'outlines');
    }
    else {
        $self->viewer_preferences(non_full_screen_page_mode => 'none');
    }

    if ($options{'-printscalingnone'}) {
        $self->viewer_preferences(print_scaling => 'none');
    }

    if ($options{'-simplex'}) {
        $self->viewer_preferences(duplex => 'simplex');
    }
    elsif ($options{'-duplexfliplongedge'}) {
        $self->viewer_preferences(duplex => 'duplex_long');
    }
    elsif ($options{'-duplexflipshortedge'}) {
        $self->viewer_preferences(duplex => 'duplex_short');
    }

    # Open Action
    if ($options{'-firstpage'}) {
        my ($page, %args) = @{$options{'-firstpage'}};
        $args{'-fit'} = 1 unless keys %args;

        if (defined $args{'-fit'}) {
            $self->open_action($page, 'fit');
        }
        elsif (defined $args{'-fith'}) {
            $self->open_action($page, 'fith', $args{'-fith'});
        }
        elsif (defined $args{'-fitb'}) {
            $self->open_action($page, 'fitb');
        }
        elsif (defined $args{'-fitbh'}) {
            $self->open_action($page, 'fitbh', $args{'-fitbh'});
        }
        elsif (defined $args{'-fitv'}) {
            $self->open_action($page, 'fitv', $args{'-fitv'});
        }
        elsif (defined $args{'-fitbv'}) {
            $self->open_action($page, 'fitbv', $args{'-fitbv'});
        }
        elsif (defined $args{'-fitr'}) {
            $self->open_action($page, 'fitr', @{$args{'-fitr'}});
        }
        elsif (defined $args{'-xyz'}) {
            $self->open_action($page, 'xyz', @{$args{'-xyz'}});
        }
    }
    $self->{'pdf'}->out_obj($self->{'catalog'});

    return $self;
}

sub proc_pages {
    my ($pdf, $object) = @_;

    if (defined $object->{'Resources'}) {
        eval {
            $object->{'Resources'}->realise();
        };
    }

    my @pages;
    $pdf->{' apipagecount'} ||= 0;
    foreach my $page ($object->{'Kids'}->elements()) {
        $page->realise();
        if ($page->{'Type'}->val() eq 'Pages') {
            push @pages, proc_pages($pdf, $page);
        }
        else {
            $pdf->{' apipagecount'}++;
            $page->{' pnum'} = $pdf->{' apipagecount'};
            if (defined $page->{'Resources'}) {
                eval {
                    $page->{'Resources'}->realise();
                };
            }
            push @pages, $page;
        }
    }

    return @pages;
}

=head1 PAGE METHODS

=head2 page

     # Add a page to the end of the document
     $page = $pdf->page();

     # Insert a page before the specified page number
     $page = $pdf->page($page_number);

Returns a new page object.  By default, the page is added to the end
of the document.  If you include an existing page number, the new page
will be inserted in that position, pushing existing pages back.

If C<$page_number> is -1, the new page is inserted as the second-last page; if
C<$page_number> is 0, the new page is inserted as the last page.

=cut

sub page {
    my $self = shift();
    my $index = shift() || 0;
    my $page;
    if ($index == 0) {
        $page = PDF::API2::Page->new($self->{'pdf'}, $self->{'pages'});
    }
    else {
        $page = PDF::API2::Page->new($self->{'pdf'}, $self->{'pages'}, $index - 1);
    }
    $page->{' apipdf'} = $self->{'pdf'};
    $page->{' api'} = $self;
    weaken $page->{' apipdf'};
    weaken $page->{' api'};
    $self->{'pdf'}->out_obj($page);
    $self->{'pdf'}->out_obj($self->{'pages'});
    if ($index == 0) {
        push @{$self->{'pagestack'}}, $page;
        weaken $self->{'pagestack'}->[-1];
    }
    elsif ($index < 0) {
        splice @{$self->{'pagestack'}}, $index, 0, $page;
        weaken $self->{'pagestack'}->[$index];
    }
    else {
        splice @{$self->{'pagestack'}}, $index - 1, 0, $page;
        weaken $self->{'pagestack'}->[$index - 1];
    }
    # $page->{'Resources'} = $self->{'pages'}->{'Resources'};
    return $page;
}

=head2 open_page

    $page = $pdf->open_page($page_number);

Returns the L<PDF::API2::Page> object of page C<$page_number>, if it exists.

If $page_number is 0 or -1, it will return the last page in the document.

=cut

# Deprecated (renamed)
sub openpage { return open_page(@_); } ## no critic

sub open_page {
    my $self = shift();
    my $index = shift() || 0;
    my ($page, $rotate, $media, $trans);

    if ($index == 0) {
        $page = $self->{'pagestack'}->[-1];
    }
    elsif ($index < 0) {
        $page = $self->{'pagestack'}->[$index];
    }
    else {
        $page = $self->{'pagestack'}->[$index - 1];
    }
    return unless ref($page);

    if (ref($page) ne 'PDF::API2::Page') {
        bless $page, 'PDF::API2::Page';
        $page->{' apipdf'} = $self->{'pdf'};
        $page->{' api'} = $self;
        weaken $page->{' apipdf'};
        weaken $page->{' api'};
        $self->{'pdf'}->out_obj($page);
        if (($rotate = $page->find_prop('Rotate')) and not $page->{' opened'}) {
            $rotate = ($rotate->val() + 360) % 360;

            if ($rotate != 0 and not $self->default('nounrotate')) {
                $page->{'Rotate'} = PDFNum(0);
                foreach my $mediatype (qw(MediaBox CropBox BleedBox TrimBox ArtBox)) {
                    if ($media = $page->find_prop($mediatype)) {
                        $media = [ map { $_->val() } $media->elements() ];
                    }
                    else {
                        $media = [0, 0, 612, 792];
                        next if $mediatype ne 'MediaBox';
                    }
                    if ($rotate == 90) {
                        $trans = "0 -1 1 0 0 $media->[2] cm" if $mediatype eq 'MediaBox';
                        $media = [$media->[1], $media->[0], $media->[3], $media->[2]];
                    }
                    elsif ($rotate == 180) {
                        $trans = "-1 0 0 -1 $media->[2] $media->[3] cm" if $mediatype eq 'MediaBox';
                    }
                    elsif ($rotate == 270) {
                        $trans = "0 1 -1 0 $media->[3] 0 cm" if $mediatype eq 'MediaBox';
                        $media = [$media->[1], $media->[0], $media->[3], $media->[2]];
                    }
                    $page->{$mediatype} = PDFArray(map { PDFNum($_) } @$media);
                }
            }
            else {
                $trans = '';
            }
        }
        else {
            $trans = '';
        }

        if (defined $page->{'Contents'} and not $page->{' opened'}) {
            $page->fixcontents();
            my $uncontent = delete $page->{'Contents'};
            my $content = $page->gfx();
            $content->add(" $trans ");

            if ($self->default('pageencaps')) {
                $content->{' stream'} .= ' q ';
            }
            foreach my $k ($uncontent->elements()) {
                $k->realise();
                $content->{' stream'} .= ' ' . unfilter($k->{'Filter'}, $k->{' stream'}) . ' ';
            }
            if ($self->default('pageencaps')) {
                $content->{' stream'} .= ' Q ';
            }

            # if we like compress we will do it now to do quicker saves
            if ($self->{'forcecompress'}) {
                $content->{' stream'} = dofilter($content->{'Filter'}, $content->{' stream'});
                $content->{' nofilt'} = 1;
                delete $content->{'-docompress'};
                $content->{'Length'} = PDFNum(length($content->{' stream'}));
            }
        }
        $page->{' opened'} = 1;
    }

    $self->{'pdf'}->out_obj($page);
    $self->{'pdf'}->out_obj($self->{'pages'});
    $page->{' apipdf'} = $self->{'pdf'};
    $page->{' api'} = $self;
    weaken $page->{' apipdf'};
    weaken $page->{' api'};
    return $page;
}

=head2 import_page

    $page = $pdf->import_page($source_pdf, $source_page_num, $target_page_num);

Imports a page from C<$source_pdf> and adds it to the specified position in
C<$pdf>.

If C<$source_page_num> or C<$target_page_num> is 0 or -1, the last page in the
document is used.

B<Note:> If you pass a page object instead of a page number for
C<$target_page_num>, the contents of the page will be merged into the existing
page.

B<Example:>

    $pdf = PDF::API2->new();
    $old = PDF::API2->open('our/old.pdf');

    # Add page 2 from the old PDF as page 1 of the new PDF
    $page = $pdf->import_page($old, 2);

    $pdf->save('our/new.pdf');

B<Note:> You can only import a page from an existing PDF file.

=cut

# Deprecated (renamed)
sub importpage { return import_page(@_); } ## no critic

sub import_page {
    my ($self, $s_pdf, $s_idx, $t_idx) = @_;
    $s_idx ||= 0;
    $t_idx ||= 0;
    my ($s_page, $t_page);

    unless (ref($s_pdf) and $s_pdf->isa('PDF::API2')) {
        die "Invalid usage: first argument must be PDF::API2 instance, not: " . ref($s_pdf);
    }

    if (ref($s_idx) eq 'PDF::API2::Page') {
        $s_page = $s_idx;
    }
    else {
        $s_page = $s_pdf->open_page($s_idx);
    }

    if (ref($t_idx) eq 'PDF::API2::Page') {
        $t_page = $t_idx;
    }
    else {
        if ($self->pages() < $t_idx) {
            $t_page = $self->page();
        }
        else {
            $t_page = $self->page($t_idx);
        }
    }

    $self->{'apiimportcache'} = $self->{'apiimportcache'} || {};
    $self->{'apiimportcache'}->{$s_pdf} = $self->{'apiimportcache'}->{$s_pdf} || {};

    # we now import into a form to keep
    # all that nasty resources from polluting
    # our very own resource naming space.
    my $xo = $self->importPageIntoForm($s_pdf, $s_page);

    # copy all page dimensions
    foreach my $k (qw(MediaBox ArtBox TrimBox BleedBox CropBox)) {
        my $prop = $s_page->find_prop($k);
        next unless defined $prop;

        my $box = walk_obj({}, $s_pdf->{'pdf'}, $self->{'pdf'}, $prop);
        my $method = lc $k;

        $t_page->$method(map { $_->val() } $box->elements());
    }

    $t_page->gfx->formimage($xo, 0, 0, 1);

    # copy annotations and/or form elements as well
    if (exists $s_page->{'Annots'} and $s_page->{'Annots'} and $self->{'copyannots'}) {
        # first set up the AcroForm, if required
        my $AcroForm;
        if (my $a = $s_pdf->{'pdf'}->{'Root'}->realise->{'AcroForm'}) {
            $a->realise();

            $AcroForm = walk_obj({}, $s_pdf->{'pdf'}, $self->{'pdf'}, $a, qw(NeedAppearances SigFlags CO DR DA Q));
        }
        my @Fields = ();
        my @Annots = ();
        foreach my $a ($s_page->{'Annots'}->elements()) {
            $a->realise();
            my $t_a = PDFDict();
            $self->{'pdf'}->new_obj($t_a);
            # these objects are likely to be both annotations and Acroform fields
            # key names are copied from PDF Reference 1.4 (Tables)
            my @k = (
                qw( Type Subtype Contents P Rect NM M F BS Border AP AS C CA T Popup A AA StructParent Rotate
                ),                                      # Annotations - Common (8.10)
                qw( Subtype Contents Open Name ),       # Text Annotations (8.15)
                qw( Subtype Contents Dest H PA ),       # Link Annotations (8.16)
                qw( Subtype Contents DA Q ),            # Free Text Annotations (8.17)
                qw( Subtype Contents L BS LE IC ) ,     # Line Annotations (8.18)
                qw( Subtype Contents BS IC ),           # Square and Circle Annotations (8.20)
                qw( Subtype Contents QuadPoints ),      # Markup Annotations (8.21)
                qw( Subtype Contents Name ),            # Rubber Stamp Annotations (8.22)
                qw( Subtype Contents InkList BS ),      # Ink Annotations (8.23)
                qw( Subtype Contents Parent Open ),     # Popup Annotations (8.24)
                qw( Subtype FS Contents Name ),         # File Attachment Annotations (8.25)
                qw( Subtype Sound Contents Name ),      # Sound Annotations (8.26)
                qw( Subtype Movie Contents A ),         # Movie Annotations (8.27)
                qw( Subtype Contents H MK ),            # Widget Annotations (8.28)
                                                        # Printers Mark Annotations (none)
                                                        # Trap Network Annotations (none)
            );

            push @k, (
                qw( Subtype FT Parent Kids T TU TM Ff V DV AA
                ),                                      # Fields - Common (8.49)
                qw( DR DA Q ),                          # Fields containing variable text (8.51)
                qw( Opt ),                              # Checkbox field (8.54)
                qw( Opt ),                              # Radio field (8.55)
                qw( MaxLen ),                           # Text field (8.57)
                qw( Opt TI I ),                         # Choice field (8.59)
            ) if $AcroForm;

            # sorting out dups
            my %ky = map { $_ => 1 } @k;
            # we do P separately, as it points to the page the Annotation is on
            delete $ky{'P'};
            # copy everything else
            foreach my $k (keys %ky) {
                next unless defined $a->{$k};
                $a->{$k}->realise();
                $t_a->{$k} = walk_obj({}, $s_pdf->{'pdf'}, $self->{'pdf'}, $a->{$k});
            }
            $t_a->{'P'} = $t_page;
            push @Annots, $t_a;
            push @Fields, $t_a if ($AcroForm and $t_a->{'Subtype'}->val() eq 'Widget');
        }
        $t_page->{'Annots'} = PDFArray(@Annots);
        $AcroForm->{'Fields'} = PDFArray(@Fields) if $AcroForm;
        $self->{'pdf'}->{'Root'}->{'AcroForm'} = $AcroForm;
    }
    $t_page->{' imported'} = 1;

    $self->{'pdf'}->out_obj($t_page);
    $self->{'pdf'}->out_obj($self->{'pages'});

    return $t_page;
}

=head2 embed_page

    $xobject = $pdf->embed_page($source_pdf, $source_page_number);

Returns a Form XObject created by extracting the specified page from a
C<$source_pdf>.

This is useful if you want to transpose the imported page somewhat differently
onto a page (e.g. two-up, four-up, etc.).

If $source_page_number is 0 or -1, it will return the last page in the document.

B<Example:>

    $pdf = PDF::API2->new();
    $old = PDF::API2->open('our/old.pdf');
    $page = $pdf->page();
    $gfx = $page->gfx();

    # Import Page 2 from the old PDF
    $xo = $pdf->embed_page($old, 2);

    # Add it to the new PDF's first page at 1/2 scale
    $gfx->formimage($xo, 0, 0, 0.5);

    $pdf->save('our/new.pdf');

B<Note:> You can only import a page from an existing PDF file.

=cut

# Deprecated (renamed)
sub importPageIntoForm { return embed_page(@_) }

sub embed_page {
    my ($self, $s_pdf, $s_idx) = @_;
    $s_idx ||= 0;

    unless (ref($s_pdf) and $s_pdf->isa('PDF::API2')) {
        die "Invalid usage: first argument must be PDF::API2 instance, not: " . ref($s_pdf);
    }

    my ($s_page, $xo);

    $xo = $self->xo_form();

    if (ref($s_idx) eq 'PDF::API2::Page') {
        $s_page = $s_idx;
    }
    else {
        $s_page = $s_pdf->open_page($s_idx);
    }

    $self->{'apiimportcache'} ||= {};
    $self->{'apiimportcache'}->{$s_pdf} ||= {};

    # This should never get past MediaBox, since it's a required object.
    foreach my $k (qw(MediaBox ArtBox TrimBox BleedBox CropBox)) {
        # next unless defined $s_page->{$k};
        # my $box = walk_obj($self->{'apiimportcache'}->{$s_pdf}, $s_pdf->{'pdf'}, $self->{'pdf'}, $s_page->{$k});
        next unless defined $s_page->find_prop($k);
        my $box = walk_obj($self->{'apiimportcache'}->{$s_pdf}, $s_pdf->{'pdf'}, $self->{'pdf'}, $s_page->find_prop($k));
        $xo->bbox(map { $_->val() } $box->elements());
        last;
    }
    $xo->bbox(0, 0, 612, 792) unless defined $xo->{'BBox'};

    foreach my $k (qw(Resources)) {
        $s_page->{$k} = $s_page->find_prop($k);
        next unless defined $s_page->{$k};
        $s_page->{$k}->realise() if ref($s_page->{$k}) =~ /Objind$/;

        foreach my $sk (qw(XObject ExtGState Font ProcSet Properties ColorSpace Pattern Shading)) {
            next unless defined $s_page->{$k}->{$sk};
            $s_page->{$k}->{$sk}->realise() if ref($s_page->{$k}->{$sk}) =~ /Objind$/;
            foreach my $ssk (keys %{$s_page->{$k}->{$sk}}) {
                next if $ssk =~ /^ /;
                $xo->resource($sk, $ssk, walk_obj($self->{'apiimportcache'}->{$s_pdf}, $s_pdf->{'pdf'}, $self->{'pdf'}, $s_page->{$k}->{$sk}->{$ssk}));
            }
        }
    }

    # create a whole content stream
    ## technically it is possible to submit an unfinished
    ## (eg. newly created) source-page, but that's nonsense,
    ## so we expect a page fixed by open_page and die otherwise
    unless ($s_page->{' opened'}) {
        croak join(' ',
                   "Pages may only be imported from a complete PDF.",
                   "Save and reopen the source PDF object first");
    }

    if (defined $s_page->{'Contents'}) {
        $s_page->fixcontents();

        $xo->{' stream'} = '';
        # open_page pages only contain one stream
        my ($k) = $s_page->{'Contents'}->elements();
        $k->realise();
        if ($k->{' nofilt'}) {
          # we have a finished stream here so we unfilter
          $xo->add('q', unfilter($k->{'Filter'}, $k->{' stream'}), 'Q');
        }
        else {
            # stream is an unfinished/unfiltered content
            # so we just copy it and add the required "qQ"
            $xo->add('q', $k->{' stream'}, 'Q');
        }
        $xo->compressFlate() if $self->{'forcecompress'};
    }

    return $xo;
}

# Used by embed_page and import_page
sub walk_obj {
    my ($object_cache, $source_pdf, $target_pdf, $source_object, @keys) = @_;

    if (ref($source_object) =~ /Objind$/) {
        $source_object->realise();
    }

    return $object_cache->{scalar $source_object} if defined $object_cache->{scalar $source_object};
    # die "infinite loop while copying objects" if $source_object->{' copied'};

    my $target_object = $source_object->copy($source_pdf); ## thanks to: yaheath // Fri, 17 Sep 2004

    # $source_object->{' copied'} = 1;
    $target_pdf->new_obj($target_object) if $source_object->is_obj($source_pdf);

    $object_cache->{scalar $source_object} = $target_object;

    if (ref($source_object) =~ /Array$/) {
        $target_object->{' val'} = [];
        foreach my $k ($source_object->elements()) {
            $k->realise() if ref($k) =~ /Objind$/;
            $target_object->add_elements(walk_obj($object_cache, $source_pdf, $target_pdf, $k));
        }
    }
    elsif (ref($source_object) =~ /Dict$/) {
        @keys = keys(%$target_object) unless scalar @keys;
        foreach my $k (@keys) {
            next if $k =~ /^ /;
            next unless defined $source_object->{$k};
            $target_object->{$k} = walk_obj($object_cache, $source_pdf, $target_pdf, $source_object->{$k});
        }
        if ($source_object->{' stream'}) {
            if ($target_object->{'Filter'}) {
                $target_object->{' nofilt'} = 1;
            }
            else {
                delete $target_object->{' nofilt'};
                $target_object->{'Filter'} = PDFArray(PDFName('FlateDecode'));
            }
            $target_object->{' stream'} = $source_object->{' stream'};
        }
    }
    delete $target_object->{' streamloc'};
    delete $target_object->{' streamsrc'};

    return $target_object;
}

=head2 page_count

    $integer = $pdf->page_count();

Return the number of pages in the document.

=cut

# Deprecated (renamed)
sub pages { return page_count(@_) }

sub page_count {
    my $self = shift();
    return scalar @{$self->{'pagestack'}};
}

=head2 page_labels

    $pdf = $pdf->page_labels($page_number, %options);

Describes how pages should be numbered beginning at the specified page number.

    # Generate a 30-page PDF
    my $pdf = PDF::API2->new();
    $pdf->page() for 1..30;

    # Number pages i to v, 1 to 20, and A-1 to A-5, respectively
    $pdf->page_labels(1, style => 'roman');
    $pdf->page_labels(6, style => 'decimal');
    $pdf->page_labels(26, style => 'decimal', prefix => 'A-');

    $pdf->save('sample.pdf');

The following options are available:

=over

=item * style

One of C<decimal> (standard decimal arabic numerals), C<Roman> (uppercase roman
numerals), C<roman> (lowercase roman numerals), C<Alpha> (uppercase letters),
or C<alpha> (lowercase letters).

There is no default numbering style.  If omitted, the page label will be just
the prefix (if set) or an empty string.

=item * prefix

The label prefix for pages in this range.

=item * start

An integer (default: 1) representing the first value to be used in this page
range.

=back

=cut

# Deprecated; replace with page_labels, updating arguments as shown
sub pageLabel {
    my $self = shift();
    while (@_) {
        my $page_index = shift();

        # Pass options as a hash rather than a hashref
        my %options = %{shift() // {}};

        # Remove leading hyphens from option names
        if (exists $options{'-prefix'}) {
            $options{'prefix'} = delete $options{'-prefix'};
        }
        if (exists $options{'-start'}) {
            $options{'start'} = delete $options{'-start'};
        }
        if (exists $options{'-style'}) {
            $options{'style'} = delete $options{'-style'};
        }

        # page_labels doesn't have a default numbering style, to be consistent
        # with the spec.
        $options{'style'} //= 'D';

        # Set one set of page labels at a time (support for multiple sets of
        # page labels by pageLabel was undocumented).  Switch from 0-based to
        # 1-based numbering.
        $self->page_labels($page_index + 1, %options);
    }

    # Return nothing (page_labels returns $self, matching other setters)
    return;
}

sub page_labels {
    my ($self, $page_number, %options) = @_;

    # $page_number is 1-based in order to be consistent with other PDF::API2
    # methods, but the page label numbering is 0-based.
    my $page_index = $page_number - 1;

    $self->{'catalog'}->{'PageLabels'} //= PDFDict();
    $self->{'catalog'}->{'PageLabels'}->{'Nums'} //= PDFArray();

    my $nums = $self->{'catalog'}->{'PageLabels'}->{'Nums'};
    $nums->add_elements(PDFNum($page_index));

    my $d = PDFDict();
    if (exists $options{'style'}) {
        unless ($options{'style'} and $options{'style'} =~ /^([rad])/i) {
            croak 'Invalid page numbering style';
        }
        $d->{'S'} = PDFName($1 eq 'd' ? 'D' : $1);
    }

    if (exists $options{'prefix'}) {
        $d->{'P'} = PDFStr($options{'prefix'} // '');
    }

    if (exists $options{'start'}) {
        $d->{'St'} = PDFNum($options{'start'} // '');
    }

    $nums->add_elements($d);

    return $self;
}

=head2 default_page_size

    # Set
    $pdf->default_page_size($size);

    # Get
    @rectangle = $pdf->default_page_size()

Set the default physical size for pages in the PDF.  If called without
arguments, return the coordinates of the rectangle describing the default
physical page size.

See L<PDF::API2::Page/"Page Sizes"> for possible values.

=cut

sub default_page_size {
    my $self = shift();

    # Set
    if (@_) {
        return $self->default_page_boundaries(media => @_);
    }

    # Get
    my $boundaries = $self->default_page_boundaries();
    return @{$boundaries->{'media'}};
}

=head2 default_page_boundaries

    # Set
    $pdf->default_page_boundaries(%boundaries);

    # Get
    %boundaries = $pdf->default_page_boundaries();

Set default prepress page boundaries for pages in the PDF.  If called without
arguments, returns the coordinates of the rectangles describing each of the
supported page boundaries.

See the equivalent C<page_boundaries> method in L<PDF::API2::Page> for details.

=cut

# Called by PDF::API2::Page::boundaries via the default_page_* methods below
sub _bounding_box {
    my $self = shift();
    my $type = shift();

    # Get
    unless (scalar @_) {
        unless ($self->{'pages'}->{$type}) {
            return if $type eq 'MediaBox';

            # Use defaults per PDF 1.7 section 14.11.2 Page Boundaries
            return $self->_bounding_box('MediaBox') if $type eq 'CropBox';
            return $self->_bounding_box('CropBox');
        }
        return map { $_->val() } $self->{'pages'}->{$type}->elements();
    }

    # Set
    $self->{'pages'}->{$type} = PDFArray(map { PDFNum(float($_)) } @_);
    return $self;
}

sub default_page_boundaries {
    return PDF::API2::Page::boundaries(@_);
}

# Deprecated; use default_page_size or default_page_boundaries
sub mediabox {
    my $self = shift();
    return $self->_bounding_box('MediaBox') unless @_;
    return $self->_bounding_box('MediaBox', page_size(@_));
}

# Deprecated; use default_page_boundaries
sub cropbox {
    my $self = shift();
    return $self->_bounding_box('CropBox') unless @_;
    return $self->_bounding_box('CropBox', page_size(@_));
}

# Deprecated; use default_page_boundaries
sub bleedbox {
    my $self = shift();
    return $self->_bounding_box('BleedBox') unless @_;
    return $self->_bounding_box('BleedBox', page_size(@_));
}

# Deprecated; use default_page_boundaries
sub trimbox {
    my $self = shift();
    return $self->_bounding_box('TrimBox') unless @_;
    return $self->_bounding_box('TrimBox', page_size(@_));
}

# Deprecated; use default_page_boundaries
sub artbox {
    my $self = shift();
    return $self->_bounding_box('ArtBox') unless @_;
    return $self->_bounding_box('ArtBox', page_size(@_));
}

=head1 FONT METHODS

=head2 font

    my $font = $pdf->font($name, %options)

Add a font to the PDF.  Returns the font object, to be used by
L<PDF::API2::Content>.

The font C<$name> is either the name of one of the L<standard 14
fonts|PDF::API2::Resource::Font::CoreFont/"STANDARD FONTS"> (e.g. Helvetica) or
the path to a font file.

    my $pdf = PDF::API2->new();
    my $font1 = $pdf->font('Helvetica-Bold');
    my $font2 = $pdf->font('/path/to/ComicSans.ttf');
    my $page = $pdf->page();
    my $content = $page->text();

    $content->translate(1 * 72, 9 * 72);
    $content->font($font1, 24);
    $content->text('Hello, World!');

    $content->distance(0, -36);
    $content->font($font2, 12);
    $content->text('This is some sample text.');

    $pdf->save('sample.pdf');

The path can be omitted if the font file is in the current directory or one of
the directories returned by C<font_path>.

TrueType (ttf/otf), Adobe PostScript Type 1 (pfa/pfb), and Adobe Glyph Bitmap
Distribution Format (bdf) fonts are supported.

The following C<%options> are available:

=over

=item * format

The font format is normally detected automatically based on the file's
extension.  If you're using a font with an atypical extension, you can set
C<format> to one of C<truetype> (TrueType or OpenType), C<type1> (PostScript
Type 1), or C<bitmap> (Adobe Bitmap).

=item * kerning

Kerning (automatic adjustment of space between pairs of characters) is enabled
by default if the font includes this information.  Set this option to false to
disable.

=item * afm_file (PostScript Type 1 fonts only)

Specifies the location of the font metrics file.

=item * pfm_file (PostScript Type 1 fonts only)

Specifies the location of the printer font metrics file.  This option overrides
the -encode option.

=item * embed (TrueType fonts only)

Fonts are embedded in the PDF by default, which is required to ensure that they
can be viewed properly on a device that doesn't have the font installed.  Set
this option to false to prevent the font from being embedded.

=back

=cut

sub font {
    my ($self, $name, %options) = @_;

    if (exists $options{'kerning'}) {
        $options{'-dokern'} = delete $options{'kerning'};
    }

    require PDF::API2::Resource::Font::CoreFont;
    if (PDF::API2::Resource::Font::CoreFont->is_standard($name)) {
        return $self->corefont($name, %options);
    }

    my $format = $options{'format'};
    $format //= ($name =~ /\.[ot]tf$/i ? 'truetype' :
                 $name =~ /\.pf[ab]$/i ? 'type1'    :
                 $name =~ /\.bdf$/i    ? 'bitmap'   : '');

    if ($format eq 'truetype') {
        $options{'embed'} //= 1;
        return $self->ttfont($name, %options);
    }
    elsif ($format eq 'type1') {
        if (exists $options{'afm_file'}) {
            $options{'-afmfile'} = delete $options{'afm_file'};
        }
        if (exists $options{'pfm_file'}) {
            $options{'-pfmfile'} = delete $options{'pfm_file'};
        }
        return $self->psfont($name, %options);
    }
    elsif ($format eq 'bitmap') {
        return $self->bdfont($name, %options);
    }
    elsif ($format) {
        croak "Unrecognized font format: $format";
    }
    elsif ($name =~ /(\..*)$/) {
        croak "Unrecognized font file extension: $1";
    }
    else {
        croak "Unrecognized font: $name";
    }
}

=head2 synthetic_font

    $font = $pdf->synthetic_font($base_font, %options)

Create and return a new synthetic font object.  See
L<PDF::API2::Resource::Font::SynFont> for details.

=cut

# Deprecated (renamed)
sub synfont { return synthetic_font(@_) }

sub synthetic_font {
    my ($self, $font, %opts) = @_;

    # PDF::API2 doesn't set BaseEncoding for TrueType fonts, so text
    # isn't searchable unless a ToUnicode CMap is included.  Include
    # the ToUnicode CMap by default, but allow it to be disabled (for
    # performance and file size reasons) by setting -unicodemap to 0.
    $opts{-unicodemap} = 1 unless exists $opts{-unicodemap};

    require PDF::API2::Resource::Font::SynFont;
    my $obj = PDF::API2::Resource::Font::SynFont->new($self->{'pdf'}, $font, %opts);

    $self->{'pdf'}->out_obj($self->{'pages'});
    $obj->tounicodemap() if $opts{-unicodemap};

    return $obj;
}

=head2 font_path

    @directories = PDF::API2->font_path()

Return the list of directories that will be searched (in order) in addition to
the current directory when you add a font to a PDF without including the full
path to the font file.

=cut

sub font_path {
    return @font_path;
}

=head2 add_to_font_path

    @directories = PDF::API2->add_to_font_path('/my/fonts', '/path/to/fonts');

Add one or more directories to the list of paths to be searched for font files.

Returns the font search path.

=cut

# Deprecated (renamed)
sub addFontDirs { return add_to_font_path(@_) }

sub add_to_font_path {
    # Allow this method to be called using either :: or -> notation.
    shift() if ref($_[0]);
    shift() if $_[0] eq __PACKAGE__;

    push @font_path, @_;
    return @font_path;
}

=head2 set_font_path

    @directories = PDF::API2->set_font_path('/my/fonts', '/path/to/fonts');

Replace the existing font search path.  This should only be necessary if you
need to remove a directory from the path for some reason, or if you need to
reorder the list.

Returns the font search path.

=cut

sub set_font_path {
    # Allow this method to be called using either :: or -> notation.
    shift() if ref($_[0]);
    shift() if $_[0] eq __PACKAGE__;

    @font_path = ((map { "$_/PDF/API2/fonts" } @INC), @_);

    return @font_path;
}

sub _find_font {
    my $font = shift();

    # Check the current directory
    return $font if -f $font;

    # Check the font search path
    foreach my $directory (@font_path) {
        return "$directory/$font" if -f "$directory/$font";
    }

    return;
}

sub corefont {
    my ($self, $name, %opts) = @_;
    require PDF::API2::Resource::Font::CoreFont;
    my $obj = PDF::API2::Resource::Font::CoreFont->new($self->{'pdf'}, $name, %opts);
    $self->{'pdf'}->out_obj($self->{'pages'});
    $obj->tounicodemap() if $opts{-unicodemap};
    return $obj;
}

sub psfont {
    my ($self, $psf, %opts) = @_;

    foreach my $o (qw(-afmfile -pfmfile)) {
        next unless defined $opts{$o};
        $opts{$o} = _find_font($opts{$o});
    }
    $psf = _find_font($psf) or croak "Unable to find font \"$psf\"";
    require PDF::API2::Resource::Font::Postscript;
    my $obj = PDF::API2::Resource::Font::Postscript->new($self->{'pdf'}, $psf, %opts);

    $self->{'pdf'}->out_obj($self->{'pages'});
    $obj->tounicodemap() if $opts{-unicodemap};

    return $obj;
}

sub ttfont {
    my ($self, $name, %opts) = @_;

    # PDF::API2 doesn't set BaseEncoding for TrueType fonts, so text
    # isn't searchable unless a ToUnicode CMap is included.  Include
    # the ToUnicode CMap by default, but allow it to be disabled (for
    # performance and file size reasons) by setting -unicodemap to 0.
    $opts{-unicodemap} = 1 unless exists $opts{-unicodemap};

    # -noembed is deprecated (replace with embed => 0)
    if ($opts{'-noembed'}) {
        $opts{'embed'} //= 1;
    }
    $opts{'embed'} //= 1;

    my $file = _find_font($name) or croak "Unable to find font \"$name\"";
    require PDF::API2::Resource::CIDFont::TrueType;
    my $obj = PDF::API2::Resource::CIDFont::TrueType->new($self->{'pdf'}, $file, %opts);

    $self->{'pdf'}->out_obj($self->{'pages'});
    $obj->tounicodemap() if $opts{-unicodemap};

    return $obj;
}

sub bdfont {
    my ($self, @opts) = @_;

    require PDF::API2::Resource::Font::BdFont;
    my $obj = PDF::API2::Resource::Font::BdFont->new($self->{'pdf'}, @opts);

    $self->{'pdf'}->out_obj($self->{'pages'});
    # $obj->tounicodemap(); # does not support Unicode

    return $obj;
}

# Deprecated.  Use Unicode-supporting TrueType fonts instead.
# See PDF::API2::Resource::CIDFont::CJKFont for details.
sub cjkfont {
    my ($self, $name, %opts) = @_;

    require PDF::API2::Resource::CIDFont::CJKFont;
    my $obj = PDF::API2::Resource::CIDFont::CJKFont->new($self->{'pdf'}, $name, %opts);

    $self->{'pdf'}->out_obj($self->{'pages'});
    $obj->tounicodemap() if $opts{-unicodemap};

    return $obj;
}

# Deprecated.  Use Unicode-supporting TrueType fonts instead.
sub unifont {
    my ($self, @opts) = @_;

    require PDF::API2::Resource::UniFont;
    my $obj = PDF::API2::Resource::UniFont->new($self->{'pdf'}, @opts);

    return $obj;
}

=head1 IMAGE METHODS

=over

=item $jpeg = $pdf->image_jpeg($file)

Imports and returns a new JPEG image object.  C<$file> may be either a filename or a filehandle.

=cut

sub image_jpeg {
    my ($self, $file, %opts) = @_;

    require PDF::API2::Resource::XObject::Image::JPEG;
    my $obj = PDF::API2::Resource::XObject::Image::JPEG->new($self->{'pdf'}, $file);

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

=item $tiff = $pdf->image_tiff($file)

Imports and returns a new TIFF image object.  C<$file> may be either a filename or a filehandle.

=cut

sub image_tiff {
    my ($self, $file, %opts) = @_;

    require PDF::API2::Resource::XObject::Image::TIFF;
    my $obj = PDF::API2::Resource::XObject::Image::TIFF->new($self->{'pdf'}, $file);

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

=item $pnm = $pdf->image_pnm($file)

Imports and returns a new PNM image object.  C<$file> may be either a filename or a filehandle.

=cut

sub image_pnm {
    my ($self, $file, %opts) = @_;

    $opts{'-compress'} //= $self->{'forcecompress'};

    require PDF::API2::Resource::XObject::Image::PNM;
    my $obj = PDF::API2::Resource::XObject::Image::PNM->new($self->{'pdf'}, $file, %opts);

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

=item $png = $pdf->image_png($file)

Imports and returns a new PNG image object.  C<$file> may be either a filename or a filehandle.

Note: PNG files that include an alpha (transparency) channel go through a
relatively slow process of separating the transparency channel into a PDF SMask
object.  Install PDF::API2::XS or Image::PNG::Libpng to speed this up by an
order of magnitude.

=cut

sub image_png {
    my ($self, $file, %opts) = @_;

    require PDF::API2::Resource::XObject::Image::PNG;
    my $obj = PDF::API2::Resource::XObject::Image::PNG->new($self->{'pdf'}, $file);

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

=item $gif = $pdf->image_gif($file)

Imports and returns a new GIF image object.  C<$file> may be either a filename or a filehandle.

=cut

sub image_gif {
    my ($self, $file, %opts) = @_;

    require PDF::API2::Resource::XObject::Image::GIF;
    my $obj = PDF::API2::Resource::XObject::Image::GIF->new($self->{'pdf'}, $file);

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

=item $gdf = $pdf->image_gd($gd_object, %options)

Imports and returns a new image object from GD::Image.

B<Options:> The only option currently supported is C<< -lossless => 1 >>.

=cut

sub image_gd {
    my ($self, $gd, %opts) = @_;

    require PDF::API2::Resource::XObject::Image::GD;
    my $obj = PDF::API2::Resource::XObject::Image::GD->new($self->{'pdf'}, $gd, undef, %opts);

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

=back

=head1 COLORSPACE METHODS

=over

=item $cs = $pdf->colorspace_act($file)

Returns a new colorspace object based on an Adobe Color Table file.

See L<PDF::API2::Resource::ColorSpace::Indexed::ACTFile> for a
reference to the file format's specification.

=cut

sub colorspace_act {
    my ($self, $file, %opts) = @_;

    require PDF::API2::Resource::ColorSpace::Indexed::ACTFile;
    my $obj = PDF::API2::Resource::ColorSpace::Indexed::ACTFile->new($self->{'pdf'}, $file);

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

=item $cs = $pdf->colorspace_web()

Returns a new colorspace-object based on the web color palette.

=cut

sub colorspace_web {
    my ($self, $file, %opts) = @_;

    require PDF::API2::Resource::ColorSpace::Indexed::WebColor;
    my $obj = PDF::API2::Resource::ColorSpace::Indexed::WebColor->new($self->{'pdf'});

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

=item $cs = $pdf->colorspace_hue()

Returns a new colorspace-object based on the hue color palette.

See L<PDF::API2::Resource::ColorSpace::Indexed::Hue> for an explanation.

=cut

sub colorspace_hue {
    my ($self, $file, %opts)=@_;

    require PDF::API2::Resource::ColorSpace::Indexed::Hue;
    my $obj = PDF::API2::Resource::ColorSpace::Indexed::Hue->new($self->{'pdf'});

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

=item $cs = $pdf->colorspace_separation($tint, $color)

Returns a new separation colorspace object based on the parameters.

I<$tint> can be any valid ink identifier, including but not limited
to: 'Cyan', 'Magenta', 'Yellow', 'Black', 'Red', 'Green', 'Blue' or
'Orange'.

I<$color> must be a valid color specification limited to: '#rrggbb',
'!hhssvv', '%ccmmyykk' or a "named color" (rgb).

The colorspace model will automatically be chosen based on the
specified color.

=cut

sub colorspace_separation {
    my ($self, $name, @clr)=@_;

    require PDF::API2::Resource::ColorSpace::Separation;
    my $obj = PDF::API2::Resource::ColorSpace::Separation->new($self->{'pdf'}, pdfkey(), $name, @clr);

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

=item $cs = $pdf->colorspace_devicen(\@tintCSx, [$samples])

Returns a new DeviceN colorspace object based on the parameters.

B<Example:>

    $cy = $pdf->colorspace_separation('Cyan',    '%f000');
    $ma = $pdf->colorspace_separation('Magenta', '%0f00');
    $ye = $pdf->colorspace_separation('Yellow',  '%00f0');
    $bk = $pdf->colorspace_separation('Black',   '%000f');

    $pms023 = $pdf->colorspace_separation('PANTONE 032CV', '%0ff0');

    $dncs = $pdf->colorspace_devicen( [ $cy,$ma,$ye,$bk,$pms023 ] );

The colorspace model will automatically be chosen based on the first
colorspace specified.

=cut

sub colorspace_devicen {
    my ($self, $clrs, $samples) = @_;
    $samples ||= 2;

    require PDF::API2::Resource::ColorSpace::DeviceN;
    my $obj = PDF::API2::Resource::ColorSpace::DeviceN->new($self->{'pdf'}, pdfkey(), $clrs, $samples);

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

=back

=head1 BARCODE METHODS

=over

=item $bc = $pdf->xo_codabar(%options)

=item $bc = $pdf->xo_code128(%options)

=item $bc = $pdf->xo_2of5int(%options)

=item $bc = $pdf->xo_3of9(%options)

=item $bc = $pdf->xo_ean13(%options)

Creates the specified barcode object as a form XObject.

=cut

sub xo_code128 {
    my ($self, @opts) = @_;

    require PDF::API2::Resource::XObject::Form::BarCode::code128;
    my $obj = PDF::API2::Resource::XObject::Form::BarCode::code128->new($self->{'pdf'}, @opts);

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

sub xo_codabar {
    my ($self, @opts) = @_;

    require PDF::API2::Resource::XObject::Form::BarCode::codabar;
    my $obj = PDF::API2::Resource::XObject::Form::BarCode::codabar->new($self->{'pdf'}, @opts);

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

sub xo_2of5int {
    my ($self, @opts) = @_;

    require PDF::API2::Resource::XObject::Form::BarCode::int2of5;
    my $obj = PDF::API2::Resource::XObject::Form::BarCode::int2of5->new($self->{'pdf'}, @opts);

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

sub xo_3of9 {
    my ($self, @opts) = @_;

    require PDF::API2::Resource::XObject::Form::BarCode::code3of9;
    my $obj = PDF::API2::Resource::XObject::Form::BarCode::code3of9->new($self->{'pdf'}, @opts);

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

sub xo_ean13 {
    my ($self, @opts) = @_;

    require PDF::API2::Resource::XObject::Form::BarCode::ean13;
    my $obj = PDF::API2::Resource::XObject::Form::BarCode::ean13->new($self->{'pdf'}, @opts);

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

=back

=head1 OTHER METHODS

=over

=item $val = $pdf->default($parameter)

=item $pdf->default($parameter, $value)

Gets/sets the default value for a behaviour of PDF::API2.

B<Supported Parameters:>

=over

=item * nounrotate

prohibits API2 from rotating imported/opened page to re-create a
default pdf-context.

=item * pageencaps

enables than API2 will add save/restore commands upon imported/opened
pages to preserve graphics-state for modification.

=item * copyannots

enables importing of annotations (B<*EXPERIMENTAL*>).

=back

=cut

sub default {
    my ($self, $parameter, $value) = @_;

    # Parameter names may consist of lowercase letters, numbers, and underscores
    $parameter = lc $parameter;
    $parameter =~ s/[^a-z\d_]//g;

    my $previous_value = $self->{$parameter};
    if (defined $value) {
        $self->{$parameter} = $value;
    }
    return $previous_value;
}

=item $xo = $pdf->xo_form()

Returns a new form XObject.

=cut

sub xo_form {
    my $self = shift();

    my $obj = PDF::API2::Resource::XObject::Form::Hybrid->new($self->{'pdf'});

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

=item $egs = $pdf->egstate()

Returns a new extended graphics state object.

=cut

sub egstate {
    my $self = shift();

    my $obj = PDF::API2::Resource::ExtGState->new($self->{'pdf'}, pdfkey());

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

=item $obj = $pdf->pattern()

Returns a new pattern object.

=cut

sub pattern {
    my ($self, %opts) = @_;

    my $obj = PDF::API2::Resource::Pattern->new($self->{'pdf'}, undef, %opts);

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

=item $obj = $pdf->shading()

Returns a new shading object.

=cut

sub shading {
    my ($self, %opts) = @_;

    my $obj = PDF::API2::Resource::Shading->new($self->{'pdf'}, undef, %opts);

    $self->{'pdf'}->out_obj($self->{'pages'});

    return $obj;
}

=item $outlines = $pdf->outlines()

Creates (if needed) and returns the document's outline tree, which is also known
as its bookmarks or the table of contents, depending on the PDF reader.

To examine or modify the outline tree, see L<PDF::API2::Outline>.

=cut

sub outlines {
    my $self = shift();

    require PDF::API2::Outlines;
    my $obj = $self->{'pdf'}->{'Root'}->{'Outlines'};
    if ($obj) {
        $obj->realise();
        bless $obj, 'PDF::API2::Outlines';
        $obj->{' api'} = $self;
        weaken $obj->{' api'};
    }
    else {
        $obj = PDF::API2::Outlines->new($self);

        $self->{'pdf'}->{'Root'}->{'Outlines'} = $obj;
        $self->{'pdf'}->new_obj($obj) unless $obj->is_obj($self->{'pdf'});
        $self->{'pdf'}->out_obj($obj);
        $self->{'pdf'}->out_obj($self->{'pdf'}->{'Root'});
    }

    return $obj;
}

sub named_destination {
    my ($self, $cat, $name, $obj) = @_;
    my $root = $self->{'catalog'};

    $root->{'Names'} ||= PDFDict();
    $root->{'Names'}->{$cat} ||= PDFDict();
    $root->{'Names'}->{$cat}->{'-vals'}  ||= {};
    $root->{'Names'}->{$cat}->{'Limits'} ||= PDFArray();
    $root->{'Names'}->{$cat}->{'Names'}  ||= PDFArray();

    unless (defined $obj) {
        $obj = PDF::API2::NamedDestination->new($self->{'pdf'});
    }
    $root->{'Names'}->{$cat}->{'-vals'}->{$name} = $obj;

    my @names = sort {$a cmp $b} keys %{$root->{'Names'}->{$cat}->{'-vals'}};

    $root->{'Names'}->{$cat}->{'Limits'}->{' val'}->[0] = PDFStr($names[0]);
    $root->{'Names'}->{$cat}->{'Limits'}->{' val'}->[1] = PDFStr($names[-1]);

    @{$root->{'Names'}->{$cat}->{'Names'}->{' val'}} = ();

    foreach my $k (@names) {
        push @{$root->{'Names'}->{$cat}->{'Names'}->{' val'}}, (
            PDFStr($k),
            $root->{'Names'}->{$cat}->{'-vals'}->{$k}
        );
    }

    return $obj;
}

1;

__END__

=back

=head1 BACKWARD COMPATIBILITY GOAL

Code written using PDF::API2 should continue to work unchanged for the life of
most long-term-stable (LTS) server distributions.  Specifically, it should
continue working for versions of Perl that were L<released|perlhist> within the
past five years (the typical support window for LTS releases) plus six months
(allowing plenty of time for package freezes prior to release).

In PDF::API2, method names, options, and functionality change over time.
Functionality that's documented (not just in source code comments) should also
continue working for the same time period, though deprecation warnings may be
added.  There may be exceptions if your code happens to rely on bugs that get
fixed, including when a method in PDF::API2 is changed to more closely follow
the PDF specification.

Undocumented features, features marked as experimental, and underlying data
structures may change at any time.  An exception is for features that were
previously documented, which should continue to work for the same time period
after the documentation is removed.

Before migrating to a new LTS server version, it's recommended that you upgrade
to the latest version of PDF::API2, enable C<use warnings>, and check your
server logs for deprecations.  Once these are resolved, your code should be safe
to use for any PDF::API2 releases during that LTS support window.

=head1 AUTHOR

PDF::API2 was originally written by Alfred Reibenschuh, extending code written
by Martin Hosken.

It is currently being maintained and developed by Steve Simms, with patches from
numerous contributors who are credited in the Changes file.

=head1 LICENSE

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation, either version 2.1 of the License, or (at your option) any
later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.

=cut
