package PDF::API2::Resource::XObject::Form::BarCode::ean13;

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


my @ean_code_odd =qw( 3211 2221 2122 1411 1132 1231 1114 1312 1213 3112 );
my @ean_code_even=qw( 1123 1222 2212 1141 2311 1321 4111 2131 3121 2113 );

sub encode {
    my $self=shift @_;
    my $string=shift @_;
    my @c=split(//,$string);
    my ($enc,@bar);
    my $v=shift @c;
    push(@bar,['07',"$v"]);
    push(@bar,'a1a');
    if($v==0) {
        foreach(0..5) {
            my $f=shift @c;
            push(@bar,[$ean_code_odd[$f],"$f"]);
        }
    } elsif($v==1) {
        my $f=shift @c;
        push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
    } elsif($v==2) {
        my $f=shift @c;
        push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
    } elsif($v==3) {
        my $f=shift @c;
        push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
    } elsif($v==4) {
        my $f=shift @c;
        push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
    } elsif($v==5) {
        my $f=shift @c;
        push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
    } elsif($v==6) {
        my $f=shift @c;
        push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
    } elsif($v==7) {
        my $f=shift @c;
        push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
    } elsif($v==8) {
        my $f=shift @c;
        push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
    } elsif($v==9) {
        my $f=shift @c;
        push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
        $f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
    }
    push(@bar,'1a1a1');
    foreach(0..5) {
        my $f=shift @c;
        push(@bar,[$ean_code_odd[$f],"$f"]);
    }
    push(@bar,'a1a');
    return @bar;
}

1;
