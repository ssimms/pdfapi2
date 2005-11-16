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
package PDF::API2::Resource::XObject::Form::BarCode::code128;

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

=item $res = PDF::API2::Resource::XObject::Form::BarCode::code128->new $pdf, %opts

Returns a code128 object. Use '-ean' to encode using EAN128 mode.

=cut

sub new {
    my ($class,$pdf,%opts) = @_;
    my $self;

    $class = ref $class if ref $class;

    $self=$class->SUPER::new($pdf,%opts);

    my @bar = $opts{-ean} ? $self->encode_ean128($opts{-code}) : $self->encode_128($opts{-type},$opts{-code});

    $self->drawbar([@bar]);

    return($self);
}


my $code128a=q| !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_|.join('',map{chr($_)}(0..31)).qq/\xf3\xf2\x80\xcc\xcb\xf4\xf1\x8a\x8b\x8c\xff/;
my $code128b=q| !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|.qq/|}~\x7f\xf3\xf2\x80\xcc\xf4\xca\xf1\x8a\x8b\x8c\xff/;
my $code128c=("\xfe" x 100).qq/\xcb\xca\xf1\x8a\x8b\x8c\xff/;

my @bar128=qw(
    212222 222122 222221 121223 121322
    131222 122213 122312 132212 221213
    221312 231212 112232 122132 122231
    113222 123122 123221 223211 221132
    221231 213212 223112 312131 311222
    321122 321221 312212 322112 322211
    212123 212321 232121 111323 131123
    131321 112313 132113 132311 211313
    231113 231311 112133 112331 132131
    113123 113321 133121 313121 211331
    231131 213113 213311 213131 311123
    311321 331121 312113 312311 332111
    314111 221411 431111 111224 111422
    121124 121421 141122 141221 112214
    112412 122114 122411 142112 142211
    241211 221114 413111 241112 134111
    111242 121142 121241 114212 124112
    124211 411212 421112 421211 212141
    214121 412121 111143 111341 131141
    114113 114311 411113 411311 113141
    114131 311141 411131 b1a4a2 b1a2a4
    b1a2c2 b3c1a1b
);

my $bar128F1="\xf1";
my $bar128F2="\xf2";
my $bar128F3="\xf3";
my $bar128F4="\xf4";

my $bar128Ca="\xca";
my $bar128Cb="\xcb";
my $bar128Cc="\xcc";

my $bar128sh="\x80";

my $bar128Sa="\x8a";
my $bar128Sb="\x8b";
my $bar128Sc="\x8c";

my $bar128St="\xff";

sub encode_128_char_idx {
    my ($code,$char)=@_;
    my ($idx);
    if(lc($code) eq 'a') {
        return if($char eq $bar128Ca);
        $idx=index($code128a,$char);
    } elsif(lc($code) eq 'b') {
        return if($char eq $bar128Cb);
        $idx=index($code128b,$char);
    } elsif(lc($code) eq 'c') {
        return if($char eq $bar128Cc);
        if($char=~/^\d+$/) {
            $idx=substr($char,0,1)*10+substr($char,1,1)*1;
        } else {
            $idx=index($code128c,$char);
        }
    }
    return($bar128[$idx],$idx);
}

sub encode_128_char {
    my ($code,$char)=@_;
    my ($b)=encode_128_char_idx($code,$char);
    return($b);
}

sub encode_128_string {
    my ($code,$str)=@_;
    my ($bar,@chk,$c,$desc,$b,$i,@bars);
    my @chars=split(//,$str);
    while(defined($c=shift @chars)) {
        if($c=~/[\xf1-\xf4]/) {
            ($b,$i)=encode_128_char_idx($code,$c);
        } elsif($c=~/[\xca-\xcc]/) {
            ($b,$i)=encode_128_char_idx($code,$c);
            if($c eq "\xca") {
                $code='a';
            } elsif($c eq "\xcb") {
                $code='b';
            } elsif($c eq "\xcc") {
                $code='c';
            }
        } else {
            if($code ne 'c') {
                if($c eq $bar128sh) {
                    ($b,$i)=encode_128_char_idx($code,$c);
                    push(@bars,$b);
                    push(@chk,$i);
                    $c=shift(@chars);
                    ($b,$i)=encode_128_char_idx($code eq 'a' ? 'b':'a',$c);
                } else {
                    ($b,$i)=encode_128_char_idx($code,$c);
                }
            } else {
                $c.=shift(@chars) if($c=~/\d/);
                if($c=~/^\d[^\d]*$/) {
                    ($b,$i)=encode_128_char_idx($code,"\xcb");
                    push(@bars,$b);
                    push(@chk,$i);
                    $code='b';
                    unshift(@chars,substr($c,1,1));
                    $c=substr($c,0,1);
                }
                ($b,$i)=encode_128_char_idx($code,$c);
            }
        }
        $c='' if($c=~/[^\x20-\x7e]/);
        push(@bars,[$b,$c]);
        push(@chk,$i);
    }
    return([@bars],@chk);
}

sub encode_128 {
    my ($self,$code,$str)=@_;
    my (@bar,$b,@chk,$c);
    if($code eq 'a') {
        push(@bar,encode_128_char($code,$bar128Sa));
        $c=103;
    } elsif($code eq 'b') {
        push(@bar,encode_128_char($code,$bar128Sb));
        $c=104;
    } elsif($code eq 'c') {
        push(@bar,encode_128_char($code,$bar128Sc));
        $c=105;
    }
    ($b,@chk)=encode_128_string($code,$str);
    # b ... bars
    # chk ... chknums
    push(@bar,@{$b});
    #calc chksum
    foreach my $i (1..scalar @chk) {
        $c+=$i*$chk[$i-1];
    }
    $c%=103;
    push(@bar,$bar128[$c]);
    push(@bar,encode_128_char($code,$bar128St));
    return(@bar);
}

sub encode_ean128 {
    my ($self,$str)=@_;
    $str=~s/[^a-zA-Z\d]+//g;
    $str=~s/(\d+)([a-zA-Z]+)/$1\xcb$2/g;
    $str=~s/([a-zA-Z]+)(\d+)/$1\xcc$2/g;
    return(encode_128('c',"\xf1$str"));
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 1.1  2005/11/16 01:19:27  areibens
    genesis

    Revision 1.10  2005/06/17 19:44:03  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.9  2005/06/17 18:53:34  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.8  2005/03/14 22:01:31  fredo
    upd 2005

    Revision 1.7  2004/12/16 00:30:54  fredo
    added no warn for recursion

    Revision 1.6  2004/06/15 09:14:54  fredo
    removed cr+lf

    Revision 1.5  2004/06/11 12:56:29  fredo
    fixed encode bug

    Revision 1.4  2004/06/07 19:44:44  fredo
    cleaned out cr+lf for lf

    Revision 1.3  2003/12/08 13:06:09  Administrator
    corrected to proper licencing statement

    Revision 1.2  2003/11/30 18:55:09  Administrator
    added EAN128

    Revision 1.1  2003/11/30 18:53:26  Administrator
    inital import


=cut
