package PDF::API2::Util;

no warnings qw[ recursion uninitialized ];

BEGIN {

    use Encode qw(:all);

    use vars qw(
        $VERSION 
        @ISA 
        @EXPORT 
        @EXPORT_OK 
        %colors 
        $key_var 
        $key_var2 
        %u2n 
        %n2u 
        %u2n_o 
        %n2u_o 
        $pua
        $uuu
        %PaperSizes
    );
    use Math::Trig;
    use List::Util qw(min max);
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Basic::PDF::Filter;

    use POSIX qw( HUGE_VAL floor );

    use Exporter;
    @ISA = qw(Exporter);
    @EXPORT = qw(
        pdfkey
        pdfkey2
        float floats floats5 intg intgs
        mMin mMax
        HSVtoRGB RGBtoHSV HSLtoRGB RGBtoHSL RGBtoLUM
        namecolor namecolor_cmyk namecolor_lab optInvColor defineColor
        dofilter unfilter
        nameByUni uniByName initNameTable defineName
        page_size
        getPaperSizes
    );
    @EXPORT_OK = qw(
        pdfkey
        pdfkey2
        digest digestx digest16 digest32
        float floats floats5 intg intgs
        mMin mMax
        cRGB cRGB8 RGBasCMYK
        HSVtoRGB RGBtoHSV HSLtoRGB RGBtoHSL RGBtoLUM
        namecolor namecolor_cmyk namecolor_lab optInvColor defineColor
        dofilter unfilter
        nameByUni uniByName initNameTable defineName
        page_size
    );


    %PaperSizes=();
    foreach my $dir (@INC) {
        if(-f "$dir/PDF/API2/Resource/unipaper.txt")
        {
            my ($fh,$line);
            open($fh,"$dir/PDF/API2/Resource/unipaper.txt");
            while($line=<$fh>)
            {
                next if($line=~m|^#|);
                chomp($line);
                my ($name,$x,$y)=split(/\s+;\s+/,$line);
                $PaperSizes{lc $name}=[$x,$y];
            }
            close($fh);
            last;
        }
    }

    no warnings qw[ recursion uninitialized ];

    ( $VERSION ) = '2.000';

    $key_var='CBA';
    $key_var2=0;

    $pua=0xE000;

    %u2n_o=();
    %n2u_o=();

    $uuu={g=>{},u=>{}};
    foreach my $dir (@INC) {
        if(-f "$dir/PDF/API2/Resource/uniglyph.txt")
        {
            my ($fh,$line);
            open($fh,"$dir/PDF/API2/Resource/uniglyph.txt");
            while($line=<$fh>)
            {
                next if($line=~m|^#|);
                chomp($line);
                $line=~s|\s+\#.+$||go;
                my ($uni,$name,$prio)=split(/\s+;\s+/,$line);
                $uni=hex($uni);
                $uuu->{u}->{$uni}||=[];
                $uuu->{g}->{$name}||=[];
                push @{$uuu->{u}->{$uni}},{uni=>$uni,name=>$name,prio=>$prio};    
                push @{$uuu->{g}->{$name}},{uni=>$uni,name=>$name,prio=>$prio};    
            }
            close($fh);
            last;
        }
    }
    foreach my $k (sort {$a<=>$b} keys %{$uuu->{u}})
    {
        $u2n_o{$k}=$uuu->{u}->{$k}->[0]->{name};
    }
    foreach my $k (keys %{$uuu->{g}})
    {
        my($r)=sort {$a->{prio}<=>$b->{prio}} @{$uuu->{g}->{$k}};
        $n2u_o{$k}=$r->{uni};
    }
    $uuu=undef;

    %u2n=%u2n_o;
    %n2u=%n2u_o;

    %colors=();
    foreach my $dir (@INC) {
        if(-f "$dir/PDF/API2/Resource/unicolor.txt")
        {
            my ($fh,$line);
            open($fh,"$dir/PDF/API2/Resource/unicolor.txt");
            while($line=<$fh>)
            {
                next if($line=~m|^#|);
                chomp($line);
                my ($name,$val)=split(/\s+;\s+/,$line);
                $colors{lc $name}=$val;
            }
            close($fh);
            last;
        }
    }
}

sub pdfkey {
    return($PDF::API2::Util::key_var++);
}

sub pdfkey2 {
    return($PDF::API2::Util::key_var.($PDF::API2::Util::key_var2++));
}

sub digestx {
    my $len=shift @_;
    my $mask=$len-1;
    my $ddata=join('',@_);
    my $mdkey='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789gT';
    my $xdata="0" x $len;
    my $off=0;
    my $set;
    foreach $set (0..(length($ddata)<<1)) {
        $off+=vec($ddata,$set,4);
        $off+=vec($xdata,($set & $mask),8);
        vec($xdata,($set & ($mask<<1 |1)),4)=vec($mdkey,($off & 0x7f),4);
    }

#   foreach $set (0..$mask) {
#       vec($xdata,$set,8)=(vec($xdata,$set,8) & 0x7f) | 0x40;
#   }

#   $off=0;
#   foreach $set (0..$mask) {
#       $off+=vec($xdata,$set,8);
#       vec($xdata,$set,8)=vec($mdkey,($off & 0x3f),8);
#   }

    return($xdata);
}

sub digest {
    return(digestx(32,@_));
}

sub digest16 {
    return(digestx(16,@_));
}

sub digest32 {
    return(digestx(32,@_));
}

sub xlog10 {
    my $n = shift;
    if($n) {
            return log(abs($n))/log(10);
    } else { return 0; }
}

sub float {
    my $f=shift @_;
    my $mxd=shift @_||4;
    $f=0 if(abs($f)<0.0000000000000001);
    my $ad=floor(xlog10($f)-$mxd);
    if(abs($f-int($f)) < (10**(-$mxd))) {
        # just in case we have an integer
        return sprintf('%i',$f);
    } elsif($ad>0){
        return sprintf('%f',$f);
    } else {
        return sprintf('%.'.abs($ad).'f',$f);
    }
}
sub floats { return map { float($_); } @_; }
sub floats5 { return map { float($_,5); } @_; }


sub intg {
    my $f=shift @_;
    return sprintf('%i',$f);
}
sub intgs { return map { intg($_); } @_; }

sub mMin {
    my $n=HUGE_VAL;
    map { $n=($n>$_) ? $_ : $n } @_;
    return($n);
}

sub mMax {
    my $n=-(HUGE_VAL);
    map { $n=($n<$_) ? $_ : $n } @_;
    return($n);
}

sub cRGB {
    my @cmy=(map { 1-$_ } @_);
    my $k=mMin(@cmy);
    return((map { $_-$k } @cmy),$k);
}

sub cRGB8 {
    return cRGB(map { $_/255 } @_);
}

sub RGBtoLUM {
    my ($r,$g,$b)=@_;
    return($r*0.299+$g*0.587+$b*0.114);
}

sub RGBasCMYK {
    my @rgb=@_;
    my @cmy=(map { 1-$_ } @rgb);
    my $k=mMin(@cmy)*0.44;
    return((map { $_-$k } @cmy),$k);
}

sub HSVtoRGB {
    my ($h,$s,$v)=@_;
    my ($r,$g,$b,$i,$f,$p,$q,$t);

    if( $s == 0 ) {
        ## achromatic (grey)
        return ($v,$v,$v);
    }

    $h %= 360;
    $h /= 60;       ## sector 0 to 5
    $i = POSIX::floor( $h );
    $f = $h - $i;   ## factorial part of h
    $p = $v * ( 1 - $s );
    $q = $v * ( 1 - $s * $f );
    $t = $v * ( 1 - $s * ( 1 - $f ) );

    if($i<1) {
        $r = $v;
        $g = $t;
        $b = $p;
    } elsif($i<2){
        $r = $q;
        $g = $v;
        $b = $p;
    } elsif($i<3){
        $r = $p;
        $g = $v;
        $b = $t;
    } elsif($i<4){
        $r = $p;
        $g = $q;
        $b = $v;
    } elsif($i<5){
        $r = $t;
        $g = $p;
        $b = $v;
    } else {
        $r = $v;
        $g = $p;
        $b = $q;
    }
    return ($r,$g,$b);
}
sub _HSVtoRGB { # test
    my ($h,$s,$v)=@_;
    my ($r,$g,$b,$i,$f,$p,$q,$t);

    if( $s == 0 ) {
        ## achromatic (grey)
        return ($v,$v,$v);
    }
    
    $h %= 360;
    
    $r = 2*cos(deg2rad($h));
    $g = 2*cos(deg2rad($h+120));
    $b = 2*cos(deg2rad($h+240));

    $p = max($r,$g,$b);
    $q = min($r,$g,$b);
    ($p,$q) = map { ($_<0 ? 0 : ($_>1 ? 1 : $_)) } ($p,$q);
    $f = $p - $q;
    
    #if($p>=$v) {
    #    ($r,$g,$b) = map { $_*$v/$p } ($r,$g,$b);
    #} else {
    #    ($r,$g,$b) = map { $_*$p/$v } ($r,$g,$b);
    #}
    #
    #if($f>=$s) {
    #    ($r,$g,$b) = map { (($_-$q/2)*$f/$s)+$q/2 } ($r,$g,$b);
    #} else {
    #    ($r,$g,$b) = map { (($_-$q/2)*$s/$f)+$q/2 } ($r,$g,$b);
    #}

    ($r,$g,$b) = map { ($_<0 ? 0 : ($_>1 ? 1 : $_)) } ($r,$g,$b);

    return ($r,$g,$b);
}

sub RGBquant ($$$) {
    my($q1,$q2,$h)=@_;
    while($h<0){$h+=360;}
    $h%=360;
    if ($h<60) {
        return($q1+(($q2-$q1)*$h/60));
    } elsif ($h<180) {
        return($q2);
    } elsif ($h<240) {
        return($q1+(($q2-$q1)*(240-$h)/60));
    } else {
        return($q1);
    }
}

sub RGBtoHSV {
    my ($r,$g,$b)=@_;
    my ($h,$s,$v,$min,$max,$delta);

    $min= mMin($r,$g,$b);
    $max= mMax($r,$g,$b);

    $v = $max;

    $delta = $max - $min;

    if( $delta > 0.000000001 ) {
        $s = $delta / $max;
    } else {
        $s = 0;
        $h = 0;
        return($h,$s,$v);
    }

    if( $r == $max ) {
        $h = ( $g - $b ) / $delta;
    } elsif( $g == $max ) {
        $h = 2 + ( $b - $r ) / $delta;
    } else {
        $h = 4 + ( $r - $g ) / $delta;
    }
    $h *= 60;
    if( $h < 0 ) {$h += 360;}
    return($h,$s,$v);
}

sub RGBtoHSL {
    my ($r,$g,$b)=@_;
    my ($h,$s,$v,$l,$min,$max,$delta);

    $min= mMin($r,$g,$b);
    $max= mMax($r,$g,$b);
    ($h,$s,$v)=RGBtoHSV($r,$g,$b);
    $l=($max+$min)/2.0;
        $delta = $max - $min;
    if($delta<0.00000000001){
        return(0,0,$l);
    } else {
        if($l<=0.5){
            $s=$delta/($max+$min);
        } else {
            $s=$delta/(2-$max-$min);
        }
    }
    return($h,$s,$l);
}

sub HSLtoRGB {
    my($h,$s,$l,$r,$g,$b,$p1,$p2)=@_;
    if($l<=0.5){
        $p2=$l*(1+$s);
    } else {
        $p2=$l+$s-($l*$s);
    }
    $p1=2*$l-$p2;
    if($s<0.0000000000001){
        $r=$l; $g=$l; $b=$l;
    } else {
        $r=RGBquant($p1,$p2,$h+120);
        $g=RGBquant($p1,$p2,$h);
        $b=RGBquant($p1,$p2,$h-120);
    }
    return($r,$g,$b);
}

sub optInvColor {
    my ($r,$g,$b) = @_;

    my $ab = (0.2*$r) + (0.7*$g) + (0.1*$b);

    if($ab > 0.45) {
        return(0,0,0);
    } else {
        return(1,1,1);
    }
}

sub defineColor {
    my ($name,$mx,$r,$g,$b)=@_;
    $colors{$name}||=[ map {$_/$mx} ($r,$g,$b) ];
    return($colors{$name});
}

sub rgbHexValues {
    my $name=lc(shift @_);
    my ($r,$g,$b);
    if(length($name)<5) {       # zb. #fa4,          #cf0
        $r=hex(substr($name,1,1))/0xf;
        $g=hex(substr($name,2,1))/0xf;
        $b=hex(substr($name,3,1))/0xf;
    } elsif(length($name)<8) {  # zb. #ffaa44,       #ccff00
        $r=hex(substr($name,1,2))/0xff;
        $g=hex(substr($name,3,2))/0xff;
        $b=hex(substr($name,5,2))/0xff;
    } elsif(length($name)<11) { # zb. #fffaaa444,    #cccfff000
        $r=hex(substr($name,1,3))/0xfff;
        $g=hex(substr($name,4,3))/0xfff;
        $b=hex(substr($name,7,3))/0xfff;
    } else {            # zb. #ffffaaaa4444, #ccccffff0000
        $r=hex(substr($name,1,4))/0xffff;
        $g=hex(substr($name,5,4))/0xffff;
        $b=hex(substr($name,9,4))/0xffff;
    }
    return($r,$g,$b);
}
sub cmykHexValues {
    my $name=lc(shift @_);
    my ($c,$m,$y,$k);
    if(length($name)<6) {       # zb. %cmyk
        $c=hex(substr($name,1,1))/0xf;
        $m=hex(substr($name,2,1))/0xf;
        $y=hex(substr($name,3,1))/0xf;
        $k=hex(substr($name,4,1))/0xf;
    } elsif(length($name)<10) { # zb. %ccmmyykk
        $c=hex(substr($name,1,2))/0xff;
        $m=hex(substr($name,3,2))/0xff;
        $y=hex(substr($name,5,2))/0xff;
        $k=hex(substr($name,7,2))/0xff;
    } elsif(length($name)<14) { # zb. %cccmmmyyykkk
        $c=hex(substr($name,1,3))/0xfff;
        $m=hex(substr($name,4,3))/0xfff;
        $y=hex(substr($name,7,3))/0xfff;
        $k=hex(substr($name,10,3))/0xfff;
    } else {            # zb. %ccccmmmmyyyykkkk
        $c=hex(substr($name,1,4))/0xffff;
        $m=hex(substr($name,5,4))/0xffff;
        $y=hex(substr($name,9,4))/0xffff;
        $k=hex(substr($name,13,4))/0xffff;
    }
    return($c,$m,$y,$k);
}
sub hsvHexValues {
    my $name=lc(shift @_);
    my ($h,$s,$v);
    if(length($name)<5) {
        $h=360*hex(substr($name,1,1))/0x10;
        $s=hex(substr($name,2,1))/0xf;
        $v=hex(substr($name,3,1))/0xf;
    } elsif(length($name)<8) {
        $h=360*hex(substr($name,1,2))/0x100;
        $s=hex(substr($name,3,2))/0xff;
        $v=hex(substr($name,5,2))/0xff;
    } elsif(length($name)<11) {
        $h=360*hex(substr($name,1,3))/0x1000;
        $s=hex(substr($name,4,3))/0xfff;
        $v=hex(substr($name,7,3))/0xfff;
    } else {
        $h=360*hex(substr($name,1,4))/0x10000;
        $s=hex(substr($name,5,4))/0xffff;
        $v=hex(substr($name,9,4))/0xffff;
    }
    return($h,$s,$v);
}
sub labHexValues {
    my $name=lc(shift @_);
    my ($l,$a,$b);
    if(length($name)<5) {
        $l=100*hex(substr($name,1,1))/0xf;
        $a=(200*hex(substr($name,2,1))/0xf)-100;
        $b=(200*hex(substr($name,3,1))/0xf)-100;
    } elsif(length($name)<8) {
        $l=100*hex(substr($name,1,2))/0xff;
        $a=(200*hex(substr($name,3,2))/0xff)-100;
        $b=(200*hex(substr($name,5,2))/0xff)-100;
    } elsif(length($name)<11) {
        $l=100*hex(substr($name,1,3))/0xfff;
        $a=(200*hex(substr($name,4,3))/0xfff)-100;
        $b=(200*hex(substr($name,7,3))/0xfff)-100;
    } else {
        $l=100*hex(substr($name,1,4))/0xffff;
        $a=(200*hex(substr($name,5,4))/0xffff)-100;
        $b=(200*hex(substr($name,9,4))/0xffff)-100;
    }
    return($l,$a,$b);
}

sub namecolor {
    my $name=shift @_;
    unless(ref $name) {
        $name=lc($name);
        $name=~s/[^\#!%\&\$a-z0-9]//go;
    }
    if($name=~/^[a-z]/) { # name spec.
        return(namecolor($colors{$name}));
    } elsif($name=~/^#/) { # rgb spec.
        return(floats5(rgbHexValues($name)));
    } elsif($name=~/^%/) { # cmyk spec.
        return(floats5(cmykHexValues($name)));
    } elsif($name=~/^!/) { # hsv spec.
        return(floats5(HSVtoRGB(hsvHexValues($name))));
    } elsif($name=~/^&/) { # hsl spec.
        return(floats5(HSLtoRGB(hsvHexValues($name))));
    } else { # or it is a ref ?
        return(floats5(@{$name || [0.5,0.5,0.5]}));
    }
}
sub namecolor_cmyk {
    my $name=shift @_;
    unless(ref $name) {
        $name=lc($name);
        $name=~s/[^\#!%\&\$a-z0-9]//go;
    }
    if($name=~/^[a-z]/) { # name spec.
        return(namecolor_cmyk($colors{$name}));
    } elsif($name=~/^#/) { # rgb spec.
        return(floats5(RGBasCMYK(rgbHexValues($name))));
    } elsif($name=~/^%/) { # cmyk spec.
        return(floats5(cmykHexValues($name)));
    } elsif($name=~/^!/) { # hsv spec.
        return(floats5(RGBasCMYK(HSVtoRGB(hsvHexValues($name)))));
    } elsif($name=~/^&/) { # hsl spec.
        return(floats5(RGBasCMYK(HSLtoRGB(hsvHexValues($name)))));
    } else { # or it is a ref ?
        return(floats5(RGBasCMYK(@{$name || [0.5,0.5,0.5]})));
    }
}
sub namecolor_lab {
    my $name=shift @_;
    unless(ref $name) {
        $name=lc($name);
        $name=~s/[^\#!%\&\$a-z0-9]//go;
    }
    if($name=~/^[a-z]/) { # name spec.
        return(namecolor_lab($colors{$name}));
    } elsif($name=~/^\$/) { # lab spec.
        return(floats5(labHexValues($name)));
    } elsif($name=~/^#/) { # rgb spec.
        my ($h,$s,$v)=RGBtoHSV(rgbHexValues($name));
        my $a=cos(deg2rad $h)*$s*100;
        my $b=sin(deg2rad $h)*$s*100;
        my $l=100*$v;
        return(floats5($l,$a,$b));
    } elsif($name=~/^!/) { # hsv spec.
        # fake conversion
        my ($h,$s,$v)=hsvHexValues($name);
        my $a=cos(deg2rad $h)*$s*100;
        my $b=sin(deg2rad $h)*$s*100;
        my $l=100*$v;
        return(floats5($l,$a,$b));
    } elsif($name=~/^&/) { # hsl spec.
        my ($h,$s,$v)=hsvHexValues($name);
        my $a=cos(deg2rad $h)*$s*100;
        my $b=sin(deg2rad $h)*$s*100;
        ($h,$s,$v)=RGBtoHSV(HSLtoRGB($h,$s,$v));
        my $l=100*$v;
        return(floats5($l,$a,$b));
    } else { # or it is a ref ?
        my ($h,$s,$v)=RGBtoHSV(@{$name || [0.5,0.5,0.5]});
        my $a=cos(deg2rad $h)*$s*100;
        my $b=sin(deg2rad $h)*$s*100;
        my $l=100*$v;
        return(floats5($l,$a,$b));
    }
}

sub unfilter 
{
    my ($filter,$stream)=@_;

    if(defined $filter) 
    {
        # we need to fix filter because it MAY be
        # an array BUT IT COULD BE only a name
        if(ref($filter)!~/Array$/) 
        {
               $filter = PDFArray($filter);
        }
        my @filts;
        my ($hasflate) = -1;
        my ($temp, $i, $temp1);

        @filts=(map { ("PDF::API2::Basic::PDF::".($_->val))->new } $filter->elementsof);

        foreach my $f (@filts) 
        {
            $stream = $f->infilt($stream, 1);
        }
    }
    return($stream);
}

sub dofilter {
    my ($filter,$stream)=@_;

    if((defined $filter) ) {
        # we need to fix filter because it MAY be
        # an array BUT IT COULD BE only a name
        if(ref($filter)!~/Array$/) {
               $filter = PDFArray($filter);
        }
        my @filts;
        my ($hasflate) = -1;
        my ($temp, $i, $temp1);

        @filts=(map { ("PDF::API2::Basic::PDF::".($_->val))->new } $filter->elementsof);

        foreach my $f (@filts) {
            $stream = $f->outfilt($stream, 1);
        }
    }
    return($stream);
}

sub nameByUni {
  my ($e)=@_;
  return($u2n{$e} || sprintf('uni%04X',$e));
}

sub uniByName {
  my ($e)=@_;
  if($e=~/^uni([0-9A-F]{4})$/) {
    return(hex($1));
  }
  return($n2u{$e} || undef);
}

sub initNameTable {
    %u2n=(); %u2n=%u2n_o;
    %n2u=(); %n2u=%n2u_o;
    $pua=0xE000;
    1;
}
sub defineName {
    my $name=shift @_;
    return($n2u{$name}) if(defined $n2u{$name});

    while(defined $u2n{$pua}) { $pua++; }

    $u2n{$pua}=$name;
    $n2u{$name}=$pua;

    return($pua);
}

sub page_size {
    my ($x1,$y1,$x2,$y2) = @_;
    if(defined $x2) {
        # full bbox
        return($x1,$y1,$x2,$y2);
    } elsif(defined $y1) {
        # half bbox
        return(0,0,$x1,$y1);
    } elsif(defined $PaperSizes{lc($x1)}) {
        # textual spec.
        return(0,0,@{$PaperSizes{lc($x1)}});
    } elsif($x1=~/^[\d\.]+$/) {
        # single quadratic
        return(0,0,$x1,$x1);
    } else {
        # pdf default.
        return(0,0,612,792);
    }
}

sub getPaperSizes 
{
    my %h=();
    foreach my $k (keys %PaperSizes)
    {
    $h{$k}=[@{$PaperSizes{$k}}];
    }
    return(%h);
}

sub xmlMarkupDecl
{
    my $xml=<<EOT;
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<!DOCTYPE p [
EOT
    foreach my $n (sort {lc($a) cmp lc($b)} keys %n2u)
    {
        next if($n eq 'apos');
        next if($n eq 'amp');
        next if($n eq 'quot');
        next if($n eq 'gt');
        next if($n eq 'lt');
        next if($n eq '.notdef');
        next if($n2u{$n}<32);
        $xml.=sprintf('<!ENTITY %s "&#x%04X;">',$n,$n2u{$n})."\n";
    }
    $xml.="\n]>\n";
    return($xml);
}


1;

__END__

function xRGBhex_to_aRGBhex ( $hstring, $lightness = 1.0 ) {

    $color=hexdec($hstring);

    $r=(($color & 0xff0000) >> 16)/255;
    $g=(($color & 0xff00) >> 8)/255;
    $b=($color & 0xff)/255;

    $rgbmax=max($r,$g,$b);

    $rgbmin=min($r,$g,$b);

    $rgbavg=($r+$g+$b)/3.0;


    if($rgbmin==$rgbmax) {
        return $hstring;
    }

    if ( $r == $rgbmax ) {
        $h = ( $g - $b ) / ( $rgbmax - $rgbmin );
    } elseif ( $g == $rgbmax ) {
        $h = 2.0 + ( $b - $r ) / ( $rgbmax - $rgbmin );
    } elseif ( $b == $rgbmax ) {
        $h = 4.0 + ( $r - $g ) / ( $rgbmax - $rgbmin );
    }
    if ( $h >= 6.0 ) {
        $h-=6.0;
    } elseif ( $h < 0.0 ) {
        $h+=6.0;
    }
    $s = ( $rgbmax - $rgbmin ) / $rgbmax;
    $s = $s>0.8 ? $s : 0.8;
    $ab = (0.3*$r) + (0.5*$g) + (0.2*$b);
    $v=$lightness*(pow($ab,(1/3)));

    $i=floor($h);
    $f=$h-$i;
    $p=$v*(1.0-$s);
    $q=$v*(1.0-$s*$f);
    $t=$v*(1.0-$s+$s*$f);

    if ($i==0) {
        return sprintf("%02X%02X%02X",$v*255,$t*255,$p*255);
    } elseif ($i==1) {
        return sprintf("%02X%02X%02X",$q*255,$v*255,$p*255);
    } elseif ($i==2) {
        return sprintf("%02X%02X%02X",$p*255,$v*255,$t*255);
    } elseif ($i==3) {
        return sprintf("%02X%02X%02X",$p*255,$q*255,$v*255);
    } elseif ($i==4) {
        return sprintf("%02X%02X%02X",$t*255,$p*255,$v*255);
    } else {
        return sprintf("%02X%02X%02X",$v*255,$p*255,$q*255);
    }
}


function RGBhex_bwinv ( $hstring ) {
        $color=hexdec($hstring);

        $r=(($color & 0xff0000) >> 16)/255;
        $g=(($color & 0xff00) >> 8)/255;
        $b=($color & 0xff)/255;

    $ab = (0.2*$r) + (0.7*$g) + (0.1*$b);

    if($ab > 0.45) {
        return "000000";
    } else {
        return "FFFFFF";
    }
}

=head1 NAME

PDF::API2::Util - utility package for often use methods across the package.

=head1 PREDEFINED PAPERSIZES

=over 4

=item %sizes = getPaperSizes();

Will retrive the registered papersizes of PDF::API2.

    print Dumper(\%sizes);
    $VAR1={
        '4a'        =>  [ 4760  , 6716  ],
        '2a'        =>  [ 3368  , 4760  ],
        'a0'        =>  [ 2380  , 3368  ],
        'a1'        =>  [ 1684  , 2380  ],
        'a2'        =>  [ 1190  , 1684  ],
        'a3'        =>  [ 842   , 1190  ],
        'a4'        =>  [ 595   , 842   ],
        'a5'        =>  [ 421   , 595   ],
        'a6'        =>  [ 297   , 421   ],
        '4b'        =>  [ 5656  , 8000  ],
        '2b'        =>  [ 4000  , 5656  ],
        'b0'        =>  [ 2828  , 4000  ],
        'b1'        =>  [ 2000  , 2828  ],
        'b2'        =>  [ 1414  , 2000  ],
        'b3'        =>  [ 1000  , 1414  ],
        'b4'        =>  [ 707   , 1000  ],
        'b5'        =>  [ 500   , 707   ],
        'b6'        =>  [ 353   , 500   ],
        'letter'    =>  [ 612   , 792   ],
        'broadsheet'    =>  [ 1296  , 1584  ],
        'ledger'    =>  [ 1224  , 792   ],
        'tabloid'   =>  [ 792   , 1224  ],
        'legal'     =>  [ 612   , 1008  ],
        'executive' =>  [ 522   , 756   ],
        '36x36'     =>  [ 2592  , 2592  ],
    };

=back

=head1 PREDEFINED COLORS

See the file C<unicolor.txt> for a complete list.

B<Please Note:> This is an amalgamation of the X11, SGML and (X)HTML specification sets.

=head1 PREDEFINED GLYPH-NAMES

See the file C<uniglyph.txt> for a complete list.

a a1 a10 a100 a101 a102 a103 a104 a105 a106 a107 a108 a11 a117 a118 a119 a12 a120 a121 a122 a123 a124
a125 a126 a127 a128 a129 a13 a130 a131 a132 a133 a134 a135 a136 a137 a138 a139 a14 a140 a141 a142 a143
a144 a145 a146 a147 a148 a149 a15 a150 a151 a152 a153 a154 a155 a156 a157 a158 a159 a16 a160 a162 a165
a166 a167 a168 a169 a17 a170 a171 a172 a173 a174 a175 a176 a177 a178 a179 a18 a180 a181 a182 a183 a184
a185 a186 a187 a188 a189 a19 a190 a191 a192 a193 a194 a195 a196 a197 a198 a199 a2 a20 a200 a201 a202 a203
a204 a205 a206 a21 a22 a23 a24 a25 a26 a27 a28 a29 a3 a30 a31 a32 a33 a34 a35 a36 a37 a38 a39 a4 a40 a41
a42 a43 a44 a45 a46 a47 a48 a49 a5 a50 a51 a52 a53 a54 a55 a56 a57 a58 a59 a6 a60 a61 a62 a63 a64 a65 a66
a67 a68 a69 a7 a70 a72 a74 a75 a78 a79 a8 a81 a82 a83 a84 a85 a86 a87 a88 a89 a9 a90 a91 a92 a93 a94 a95
a96 a97 a98 a99 aacgr aacute Aacutesmall abreve acirc acircumflex Acircumflexsmall acute acutecomb
Acutesmall acy adieresis Adieresissmall ae aeacute aelig AEsmall afii00208 afii10017 afii10018 afii10019
afii10020 afii10021 afii10022 afii10023 afii10024 afii10025 afii10026 afii10027 afii10028 afii10029
afii10030 afii10031 afii10032 afii10033 afii10034 afii10035 afii10036 afii10037 afii10038 afii10039
afii10040 afii10041 afii10042 afii10043 afii10044 afii10045 afii10046 afii10047 afii10048 afii10049
afii10050 afii10051 afii10052 afii10053 afii10054 afii10055 afii10056 afii10057 afii10058 afii10059
afii10060 afii10061 afii10062 afii10063 afii10064 afii10065 afii10066 afii10067 afii10068 afii10069
afii10070 afii10071 afii10072 afii10073 afii10074 afii10075 afii10076 afii10077 afii10078 afii10079
afii10080 afii10081 afii10082 afii10083 afii10084 afii10085 afii10086 afii10087 afii10088 afii10089
afii10090 afii10091 afii10092 afii10093 afii10094 afii10095 afii10096 afii10097 afii10098 afii10099
afii10100 afii10101 afii10102 afii10103 afii10104 afii10105 afii10106 afii10107 afii10108 afii10109
afii10110 afii10145 afii10146 afii10147 afii10148 afii10192 afii10193 afii10194 afii10195 afii10196
afii10831 afii10832 afii10846 afii299 afii300 afii301 afii57381 afii57388 afii57392 afii57393 afii57394
afii57395 afii57396 afii57397 afii57398 afii57399 afii57400 afii57401 afii57403 afii57407 afii57409
afii57410 afii57411 afii57412 afii57413 afii57414 afii57415 afii57416 afii57417 afii57418 afii57419
afii57420 afii57421 afii57422 afii57423 afii57424 afii57425 afii57426 afii57427 afii57428 afii57429
afii57430 afii57431 afii57432 afii57433 afii57434 afii57440 afii57441 afii57442 afii57443 afii57444
afii57445 afii57446 afii57448 afii57449 afii57450 afii57451 afii57452 afii57453 afii57454 afii57455
afii57456 afii57457 afii57458 afii57470 afii57505 afii57506 afii57507 afii57508 afii57509 afii57511
afii57512 afii57513 afii57514 afii57519 afii57534 afii57636 afii57645 afii57658 afii57664 afii57665
afii57666 afii57667 afii57668 afii57669 afii57670 afii57671 afii57672 afii57673 afii57674 afii57675
afii57676 afii57677 afii57678 afii57679 afii57680 afii57681 afii57682 afii57683 afii57684 afii57685
afii57686 afii57687 afii57688 afii57689 afii57690 afii57694 afii57695 afii57700 afii57705 afii57716
afii57717 afii57718 afii57723 afii57793 afii57794 afii57795 afii57796 afii57797 afii57798 afii57799
afii57800 afii57801 afii57802 afii57803 afii57804 afii57806 afii57807 afii57839 afii57841 afii57842
afii57929 afii61248 afii61289 afii61352 afii61573 afii61574 afii61575 afii61664 afii63167 afii64937 agr
agrave Agravesmall airplane alefsym aleph alpha alphatonos amacr amacron amalg amp ampersand ampersandit
ampersanditlc ampersandsmall and ang ang90 angle angleleft angleright angmsd angsph angst anoteleia aogon
aogonek ap ape apos approxequal aquarius aries aring aringacute Aringsmall arrowboth arrowdblboth
arrowdbldown arrowdblleft arrowdblright arrowdblup arrowdown arrowdwnleft1 arrowdwnrt1 arrowhorizex
arrowleft arrowleftdwn1 arrowleftup1 arrowright arrowrtdwn1 arrowrtup1 arrowup arrowupdn arrowupdnbse
arrowupleft1 arrowuprt1 arrowvertex asciicircum asciitilde Asmall ast asterisk asteriskmath asuperior
asymp at atilde Atildesmall auml b backslash ballpoint bar barb2down barb2left barb2ne barb2nw barb2right
barb2se barb2sw barb2up barb4down barb4left barb4ne barb4nw barb4right barb4se barb4sw barb4up barwed
bcong bcy bdash1 bdash2 bdown bdquo becaus bell bepsi bernou beta beth bgr blank bleft bleftright blk12
blk14 blk34 block bne bnw bomb book bottom bowtie box2 box3 box4 boxcheckbld boxdl boxdr boxh boxhd boxhu
boxshadowdwn boxshadowup boxul boxur boxv boxvh boxvl boxvr boxxmarkbld bprime braceex braceleft
braceleftbt braceleftmid bracelefttp braceright bracerightbt bracerightmid bracerighttp bracketleft
bracketleftbt bracketleftex bracketlefttp bracketright bracketrightbt bracketrightex bracketrighttp breve
Brevesmall bright brokenbar brvbar bse bsim bsime Bsmall bsol bsuperior bsw budleafne budleafnw budleafse
budleafsw bull bullet bump bumpe bup bupdown c cacute cancer candle cap capricorn caret caron Caronsmall
carriagereturn ccaron ccedil ccedilla Ccedillasmall ccirc ccircumflex cdot cdotaccent cedil cedilla
Cedillasmall cent centinferior centoldstyle centsuperior chcy check checkbld chi cir circ circle circle2
circle4 circle6 circledown circleleft circlemultiply circleplus circleright circleshadowdwn
circleshadowup circlestar circleup circumflex Circumflexsmall cire clear club clubs colon colone
colonmonetary comma commaaccent commainferior command commasuperior commat comp compfn cong congruent
conint coprod copy copyright copyrightsans copyrightserif copysr crarr crescentstar cross crossceltic
crossmaltese crossoutline crossshadow crosstar2 Csmall cuepr cuesc cularr cup cupre curarr curren
currency cuspopen cuspopen1 cuvee cuwed cyrbreve cyrflex d dagger daggerdbl daleth darr darr2 dash dashv
dblac dblgrave dcaron dcroat dcy deg degree deleteleft deleteright delta dgr dharl dharr diam diamond
diams die dieresis dieresisacute dieresisgrave Dieresissmall dieresistonos divide divonx djcy dkshade
dlarr dlcorn dlcrop dnblock dodecastar3 dollar dollarinferior dollaroldstyle dollarsuperior dong dot
dotaccent Dotaccentsmall dotbelowcomb DotDot dotlessi dotlessj dotmath drarr drcorn drcrop droplet dscy
Dsmall dstrok dsuperior dtri dtrif dzcy e eacgr eacute Eacutesmall ebreve ecaron ecir ecirc ecircumflex
Ecircumflexsmall ecolon ecy edieresis Edieresissmall edot edotaccent eeacgr eegr efDot egr egrave
Egravesmall egs eight eightinferior eightoclock eightoldstyle eightsans eightsansinv eightsuperior
element elevenoclock ell ellipsis els emacr emacron emdash empty emptyset emsp emsp13 emsp14 endash eng
ensp envelopeback envelopefront eogon eogonek epsi epsilon epsilontonos epsis equal equals equiv
equivalence erDot escape esdot Esmall estimated esuperior eta etatonos eth Ethsmall euml euro excl exclam
exclamdbl exclamdown exclamdownsmall exclamsmall exist existential f fcy female ff ffi ffl fi figuredash
filecabinet filetalltext filetalltext1 filetalltext3 filledbox filledrect five fiveeighths fiveinferior
fiveoclock fiveoldstyle fivesans fivesansinv fivesuperior fl flag flat floppy3 floppy5 florin fnof folder
folderopen forall fork four fourinferior fouroclock fouroldstyle foursans foursansinv foursuperior frac12
frac13 frac14 frac15 frac16 frac18 frac23 frac25 frac34 frac35 frac38 frac45 frac56 frac58 frac78
fraction franc frasl frown frownface Fsmall g gamma gammad gbreve gcaron gcedil gcirc gcircumflex
gcommaaccent gcy gdot gdotaccent ge gel gemini germandbls ges Gg ggr gimel gjcy gl gnE gnsim gradient
grave gravecomb Gravesmall greater greaterequal gsdot gsim Gsmall gt guillemotleft guillemotright
guilsinglleft guilsinglright gvnE h H18533 H18543 H18551 H22073 hairsp hamilt handhalt handok handptdwn
handptleft handptright handptup handv handwrite handwriteleft hardcy harddisk harr harrw hbar hcirc
hcircumflex head2down head2left head2right head2up heart hearts hellip hexstar2 hookabovecomb horbar
hourglass house Hsmall hstrok hungarumlaut Hungarumlautsmall hybull hyphen hypheninferior hyphensuperior
i iacgr iacute Iacutesmall ibreve icirc icircumflex Icircumflexsmall icy idiagr idieresis Idieresissmall
idigr Idot Idotaccent iecy iexcl iff Ifraktur igr igrave Igravesmall ij ijlig imacr imacron image incare
infin infinity inodot int intcal integral integralbt integralex integraltp intersection invbullet
invcircle invsmileface iocy iogon iogonek iota iotadieresis iotadieresistonos iotatonos iquest isin
Ismall isuperior itilde iukcy iuml j jcirc jcircumflex jcy jsercy Jsmall jukcy k kappa kappav kcedil
kcommaaccent kcy keyboard kgr kgreen kgreenlandic khcy khgr kjcy Ksmall l lAarr lacute lagran lambda lang
laquo larr larr2 larrhk larrlp larrtl lcaron lcedil lceil lcommaaccent lcub lcy ldot ldquo ldquor le
leafccwne leafccwnw leafccwse leafccwsw leafne leafnw leafse leafsw leg leo les less lessequal lfblock
lfloor lg lgr lhard lharu lhblk libra lira ljcy ll lmidot lnE lnsim logicaland logicalnot logicalor longs
lowast lowbar loz lozenge lozenge4 lozenge6 lozf lpar lrarr2 lrhar2 lsaquo lsh lsim lslash Lslashsmall
Lsmall lsqb lsquo lsquor lstrok lsuperior lt lthree ltimes ltri ltrie ltrif ltshade lvnE m macr macron
Macronsmall mailboxflagdwn mailboxflagup mailbxopnflgdwn mailbxopnflgup male malt map marker mcy mdash
mgr micro mid middot minus minusb minute mldr mnplus models mouse2button Msmall msuperior mu multiply
mumap musicalnote musicalnotedbl n nabla nacute nap napos napostrophe natur nbsp ncaron ncedil
ncommaaccent ncong ncy ndash ne nearr nequiv neutralface nexist nge nges ngr ngt nharr ni nine
nineinferior nineoclock nineoldstyle ninesans ninesansinv ninesuperior njcy nlarr nldr nle nles nlt nltri
nltrie nmid not notelement notequal notin notsubset npar npr npre nrarr nrtri nrtrie nsc nsce nsim nsime
Nsmall nsub nsube nsup nsupe nsuperior ntilde Ntildesmall nu num numbersign numero numsp nvdash nwarr o
oacgr oacute Oacutesmall oast obreve ocir ocirc ocircumflex Ocircumflexsmall octastar2 octastar4 ocy
odash odblac odieresis Odieresissmall odot oe oelig OEsmall ogon ogonek Ogoneksmall ogr ograve
Ogravesmall ohacgr ohgr ohm ohorn ohungarumlaut olarr oline om omacr omacron omega omega1 omegatonos
omicron omicrontonos ominus one onedotenleader oneeighth onefitted onehalf oneinferior oneoclock
oneoldstyle onequarter onesans onesansinv onesuperior onethird openbullet oplus or orarr order ordf
ordfeminine ordm ordmasculine orthogonal oS oslash oslashacute Oslashsmall Osmall osol osuperior otilde
Otildesmall otimes ouml overline p par para paragraph parenleft parenleftbt parenleftex parenleftinferior
parenleftsuperior parenlefttp parenright parenrightbt parenrightex parenrightinferior parenrightsuperior
parenrighttp part partialdiff pc pcy pencil pennant pentastar2 percent percnt period periodcentered
periodinferior periodsuperior permil perp perpendicular perthousand peseta pgr phgr phi phi1 phis phiv
phmmat phone pi pisces piv planck plus plusb plusdo plusminus plusmn pound pr prescription prime prnsim
prod product prop propersubset propersuperset proportional prsim psgr psi Psmall puncsp q Qsmall query
quest question questiondown questiondownsmall questionsmall quiltsquare2 quiltsquare2inv quot quotedbl
quotedblbase quotedblleft quotedbllftbld quotedblright quotedblrtbld quoteleft quotereversed quoteright
quotesinglbase quotesingle r rAarr racute radic radical radicalex rang raquo rarr rarr2 rarrhk rarrlp
rarrtl rarrw rcaron rcedil rceil rcommaaccent rcub rcy rdquo rdquor readingglasses real rect reflexsubset
reflexsuperset reg registercircle registered registersans registerserif registersquare revlogicalnot
rfloor Rfraktur rgr rhard rharu rho rhombus4 rhombus6 rhov ring ring2 ring4 ring6 ringbutton2 Ringsmall
rlarr2 rlhar2 rosette rosettesolid rpar rsaquo rsh Rsmall rsqb rsquo rsquor rsuperior rtblock rthree
rtimes rtri rtrie rtrif rupiah rx s sacute saggitarius samalg sbquo sc scaron Scaronsmall sccue scedil
scedilla scirc scircumflex scissors scissorscutting scnsim scommaaccent scorpio scsim scy sdot sdotb
second sect section semi semicolon setmn seven seveneighths seveninferior sevenoclock sevenoldstyle
sevensans sevensansinv sevensuperior sextile SF010000 SF020000 SF030000 SF040000 SF050000 SF060000
SF070000 SF080000 SF090000 SF100000 SF110000 SF190000 SF200000 SF210000 SF220000 SF230000 SF240000
SF250000 SF260000 SF270000 SF280000 SF360000 SF370000 SF380000 SF390000 SF400000 SF410000 SF420000
SF430000 SF440000 SF450000 SF460000 SF470000 SF480000 SF490000 SF500000 SF510000 SF520000 SF530000
SF540000 sfgr sgr shade sharp shchcy shcy shy sigma sigma1 sigmav sim sime similar six sixinferior
sixoclock sixoldstyle sixsans sixsansinv sixsuperior skullcrossbones slash smile smileface snowflake
softcy sol space spade spades sqcap sqcup sqsub sqsube sqsup sqsupe squ square square2 square4 square6
squf Ssmall sstarf ssuperior star starf starofdavid starshadow sterling sub sube subnE suchthat sum
summation sun sung sunshine sup sup1 sup2 sup3 supe supnE szlig t tapereel target tau taurus tbar tcaron
tcedil tcommaaccent tcy tdot telephonesolid telhandsetcirc telrec tenoclock tensans tensansinv tgr there4
therefore theta theta1 thetas thetasym thetav thgr thinsp thkap thksim thorn Thornsmall three
threeeighths threeinferior threeoclock threeoldstyle threequarters threequartersemdash threesans
threesansinv threesuperior thumbdown thumbup tilde tildecomb Tildesmall times timesb tonos top tprime
trade trademark trademarksans trademarkserif triagdn triaglf triagrt triagup trie tristar2 tscy tshcy
Tsmall tstrok tsuperior twelveoclock twixt two twodotenleader twoinferior twooclock twooldstyle twosans
twosansinv twosuperior twothirds u uacgr uacute Uacutesmall uarr uarr2 ubrcy ubreve ucirc ucircumflex
Ucircumflexsmall ucy udblac udiagr udieresis Udieresissmall udigr ugr ugrave Ugravesmall uharl uharr
uhblk uhorn uhungarumlaut ulcorn ulcrop umacr umacron uml underscore underscoredbl union universal uogon
uogonek upblock uplus upsi upsih upsilon Upsilon1 upsilondieresis upsilondieresistonos upsilontonos
urcorn urcrop uring Usmall utilde utri utrif uuml v varr vcy vdash veebar vellip verbar vineleafboldne
vineleafboldnw vineleafboldse vineleafboldsw virgo vltri vprime vprop vrtri Vsmall Vvdash w wacute wcirc
wcircumflex wdieresis wedgeq weierp weierstrass wgrave wheel windowslogo wreath Wsmall x xcirc xdtri xgr
xi xmarkbld xrhombus Xsmall xutri y yacute Yacutesmall yacy ycirc ycircumflex ycy ydieresis
Ydieresissmall yen ygrave yicy yinyang Ysmall yucy yuml z zacute zcaron Zcaronsmall zcy zdot zdotaccent
zero zeroinferior zerooldstyle zerosans zerosansinv zerosuperior zeta zgr zhcy Zsmall zwnj

B<Please Note:> You may notice that apart from the 'AGL/WGL4', names from the XML, (X)HTML and SGML
specification sets have been included to enable interoperability towards PDF.

=cut
