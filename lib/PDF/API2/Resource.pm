package PDF::API2::Resource;

BEGIN {

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Basic::PDF::Dict;
    use POSIX;

    use vars qw(@ISA $VERSION);

    @ISA = qw( PDF::API2::Basic::PDF::Dict );

    ( $VERSION ) = '2.000';

}

no warnings qw[ deprecated recursion uninitialized ];

=head1 $res = PDF::API2::Resource->new $pdf, $name

Returns a resource object.

=cut

sub new {
    my ($class,$pdf,$name) = @_;
    my $self;

    $class = ref $class if ref $class;

    $self=$class->SUPER::new();
    $pdf->new_obj($self) unless($self->is_obj($pdf));

    $self->name($name || pdfkey());

    $self->{' apipdf'}=$pdf;

    return($self);
}

=item $res = PDF::API2::Resource->new_api $api, $name

Returns a resource object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $obj->{' api'}=$api;

    return($obj);
}

=item $name = $res->name $name

Returns or sets the Name of the resource.

=cut

sub name {
    my $self=shift @_;
    if(scalar @_ >0 && defined($_[0])) {
        $self->{Name}=PDFName($_[0]);
    }
    return($self->{Name}->val);
}

sub outobjdeep {
    my ($self, $fh, $pdf, %opts) = @_;

    return $self->SUPER::outobjdeep($fh, $pdf) if defined $opts{'passthru'};
    foreach my $k (qw/ api apipdf /) {
        $self->{" $k"}=undef;
        delete($self->{" $k"});
    }
    $self->SUPER::outobjdeep($fh, $pdf, %opts);
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=cut
