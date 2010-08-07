package PDF::API2::Resource::XObject::Form::Hybrid;

BEGIN {

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Basic::PDF::Dict;
    use PDF::API2::Resource::XObject::Form;

    use PDF::API2::Content;

    use POSIX;

    use vars qw(@ISA $VERSION);

    @ISA = (
        'PDF::API2::Content',
        'PDF::API2::Resource::XObject::Form'
    );

    ( $VERSION ) = '2.001';
}
no warnings qw[ deprecated recursion uninitialized ];

sub new {
    my ($class,$pdf) = @_;
    my $self;

    $class = ref $class if ref $class;

    $self=PDF::API2::Resource::XObject::Form::new($class,$pdf,pdfkey());
    $pdf->new_obj($self) unless($self->is_obj($pdf));

    $self->{' apipdf'}=$pdf;

    $self->{' stream'}='';
    $self->{' poststream'}='';
    $self->{' font'}=undef;
    $self->{' fontsize'}=0;
    $self->{' charspace'}=0;
    $self->{' hspace'}=100;
    $self->{' wordspace'}=0;
    $self->{' lead'}=0;
    $self->{' rise'}=0;
    $self->{' render'}=0;
    $self->{' matrix'}=[1,0,0,1,0,0];
    $self->{' fillcolor'}=[0];
    $self->{' strokecolor'}=[0];
    $self->{' translate'}=[0,0];
    $self->{' scale'}=[1,1];
    $self->{' skew'}=[0,0];
    $self->{' rotate'}=0;
    $self->{' apiistext'}=0;

    $self->{Resources}=PDFDict();
    $self->{Resources}->{ProcSet}=PDFArray(map { PDFName($_) } qw[ PDF Text ImageB ImageC ImageI ]);

    $self->compressFlate;

    return($self);
}

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $obj->{' api'}=$api;

    return($obj);
}

sub outobjdeep {
    my ($self, @opts) = @_;
    $self->textend unless($self->{' nofilt'});
    foreach my $k (qw/ api apipdf apipage font fontsize charspace hspace wordspace lead rise render matrix fillcolor strokecolor translate scale skew rotate /) {
        $self->{" $k"}=undef;
        delete($self->{" $k"});
    }
    PDF::API2::Basic::PDF::Dict::outobjdeep($self,@opts);
}

1;
