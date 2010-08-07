package PDF::API2::Resource::XObject::Form::BarCode::int2of5;

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


my @bar25interleaved=qw(
    11221
    21112
    12112
    22111
    11212
    21211
    12211
    11122
    21121
    12121
);

sub encode {
    my $self=shift @_;
    my $string=shift @_;
    $string=~ tr/0123456789//cd;
    my ($enc,@bar);

    push(@bar,'aaaa');
    while(length($string)>0)
    {
        $string=~ s/^(\d{1,1})(\d{0,1})(\d*?)$/$3/;
        $c1=$1;
        $c2=$2;
        $c2='0' if ($c2 eq "");
        $s1=$bar25interleaved[$c1];
        $s2=$bar25interleaved[$c2];
        $o='';
        for($cnt=0;$cnt<5;$cnt++)
        {
            $o.=substr($s1,$cnt,1);
            $o.=substr($s2,$cnt,1);
        }
        push(@bar,[$o,($c1 . $c2)]);
    }
    push(@bar,'baaa');
    return(@bar);
}

1;
