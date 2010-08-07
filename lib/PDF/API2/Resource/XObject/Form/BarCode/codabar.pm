package PDF::API2::Resource::XObject::Form::BarCode::codabar;

BEGIN {

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Resource::XObject::Form::BarCode;

    use POSIX;

    use vars qw(@ISA $VERSION);

    @ISA = qw( PDF::API2::Resource::XObject::Form::BarCode );

    ( $VERSION ) = '2.000';

}
no warnings qw[ deprecated recursion uninitialized ];

sub new {
    my ($class,$pdf,%opts) = @_;
    my $self;

    $class = ref $class if ref $class;

    $self=$class->SUPER::new($pdf,%opts);

    my @bar = $self->encode($opts{-code});

    $self->drawbar([@bar]);

    return($self);
}


my $codabar=q|0123456789-$:/.+ABCD|;

my @barcodabar=qw(
    11111221 11112211 11121121 22111111 11211211
    21111211 12111121 12112111 12211111 21121111
    11122111 11221111 21112121 21211121 21212111
    11212121 11221211 12121121 12121121 11122211
);

sub encode_char {
        my $self=shift @_;
        my $char=uc(shift @_);
        return($barcodabar[index($codabar,$char)]);
}

1;
