#=======================================================================
#    ____  ____  _____              _    ____ ___   ____
#   |  _ \|  _ \|  ___|  _   _     / \  |  _ \_ _| |___ \
#   | |_) | | | | |_    (_) (_)   / _ \ | |_) | |    __) |
#   |  __/| |_| |  _|    _   _   / ___ \|  __/| |   / __/
#   |_|   |____/|_|     (_) (_) /_/   \_\_|  |___| |_____|
#
#   A Perl Module Chain to faciliate the Creation and Modification
#   of High-Quality "Portable Document Format (PDF)" Files.
#
#   Copyright 1999-2005 Alfred Reibenschuh <areibens@cpan.org>.
#
#=======================================================================
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU Lesser General Public
#   License as published by the Free Software Foundation; either
#   version 2 of the License, or (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   Lesser General Public License for more details.
#
#   You should have received a copy of the GNU Lesser General Public
#   License along with this library; if not, write to the
#   Free Software Foundation, Inc., 59 Temple Place - Suite 330,
#   Boston, MA 02111-1307, USA.
#
#   $Id$
#
#=======================================================================


package PDF::API2::Resource::XObject::Form::BarCode::ean13;

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

=item $res = PDF::API2::Resource::XObject::Form::BarCode::ea13->new $pdf

Returns a ean13 object.

=cut

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

__END__

=head1 AUTHOR

alfred reibenschuh

=cut
