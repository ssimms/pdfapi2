package PDF::API2::Resource::Font::CoreFont;

use base 'PDF::API2::Resource::Font';

use strict;
use warnings;

# VERSION

use File::Basename;

use PDF::API2::Util;
use PDF::API2::Basic::PDF::Utils;

# Windows fonts with Type1 equivalents
my $alias = {
    'arial'           => 'helvetica',
    'arialitalic'     => 'helveticaoblique',
    'arialbold'       => 'helveticabold',
    'arialbolditalic' => 'helveticaboldoblique',

    'times'                   => 'timesroman',
    'timesnewromanbolditalic' => 'timesbolditalic',
    'timesnewromanbold'       => 'timesbold',
    'timesnewromanitalic'     => 'timesitalic',
    'timesnewroman'           => 'timesroman',

    'couriernewbolditalic' => 'courierboldoblique',
    'couriernewbold'       => 'courierbold',
    'couriernewitalic'     => 'courieroblique',
    'couriernew'           => 'courier',
};

=head1 NAME

PDF::API2::Resource::Font::CoreFont - Module for using the 14 PDF built-in fonts.

=head1 SYNOPSIS

    use PDF::API2;
    my $pdf = PDF::API2->new();
    my $font = $pdf->corefont('Times-Roman');

=head1 METHODS

=over

=item $font = PDF::API2::Resource::Font::CoreFont->new($pdf, $name, %options)

Returns a corefont object.  Spaces and hyphens are ignored in the name, which is
also case-insensitive.

=cut

=pod

Valid C<%options> are:

C<-encode> changes the encoding of the font from its default.  See L<Encode> for
the supported values.

C<-pdfname> changes the reference name of the font from its default.  The
reference name is normally generated automatically and can be retrieved via
C<$name = $font->fontname()>.

=cut

sub _look_for_font {
    my $name = shift();
    eval "require PDF::API2::Resource::Font::CoreFont::$name";
    if ($@) {
        die "requested font '$name' not installed";
    }

    my $class = "PDF::API2::Resource::Font::CoreFont::$name";
    my $font = _deep_copy($class->data());
    $font->{'uni'} ||= [];
    foreach my $n (0..255) {
        unless (defined $font->{'uni'}->[$n]) {
            $font->{'uni'}->[$n] = uniByName($font->{'char'}->[$n]);
        }
    }
    return %$font;
}

# Deep copy something, thanks to Randal L. Schwartz
# Changed to deal with code refs, in which case it doesn't try to deep copy
sub _deep_copy {
    my $this = shift();
    no warnings 'recursion';
    unless (ref($this)) {
        return $this;
    }
    elsif (ref($this) eq 'ARRAY') {
        return [ map { _deep_copy($_) } @$this];
    }
    elsif (ref($this) eq 'HASH') {
        return +{ map { $_ => _deep_copy($this->{$_}) } keys %$this };
    }
    elsif (ref $this eq "CODE") {
        # Can't deep copy code refs
        return $this;
    }
    else {
        die 'Unable to copy a ' . ref($this);
    }
}

sub new {
    my ($class, $pdf, $name, %options) = @_;
    my $data;

    if (-f $name) {
        eval "require '$name'";
        $name = basename($name, '.pm');
    }

    my $lookname = lc($name);
    $lookname =~ s/[^a-z0-9]+//gi;
    $lookname = $alias->{$lookname} if $alias->{$lookname};

    $options{'-encode'} ||= 'asis';
    unless (defined $options{'-metrics'}) {
        $data = { _look_for_font($lookname) };
    }
    else {
        $data = { %{$options{'-metrics'}} };
    }

    die "Undefined font '$name($lookname)'" unless $data->{'fontname'};

    $class = ref($class) if ref($class);
    my $self = $class->SUPER::new($pdf, $data->{'apiname'} . pdfkey() . '~' . time());
    $pdf->new_obj($self) unless $self->is_obj($pdf);
    $self->{' data'} = $data;
    $self->{'-dokern'} = 1 if $options{'-dokern'};

    $self->{'Subtype'} = PDFName($self->data->{'type'});
    $self->{'BaseFont'} = PDFName($self->fontname());
    if ($options{'-pdfname'}) {
        $self->name($options{'-pdfname'});
    }

    unless ($self->data->{'iscore'}) {
        $self->{'FontDescriptor'} = $self->descrByData();
    }

    $self->encodeByData($options{'-encode'});

    return $self;
}

1;

__END__

=back

=head1 SUPPORTED FONTS

=over

=item PDF::API2::CoreFont supports the following Adobe core fonts:

  Courier
  Courier-Bold
  Courier-BoldOblique
  Courier-Oblique
  Helvetica
  Helvetica-Bold
  Helvetica-BoldOblique
  Helvetica-Oblique
  Symbol
  Times-Bold
  Times-BoldItalic
  Times-Italic
  Times-Roman
  ZapfDingbats

=item PDF::API2::CoreFont supports the following Windows fonts:

  Georgia
  Georgia,Bold
  Georgia,BoldItalic
  Georgia,Italic
  Verdana
  Verdana,Bold
  Verdana,BoldItalic
  Verdana,Italic
  Webdings
  Wingdings

=back

=cut
