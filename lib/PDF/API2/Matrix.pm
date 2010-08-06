#=======================================================================
#    ____  ____  _____              _    ____ ___   ____
#   |  _ \|  _ \|  ___|  _   _     / \  |  _ \_ _| |___ \
#   | |_) | | | | |_    (_) (_)   / _ \ | |_) | |    __) |
#   |  __/| |_| |  _|    _   _   / ___ \|  __/| |   / __/
#   |_|   |____/|_|     (_) (_) /_/   \_\_|  |___| |_____|
#
#   Copyright 1999-2001 Alfred Reibenschuh <areibens@cpan.org>.
#
#   This library is free software; you can redistribute it
#   and/or modify it under the same terms as Perl itself.
#
#=======================================================================
#
#   PDF::API2::Matrix
#   Original Copyright 1995-96 Ulrich Pfeifer.
#   modified by Alfred Reibenschuh <areibens@cpan.org> for PDF::API2
#
#   $Id$
#
#=======================================================================
package PDF::API2::Matrix;

    use vars qw( $VERSION );

    ( $VERSION ) = '2.000';

no warnings qw[ deprecated recursion uninitialized ];

sub new {
    my $type = shift;
    my $self = [];
    my $len = scalar(@{$_[0]});
    for (@_) {
        return undef if scalar(@{$_}) != $len;
        push(@{$self}, [@{$_}]);
    }
    bless $self, $type;
}

sub concat {
    my $self = shift;
    my $other = shift;
    my $result = new PDF::API2::Matrix (@{$self});

    return undef if scalar(@{$self}) != scalar(@{$other});
    for my $i (0 .. $#{$self}) {
    push @{$result->[$i]}, @{$other->[$i]};
    }
    $result;
}

sub transpose {
    my $self = shift;
    my @result;
    my $m;

    for my $col (@{$self->[0]}) {
        push @result, [];
    }
    for my $row (@{$self}) {
        $m=0;
        for my $col (@{$row}) {
            push(@{$result[$m++]}, $col);
        }
    }
    new PDF::API2::Matrix (@result);
}

sub vekpro {
    my($a, $b) = @_;
    my $result=0;

    for my $i (0 .. $#{$a}) {
        $result += $a->[$i] * $b->[$i];
    }
    $result;
}

sub multiply {
    my $self  = shift;
    my $other = shift->transpose;
    my @result;
    my $m;

    return undef if $#{$self->[0]} != $#{$other->[0]};
    for my $row (@{$self}) {
        my $rescol = [];
    for my $col (@{$other}) {
            push(@{$rescol}, vekpro($row,$col));
        }
        push(@result, $rescol);
    }
    new PDF::API2::Matrix (@result);
}


sub solve {
    my $m    = new PDF::API2::Matrix (@{$_[0]});
    my $mr   = $#{$m};
    my $mc   = $#{$m->[0]};
    my $f;
    my $try;
    my $k;
    my $i;
    my $j;
    my $eps = 0.000001;

    return undef if $mc <= $mr;
    ROW: for($i = 0; $i <= $mr; $i++) {
    $try=$i;
    # make diagonal element nonzero if possible
    while (abs($m->[$i]->[$i]) < $eps) {
        last ROW if $try++ > $mr;
        my $row = splice(@{$m},$i,1);
        push(@{$m}, $row);
    }

    # normalize row
    $f = $m->[$i]->[$i];
    for($k = 0; $k <= $mc; $k++) {
            $m->[$i]->[$k] /= $f;
    }
    # subtract multiple of designated row from other rows
        for($j = 0; $j <= $mr; $j++) {
        next if $i == $j;
            $f = $m->[$j]->[$i];
            for($k = 0; $k <= $mc; $k++) {
                $m->[$j]->[$k] -= $m->[$i]->[$k] * $f;
            }
        }
    }
# Answer is in augmented column
    transpose new PDF::API2::Matrix @{$m->transpose}[$mr+1 .. $mc];
}

sub print {
    my $self = shift;

    print STDERR "Matrix: \n";
    print @_ if scalar(@_);
    for my $row (@{$self}) {
        for my $col (@{$row}) {
            printf STDERR "%10.5f ", $col;
        }
        print STDERR "\n";
    }
}

1;

__END__

