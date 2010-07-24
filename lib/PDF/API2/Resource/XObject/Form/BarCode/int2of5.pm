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
package PDF::API2::Resource::XObject::Form::BarCode::int2of5;

BEGIN {

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Resource::XObject::Form::BarCode;

    use POSIX;

    use vars qw(@ISA $VERSION);

    @ISA = qw( PDF::API2::Resource::XObject::Form::BarCode );

    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$

}
no warnings qw[ deprecated recursion uninitialized ];

=item $res = PDF::API2::Resource::XObject::Form::BarCode::int2of5->new $pdf

Returns a 2of5int object.

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

__END__

=head1 AUTHOR

alfred reibenschuh

=cut
