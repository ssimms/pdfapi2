package PDF::API2::Resource::XObject::Image;

BEGIN {

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Resource::XObject;

    use POSIX;
    use Compress::Zlib;

    use vars qw(@ISA $VERSION);

    @ISA = qw( PDF::API2::Resource::XObject );

    ( $VERSION ) = '2.000';

}
no warnings qw[ deprecated recursion uninitialized ];

=item $res = PDF::API2::Resource::XObject::Image->new $pdf, $name

Returns a image-resource object. base class for all types of bitmap-images.

=cut

sub new {
    my ($class,$pdf,$name) = @_;
    my $self;

    $class = ref $class if ref $class;

    $self=$class->SUPER::new($pdf,$name);
    $pdf->new_obj($self) unless($self->is_obj($pdf));

    $self->subtype('Image');

    $self->{' apipdf'}=$pdf;

    return($self);
}

=item $res = PDF::API2::Resource::XObject::Image->new_api $api, $name

Returns a image resource object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $obj->{' api'}=$api;

    return($obj);
}

=item $wd = $img->width

=cut

sub width {
    my $self = shift @_;
    my $x=shift @_;
    $self->{Width}=PDFNum($x) if(defined $x);
    return($self->{Width}->val);
}

=item $ht = $img->height

=cut

sub height {
    my $self = shift @_;
    my $x=shift @_;
    $self->{Height}=PDFNum($x) if(defined $x);
    return($self->{Height}->val);
}

=item $img->smask $smaskobj

=cut

sub smask {
    my $self = shift @_;
    my $maskobj = shift @_;
    $self->{SMask}=$maskobj;
    return $self;
}

=item $img->mask @maskcolorange

=cut

sub mask {
    my $self = shift @_;
    $self->{Mask}=PDFArray(map { PDFNum($_) } @_);
    return $self;
}

=item $img->imask $maskobj

=cut

sub imask {
    my $self = shift @_;
    $self->{Mask}=shift @_;
    return $self;
}

=item $img->colorspace $csobj

=cut

sub colorspace {
    my $self = shift @_;
    my $obj = shift @_;
    $self->{'ColorSpace'}=ref $obj ? $obj : PDFName($obj) ;
    return $self;
}

=item $img->filters @filternames

=cut

sub filters {
    my $self = shift @_;
    $self->{Filter}=PDFArray(map { ref($_) ? $_ : PDFName($_) } @_);
    return $self;
}

=item $img->bpc $num

=cut

sub bpc {
    my $self = shift @_;
    $self->{BitsPerComponent}=PDFNum(shift @_);
    return $self;
}

sub outobjdeep {
    my ($self, @opts) = @_;
    foreach my $k (qw/ api apipdf /) {
        $self->{" $k"}=undef;
        delete($self->{" $k"});
    }
    $self->SUPER::outobjdeep(@opts);
}


1;

__END__

=head1 AUTHOR

alfred reibenschuh

=cut
