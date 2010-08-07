package PDF::API2::Resource::XObject::Form;

BEGIN {

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Resource::XObject;

    use POSIX;

    use vars qw(@ISA $VERSION);

    @ISA = qw( PDF::API2::Resource::XObject );

    ( $VERSION ) = '2.000';

}
no warnings qw[ deprecated recursion uninitialized ];

=head1 NAME

PDF::API2::Resource::XObject::Form

=head1 METHODS

=over

=item $res = PDF::API2::Resource::XObject::Form->new $pdf

Returns a form-resource object. base class for all types of form-xobjects.

=cut

sub new {
    my ($class,$pdf) = @_;
    my $self;

    $class = ref $class if ref $class;

    $self=$class->SUPER::new($pdf,pdfkey());
    $pdf->new_obj($self) unless($self->is_obj($pdf));

    $self->subtype('Form');
    $self->{FormType}=PDFNum(1);

    $self->{' apipdf'}=$pdf;

    return($self);
}

=item $res = PDF::API2::Resource::XObject::Form->new_api $api, $name

Returns a form resource object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $obj->{' api'}=$api;

    return($obj);
}

=item ($llx, $lly, $urx, $ury) = $res->bbox $llx, $lly, $urx, $ury

=cut

sub bbox {
    my $self = shift @_;
    my @b;
    if(@b=@_){
        $self->{BBox}=PDFArray(map { PDFNum($_) } @b);
    }
    @b=$self->{BBox}->elementsof;
    return(map { $_->val } @b);
}

=item $res->resource $type, $key, $obj

Adds a resource to the form.

B<Example:>

    $res->resource('Font',$fontkey,$fontobj);
    $res->resource('XObject',$imagekey,$imageobj);
    $res->resource('Shading',$shadekey,$shadeobj);
    $res->resource('ColorSpace',$spacekey,$speceobj);

B<Note:> You only have to add the required resources, if
they are NOT handled by the *font*, *image*, *shade* or *space*
methods.

=cut

sub resource {
    my ($self, $type, $key, $obj, $force) = @_;
    # we are a self-contained content stream.

    $self->{Resources}||=PDFDict();

    my $dict=$self->{Resources};
    $dict->realise if(ref($dict)=~/Objind$/);

    $dict->{$type}||= PDFDict();
    $dict->{$type}->realise if(ref($dict->{$type})=~/Objind$/);
    unless (defined $obj) {
        return($dict->{$type}->{$key} || undef);
    } else {
        if($force) {
            $dict->{$type}->{$key}=$obj;
        } else {
            $dict->{$type}->{$key}||= $obj;
        }
        return($dict);
    }
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

=back

=head1 AUTHOR

alfred reibenschuh

=cut
