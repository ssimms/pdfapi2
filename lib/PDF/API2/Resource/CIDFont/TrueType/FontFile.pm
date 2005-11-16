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
package PDF::API2::Resource::CIDFont::TrueType::FontFile;

BEGIN {

    use utf8;
    use Encode qw(:all);
    use PDF::API2::Util;
    use PDF::API2::IOString;

    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Basic::PDF::Dict;
    use PDF::API2::Basic::TTF::Font;
    use Data::Dumper;
    use POSIX;

    use vars qw( @ISA $VERSION $cmap );

    @ISA = qw( PDF::API2::Basic::PDF::Dict );

    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$
    $cmap={};
}
no warnings qw[ recursion uninitialized ];


sub _look_for_cmap ($) {
    my $fname=lc(shift);
    $fname=~s/[^a-z0-9]+//gi;
    return({%{$cmap->{$fname}}}) if(defined $cmap->{$fname});
    eval "require PDF::API2::Resource::CIDFont::CMap::$fname; ";
    unless($@){
        return({%{$cmap->{$fname}}});
    } else {
        die "requested cmap '$fname' not installed ";
    }
}

sub readcffindex
{
    my ($fh,$off,$buf)=@_;
    my @idx=();
    my $index=[];
    seek($fh,$off,0);
    read($fh,$buf,3);
    my ($count,$offsize)=unpack('nC',$buf);
    foreach (0..$count)
    {
        read($fh,$buf,$offsize);
        $buf=substr("\x00\x00\x00$buf",-4,4);
        my $id=unpack('N',$buf);
        push @idx,$id;
    }
    my $dataoff=tell($fh)-1;

    foreach my $i (0..$count-1)
    {
        push @{$index},{ 'OFF' => $dataoff+$idx[$i], 'LEN' => $idx[$i+1]-$idx[$i] };
    }
    return($index);
}

sub readcffdict
{
    my ($fh,$off,$len,$foff,$buf)=@_;
    my @idx=();
    my $dict={};
    seek($fh,$off,0);
    my @st=();
    while(tell($fh)<($off+$len))
    {
        read($fh,$buf,1);
        my $b0=unpack('C',$buf);
        my $v='';

        if($b0==12) # two byte commands
        {
            read($fh,$buf,1);
            my $b1=unpack('C',$buf);
            if($b1==0)
            {
                $dict->{Copyright}={ 'SID' => splice(@st,-1) };
            }
            elsif($b1==1)
            {
                $dict->{isFixedPitch}=splice(@st,-1);
            }
            elsif($b1==2)
            {
                $dict->{ItalicAngle}=splice(@st,-1);
            }
            elsif($b1==3)
            {
                $dict->{UnderlinePosition}=splice(@st,-1);
            }
            elsif($b1==4)
            {
                $dict->{UnderlineThickness}=splice(@st,-1);
            }
            elsif($b1==5)
            {
                $dict->{PaintType}=splice(@st,-1);
            }
            elsif($b1==6)
            {
                $dict->{CharstringType}=splice(@st,-1);
            }
            elsif($b1==7)
            {
                $dict->{FontMatrix}=[ splice(@st,-4) ];
            }
            elsif($b1==8)
            {
                $dict->{StrokeWidth}=splice(@st,-1);
            }
            elsif($b1==20)
            {
                $dict->{SyntheticBase}=splice(@st,-1);
            }
            elsif($b1==21)
            {
                $dict->{PostScript}={ 'SID' => splice(@st,-1) };
            }
            elsif($b1==22)
            {
                $dict->{BaseFontName}={ 'SID' => splice(@st,-1) };
            }
            elsif($b1==23)
            {
                $dict->{BaseFontBlend}=[ splice(@st,0) ];
            }
            elsif($b1==24)
            {
                $dict->{MultipleMaster}=[ splice(@st,0) ];
            }
            elsif($b1==25)
            {
                $dict->{BlendAxisTypes}=[ splice(@st,0) ];
            }
            elsif($b1==30)
            {
                $dict->{ROS}=[ splice(@st,-3) ];
            }
            elsif($b1==31)
            {
                $dict->{CIDFontVersion}=splice(@st,-1);
            }
            elsif($b1==32)
            {
                $dict->{CIDFontRevision}=splice(@st,-1);
            }
            elsif($b1==33)
            {
                $dict->{CIDFontType}=splice(@st,-1);
            }
            elsif($b1==34)
            {
                $dict->{CIDCount}=splice(@st,-1);
            }
            elsif($b1==35)
            {
                $dict->{UIDBase}=splice(@st,-1);
            }
            elsif($b1==36)
            {
                $dict->{FDArray}={ 'OFF' => $foff+splice(@st,-1) };
            }
            elsif($b1==37)
            {
                $dict->{FDSelect}={ 'OFF' => $foff+splice(@st,-1) };
            }
            elsif($b1==38)
            {
                $dict->{FontName}={ 'SID' => splice(@st,-1) };
            }
            elsif($b1==39)
            {
                $dict->{Chameleon}=splice(@st,-1);
            }
            next;
        }
        elsif($b0<28) # commands
        {
            if($b0==0)
            {
                $dict->{Version}={ 'SID' => splice(@st,-1) };
            }
            elsif($b0==1)
            {
                $dict->{Notice}={ 'SID' => splice(@st,-1) };
            }
            elsif($b0==2)
            {
                $dict->{FullName}={ 'SID' => splice(@st,-1) };
            }
            elsif($b0==3)
            {
                $dict->{FamilyName}={ 'SID' => splice(@st,-1) };
            }
            elsif($b0==4)
            {
                $dict->{Weight}={ 'SID' => splice(@st,-1) };
            }
            elsif($b0==5)
            {
                $dict->{FontBBX}=[ splice(@st,-4) ];
            }
            elsif($b0==13)
            {
                $dict->{UniqueID}=splice(@st,-1);
            }
            elsif($b0==14)
            {
                $dict->{XUID}=[splice(@st,0)];
            }
            elsif($b0==15)
            {
                $dict->{CharSet}={ 'OFF' => $foff+splice(@st,-1) };
            }
            elsif($b0==16)
            {
                $dict->{Encoding}={ 'OFF' => $foff+splice(@st,-1) };
            }
            elsif($b0==17)
            {
                $dict->{CharStrings}={ 'OFF' => $foff+splice(@st,-1) };
            }
            elsif($b0==18)
            {
                $dict->{Private}={ 'LEN' => splice(@st,-1), 'OFF' => $foff+splice(@st,-1) };
            }
            next;
        }
        elsif($b0==28) # int16
        {
            read($fh,$buf,2);
            $v=unpack('n',$buf);
            $v=-(0x10000-$v) if($v>0x7fff);
        }
        elsif($b0==29) # int32
        {
            read($fh,$buf,4);
            $v=unpack('N',$buf);
            $v=-$v+0xffffffff+1 if($v>0x7fffffff);
        }
        elsif($b0==30) # float
        {
            $e=1;
            while($e)
            {
                read($fh,$buf,1);
                $v0=unpack('C',$buf);
                foreach my $m ($v0>>8,$v0&0xf)
                {
                    if($m<10)
                    {
                        $v.=$m;
                    }
                    elsif($m==10)
                    {
                        $v.='.';
                    }
                    elsif($m==11)
                    {
                        $v.='E+';
                    }
                    elsif($m==12)
                    {
                        $v.='E-';
                    }
                    elsif($m==14)
                    {
                        $v.='-';
                    }
                    elsif($m==15)
                    {
                        $e=0;
                        last;
                    }
                }
            }
        }
        elsif($b0==31) # command
        {
            $v="c=$b0";
            next;
        }
        elsif($b0<247) # 1 byte signed
        {
            $v=$b0-139;
        }
        elsif($b0<251) # 2 byte plus
        {
            read($fh,$buf,1);
            $v=unpack('C',$buf);
            $v=($b0-247)*256+($v+108);
        }
        elsif($b0<255) # 2 byte minus
        {
            read($fh,$buf,1);
            $v=unpack('C',$buf);
            $v=-($b0-251)*256-$v-108;
        }
        push @st,$v;
    }   
    
    return($dict);
}

sub read_kern_table
{
    my $font=shift @_;
    my $upem=shift @_;
    my $self=shift @_;
    my $fh=$font->{' INFILE'};
    my $data=undef;

    return(undef) unless($font->{kern});

    my $buf = undef;

    seek($fh,$font->{kern}->{' OFFSET'}+2,0);
    read($fh,$buf, 2);
    my $num=unpack('n',$buf);
    foreach my $n (1..$num)
    {
        read($fh, $buf, 6);
        my ($ver, $len, $cov) = unpack('n3', $buf);
        $len-=6;
        my $fmt=$cov>>8;
        if($fmt==0)
        {
            $data||={};
            read($fh, $buf, 8);
            my $nc = unpack('n', $buf);
            foreach (1..$nc)
            {
                read($fh, $buf, 6);
                my ($idx1,$idx2,$val)=unpack('nnn',$buf);
                $val-=65536 if($val>32767);
                $val= $val < 0 ? -floor($val*1000/$upem) : -ceil($val*1000/$upem);
                if($val != 0)
                {
                    $data->{"$idx1:$idx2"}=$val;
                    $data->{$self->data->{g2n}->[$idx1].':'.$self->data->{g2n}->[$idx2]}=$val;
                }
            }
        }
        elsif($fmt==2)
        {
            read($fh, $buf, $len);
        }
        else
        {
            read($fh, $buf, $len);
        }
    }
    ##print Dumper($data);
    return($data);
}

sub readcffstructs
{
    my $font=shift @_;
    my $fh=$font->{' INFILE'};
    my $data={};
    # read CFF table
    seek($fh,$font->{'CFF '}->{' OFFSET'},0);
    read($fh,$buf, 4);
    my ($cffmajor,$cffminor,$cffheadsize,$cffglobaloffsize)=unpack('C4',$buf);

    $data->{name}=readcffindex($fh,$font->{'CFF '}->{' OFFSET'}+$cffheadsize);
    foreach my $dict (@{$data->{name}})
    {
        seek($fh,$dict->{OFF},0);
        read($fh,$dict->{VAL},$dict->{LEN});
    }

    $data->{topdict}=readcffindex($fh,$data->{name}->[-1]->{OFF}+$data->{name}->[-1]->{LEN});
    foreach my $dict (@{$data->{topdict}})
    {
        $dict->{VAL}=readcffdict($fh,$dict->{OFF},$dict->{LEN},$font->{'CFF '}->{' OFFSET'});
    }

    $data->{string}=readcffindex($fh,$data->{topdict}->[-1]->{OFF}+$data->{topdict}->[-1]->{LEN});
    foreach my $dict (@{$data->{string}})
    {
        seek($fh,$dict->{OFF},0);
        read($fh,$dict->{VAL},$dict->{LEN});
    }
    push @{$data->{string}},{ 'VAL' => '001.000' };
    push @{$data->{string}},{ 'VAL' => '001.001' };
    push @{$data->{string}},{ 'VAL' => '001.002' };
    push @{$data->{string}},{ 'VAL' => '001.003' };
    push @{$data->{string}},{ 'VAL' => 'Black' };
    push @{$data->{string}},{ 'VAL' => 'Bold' };
    push @{$data->{string}},{ 'VAL' => 'Book' };
    push @{$data->{string}},{ 'VAL' => 'Light' };
    push @{$data->{string}},{ 'VAL' => 'Medium' };
    push @{$data->{string}},{ 'VAL' => 'Regular' };
    push @{$data->{string}},{ 'VAL' => 'Roman' };
    push @{$data->{string}},{ 'VAL' => 'Semibold' };

    foreach my $dict (@{$data->{topdict}})
    {
        foreach my $k (keys %{$dict->{VAL}})
        {
            my $dt=$dict->{VAL}->{$k};
            if($k eq 'ROS')
            {
                $dict->{VAL}->{$k}->[0]=$data->{string}->[$dict->{VAL}->{$k}->[0]-391]->{VAL};
                $dict->{VAL}->{$k}->[1]=$data->{string}->[$dict->{VAL}->{$k}->[1]-391]->{VAL};
                next;
            }
            next unless(ref($dt) eq 'HASH' && defined $dt->{SID});
            if($dt->{SID}>=379)
            {
                $dict->{VAL}->{$k}=$data->{string}->[$dt->{SID}-391]->{VAL};
            }
        }
    }
    my $dict={};
    foreach my $k (qw[ CIDCount CIDFontVersion FamilyName FontBBX FullName ROS Weight XUID ])
    {
        $dict->{$k}=$data->{topdict}->[0]->{VAL}->{$k} if(defined $data->{topdict}->[0]->{VAL}->{$k});
    }
    return($dict);
}

sub new {
    my ($class,$pdf,$file,%opts)=@_;
    my $data={};

    die "cannot find font '$file' ..." unless(-f $file);
    my $font=PDF::API2::Basic::TTF::Font->open($file);
    $data->{obj}=$font;

    $class = ref $class if ref $class;
    $self=$class->SUPER::new();

    $self->{Filter}=PDFArray(PDFName('FlateDecode'));
    $self->{' font'}=$font;
    $self->{' data'}=$data;

    $data->{iscff} = (defined $font->{'CFF '}) ? 1 : 0;

    $self->{Subtype}=PDFName('Type1C') if($data->{iscff});

    $data->{fontfamily}=$font->{'name'}->read->find_name(1);
    $data->{fontname}=$font->{'name'}->read->find_name(4);

    $font->{'OS/2'}->read;
    my @stretch=qw[
        Normal
        UltraCondensed
        ExtraCondensed
        Condensed
        SemiCondensed
        Normal
        SemiExpanded
        Expanded
        ExtraExpanded
        UltraExpanded
    ];
    $data->{fontstretch}=$stretch[$font->{'OS/2'}->{usWidthClass}] || 'Normal';

    $data->{fontweight}=$font->{'OS/2'}->{usWeightClass};
    
    $data->{panose}=pack('n',$font->{'OS/2'}->{sFamilyClass});

    foreach my $p (qw[bFamilyType bSerifStyle bWeight bProportion bContrast bStrokeVariation bArmStyle bLetterform bMidline bXheight])
    {
        $data->{panose}.=pack('C',$font->{'OS/2'}->{$p});
    }
    
    $data->{apiname}=$data->{fontname};
    $data->{apiname}=~s/[^A-Za-z0-9]+/ /og;
    $data->{apiname}=join('',map { $_=~s/[^A-Za-z0-9]+//og; $_=ucfirst(lc(substr($_,0,2))); $_; } split(/\s+/,$data->{apiname}));
    $data->{fontname}=~s/[\x00-\x1f\s]//og;

    $data->{altname}=$font->{'name'}->find_name(1);
    $data->{altname}=~s/[\x00-\x1f\s]//og;

    $data->{subname}=$font->{'name'}->find_name(2);
    $data->{subname}=~s/[\x00-\x1f\s]//og;

    $font->{cmap}->read->find_ms($opts{-isocmap}||0);
    if(defined $font->{cmap}->find_ms) 
    {
        $data->{issymbol} = ($font->{cmap}->find_ms->{'Platform'} == 3 && $font->{cmap}->read->find_ms->{'Encoding'} == 0) || 0;
    } 
    else 
    {
        $data->{issymbol} = 0;
    }

    $data->{upem}=$font->{'head'}->read->{'unitsPerEm'};

    $data->{fontbbox}=[
        int($font->{'head'}->{'xMin'} * 1000 / $data->{upem}),
        int($font->{'head'}->{'yMin'} * 1000 / $data->{upem}),
        int($font->{'head'}->{'xMax'} * 1000 / $data->{upem}),
        int($font->{'head'}->{'yMax'} * 1000 / $data->{upem})
    ];

    $data->{stemv}=0;
    $data->{stemh}=0;

    $data->{missingwidth}=int($font->{'hhea'}->read->{'advanceWidthMax'} * 1000 / $data->{upem}) || 1000;
    $data->{maxwidth}=int($font->{'hhea'}->{'advanceWidthMax'} * 1000 / $data->{upem});
    $data->{ascender}=int($font->{'hhea'}->read->{'Ascender'} * 1000 / $data->{upem});
    $data->{descender}=int($font->{'hhea'}{'Descender'} * 1000 / $data->{upem});

    $data->{flags} = 0;
    $data->{flags} |= 1 if ($font->{'OS/2'}->read->{'bProportion'} == 9);
    $data->{flags} |= 2 unless ($font->{'OS/2'}{'bSerifStyle'} > 10 && $font->{'OS/2'}{'bSerifStyle'} < 14);
    $data->{flags} |= 8 if ($font->{'OS/2'}{'bFamilyType'} == 2);
    $data->{flags} |= 32; # if ($font->{'OS/2'}{'bFamilyType'} > 3);
    $data->{flags} |= 64 if ($font->{'OS/2'}{'bLetterform'} > 8);;

    $data->{capheight}=$font->{'OS/2'}->{CapHeight} || int($data->{fontbbox}->[3]*0.8);
    $data->{xheight}=$font->{'OS/2'}->{xHeight} || int($data->{fontbbox}->[3]*0.4);

    if($data->{issymbol}) 
    {
        $data->{e2u}=[0xf000 .. 0xf0ff];
    } 
    else 
    {
        $data->{e2u}=[ unpack('U*',decode('cp1252', pack('C*',0..255))) ];
    }

    if(($font->{'post'}->read->{FormatType} == 3) && defined($font->{cmap}->read->find_ms)) 
    {
        $data->{g2n} = [];
        foreach my $u (sort {$a<=>$b} keys %{$font->{cmap}->read->find_ms->{val}}) 
        {
            my $n=nameByUni($u);
            $data->{g2n}->[$font->{cmap}->read->find_ms->{val}->{$u}]=$n;
        }
    } 
    else 
    {
        $data->{g2n} = [ map { $_ || '.notdef' } @{$font->{'post'}->read->{'VAL'}} ];
    }

    $data->{italicangle}=$font->{'post'}->{italicAngle};
    $data->{isfixedpitch}=$font->{'post'}->{isFixedPitch};
    $data->{underlineposition}=$font->{'post'}->{underlinePosition};
    $data->{underlinethickness}=$font->{'post'}->{underlineThickness};

    if($self->iscff)
    {
        $data->{cff}=readcffstructs($font);
    }

    if(defined $data->{cff}->{ROS})
    {
        my %cffcmap=( 
            'Adobe:Japan1'=>'japanese',
            'Adobe:Korea1'=>'korean',
            'Adobe:CNS1'=>'traditional',
            'Adobe:GB1'=>'simplified',
        );
        my $ccmap=_look_for_cmap($cffcmap{"$data->{cff}->{ROS}->[0]:$data->{cff}->{ROS}->[1]"});
        $data->{u2g}=$ccmap->{u2g};
        $data->{g2u}=$ccmap->{g2u};
    }
    else
    {
        $data->{u2g} = {};

        my $gmap=$font->{cmap}->read->find_ms->{val};
        foreach my $u (sort {$a<=>$b} keys %{$gmap}) 
        {
            my $uni=$u||0;
            $data->{u2g}->{$uni}=$gmap->{$uni};
        }
        $data->{g2u}=[ map { $_ || 0 } $font->{'cmap'}->read->reverse ];
    }

    if($data->{issymbol}) 
    {
        map { $data->{u2g}->{$_} ||= $font->{'cmap'}->read->ms_lookup($_) } (0xf000 .. 0xf0ff);
        map { $data->{u2g}->{$_ & 0xff} ||= $font->{'cmap'}->read->ms_lookup($_) } (0xf000 .. 0xf0ff);
    }

    $data->{e2n}=[ map { $data->{g2n}->[$data->{u2g}->{$_} || 0] || '.notdef' } @{$data->{e2u}} ];

    $data->{e2g}=[ map { $data->{u2g}->{$_ || 0} || 0 } @{$data->{e2u}} ];
    $data->{u2e}={};
    foreach my $n (reverse 0..255) 
    {
        $data->{u2e}->{$data->{e2u}->[$n]}=$n unless(defined $data->{u2e}->{$data->{e2u}->[$n]});
    }

    $data->{u2n}={ map { $data->{g2u}->[$_] => $data->{g2n}->[$_] } (0 .. (scalar @{$data->{g2u}} -1)) };

    $data->{wx}=[];
    foreach my $w (0..(scalar @{$data->{g2u}}-1)) 
    {
        $data->{wx}->[$w]=int($font->{'hmtx'}->read->{'advance'}[$w]*1000/$data->{upem})
            || $data->{missingwidth};
    }
    
    $data->{kern}=read_kern_table($font,$data->{upem},$self);
    delete $data->{kern} unless(defined $data->{kern});
    
    return($self,$data);
}

sub font { return( $_[0]->{' font'} ); }
sub data { return( $_[0]->{' data'} ); }
sub iscff { return( $_[0]->data->{iscff} ); }

sub haveKernPairs { return( $_[0]->data->{kern} ? 1 : 0 ); }

sub kernPairCid
{
    my ($self, $i1, $i2) = @_;
    return(0) if($i1==0 || $i2==0);
    return($self->data->{kern}->{"$i1:$i2"} || 0);
}

sub subsetByCId 
{
    my $self = shift @_;
    my $g = shift @_;
    $self->data->{subset}=1;
    vec($self->data->{subvec},$g,1)=1;
    return if($self->iscff);
    if(defined $self->font->{loca}->read->{glyphs}->[$g]) {
        $self->font->{loca}->read->{glyphs}->[$g]->read;
        map { vec($self->data->{subvec},$_,1)=1; } $self->font->{loca}->{glyphs}->[$g]->get_refs;
    }
}

sub subvec {
    my $self = shift @_;
    return(1) if($self->iscff);
    my $g = shift @_;
    return(vec($self->data->{subvec},$g,1));
}

sub glyphNum { return ( $_[0]->font->{'maxp'}->read->{'numGlyphs'} ); }

sub outobjdeep {
    my ($self, $fh, $pdf, %opts) = @_;

    return $self->SUPER::outobjdeep($fh, $pdf) if defined $opts{'passthru'};

    my $f = $self->font;

    if($self->iscff) {
        $f->{'CFF '}->read_dat;
        $self->{' stream'} = $f->{'CFF '}->{' dat'};
    } else {
        if ($self->data->{subset} && !$self->data->{nosubset}) {
            $f->{'glyf'}->read;
            for (my $i = 0; $i < $self->glyphNum; $i++) {
                next if($self->subvec($i));
                $f->{'loca'}{'glyphs'}->[$i] = undef;
            #    print STDERR "$i,";
            }
        }

        $self->{' stream'} = "";
        my $ffh = PDF::API2::IOString->new(\$self->{' stream'});
        $f->out($ffh, 'cmap', 'cvt ', 'fpgm', 'glyf', 'head', 'hhea', 'hmtx', 'loca', 'maxp', 'prep');
        $self->{'Length1'}=PDFNum(length($self->{' stream'}));
    }

    $self->SUPER::outobjdeep($fh, $pdf, %opts);
}


1;

__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 2.0  2005/11/16 02:18:14  areibens
    revision workaround for SF cvs import not to screw up CPAN

    Revision 1.2  2005/11/16 01:27:50  areibens
    genesis2

    Revision 1.1  2005/11/16 01:19:26  areibens
    genesis

    Revision 1.20  2005/11/02 18:21:29  fredo
    added kerning lookup strategy

    Revision 1.19  2005/10/22 19:56:55  fredo
    added mor agressive kerning strategy

    Revision 1.18  2005/10/20 21:05:14  fredo
    added handling of optional kerning

    Revision 1.17  2005/09/12 16:52:59  fredo
    added -isocmap option; fixed cmap handling for fallback entries

    Revision 1.16  2005/06/17 19:44:03  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.15  2005/06/17 18:53:34  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.14  2005/03/20 23:24:23  fredo
    added workaround for broken truetype naming-tables

    Revision 1.13  2005/03/14 22:01:27  fredo
    upd 2005

    Revision 1.12  2005/01/21 10:00:43  fredo
    added handling of nosubset option

    Revision 1.11  2004/12/29 01:12:27  fredo
    fixed no warn for recursion

    Revision 1.10  2004/12/16 00:30:53  fredo
    added no warn for recursion

    Revision 1.9  2004/11/22 21:07:55  fredo
    fixed multibyte-encoding support to work consistently acress cjk/ttf/otf

    Revision 1.8  2004/11/22 02:25:05  fredo
    added advanced attributes

    Revision 1.7  2004/08/25 03:03:27  fredo
    removed fuss

    Revision 1.6  2004/06/15 09:14:52  fredo
    removed cr+lf

    Revision 1.5  2004/06/07 19:44:43  fredo
    cleaned out cr+lf for lf

    Revision 1.4  2004/04/20 09:46:25  fredo
    added glyph->read fix for subset-vector

    Revision 1.3  2003/12/08 13:06:01  Administrator
    corrected to proper licencing statement

    Revision 1.2  2003/11/30 17:31:41  Administrator
    merged into default

    Revision 1.1.1.1.2.2  2003/11/30 16:57:02  Administrator
    merged into default

    Revision 1.1.1.1.2.1  2003/11/30 14:16:39  Administrator
    added CVS id/log


=cut
