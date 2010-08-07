package PDF::API2::Resource::Shading;

BEGIN {

    use strict;
    use vars qw(@ISA);
    use PDF::API2::Resource;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Util;
    use Math::Trig;

    @ISA = qw(PDF::API2::Resource);

}
no warnings qw[ deprecated recursion uninitialized ];

sub new {
    my ($class,$pdf,$key,%opts)=@_;

    $class = ref $class if ref $class;
    $self=$class->SUPER::new($pdf,$key || pdfkey());
    $pdf->new_obj($self) unless($self->is_obj($pdf));
    $self->{' apipdf'}=$pdf;

#    $self->{ColorSpace}=PDFName($opts{-colorspace}||'DeviceRGB');
#
#    $sh->{ShadingType}=PDFNum(2);
#    $sh->{Coords}=PDFArray(PDFNum(0),PDFNum(0),PDFNum(1),PDFNum(1));
#    $sh->{Function}=PDFDict();
#    $sh->{Function}->{FunctionType}=PDFNum(2);
#    $sh->{Function}->{Domain}=PDFArray(PDFNum(0),PDFNum(1));
#    $sh->{Function}->{C0}=PDFArray(PDFNum(1),PDFNum(1),PDFNum(1));
#    $sh->{Function}->{C1}=PDFArray(PDFNum(0),PDFNum(0),PDFNum(1));
#    $sh->{Function}->{N}=PDFNum(1);

    return($self);
}

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $self->{' api'}=$api;

    return($obj);
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
