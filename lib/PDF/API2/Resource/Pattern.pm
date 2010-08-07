package PDF::API2::Resource::Pattern;

BEGIN {

    use strict;
    use vars qw(@ISA $VERSION);
    use PDF::API2::Basic::PDF::Array;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Util;
    use Math::Trig;

    @ISA = qw(PDF::API2::Resource);

    ( $VERSION ) = '2.000';

}
no warnings qw[ deprecated recursion uninitialized ];

sub new {
    my ($class,$pdf,$key,%opts)=@_;

    $class = ref $class if ref $class;
    $self=$class->SUPER::new($pdf,$key || pdfkey());
    $pdf->new_obj($self) unless($self->is_obj($pdf));
    $self->{Type}=PDFName('Pattern');
    $self->{' apipdf'}=$pdf;

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
