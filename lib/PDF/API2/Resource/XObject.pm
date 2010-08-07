package PDF::API2::Resource::XObject;

BEGIN {

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Resource;

    use POSIX;

    use vars qw(@ISA $VERSION);

    @ISA = qw( PDF::API2::Resource );

    ( $VERSION ) = '2.000';

}
no warnings qw[ deprecated recursion uninitialized ];

=head1 NAME

PDF::API2::Resource::XObject

=head1 METHODS

=over

=item $res = PDF::API2::Resource::XObject->new $pdf, $name

Returns a xobject-resource object.

=cut

sub new {
    my ($class,$pdf,$name) = @_;
    my $self;

    $class = ref $class if ref $class;

    $self=$class->SUPER::new($pdf,$name);
    $pdf->new_obj($self) unless($self->is_obj($pdf));

    $self->{Type}=PDFName('XObject');

    $self->{' apipdf'}=$pdf;

    return($self);
}

=item $res = PDF::API2::Resource::XObject->new_api $api, $name

Returns a xobject resource object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $obj->{' api'}=$api;

    return($obj);
}

=item $name = $res->subtype $typename

Returns or sets the Subtype of the xobject resource.

=cut

sub subtype {
    my $self=shift @_;
    if(scalar @_ >0 && defined($_[0])) {
        $self->{Subtype}=PDFName($_[0]);
    }
    return($self->{Subtype}->val);
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

=back

=head1 AUTHOR

Alfred Reibenschuh

=cut
