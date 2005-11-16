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
package PDF::API2::Resource::XObject::Form::BarCode;

BEGIN {

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Resource::XObject::Form::Hybrid;

    use POSIX;

    use vars qw(@ISA $VERSION);

    @ISA = qw( PDF::API2::Resource::XObject::Form::Hybrid );

    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$

}
no warnings qw[ deprecated recursion uninitialized ];

=item $res = PDF::API2::Resource::XObject::Form::BarCode->new $pdf, %opts

Returns a barcode-form object.

=cut

sub new {
    my ($class,$pdf,%opts) = @_;
    my $self;

    $class = ref $class if ref $class;

    $self=$class->SUPER::new($pdf);

    $self->{' bfont'}=$opts{-font};

    $self->{' umzn'}=$opts{-umzn};      # (u)pper (m)ending (z)o(n)e
    $self->{' lmzn'}=$opts{-lmzn};      # (l)ower (m)ending (z)o(n)e
    $self->{' zone'}=$opts{-zone};
    $self->{' quzn'}=$opts{-quzn};      # (qu)iet (z)o(n)e
    $self->{' ofwt'}=$opts{-ofwt}||0.01;        # (o)ver(f)low (w)id(t)h
    $self->{' fnsz'}=$opts{-fnsz};      # (f)o(n)t(s)i(z)e
    $self->{' spcr'}=$opts{-spcr}||'';

    return($self);
}

=item $res = PDF::API2::Resource::XObject::Form::BarCode->new_api $api, %opts

Returns a barcode-form object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $obj->{' api'}=$api;

    return($obj);
}

sub outobjdeep {
    my ($self, @opts) = @_;
    $self->SUPER::outobjdeep(@opts);
}

my %bar_wdt=(
     0 => 0,
     1 => 1,
     2 => 2,
     3 => 3,
     4 => 4,
     5 => 5,
     6 => 6,
     7 => 7,
     8 => 8,
     9 => 9,
    'a' => 1,
    'b' => 2,
    'c' => 3,
    'd' => 4,
    'e' => 5,
    'f' => 6,
    'g' => 7,
    'h' => 8,
    'i' => 9,
    'A' => 1,
    'B' => 2,
    'C' => 3,
    'D' => 4,
    'E' => 5,
    'F' => 6,
    'G' => 7,
    'H' => 8,
    'I' => 9,
);

sub encode {
        my $self=shift @_;
        my $string=shift @_;
        my @bar;

        my @c=split(//,$string);

        @bar = map { [ $self->encode_string($_), $_ ] } @c;

        return(@bar);
}

sub encode_string {
        my $self=shift @_;
        my $string=shift @_;
        my $bar;
        my @c=split(//,$string);

        foreach my $char (@c) {
                $bar.=$self->encode_char($char);
        }
        return($bar);
}

sub drawbar {
    my $self=shift @_;
    my @bar=@{shift @_};
    my $bartext=shift @_;
    my $ext=shift @_;

    my $x=$self->{' quzn'};
    my ($code,$str,$f,$t,$l,$h,$xo);
    $self->fillcolor('black');
    $self->strokecolor('black');

    my $bw=1;
    foreach my $b (@bar) {
        if(ref($b)) {
            ($code,$str)=@{$b};
        } else {
            $code=$b;
            $str=undef;
        }
        $xo=0;
        foreach my $c (split(//,$code)) {
            my $w=$bar_wdt{$c};
            $xo+=$w/2;
            if($c=~/[0-9]/) {
                $l=$self->{' quzn'} + $self->{' lmzn'};
                $h=$self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'};
                $t=$self->{' quzn'};
                $f=$self->{' fnsz'}||$self->{' lmzn'};
            } elsif($c=~/[a-z]/) {
                $l=$self->{' quzn'};
                $h=$self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'};
                $t=$self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'};
                $f=$self->{' fnsz'}||$self->{' umzn'};
            } elsif($c=~/[A-Z]/) {
                $l=$self->{' quzn'};
                $h=$self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'};
                $f=$self->{' fnsz'}||$self->{' umzn'};
                $t=$self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'} - $f;
            } else {
                $l=$self->{' quzn'} + $self->{' lmzn'};
                $h=$self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'};
                $t=$self->{' quzn'};
                $f=$self->{' fnsz'}||$self->{' lmzn'};
            }
            if($bw) {
                if($c ne '0') {
                    $self->linewidth($w-$self->{' ofwt'});
                    $self->move($x+$xo,$l);
                    $self->line($x+$xo,$h);
                    $self->stroke;
                }
                $bw=0;
            } else {
                $bw=1;
            }
            $xo+=$w/2;
        }
        if(defined($str) && ($self->{' lmzn'}>0)) {
            $str=join($self->{' spcr'},split(//,$str));
            $self->textstart;
            $self->translate($x+($xo/2),$t);
            $self->font($self->{' bfont'},$f);
            $self->text_center($str);
            $self->textend;
        }
        $x+=$xo;
    }
    if(defined $bartext) {
        $f=$self->{' fnsz'}||$self->{' lmzn'};
        $t=$self->{' quzn'}-$f;
        $self->textstart;
        $self->translate(($self->{' quzn'}+$x)/2,$t);
        $self->font($self->{' bfont'},$f);
        $self->text_center($bartext);
        $self->textend;
    }
    $self->{' w'}=$self->{' quzn'}+$x;
    $self->{' h'}=2*$self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'};
    $self->{BBox}=PDFArray(PDFNum(0),PDFNum(0),PDFNum($self->{' w'}),PDFNum($self->{' h'}));
}

=item $wd = $bc->width

=cut

sub width {
    my $self = shift @_;
    return($self->{' w'});
}

=item $ht = $bc->height

=cut

sub height {
    my $self = shift @_;
    return($self->{' h'});
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 1.2  2005/11/16 01:27:50  areibens
    genesis2

    Revision 1.1  2005/11/16 01:19:27  areibens
    genesis

    Revision 1.10  2005/06/17 19:44:03  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.9  2005/06/17 18:53:34  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.8  2005/03/14 22:01:30  fredo
    upd 2005

    Revision 1.7  2004/12/16 00:30:54  fredo
    added no warn for recursion

    Revision 1.6  2004/06/15 09:14:54  fredo
    removed cr+lf

    Revision 1.5  2004/06/07 19:44:44  fredo
    cleaned out cr+lf for lf

    Revision 1.4  2003/12/08 13:06:09  Administrator
    corrected to proper licencing statement

    Revision 1.3  2003/11/30 17:34:51  Administrator
    merged into default

    Revision 1.2.2.1  2003/11/30 16:57:09  Administrator
    merged into default

    Revision 1.2  2003/11/30 11:50:45  Administrator
    added CVS id/log


=cut
