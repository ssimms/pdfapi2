package PDF::API2::Resource::XObject::Form::BarCode::codabar;

use base 'PDF::API2::Resource::XObject::Form::BarCode';

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
