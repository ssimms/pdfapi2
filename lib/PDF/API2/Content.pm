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

package PDF::API2::Content;

BEGIN {

    use strict;
    use vars qw(@ISA $VERSION);
    use PDF::API2::Basic::PDF::Dict;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Util;
    use PDF::API2::Matrix;
    use Math::Trig;
    use Encode;
    use Compress::Zlib;

    @ISA = qw(PDF::API2::Basic::PDF::Dict);
    
    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$

}

no warnings qw[ deprecated recursion uninitialized ];

=head1 $co = PDF::API2::Content->new @parameters

Returns a new content object (called from $page->text/gfx).

=cut

sub new {
    my ($class)=@_;
    my $self = $class->SUPER::new(@_);
    $self->{' stream'}='';
    $self->{' poststream'}='';
    $self->{' font'}=undef;
    $self->{' fontset'}=0;
    $self->{' fontsize'}=0;
    $self->{' charspace'}=0;
    $self->{' hspace'}=100;
    $self->{' wordspace'}=0;
    $self->{' lead'}=0;
    $self->{' rise'}=0;
    $self->{' render'}=0;
    $self->{' matrix'}=[1,0,0,1,0,0];
    $self->{' textmatrix'}=[1,0,0,1,0,0];
    $self->{' textlinematrix'}=[0,0];
    $self->{' fillcolor'}=[0];
    $self->{' strokecolor'}=[0];
    $self->{' translate'}=[0,0];
    $self->{' scale'}=[1,1];
    $self->{' skew'}=[0,0];
    $self->{' rotate'}=0;
    $self->{' apiistext'}=0;
#    $self->save;
    return($self);
}

sub outobjdeep {
    my $self = shift @_;
    $self->textend;
    foreach my $k (qw[ api apipdf apiistext apipage font fontset fontsize 
        charspace hspace wordspace lead rise render matrix textmatrix textlinematrix 
        fillcolor strokecolor translate scale skew rotate ]) 
    {
        $self->{" $k"}=undef;
        delete($self->{" $k"});
    }
    if($self->{-docompress}==1 && $self->{Filter})
    {
        $self->{' stream'}=Compress::Zlib::compress($self->{' stream'});
        $self->{' nofilt'}=1;
        delete $self->{-docompress};
    }
    $self->SUPER::outobjdeep(@_);
}

=item $co->add @content

Adds @content to the object.

=cut

sub add_post 
{
    my $self=shift @_;
    if(scalar @_>0) 
    {
        $self->{' poststream'}.=($self->{' poststream'}=~m|\s$|o?'':' ').join(' ',@_).' ';
    }
    $self;
}
sub add 
{
    my $self=shift @_;
    if(scalar @_>0) 
    {
        $self->{' stream'}.=encode("iso-8859-1",($self->{' stream'}=~m|\s$|o?'':' ').join(' ',@_).' ');
    }
    $self;
}

=item $co->save

Saves the state of the object.

=cut

sub _save 
{
    return('q');
}

sub save 
{
    my $self=shift @_;
    unless(defined($self->{' apiistext'}) && $self->{' apiistext'} == 1) 
    {
        $self->add(_save());
    }
}

=item $co->restore

Restores the state of the object.

=cut

sub _restore 
{
    return('Q');
}

sub restore 
{
    my $self=shift @_;
    unless(defined($self->{' apiistext'}) && $self->{' apiistext'} == 1) {
        $self->add(_restore());
    }
}

=item $co->compress

Marks content for compression on output.

=cut

sub compress 
{
    my $self=shift @_;
    $self->{'Filter'}=PDFArray(PDFName('FlateDecode'));
    $self->{-docompress}=1;
    return($self);
}

sub metaStart
{
    my $self=shift @_;
    my $tag=shift @_;
    my $obj=shift @_;
    $self->add("/$tag");
    if(defined $obj)
    {
        my $dict=PDFDict();
        $dict->{Metadata}=$obj;
        $self->resource('Properties',$obj->name,$dict);        
        $self->add('/'.($obj->name));
        $self->add('BDC');
    }
    else
    {
        $self->add('BMC');
    }
    return($self);
}

sub metaEnd
{
    my $self=shift @_;
    $self->add('EMC');
    return($self);
}

=item $co->flatness $flat

Sets flatness.

=cut

sub _flatness 
{
    my ($flatness)=@_;
    return($flatness,'i');
}
sub flatness 
{
    my ($self,$flatness)=@_;
    $self->add(_flatness($flatness));
}

=item $co->linecap $cap

Sets linecap.

=cut

sub _linecap 
{
    my ($linecap)=@_;
    return($linecap,'J');
}
sub linecap 
{
    my ($self,$linecap)=@_;
    $self->add(_linecap($linecap));
}

=item $co->linedash @dash

Sets linedash.

=cut

sub _linedash 
{
    my (@a)=@_;
    if(scalar @a < 1) 
    {
            return('[',']','0','d');
    } 
    else 
    {
        if($a[0]=~/^\-/)
        {
            my %a=@a;
            $a{-pattern}=[$a{-full}||0,$a{-clear}||0] unless(ref $a{-pattern});
            return('[',floats(@{$a{-pattern}}),']',($a{-shift}||0),'d');
        } 
        else 
        {
            return('[',floats(@a),'] 0 d');
        }
    }
}
sub linedash 
{
    my ($self,@a)=@_;
    $self->add(_linedash(@a));
}

=item $co->linejoin $join

Sets linejoin.

=cut

sub _linejoin 
{
    my ($linejoin)=@_;
    return($linejoin,'j');
}
sub linejoin 
{
    my ($this,$linejoin)=@_;
    $this->add(_linejoin($linejoin));
}

=item $co->linewidth $width

Sets linewidth.

=cut

sub _linewidth 
{
    my ($linewidth)=@_;
    return($linewidth,'w');
}
sub linewidth 
{
    my ($this,$linewidth)=@_;
    $this->add(_linewidth($linewidth));
}

=item $co->meterlimit $limit

Sets meterlimit.

=cut

sub _meterlimit 
{
    my ($limit)=@_;
    return($limit,'M');
}
sub meterlimit 
{
    my ($this, $limit)=@_;
    $this->add(_meterlimit($limit));
}

=item $co->matrix $a,$b,$c,$d,$e,$f

Sets matrix transformation.

=cut

sub _matrix_text 
{
    my ($a,$b,$c,$d,$e,$f)=@_;
    return(floats($a,$b,$c,$d,$e,$f),'Tm');
}
sub _matrix_gfx 
{
    my ($a,$b,$c,$d,$e,$f)=@_;
    return(floats($a,$b,$c,$d,$e,$f),'cm');
}
sub matrix 
{
    my $self=shift @_;
    my ($a,$b,$c,$d,$e,$f)=@_;
    if(defined $a) 
    {
        if(defined($self->{' apiistext'}) && $self->{' apiistext'} == 1) 
        {
            $self->add(_matrix_text($a,$b,$c,$d,$e,$f));
            @{$self->{' textmatrix'}}=($a,$b,$c,$d,$e,$f);
            @{$self->{' textlinematrix'}}=(0,0);
        } 
        else 
        {
            $self->add(_matrix_gfx($a,$b,$c,$d,$e,$f));
        }
    }
    if(defined($self->{' apiistext'}) && $self->{' apiistext'} == 1) 
    {
        return(@{$self->{' textmatrix'}});
    } 
    else 
    {
        return($self);
    }
}

=item $co->translate $x,$y

Sets translation transformation.

=cut

sub _translate 
{
    my ($x,$y)=@_;
    return(1,0,0,1,$x,$y);
}
sub translate 
{
  my ($self,$x,$y)=@_;
  $self->transform(-translate=>[$x,$y]);
}

=item $co->scale $sx,$sy

Sets scaleing transformation.

=cut

sub _scale 
{
    my ($x,$y)=@_;
    return($x,0,0,$y,0,0);
}
sub scale 
{
  my ($self,$sx,$sy)=@_;
  $self->transform(-scale=>[$sx,$sy]);
}

=item $co->skew $sa,$sb

Sets skew transformation.

=cut

sub _skew 
{
    my ($a,$b)=@_;
    return(1, tan(deg2rad($a)),tan(deg2rad($b)),1,0,0);
}
sub skew 
{
  my ($self,$a,$b)=@_;
  $self->transform(-skew=>[$a,$b]);
}

=item $co->rotate $rot

Sets rotation transformation.

=cut

sub _rotate 
{
    my ($a)=@_;
    return(cos(deg2rad($a)), sin(deg2rad($a)),-sin(deg2rad($a)), cos(deg2rad($a)),0,0);
}
sub rotate 
{
  my ($self,$a)=@_;
  $self->transform(-rotate=>$a);
}

=item $co->transform %opts

Sets transformations (eg. translate, rotate, scale, skew) in pdf-canonical order.

B<Example:>

    $co->transform(
        -translate => [$x,$y],
        -rotate    => $rot,
        -scale     => [$sx,$sy],
        -skew      => [$sa,$sb],
    )

=cut

sub _transform 
{
    my (%opt)=@_;
    my $mtx=PDF::API2::Matrix->new([1,0,0],[0,1,0],[0,0,1]);
    foreach my $o (qw( -matrix -skew -scale -rotate -translate )) {
        next unless(defined($opt{$o}));
        if($o eq '-translate') {
            my @mx=_translate(@{$opt{$o}});
            $mtx=$mtx->multiply(PDF::API2::Matrix->new(
                [$mx[0],$mx[1],0],
                [$mx[2],$mx[3],0],
                [$mx[4],$mx[5],1]
            ));
        } elsif($o eq '-rotate') {
            my @mx=_rotate($opt{$o});
            $mtx=$mtx->multiply(PDF::API2::Matrix->new(
                [$mx[0],$mx[1],0],
                [$mx[2],$mx[3],0],
                [$mx[4],$mx[5],1]
            ));
        } elsif($o eq '-scale') {
            my @mx=_scale(@{$opt{$o}});
            $mtx=$mtx->multiply(PDF::API2::Matrix->new(
                [$mx[0],$mx[1],0],
                [$mx[2],$mx[3],0],
                [$mx[4],$mx[5],1]
            ));
        } elsif($o eq '-skew') {
            my @mx=_skew(@{$opt{$o}});
            $mtx=$mtx->multiply(PDF::API2::Matrix->new(
                [$mx[0],$mx[1],0],
                [$mx[2],$mx[3],0],
                [$mx[4],$mx[5],1]
            ));
        } elsif($o eq '-matrix') {
            my @mx=@{$opt{$o}};
            $mtx=$mtx->multiply(PDF::API2::Matrix->new(
                [$mx[0],$mx[1],0],
                [$mx[2],$mx[3],0],
                [$mx[4],$mx[5],1]
            ));
        }
    }
    if($opt{-point})
    {
        my $mp=PDF::API2::Matrix->new([$opt{-point}->[0],$opt{-point}->[1],1]);
        $mp=$mp->multiply($mtx);
        return($mp->[0][0],$mp->[0][1]);
    }
    return(
        $mtx->[0][0],$mtx->[0][1],
        $mtx->[1][0],$mtx->[1][1],
        $mtx->[2][0],$mtx->[2][1]
    );
}
sub transform {
    my ($self,%opt)=@_;
    $self->matrix(_transform(%opt));
    if($opt{-translate}) {
        @{$self->{' translate'}}=@{$opt{-translate}};
    } else {
        @{$self->{' translate'}}=(0,0);
    }
    if($opt{-rotate}) {
        $self->{' rotate'}=$opt{-rotate};
    } else {
        $self->{' rotate'}=0;
    }
    if($opt{-scale}) {
        @{$self->{' scale'}}=@{$opt{-scale}};
    } else {
        @{$self->{' scale'}}=(1,1);
    }
    if($opt{-skew}) {
        @{$self->{' skew'}}=@{$opt{-skew}};
    } else {
        @{$self->{' skew'}}=(0,0);
    }
    return($self);
}

=item $co->fillcolor @colors

=item $co->strokecolor @colors

Sets fill-/strokecolor, see PDF::API2::Util for a list of possible color specifiers.

B<Examples:>

    $co->fillcolor('blue');       # blue
    $co->strokecolor('#FF0000');  # red
    $co->fillcolor('%FFF000000'); # cyan

=cut

# default colorspaces: rgb/hsv/named cmyk/hsl lab
#   ... only one text string
#
# pattern or shading space
#   ... only one object
#
# legacy greylevel
#   ... only one value
#
# 

sub _makecolor {
    my ($self,$sf,@clr)=@_;
    if($clr[0]=~/^[a-z\#\!]+/) {
        # colorname or #! specifier
        # with rgb target colorspace
        # namecolor returns always a RGB
        return(namecolor($clr[0]),($sf?'rg':'RG'));
    } elsif($clr[0]=~/^[\%]+/) {
        # % specifier
        # with cmyk target colorspace
        return(namecolor_cmyk($clr[0]),($sf?'k':'K'));
    } elsif($clr[0]=~/^[\$\&]/) {
        # &$ specifier
        # with L*a*b target colorspace
        if(!defined $self->resource('ColorSpace','LabS')) {
            my $dc=PDFDict();
            my $cs=PDFArray(PDFName('Lab'),$dc);
        #    $dc->{WhitePoint}=PDFArray(map { PDFNum($_) } qw(0.9505 1.0000 1.0890));
            $dc->{WhitePoint}=PDFArray(map { PDFNum($_) } qw(1 1 1));
            $dc->{Range}=PDFArray(map { PDFNum($_) } qw(-128 127 -128 127));
            $dc->{Gamma}=PDFArray(map { PDFNum($_) } qw(2.2 2.2 2.2));
            $self->resource('ColorSpace','LabS',$cs);
        }
        return('/LabS',($sf?'cs':'CS'),namecolor_lab($clr[0]),($sf?'sc':'SC'));
    } elsif((scalar @clr == 1) && ref($clr[0])) {
        # pattern or shading space
        return('/Pattern',($sf?'cs':'CS'),'/'.($clr[0]->name),($sf?'scn':'SCN'));
    } elsif(scalar @clr == 1) {
        # grey color spec.
        while($clr[0]>1) { $clr[0]/=255; }
        # adjusted for 8/16/32bit spec.
        return($clr[0],($sf?'g':'G'));
    } elsif(scalar @clr > 1 && ref($clr[0])) {
        # indexed colorspace plus color-index
        # or custom colorspace plus param
        my $cs=shift @clr;
        return('/'.($cs->name),($sf?'cs':'CS'),$cs->param(@clr),($sf?'sc':'SC'));
    } elsif(scalar @clr == 2) {
        # indexed colorspace plus color-index
        # or custom colorspace plus param
        return('/'.($clr[0]->name),($sf?'cs':'CS'),$clr[0]->param($clr[1]),($sf?'sc':'SC'));
    } elsif(scalar @clr == 3) {
        # legacy rgb color-spec (0 <= x <= 1)
        #if(!defined $self->resource('ColorSpace','RgbS')) {
        #    my $dc=PDFDict();
        #    my $cs=PDFArray(PDFName('CalRGB'),$dc);
        #    $dc->{WhitePoint}=PDFArray(map { PDFNum($_) } qw(0.9505 1.0000 1.0890));
        #    $dc->{Gamma}=PDFArray(map { PDFNum($_) } qw(2.2 2.2 2.2));
        #    $self->resource('ColorSpace','RgbS',$cs);
        #}
        #return('/RgbS',($sf?'cs':'CS'),floats5(@clr),($sf?'sc':'SC'));
        return(floats($clr[0],$clr[1],$clr[2]),($sf?'rg':'RG'));
    } elsif(scalar @clr == 4) {
        # legacy cmyk color-spec (0 <= x <= 1)
        return(floats($clr[0],$clr[1],$clr[2],$clr[3]),($sf?'k':'K'));
    } else {
        die 'invalid color specification.';
    }
}

sub _fillcolor 
{
    my ($self,@clrs)=@_;
    if(ref($clrs[0]) =~ m|^PDF::API2::Resource::ColorSpace|) 
    {
        $self->resource('ColorSpace',$clrs[0]->name,$clrs[0]);
    } 
    elsif(ref($clrs[0]) =~ m|^PDF::API2::Resource::Pattern|) 
    {
        $self->resource('Pattern',$clrs[0]->name,$clrs[0]);
    }
    return($self->_makecolor(1,@clrs));
}
sub fillcolor 
{
    my $self=shift @_;
    if(scalar @_) 
    {
        @{$self->{' fillcolor'}}=@_;
        $self->add($self->_fillcolor(@_));
    }
    return(@{$self->{' fillcolor'}});
}

sub _strokecolor 
{
    my ($self,@clrs)=@_;
    if(ref($clrs[0]) =~ m|^PDF::API2::Resource::ColorSpace|) 
    {
        $self->resource('ColorSpace',$clrs[0]->name,$clrs[0]);
    } 
    elsif(ref($clrs[0]) =~ m|^PDF::API2::Resource::Pattern|) 
    {
        $self->resource('Pattern',$clrs[0]->name,$clrs[0]);
    }
    return($self->_makecolor(0,@clrs));
}
sub strokecolor 
{
    my $self=shift @_;
    if(scalar @_) 
    {
        @{$self->{' strokecolor'}}=@_;
        $self->add($self->_strokecolor(@_));
    }
    return(@{$self->{' strokecolor'}});
}

=head1 GRAPHICS METHODS

=over 4

=item $gfx->move $x, $y

=cut

sub _move
{
    my($x,$y)=@_;
    return(floats($x,$y),'m');
}
sub move 
{ # x,y ...
    my $self=shift @_;
    my($x,$y);
    while(defined($x=shift @_)) 
    {
        $y=shift @_;
        $self->{' x'}=$x;
        $self->{' y'}=$y;
        $self->{' mx'}=$x;
        $self->{' my'}=$y;
        if(defined($self->{' apiistext'}) && $self->{' apiistext'} == 1) 
        {
            $self->add_post(floats($x,$y),'m');
        } 
        else 
        {
            $self->add(floats($x,$y),'m');
        }
    }
    return($self);
}

=item $gfx->line $x, $y

=cut

sub _line
{
    my($x,$y)=@_;
    return(floats($x,$y),'l');
}
sub line 
{ # x,y ...
    my $self=shift @_;
    my($x,$y);
    while(defined($x=shift @_)) 
    {
        $y=shift @_;
        $self->{' x'}=$x;
        $self->{' y'}=$y;
        if(defined($self->{' apiistext'}) && $self->{' apiistext'} == 1) 
        {
            $self->add_post(floats($x,$y),'l');
        } 
        else 
        {
            $self->add(floats($x,$y),'l');
        }
    }
    return($self);
}

=item $gfx->hline $x

=cut

sub hline 
{
    my($self,$x)=@_;
    if(defined($self->{' apiistext'}) && $self->{' apiistext'} == 1) 
    {
        $self->add_post(floats($x,$self->{' y'}),'l');
    } 
    else 
    {
        $self->add(floats($x,$self->{' y'}),'l');
    }
    $self->{' x'}=$x;
    return($self);
}

=item $gfx->vline $y

=cut

sub vline 
{
    my($self,$y)=@_;
    if(defined($self->{' apiistext'}) && $self->{' apiistext'} == 1) 
    {
        $self->add_post(floats($self->{' x'},$y),'l');
    } 
    else 
    {
        $self->add(floats($self->{' x'},$y),'l');
    }
    $self->{' y'}=$y;
    return($self);
}

=item $gfx->curve $cx1, $cy1, $cx2, $cy2, $x, $y

=cut

sub curve 
{ # x1,y1,x2,y2,x3,y3 ...
    my $self=shift @_;
    my($x1,$y1,$x2,$y2,$x3,$y3);
    while(defined($x1=shift @_)) 
    {
        $y1=shift @_;
        $x2=shift @_;
        $y2=shift @_;
        $x3=shift @_;
        $y3=shift @_;
        if(defined($self->{' apiistext'}) && $self->{' apiistext'} == 1) 
        {
            $self->add_post(floats($x1,$y1,$x2,$y2,$x3,$y3),'c');
        } 
        else 
        {
            $self->add(floats($x1,$y1,$x2,$y2,$x3,$y3),'c');
        }
        $self->{' x'}=$x3;
        $self->{' y'}=$y3;
    }
    return($self);
}

=item $gfx->spline $cx1, $cy1, $x, $y

=cut

sub spline
{
    my $self=shift @_;
    
    while(scalar @_ >= 4)
    {
        my $cx=shift @_;
        my $cy=shift @_;
        my $x=shift @_;
        my $y=shift @_;
        my $c1x=(2*$cx+$self->{' x'})/3;
        my $c1y=(2*$cy+$self->{' y'})/3;
        my $c2x=(2*$cx+$x)/3;
        my $c2y=(2*$cy+$y)/3;
        $self->curve($c1x,$c1y,$c2x,$c2y,$x,$y);
    }
}

sub arctocurve 
{
    my ($a,$b,$alpha,$beta)=@_;
    if(abs($beta-$alpha) > 30) 
    {
        return (
            arctocurve($a,$b,$alpha,($beta+$alpha)/2),
            arctocurve($a,$b,($beta+$alpha)/2,$beta)
        );
    } 
    else 
    {
        $alpha = ($alpha * pi / 180);
        $beta  = ($beta * pi / 180);

        my $bcp = (4.0/3 * (1 - cos(($beta - $alpha)/2)) / sin(($beta - $alpha)/2));
        my $sin_alpha = sin($alpha);
        my $sin_beta =  sin($beta);
        my $cos_alpha = cos($alpha);
        my $cos_beta =  cos($beta);

        my $p0_x = $a * $cos_alpha;
        my $p0_y = $b * $sin_alpha;
        my $p1_x = $a * ($cos_alpha - $bcp * $sin_alpha);
        my $p1_y = $b * ($sin_alpha + $bcp * $cos_alpha);
        my $p2_x = $a * ($cos_beta + $bcp * $sin_beta);
        my $p2_y = $b * ($sin_beta - $bcp * $cos_beta);
        my $p3_x = $a * $cos_beta;
        my $p3_y = $b * $sin_beta;
        return($p0_x,$p0_y,$p1_x,$p1_y,$p2_x,$p2_y,$p3_x,$p3_y);
    }
}

=item $gfx->arc $x, $y, $a, $b, $alfa, $beta, $move

will draw an arc centered at x,y with minor/major-axis
given by a,b from alfa to beta (degrees). move must be
set to 1, unless you want to continue an existing path.

=cut

sub arc 
{ # x,y,a,b,alf,bet[,mov]
    my ($self,$x,$y,$a,$b,$alpha,$beta,$move)=@_;
    my @points=arctocurve($a,$b,$alpha,$beta);
    my ($p0_x,$p0_y,$p1_x,$p1_y,$p2_x,$p2_y,$p3_x,$p3_y);

    $p0_x= $x + shift @points;
    $p0_y= $y + shift @points;

    $self->move($p0_x,$p0_y) if($move);

    while(scalar @points > 0) 
    {
        $p1_x= $x + shift @points;
        $p1_y= $y + shift @points;
        $p2_x= $x + shift @points;
        $p2_y= $y + shift @points;
        $p3_x= $x + shift @points;
        $p3_y= $y + shift @points;
        $self->curve($p1_x,$p1_y,$p2_x,$p2_y,$p3_x,$p3_y);
        shift @points;
        shift @points;
        $self->{' x'}=$p3_x;
        $self->{' y'}=$p3_y;
    }
    return($self);
}

=item $gfx->ellipse $x, $y, $a, $b

=cut

sub ellipse 
{
    my ($self,$x,$y,$a,$b) = @_;
    $self->arc($x,$y,$a,$b,0,360,1);
    $self->close;
    return($self);
}

=item $gfx->circle $x, $y, $r

=cut

sub circle 
{
    my ($self,$x,$y,$r) = @_;
    $self->arc($x,$y,$r,$r,0,360,1);
    $self->close;
    return($self);
}

=item $gfx->bogen $x1, $y1, $x2, $y2, $r, $move, $larc, $span

will draw an arc of a circle from x1,y1 to x2,y2 with radius r.
move must be set to 1, unless you want to continue an existing path.
larc can be set to 1, if you want to draw the larger instead of the
shorter arc. span can be set to 1, if you want to draw the arc
on the other side. NOTE: 2*r cannot be smaller than the distance
from x1,y1 to x2,y2.

=cut

sub bogen 
{ # x1,y1,x2,y2,r[,move[,large-arc[,span-factor]]]
    my ($self,$x1,$y1,$x2,$y2,$r,$move,$larc,$spf) = @_;
    my ($p0_x,$p0_y,$p1_x,$p1_y,$p2_x,$p2_y,$p3_x,$p3_y);
    my $x=$x2-$x1;
    $x=$x1-$x2 if($spf>0);
    my $y=$y2-$y1;
    $y=$y1-$y2 if($spf>0);
    my $z=sqrt($x**2+$y**2);
    my $alfa_rad=asin($y/$z);

    if($spf>0) 
    {
        $alfa_rad-=pi/2 if($x<0);
        $alfa_rad=-$alfa_rad if($y>0);
    } 
    else 
    {
        $alfa_rad+=pi/2 if($x<0);
        $alfa_rad=-$alfa_rad if($y<0);
    }

    my $alfa=rad2deg($alfa_rad);
    my $d=2*$r;
    my ($beta,$beta_rad,@points);

    $beta=rad2deg(2*asin($z/$d));
    $beta=360-$beta if($larc>0);

    $beta_rad=deg2rad($beta);

    @points=arctocurve($r,$r,90+$alfa+$beta/2,90+$alfa-$beta/2);

    if($spf>0) 
    {
        my @pts=@points;
        @points=();
        while($y=pop @pts){
            $x=pop @pts;
            push(@points,$x,$y);
        }
    }

    $p0_x=shift @points;
    $p0_y=shift @points;
    $x=$x1-$p0_x;
    $y=$y1-$p0_y;

    $self->move($x,$y) if($move);

    while(scalar @points > 0) 
    {
        $p1_x= $x + shift @points;
        $p1_y= $y + shift @points;
        $p2_x= $x + shift @points;
        $p2_y= $y + shift @points;
        $p3_x= $x + shift @points;
        $p3_y= $y + shift @points;
        $self->curve($p1_x,$p1_y,$p2_x,$p2_y,$p3_x,$p3_y);
        shift @points;
        shift @points;
    }
    return($self);
}

=item $gfx->pie $x, $y, $a, $b, $alfa, $beta

=cut

sub pie 
{
    my $self=shift @_;
    my ($x,$y,$a,$b,$alfa,$beta)=@_;
    my ($p0_x,$p0_y)=arctocurve($a,$b,$alfa,$beta);
    $self->move($x,$y);
    $self->line($p0_x+$x,$p0_y+$y);
    $self->arc($x,$y,$a,$b,$alfa,$beta);
    $self->close;
}

=item $gfx->rect $x1,$y1, $w1,$h1, ..., $xn,$yn, $wn,$hn

=cut

sub rect 
{ # x,y,w,h ...
    my $self=shift @_;
    my($x,$y,$w,$h);
    while(defined($x=shift @_)) 
    {
        $y=shift @_;
        $w=shift @_;
        $h=shift @_;
        $self->add(floats($x,$y,$w,$h),'re');
    }
    $self->{' x'}=$x;
    $self->{' y'}=$y;
    return($self);
}

=item $gfx->rectxy $x1,$y1, $x2,$y2

=cut

sub rectxy 
{
    my ($self,$x,$y,$x2,$y2)=@_;
    $self->rect($x,$y,($x2-$x),($y2-$y));
    return($self);
}

=item $gfx->poly $x1,$y1, ..., $xn,$yn

=cut

sub poly 
{
    my $self=shift @_;
    my($x,$y);
    $x=shift @_;
    $y=shift @_;
    $self->move($x,$y);
    $self->line(@_);
    return($self);
}

=item $gfx->close

=cut

sub close 
{
    my $self=shift @_;
    $self->add('h');
    $self->{' x'}=$self->{' mx'};
    $self->{' y'}=$self->{' my'};
    return($self);
}

=item $gfx->endpath

=cut

sub endpath 
{
    my $self=shift @_;
    $self->add('n');
    return($self);
}

=item $gfx->clip $nonzero

=cut

sub clip 
{ # nonzero
    my $self=shift @_;
    $self->add(!(shift @_)?'W':'W*');
    return($self);
}

=item $gfx->stroke

=cut

sub _stroke 
{
    return('S');
}
sub stroke 
{
    my $self=shift @_;
    $self->add(_stroke);
    return($self);
}

=item $gfx->fill $nonzero

=cut

sub fill 
{ # nonzero
    my $self=shift @_;
    $self->add(!(shift @_)?'f':'f*');
    return($self);
}

=item $gfx->fillstroke $nonzero

=cut

sub fillstroke 
{ # nonzero
    my $self=shift @_;
    $self->add(!(shift @_)?'B':'B*');
    return($self);
}

=item $gfx->image $imgobj, $x,$y, $w,$h

=item $gfx->image $imgobj, $x,$y, $scale

=item $gfx->image $imgobj, $x,$y

B<Please Note:> The width/height or scale given
is in user-space coordinates which is subject to
transformations which may have been specified beforehand.

Per default this has a 72dpi resolution, so if you want an
image to have a 150 or 300dpi resolution, you should specify
a scale of 72/150 (or 72/300) or adjust width/height accordingly.

=cut

sub image 
{
    my $self=shift @_;
    my $img=shift @_;
    my ($x,$y,$w,$h)=@_;
    if(defined $img->{Metadata})
    {
        $self->metaStart('PPAM:PlacedImage',$img->{Metadata});
    }
    $self->save;
    if(!defined $w) 
    {
        $h=$img->height;
        $w=$img->width;
    } 
    elsif(!defined $h) 
    {
        $h=$img->height*$w;
        $w=$img->width*$w;
    }
    $self->matrix($w,0,0,$h,$x,$y);
    $self->add("/".$img->name,'Do');
    $self->restore;
    $self->{' x'}=$x;
    $self->{' y'}=$y;
    $self->resource('XObject',$img->name,$img);
    if(defined $img->{Metadata})
    {
        $self->metaEnd;
    }
    return($self);
}

=item $gfx->formimage $imgobj, $x, $y, $scale

=item $gfx->formimage $imgobj, $x, $y

Places the X-Object (or XO-Form) at x/y with optional scale.

=cut

sub formimage 
{
    my $self=shift @_;
    my $img=shift @_;
    my ($x,$y,$s)=@_;
    $self->save;
    if(!defined $s) 
    {
        $self->matrix(1,0,0,1,$x,$y);
    } 
    else 
    {
        $self->matrix($s,0,0,$s,$x,$y);
    }
    $self->add("/".$img->name,'Do');
    $self->restore;
    $self->resource('XObject',$img->name,$img);
    return($self);
}

=item $gfx->shade $shadeobj, $x1,$y1, $x2,$y2

=cut

sub shade 
{
    my $self=shift @_;
    my $shade=shift @_;
    my @cord=@_;
    my @tm=(
        $cord[2]-$cord[0] , 0,
        0                 , $cord[3]-$cord[1],
        $cord[0]          , $cord[1]
    );
    $self->save;
    $self->matrix(@tm);
    $self->add("/".$shade->name,'sh');

    $self->resource('Shading',$shade->name,$shade);

    $self->restore;
    return($self);
}

=item $gfx->egstate $egsobj

=cut

sub egstate 
{
    my $self=shift @_;
    my $egs=shift @_;
    $self->add("/".$egs->name,'gs');
    $self->resource('ExtGState',$egs->name,$egs);
    return($self);
}

=item $hyb->textstart

=cut

sub textstart 
{
    my ($self)=@_;
    if(!defined($self->{' apiistext'}) || $self->{' apiistext'} != 1) 
    {
        $self->add(' BT ');
        $self->{' apiistext'}=1;
        $self->{' font'}=undef;
        $self->{' fontset'}=0;
        $self->{' fontsize'}=0;
        $self->{' charspace'}=0;
        $self->{' hspace'}=100;
        $self->{' wordspace'}=0;
        $self->{' lead'}=0;
        $self->{' rise'}=0;
        $self->{' render'}=0;
        @{$self->{' matrix'}}=(1,0,0,1,0,0);
        @{$self->{' textmatrix'}}=(1,0,0,1,0,0);
        @{$self->{' textlinematrix'}}=(0,0);
        @{$self->{' fillcolor'}}=(0);
        @{$self->{' strokecolor'}}=(0);
        @{$self->{' translate'}}=(0,0);
        @{$self->{' scale'}}=(1,1);
        @{$self->{' skew'}}=(0,0);
        $self->{' rotate'}=0;
    }
    return($self);
}

=item %state = $txt->textstate %state

Sets or gets the current text-object state.

=cut

sub textstate 
{
    my $self=shift @_;
    my %state;
    if(scalar @_) 
    {
        %state=@_;
        foreach my $k (qw( charspace hspace wordspace lead rise render )) 
        {
            next unless($state{$k});
            eval ' $self->'.$k.'($state{$k}); ';
        }
        if($state{font} && $state{fontsize}) 
        {
            $self->font($state{font},$state{fontsize});
        }
        if($state{textmatrix}) 
        {
            $self->matrix(@{$state{textmatrix}});
            @{$self->{' translate'}}=@{$state{translate}};
            $self->{' rotate'}=$state{rotate};
            @{$self->{' scale'}}=@{$state{scale}};
            @{$self->{' skew'}}=@{$state{skew}};
        }
        if($state{fillcolor}) 
        {
            $self->fillcolor(@{$state{fillcolor}});
        }
        if($state{strokecolor}) 
        {
            $self->strokecolor(@{$state{strokecolor}});
        }
        %state=();
    } 
    else 
    {
        foreach my $k (qw( font fontsize charspace hspace wordspace lead rise render )) 
        {
            $state{$k}=$self->{" $k"};
        }
        $state{matrix}=[@{$self->{" matrix"}}];
        $state{textmatrix}=[@{$self->{" textmatrix"}}];
        $state{textlinematrix}=[@{$self->{" textlinematrix"}}];
        $state{rotate}=$self->{" rotate"};
        $state{scale}=[@{$self->{" scale"}}];
        $state{skew}=[@{$self->{" skew"}}];
        $state{translate}=[@{$self->{" translate"}}];
        $state{fillcolor}=[@{$self->{" fillcolor"}}];
        $state{strokecolor}=[@{$self->{" strokecolor"}}];
    }
    return(%state);
}

sub textstate2 
{
    my $self=shift @_;
    my %state;
    if(scalar @_) 
    {
        %state=@_;
        foreach my $k (qw[ charspace hspace wordspace lead rise render ]) 
        {
            next unless($state{$k});
            if($self->{" $k"} ne $state{$k})
            {
                eval ' $self->'.$k.'($state{$k}); ';
            }
        }
        if($state{font} && $state{fontsize}) 
        {
            if($self->{" font"} ne $state{font} || $self->{" fontsize"} ne $state{fontsize})
            {
                $self->font($state{font},$state{fontsize});
            }
        }
        if($state{fillcolor}) 
        {
            $self->fillcolor(@{$state{fillcolor}});
        }
        if($state{strokecolor}) 
        {
            $self->strokecolor(@{$state{strokecolor}});
        }
        %state=();
    } 
    else 
    {
        foreach my $k (qw[ font fontsize charspace hspace wordspace lead rise render ]) 
        {
            $state{$k}=$self->{" $k"};
        }
        $state{fillcolor}=[@{$self->{" fillcolor"}}];
        $state{strokecolor}=[@{$self->{" strokecolor"}}];
    }
    return(%state);
}

=item ($tx,$ty) = $txt->textpos

Gets the current estimated text position.

B<Note:> This is relative to text-space.

=cut

sub _textpos 
{
    my ($self,@xy)=@_;
    my ($x,$y)=(0,0);
    while(scalar @xy > 0)
    {
        $x+=shift @xy;
        $y+=shift @xy;
    }
    my (@m)=_transform(
        -matrix=>$self->{" textmatrix"},
        -point=>[$x,$y]
    );
    return($m[0],$m[1]);
}
sub textpos 
{
    my $self=shift @_;
    return($self->_textpos(@{$self->{" textlinematrix"}}));
}
sub textpos2 
{
    my $self=shift @_;
    return(@{$self->{" textlinematrix"}});
}

=item $txt->transform_rel %opts

Sets transformations (eg. translate, rotate, scale, skew) in pdf-canonical order,
but relative to the previously set values.

B<Example:>

  $txt->transform_rel(
    -translate => [$x,$y],
    -rotate    => $rot,
    -scale     => [$sx,$sy],
    -skew      => [$sa,$sb],
  )

=cut

sub transform_rel {
  my ($self,%opt)=@_;
  my ($sa1,$sb1)=@{$opt{-skew} ? $opt{-skew} : [0,0]};
  my ($sa0,$sb0)=@{$self->{" skew"}};


  my ($sx1,$sy1)=@{$opt{-scale} ? $opt{-scale} : [1,1]};
  my ($sx0,$sy0)=@{$self->{" scale"}};

  my $rot1=$opt{"-rotate"} || 0;
  my $rot0=$self->{" rotate"};

  my ($tx1,$ty1)=@{$opt{-translate} ? $opt{-translate} : [0,0]};
  my ($tx0,$ty0)=@{$self->{" translate"}};

  $self->transform(
    -skew=>[$sa0+$sa1,$sb0+$sb1],
    -scale=>[$sx0*$sx1,$sy0*$sy1],
    -rotate=>$rot0+$rot1,
    -translate=>[$tx0+$tx1,$ty0+$ty1],
  );
  return($self);
}

sub matrix_update {
  use PDF::API2::Matrix;
  my ($self,$tx,$ty)=@_;
  $self->{' textlinematrix'}->[0]+=$tx;
  $self->{' textlinematrix'}->[1]+=$ty;
  return($self);
}

=item $txt->font $fontobj,$size

=item $txt->fontset $fontobj,$size

I<The fontset method WILL NOT APPLY the font+size to the pdf-stream, but
which will later be done by the text-methods.>

B<Only use fontset if you know what you are doing, there is no super-secret failsave!>

=cut

sub _font
{
    my ($font,$size)=@_;
    if($font->isvirtual)
    {
        return('/'.$font->fontlist->[0]->name.' '.float($size).' Tf');
    }
    else
    {
        return('/'.$font->name.' '.float($size).' Tf');
    }
}
sub font 
{
    my ($self,$font,$size)=@_;
    $self->fontset($font,$size);
    $self->add(_font($font,$size));
    $self->{' fontset'}=1;
    return($self);
}

sub fontset {
  my ($self,$font,$size)=@_;
  $self->{' font'}=$font;
  $self->{' fontsize'}=$size;
  $self->{' fontset'}=0;

  if($font->isvirtual)
  {
    foreach my $f (@{$font->fontlist})
    {
        $self->resource('Font',$f->name,$f);
    }
  }
  else
  {
    $self->resource('Font',$font->name,$font);
  }

  return($self);
}

=item $spacing = $txt->charspace $spacing

=cut

sub _charspace 
{
  my ($para)=@_;
  return(float($para,6).' Tc');
}
sub charspace 
{
  my ($self,$para)=@_;
  if(defined $para) 
  {
    $self->{' charspace'}=$para;
    $self->add(_charspace($para));
  }
  return $self->{' charspace'};
}

=item $spacing = $txt->wordspace $spacing

=cut

sub _wordspace 
{
  my ($para)=@_;
  return(float($para,6).' Tw');
}
sub wordspace {
  my ($self,$para)=@_;
  if(defined $para) 
  {
    $self->{' wordspace'}=$para;
    $self->add(_wordspace($para));
  }
  return $self->{' wordspace'};
}

=item $spacing = $txt->hspace $spacing

=cut

sub _hspace 
{
  my ($para)=@_;
  return(float($para,6).' Tz');
}
sub hspace 
{
  my ($self,$para)=@_;
  if(defined $para) 
  {
    $self->{' hspace'}=$para;
    $self->add(_hspace($para));
  }
  return $self->{' hspace'};
}

=item $leading = $txt->lead $leading

=cut

sub _lead 
{
  my ($para)=@_;
  return(float($para).' TL');
}
sub lead 
{
    my ($self,$para)=@_;
    if (defined ($para)) 
    {
        $self->{' lead'} = $para;
        $self->add(_lead($para));
    }
    return $self->{' lead'};
}

=item $rise = $txt->rise $rise

=cut

sub _rise 
{
  my ($para)=@_;
  return(float($para).' Ts');
}
sub rise 
{
    my ($self,$para)=@_;
    if (defined ($para)) 
    {
        $self->{' rise'} = $para;
        $self->add(_rise($para));
    }
    return $self->{' rise'};
}

=item $rendering = $txt->render $rendering

=cut

sub _render 
{
  my ($para)=@_;
  return(intg($para).' Tr');
}
sub render 
{
    my ($self,$para)=@_;
    if (defined ($para)) 
    {
        $self->{' render'} = $para;
        $self->add(_render($para));
    }
    return $self->{' render'};
}

=item $txt->cr $linesize

takes an optional argument giving a custom leading between lines.

=cut

sub cr 
{
    my ($self,$para)=@_;
    if(defined($para)) 
    {
        $self->add(0,float($para),'Td');
        $self->matrix_update(0,$para);
    } 
    else 
    {
        $self->add('T*');
        $self->matrix_update(0,$self->lead);
    }
    $self->{' textlinematrix'}->[0]=0;
}

=item $txt->nl

=cut

sub nl 
{
    my ($self,$width)=@_;
    $self->add('T*');
    $self->matrix_update(-($width||0),-$self->lead);
    $self->{' textlinematrix'}->[0]=0;
}

=item $txt->distance $dx,$dy

=cut

sub distance 
{
    my ($self,$dx,$dy)=@_;
    $self->add(float($dx),float($dy),'Td');
    $self->matrix_update($dx,$dy);
    $self->{' textlinematrix'}->[0]=$dx;
}

=item $width = $txt->advancewidth $string [, %textstate]

Returns the width of the string based on all currently set text-attributes
or on those overridden by %textstate.

=cut

sub advancewidth 
{
    my ($self,$text,@opts)=@_;
    if(scalar @opts > 1)
    {
        my %opts=@opts;
        foreach my $k (qw[ font fontsize wordspace charspace hspace])
        {
            $opts{$k}=$self->{" $k"} unless(defined $opts{$k});
        }
        my $glyph_width=$opts{font}->width($text)*$opts{fontsize};
        my @txt=split(/\x20/,$text);
        my $num_space=(scalar @txt)-1;
        my $num_char=length($text);
        my $word_spaces=$opts{wordspace}*$num_space;
        my $char_spaces=$opts{charspace}*$num_char;
        my $advance=($glyph_width+$word_spaces+$char_spaces)*$opts{hspace}/100;
        return $advance;
    }
    else
    {
        my $glyph_width=$self->{' font'}->width($text)*$self->{' fontsize'};
        my @txt=split(/\x20/,$text);
        my $num_space=(scalar @txt)-1;
        my $num_char=length($text);
        my $word_spaces=$self->wordspace*$num_space;
        my $char_spaces=$self->charspace*$num_char;
        my $advance=($glyph_width+$word_spaces+$char_spaces)*$self->hspace/100;
        return $advance;
    }
}

=item $width = $txt->text $text, %options

Applys text to the content and optionally returns the width of the given text.

Options

=ovar 4

=item -indent

Indent the text by the number of points.

=item -underline

If this is a scalar, it is the distance, in points, below the baseline where
the line is drawn. The line thickness is one point. If it is a reference to an
array, each pair is the distance below the baseline and the thickness of the
line (ie., C<-underline=E<gt>[2,1,4,2]> will draw a double underline
with the lower twice as thick as the upper).

If thickness is a reference to an array, the first value is the thickness
and the second value is the color of the line (ie., 
C<-underline=E<gt>[2,[1,'red'],4,[2,'#0000ff']]> will draw a "red" and a 
"blue" line).

You can also use the string C<'auto'> for either or both distance and thickness 
values to auto-magically calculate best values from the font-definition.

=back

=cut

sub _text_underline 
{
    my ($self,$xy1,$xy2,$underline,$color)=@_;
    $color||='black';
    my @underline=();
    if(ref($underline) eq 'ARRAY')
    {
        @underline=@{$underline};
    }
    else
    {
        @underline=($underline,1);
    }
    push @underline,1 if(@underline%2);

    my $underlineposition=(-$self->{' font'}->underlineposition()*$self->{' fontsize'}/1000||1);
    my $underlinethickness=($self->{' font'}->underlinethickness()*$self->{' fontsize'}/1000||1);
    my $pos=1;
    
    while(@underline)
    {
        $self->add_post(_save);

        my $distance=shift @underline;
        my $thickness=shift @underline;
        my $scolor=$color;
        if(ref $thickness)
        {
            ($thickness,$scolor)=@{$thickness};
        }

        if($distance eq 'auto')
        {
            $distance=$pos*$underlineposition;
        }
        if($thickness eq 'auto')
        {
            $thickness=$underlinethickness;
        }

        my ($x1,$y1)=$self->_textpos(@{$xy1},0,-($distance+($thickness/2)));
        my ($x2,$y2)=$self->_textpos(@{$xy2},0,-($distance+($thickness/2)));

        $self->add_post($self->_strokecolor($scolor));
        $self->add_post(_linewidth($thickness));
        $self->add_post(_move($x1,$y1));
        $self->add_post(_line($x2,$y2));
        $self->add_post(_stroke);

        $self->add_post(_restore);
        $pos++;
    }
}

sub text 
{
    my ($self,$text,%opt)=@_;
    my $wd=0;
    if($self->{' fontset'}==0)
    {
        $self->font($self->{' font'},$self->{' fontsize'});
        $self->{' fontset'}=1;
    }
    if(defined $opt{-indent}) 
    {
        $self->add('[',(-$opt{-indent}*(1000/$self->{' fontsize'})*(100/$self->hspace)),']','TJ');
        $wd+=$opt{-indent};
        $self->matrix_update($wd,0);
    }
    my $ulxy1=[$self->textpos2];
    #if($self->{' font'}->isvirtual)
    #{
        $self->add($self->{' font'}->text($text,$self->{' fontsize'}));
    #} 
    #else 
    #{
    #    $self->add($self->{' font'}->text($text),'Tj');
    #}
    $wd=$self->advancewidth($text);
    $self->matrix_update($wd,0);

    my $ulxy2=[$self->textpos2];

    if(defined $opt{-underline}) 
    {
        $self->_text_underline($ulxy1,$ulxy2,$opt{-underline},$opt{-strokecolor});
    }

    return($wd);
}

=item $txt->text_center $text

=cut

sub text_center 
{
  my ($self,$text,@opts)=@_;
  my $width=$self->advancewidth($text);
  return $self->text($text,-indent=>-($width/2),@opts);
}

=item $txt->text_right $text, %options

=cut

sub text_right 
{
  my ($self,$text,@opts)=@_;
  my $width=$self->advancewidth($text);
  return $self->text($text,-indent=>-$width,@opts);
}

=item $width = $txt->text_justified $text, $width, %options

** DEVELOPER METHOD **

=cut

sub text_justified 
{
    my ($self,$text,$width,%opts)=@_;
    my $hs=$self->hspace;
    $self->hspace($hs*($width/$self->advancewidth($text)));
    $self->text($text,%opts);
    $self->hspace($hs);
    return($width);
}

sub _text_fill_line 
{
    my ($self,$text,$width,$over)=@_;
    my @txt=split(/\x20/,$text);
    my @line=();
    local $";
    $"=' ';
    while(@txt)
    {
         push @line,(shift @txt);
         last if($self->advancewidth("@line")>$width);
    }
    if(!$over && (scalar @line > 1) && ($self->advancewidth("@line") > $width)) 
    {
        unshift @txt,pop @line;
    }
    my $ret="@txt";
    my $line="@line";
    return($line,$ret);
}


=item ($width,$chunktext) = $txt->text_fill_left $text, $width

** DEVELOPER METHOD **

=cut

sub text_fill_left 
{
    my ($self,$text,$width,%opts)=@_;
    my ($line,$ret)=$self->_text_fill_line($text,$width,1);
    $width=$self->text($line,%opts);
    return($width,$ret);
}

=item ($width,$chunktext) = $txt->text_fill_center $text, $width, %options

** DEVELOPER METHOD **

=cut

sub text_fill_center 
{
    my ($self,$text,$width,%opts)=@_;
    my ($line,$ret)=$self->_text_fill_line($text,$width,1);
    $width=$self->text_center($line,%opts);
    return($width,$ret);
}

=item ($width,$chunktext) = $txt->text_fill_right $text, $width

** DEVELOPER METHOD **

=cut

sub text_fill_right 
{
    my ($self,$text,$width,%opts)=@_;
    my ($line,$ret)=$self->_text_fill_line($text,$width,1);
    $width=$self->text_right($line,%opts);
    return($width,$ret);
}

=item ($width,$chunktext) = $txt->text_fill_justified $text, $width

** DEVELOPER METHOD **

=cut

sub text_fill_justified 
{
    my ($self,$text,$width,%opts)=@_;
    my ($line,$ret)=$self->_text_fill_line($text,$width,1);
    my $hs=$self->hspace;
    my $w=$self->advancewidth($line);
    if($ret||$w>=$width)
    {
        $self->hspace($hs*($width/$w));
    }
    $width=$self->text($line,%opts);
    $self->hspace($hs);
    return($width,$ret);
}

=item $overflow_text = $txt->paragraph $text, $width, $height, %options

** DEVELOPER METHOD **

Apply the text within the rectangle and return any leftover text.

B<Options>

=over 4

=item -align => $choice

Choice is 'justified', 'right', 'center', 'left'
Default is 'left'

=item -underline => $distance

=item -underline => [ $distance, $thickness, ... ]

If a scalar, distance below baseline,
else array reference with pairs of distance and line thickness.

=back

B<Example:>

    $txt->font($font,$fontsize);
    $txt->lead($lead);
    $txt->translate($x,$y);
    $overflow = $txt->paragraph( 'long paragraph here ...',
                                 $width,
                                 $y+$lead-$bottom_margin );

=cut

sub paragraph 
{
    my ($self,$text,$width,$height,%opts)=@_;
    my @line=();
    my $nwidth=0;
    my $lead=$self->lead();
    while(length($text)>0) 
    {
        last if(($height-=$lead)<0);
        if($opts{-align}=~/^j/i)
        {
            ($nwidth,$text)=$self->text_fill_justified($text,$width,%opts);
        }
        elsif($opts{-align}=~/^r/i)
        {
            ($nwidth,$text)=$self->text_fill_right($text,$width,%opts);
        }
        elsif($opts{-align}=~/^c/i)
        {
            ($nwidth,$text)=$self->text_fill_center($text,$width,%opts);
        }
        else
        {
            ($nwidth,$text)=$self->text_fill_left($text,$width,%opts);
        }
        $self->nl;
    }

    return($text);
}

=item $hyb->textend

=cut

sub textend {
    my ($self)=@_;
    if($self->{' apiistext'} == 1) {
        $self->add(' ET ',$self->{' poststream'});
        $self->{' apiistext'}=0;
        $self->{' poststream'}='';
    }
    return($self);
}

=item $width = $txt->textlabel $x, $y, $font, $size, $text, %options

Applys text with options, but without teststart/end 
and optionally returns the width of the given text.

B<Example:> 

    $t = $page->gfx;
    $t->textlabel(300,700,$myfont,20,'Page Header',
        -rotate => -30,
        -color => '#FF0000',
        -hspace => 120,
        -align => 'center',
    );
    $t->textlabel(500,500,$myfont,20,'Page Header',
        -rotate => 30,
        -color => '#0000FF',
        -hspace => 80,
        -align => 'right',
    );
    
=cut

sub textlabel 
{
    my ($self,$x,$y,$font,$size,$text,%opts,$wht) = @_;
    my %trans_opts=( -translate => [$x,$y] );
    my %text_state=();
    $trans_opts{-rotate} = $opts{-rotate} if($opts{-rotate});

    my $wastext = $self->{' apiistext'};
    if($wastext) {
        %text_state=$self->textstate;
        $self->textend;
    }
    $self->save;
    $self->textstart;
    
    $self->transform(%trans_opts);
    
    $self->fillcolor(ref($opts{-color}) ? @{$opts{-color}} : $opts{-color}) if($opts{-color});
    $self->strokecolor(ref($opts{-strokecolor}) ? @{$opts{-strokecolor}} : $opts{-strokecolor}) if($opts{-strokecolor});

    $self->font($font,$size);

    $self->charspace($opts{-charspace})     if($opts{-charspace});
    $self->hspace($opts{-hspace})           if($opts{-hspace});
    $self->wordspace($opts{-wordspace})     if($opts{-wordspace});
    $self->render($opts{-render})           if($opts{-render});

    if($opts{-right} || $opts{-align}=~/^r/i) 
    {
        $wht = $self->text_right($text,%opts);
    } 
    elsif($opts{-center} || $opts{-align}=~/^c/i) 
    {
        $wht = $self->text_center($text,%opts);
    } 
    else 
    {
        $wht = $self->text($text,%opts);
    }
    
    $self->textend;
    $self->restore;
    
    if($wastext) {
        $self->textstart;
        $self->textstate(%text_state);
    }
    return($wht);
}

sub resource 
{
    my ($self, $type, $key, $obj, $force) = @_;
    if($self->{' apipage'}) 
    {
        # we are a content stream on a page.
        return( $self->{' apipage'}->resource($type, $key, $obj, $force) );
    } 
    else 
    {
        # we are a self-contained content stream.
        $self->{Resources}||=PDFDict();

        my $dict=$self->{Resources};
        $dict->realise if(ref($dict)=~/Objind$/);

        $dict->{$type}||= PDFDict();
        $dict->{$type}->realise if(ref($dict->{$type})=~/Objind$/);
        unless (defined $obj) 
        {
            return($dict->{$type}->{$key} || undef);
        } 
        else 
        {
            if($force) 
            {
                $dict->{$type}->{$key}=$obj;
            } 
            else 
            {
                $dict->{$type}->{$key}||=$obj;
            }
            return($dict);
        }
    }
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 1.2  2005/11/16 01:27:48  areibens
    genesis2

    Revision 1.1  2005/11/16 01:19:24  areibens
    genesis

    Revision 1.40  2005/10/19 19:04:43  fredo
    added extended typographic text handling call

    Revision 1.39  2005/10/01 22:10:57  fredo
    added more docs for textlabel

    Revision 1.38  2005/06/17 19:43:46  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.37  2005/06/17 18:53:04  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.36  2005/05/29 09:48:46  fredo
    added conditional textstate2 method

    Revision 1.35  2003/04/09 11:12:13  fredo
    documented form-image

    Revision 1.34  2005/03/15 02:20:46  fredo
    added metadata stubs

    Revision 1.33  2005/03/14 22:01:05  fredo
    upd 2005

    Revision 1.32  2005/03/14 20:26:44  fredo
    added 'auto' value for -underline parameter in text
    fixed text line construction to to work under width==0 conditions

    Revision 1.31  2005/02/22 22:59:49  fredo
    fixed infinite loop in paragraph if words longer than a paragraph are present.

    Revision 1.30  2005/02/07 19:31:24  fredo
    fixed reset of textlinematrix on textmatrix set/resets

    Revision 1.29  2005/01/21 10:19:48  fredo
    added spline operator

    Revision 1.28  2005/01/03 01:16:51  fredo
    fixed textpos tracking in nl method

    Revision 1.27  2004/12/31 03:59:09  fredo
    fixed paragraph and text_fill_* methods
    (thanks to Shawn Corey <shawn.corey@sympatico.ca>)

    Revision 1.26  2004/12/31 02:53:18  fredo
    minor code corrections

    Revision 1.25  2004/12/31 02:06:37  fredo
    fixed textpos calculation,
    added underline capability
    (thanks to Shawn Corey <shawn.corey@sympatico.ca>)

    Revision 1.24  2004/12/29 22:01:57  fredo
    advancewidth now can take a virtual textstate

    Revision 1.23  2004/12/29 01:48:15  fredo
    fixed _font method

    Revision 1.22  2004/12/29 01:14:57  fredo
    added virtual attribute support

    Revision 1.21  2004/12/20 12:11:54  fredo
    added fontset method to not set via 'Tf'

    Revision 1.20  2004/12/16 00:30:51  fredo
    added no warn for recursion

    Revision 1.19  2004/12/15 16:44:43  fredo
    added condition to apply font (Tf) only when needed

    Revision 1.18  2004/11/25 20:53:59  fredo
    fixed unifont registration

    Revision 1.17  2004/11/24 20:10:31  fredo
    added virtual font handling, fixed var shadow bug

    Revision 1.16  2004/10/26 11:34:22  fredo
    reworked text_fill for paragraph, but still being development

    Revision 1.15  2004/08/31 13:50:09  fredo
    fixed space vs. whitespace split bug

    Revision 1.14  2004/07/29 10:46:37  fredo
    added new text_fill_* methods and a simple paragraph

    Revision 1.13  2004/06/21 22:33:36  fredo
    added basic pattern/shading handling

    Revision 1.12  2004/06/15 09:11:37  fredo
    removed cr+lf

    Revision 1.11  2004/06/07 19:44:12  fredo
    cleaned out cr+lf for lf

    Revision 1.10  2004/05/31 23:20:48  fredo
    added basic platform encoding independency

    Revision 1.9  2004/04/07 10:49:26  fredo
    fixed handling of colorSpaces for fill/strokecolor

    Revision 1.8  2004/02/12 14:46:44  fredo
    removed duplicate definition of egstate method

    Revision 1.7  2004/02/06 02:01:25  fredo
    added save/restore around textlabel

    Revision 1.6  2004/02/05 23:24:00  fredo
    fixed lab behavior

    Revision 1.5  2004/02/05 12:26:08  fredo
    revised '_makecolor' to use Lab for hsv/hsl,
    added textlabel method

    Revision 1.4  2003/12/08 13:05:19  Administrator
    corrected to proper licencing statement

    Revision 1.3  2003/11/30 17:09:18  Administrator
    merged into default

    Revision 1.2.2.1  2003/11/30 16:56:21  Administrator
    merged into default

    Revision 1.2  2003/11/30 11:33:59  Administrator
    added CVS id/log


=cut
