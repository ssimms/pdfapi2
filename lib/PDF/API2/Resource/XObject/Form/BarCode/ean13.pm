package PDF::API2::Resource::XObject::Form::BarCode::ean13;

# VERSION

use base 'PDF::API2::Resource::XObject::Form::BarCode';

use strict;
use warnings;

sub new {
    my ($class, $pdf, %options) = @_;
    my $self = $class->SUPER::new($pdf, %options);

    my @bars = $self->encode($options{'-code'});

    $self->drawbar([@bars]);

    return $self;
}

my @ean_code_odd  = qw( 3211 2221 2122 1411 1132 1231 1114 1312 1213 3112 );
my @ean_code_even = qw( 1123 1222 2212 1141 2311 1321 4111 2131 3121 2113 );

sub encode {
    my ($self, $string) = @_;
    my @c = split //, $string;

    # The first digit determines the even/odd pattern of the next six
    # digits, and is printed to the left of the barcode
    my $v = shift @c;
    my @bars = (['07', $v]);

    # Start Code
    push @bars, 'a1a';

    # Digits 2-7
    if ($v == 0) {
        foreach (0..5) {
            my $digit = shift @c;
            push @bars, [$ean_code_odd[$digit], $digit];
        }
    }
    elsif ($v == 1) {
        my $digit = shift @c;
        push @bars, [$ean_code_odd[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
    }
    elsif ($v == 2) {
        my $digit = shift @c;
        push @bars, [$ean_code_odd[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
    }
    elsif ($v == 3) {
        my $digit = shift @c;
        push @bars, [$ean_code_odd[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
    }
    elsif ($v == 4) {
        my $digit = shift @c;
        push @bars, [$ean_code_odd[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
    }
    elsif ($v == 5) {
        my $digit = shift @c;
        push @bars, [$ean_code_odd[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
    }
    elsif ($v == 6) {
        my $digit = shift @c;
        push @bars, [$ean_code_odd[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
    }
    elsif ($v == 7) {
        my $digit = shift @c;
        push @bars, [$ean_code_odd[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
    }
    elsif ($v == 8) {
        my $digit = shift @c;
        push @bars, [$ean_code_odd[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
    }
    elsif ($v == 9) {
        my $digit = shift @c;
        push @bars, [$ean_code_odd[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
        $digit = shift @c; push @bars, [$ean_code_even[$digit], $digit];
        $digit = shift @c; push @bars, [$ean_code_odd[$digit],  $digit];
    }

    # Center Code
    push @bars, '1a1a1';

    # Digits 8-13
    for (0..5) {
        my $digit = shift @c;
        push @bars, [$ean_code_odd[$digit], $digit];
    }

    # Stop Code
    push @bars, 'a1a';

    return @bars;
}

1;
