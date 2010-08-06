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
#   THIS LIBRARY IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR
#   MODIFY IT UNDER THE TERMS OF THE GNU LESSER GENERAL PUBLIC
#   LICENSE AS PUBLISHED BY THE FREE SOFTWARE FOUNDATION; EITHER
#   VERSION 2 OF THE LICENSE, OR (AT YOUR OPTION) ANY LATER VERSION.
#
#   THIS FILE IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL,
#   AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
#   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
#   FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
#   SHALL THE AUTHORS AND COPYRIGHT HOLDERS AND THEIR CONTRIBUTORS 
#   BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
#   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
#   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
#   OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
#   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
#   STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
#   ARISING IN ANY WAY OUT OF THE USE OF THIS FILE, EVEN IF 
#   ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#   SEE THE GNU LESSER GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
#   YOU SHOULD HAVE RECEIVED A COPY OF THE GNU LESSER GENERAL PUBLIC
#   LICENSE ALONG WITH THIS LIBRARY; IF NOT, WRITE TO THE
#   FREE SOFTWARE FOUNDATION, INC., 59 TEMPLE PLACE - SUITE 330,
#   BOSTON, MA 02111-1307, USA.
#
#   $Id$
#
#=======================================================================
package PDF::API2::Resource::Font::neTrueType;

=head1 NAME

PDF::API2::Resource::Font::neTrueType - Module for using 8bit nonembedded truetype Fonts.

=head1 SYNOPSIS

    #
    use PDF::API2;
    #
    $pdf = PDF::API2->new;
    $cft = $pdf->nettfont('Times-Roman.ttf', -encode => 'latin1');
    #

=head1 METHODS

=over 4

=cut

BEGIN {

    use utf8;
    use Encode qw(:all);

    use File::Basename;

    use vars qw( @ISA $fonts $alias $subs $encodings $VERSION );
    use PDF::API2::Resource::Font;
    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;

    @ISA=qw(PDF::API2::Resource::Font);

    ( $VERSION ) = '1.002';

}
no warnings qw[ deprecated recursion uninitialized ];

=item $font = PDF::API2::Resource::Font::neTrueType->new $pdf, $fontfile, %options

Returns a corefont object.

=cut

=pod

Valid %options are:

I<-encode>
... changes the encoding of the font from its default.
See I<perl's Encode> for the supported values.

I<-pdfname> ... changes the reference-name of the font from its default.
The reference-name is normally generated automatically and can be
retrived via $pdfname=$font->name.

=cut

sub unpack_fixed
{
    my ($dat) = @_;
    my ($res, $frac) = unpack("nn", $dat);
    $res -= 65536 if $res > 32767;
    $res += $frac / 65536.;
    return($res);
}

sub unpack_f2dot14
{
    my ($dat) = @_;
    my $res = unpack("n", $dat);
    my $frac = $res & 0x3fff;
    $res >>= 14;
    $res -= 4 if $res > 1;
    $res += $frac / 16384.;
    return($res);
}

sub unpack_long
{
    my ($dat) = @_;
    my $res = unpack("N", $dat);
    $res -= (1 << 32) if ($res >= 1 << 31);
    return($res);
}

sub unpack_ulong
{
    my ($dat) = @_;
    my $res = unpack("N", $dat);
    return($res);
}

sub unpack_short
{
    my ($dat) = @_;
    my $res = unpack("n", $dat);
    $res -= 65536 if ($res >= 32768);
    return($res);
}

sub unpack_ushort
{
    my ($dat) = @_;
    my $res = unpack("n", $dat);
    return($res);
}

sub read_name_table
{
    my ($data, $fh, $num, $stroff, $buf) = @_;
    # read name table
    seek($fh,$data->{name}->{OFF},0);

    read($fh,$buf, 6);

    ($num, $stroff) = unpack("x2nn", $buf);

    $data->{name}->{ARR}=[];

    for (my $i = 0; $i < $num; $i++)
    {
        read($fh,$buf, 12);
        my ($pid, $eid, $lid, $nid, $len, $off) = unpack("n6", $buf);
        push @{$data->{name}->{ARR}},[$pid, $eid, $lid, $nid, $len, $off];
    }

    foreach my $arr ( @{$data->{name}->{ARR}} ) {
        my ($pid, $eid, $lid, $nid, $len, $off) = @{$arr};
        seek($fh,$data->{name}->{OFF} + $stroff + $off, 0);
        read($fh, $buf, $len);

        if ($pid == 0 || $pid == 3 || ($pid == 2 && $eid == 1))
            { $buf = pack('C*',map { $_>255 ? 20 : $_ } unpack('n*',$buf)); }

        $data->{name}->{strings}[$nid][$pid][$eid]{$lid} = $buf;
    }
}

sub read_os2_table
{
    my ($data, $fh, $buf) = @_;

    # read OS/2 table
    seek($fh,$data->{'OS/2'}->{OFF},0);
    read($fh,$buf, 2);
    my $os2ver=unpack_ushort($buf);

    seek($fh,$data->{'OS/2'}->{OFF}+4,0);
    read($fh,$buf, 4);
    ($data->{V}->{usWeightClass},$data->{V}->{usWidthClass})=unpack('nn',$buf);

    seek($fh,$data->{'OS/2'}->{OFF}+30,0);
    read($fh,$buf, 12);
    $data->{V}->{panoseHex}=unpack('H*',$buf);
    $data->{V}->{panose}=$buf;
	($data->{V}->{sFamilyClass}, $data->{V}->{bFamilyType}, $data->{V}->{bSerifStyle}, $data->{V}->{bWeight},
		$data->{V}->{bProportion}, $data->{V}->{bContrast}, $data->{V}->{bStrokeVariation}, $data->{V}->{bArmStyle},
		$data->{V}->{bLetterform}, $data->{V}->{bMidline}, $data->{V}->{bXheight}) = unpack('nC*',$buf);
		
	$data->{V}->{flags} = 0;
    $data->{V}->{flags} |= 1 if ($data->{V}->{'bProportion'} == 9);
    $data->{V}->{flags} |= 2 unless ($data->{V}->{'bSerifStyle'} > 10 && $data->{V}->{'bSerifStyle'} < 14);
    $data->{V}->{flags} |= 8 if ($data->{V}->{'bFamilyType'} == 2);
    $data->{V}->{flags} |= 32; # if ($data->{V}->{'bFamilyType'} > 3);
    $data->{V}->{flags} |= 64 if ($data->{V}->{'bLetterform'} > 8);
    
    seek($fh,$data->{'OS/2'}->{OFF}+42,0);
    read($fh,$buf, 16);
    $data->{V}->{ulUnicodeRange}=[ unpack('NNNN',$buf) ]; 
    my @ulCodePageRange=(); 

    if($os2ver>0) {
        seek($fh,$data->{'OS/2'}->{OFF}+78,0);
        read($fh,$buf, 8);
        $data->{V}->{ulCodePageRange}=[ unpack('NN',$buf) ]; 
        read($fh,$buf, 4);
        ($data->{V}->{xHeight},$data->{V}->{CapHeight})=unpack('nn',$buf); 
    }
}

sub read_head_table
{
    my ($data, $fh, $buf) = @_;

    seek($fh,$data->{'head'}->{OFF}+18,0);
    read($fh,$buf, 2);
    $data->{V}->{upem}=unpack_ushort($buf);
    $data->{V}->{upemf}=1000/$data->{V}->{upem};

    seek($fh,$data->{'head'}->{OFF}+36,0);
    read($fh,$buf, 2);
    $data->{V}->{xMin}=unpack_short($buf);
    read($fh,$buf, 2);
    $data->{V}->{yMin}=unpack_short($buf);
    read($fh,$buf, 2);
    $data->{V}->{xMax}=unpack_short($buf);
    read($fh,$buf, 2);
    $data->{V}->{yMax}=unpack_short($buf);

    $data->{V}->{fontbbox}=[
        int($data->{V}->{'xMin'} * $data->{V}->{upemf}),
        int($data->{V}->{'yMin'} * $data->{V}->{upemf}),
        int($data->{V}->{'xMax'} * $data->{V}->{upemf}),
        int($data->{V}->{'yMax'} * $data->{V}->{upemf})
    ];
    seek($fh,$data->{'head'}->{OFF}+50,0);
    read($fh,$data->{'head'}->{indexToLocFormat}, 2);
    $data->{'head'}->{indexToLocFormat}=unpack_ushort($data->{'head'}->{indexToLocFormat});
}

sub read_maxp_table
{
    my ($data, $fh, $buf) = @_;

    seek($fh,$data->{'maxp'}->{OFF}+4,0);
    read($fh,$buf, 2);
    $data->{V}->{numGlyphs}=unpack_ushort($buf);
    $data->{maxp}->{numGlyphs}=$data->{V}->{numGlyphs};
}

sub read_hhea_table
{
    my ($data, $fh, $buf) = @_;

    seek($fh,$data->{'hhea'}->{OFF}+4,0);
    read($fh,$buf, 2);
    $data->{V}->{ascender}=unpack_short($buf);

    read($fh,$buf, 2);
    $data->{V}->{descender}=unpack_short($buf);

    read($fh,$buf, 2);
    $data->{V}->{linegap}=unpack_short($buf);

    read($fh,$buf, 2);
    $data->{V}->{advancewidthmax}=unpack_short($buf);

    seek($fh,$data->{'hhea'}->{OFF}+34,0);
    read($fh,$buf, 2);
    $data->{V}->{numberOfHMetrics}=unpack_ushort($buf);
}

sub read_hmtx_table
{
    my ($data, $fh, $buf) = @_;

    seek($fh,$data->{'hmtx'}->{OFF},0);
    $data->{hmtx}->{wx}=[];

    foreach (1..$data->{V}->{numberOfHMetrics})
    {
        read($fh,$buf, 2);
        my $wx=int(unpack_ushort($buf)*1000/$data->{V}->{upem});
        push @{$data->{hmtx}->{wx}},$wx;
        read($fh,$buf, 2);
    }
    $data->{V}->{missingwidth}=$data->{hmtx}->{wx}->[-1];
}

sub read_cmap_table
{
    my ($data, $fh, $buf) = @_;
    my $cmap=$data->{cmap};
    seek($fh,$cmap->{OFF},0);

    read($fh,$buf,4);
    $cmap->{Num} = unpack("x2n", $buf);
    $cmap->{Tables} = [];
    
    foreach my $i (0..$cmap->{Num})
    {
        my $s = {};
        read($fh,$buf,8);
        ($s->{Platform}, $s->{Encoding}, $s->{LOC}) = (unpack("nnN", $buf));
        $s->{LOC} += $cmap->{OFF};
        push(@{$cmap->{Tables}}, $s);
    }

    foreach my $i (0..$cmap->{Num})
    {
        my $s = $cmap->{Tables}[$i];
        seek($fh,$s->{LOC}, 0);
        read($fh,$buf, 2);
        $s->{Format} = unpack("n", $buf);

        if ($s->{Format} == 0)
        {
            my $len;
            $fh->read($buf, 4);
            ($len, $s->{Ver}) = unpack('n2', $buf);
            $s->{val}={};
            foreach my $j (0..255)
            {
                read($fh,$buf, 1);
                $s->{val}->{$j}=unpack('C',$buf);
            } 
        } 
        elsif ($s->{Format} == 2)
        {
            # cjk euc ?
        } 
        elsif ($s->{Format} == 4)
        {
            my ($len,$count);
            $fh->read($buf, 12);
            ($len, $s->{Ver},$count) = unpack('n3', $buf);
            $count >>= 1;
            $s->{val}={};
            read($fh, $buf, $len - 14);
            foreach my $j (0..$count-1)
            {
                my $end = unpack("n", substr($buf, $j << 1, 2));
                my $start = unpack("n", substr($buf, ($j << 1) + ($count << 1) + 2, 2));
                my $delta = unpack("n", substr($buf, ($j << 1) + ($count << 2) + 2, 2));
                $delta -= 65536 if $delta > 32767;
                my $range = unpack("n", substr($buf, ($j << 1) + $count * 6 + 2, 2));
                foreach my $k ($start..$end)
                {
                    my $id=undef;
                    
                    if ($range == 0 || $range == 65535) # support the buggy FOG with its range=65535 for final segment
                    { 
                        $id = $k + $delta; 
                    }
                    else
                    { 
                        $id = unpack("n", 
                            substr($buf, ($j << 1) + $count * 6 +
                                2 + ($k - $start) * 2 + $range, 2)) + $delta; 
                    }
                    
                    $id -= 65536 if($id >= 65536);
                    $s->{val}->{$k} = $id if($id);
                }
            } 
        }
        elsif ($s->{Format} == 6)
        {
            my ($len,$start,$count);
            $fh->read($buf, 8);
            ($len, $s->{Ver},$start,$count) = unpack('n4', $buf);
            $s->{val}={};
            foreach my $j (0..$count-1)
            {
                read($fh,$buf, 2);
                $s->{val}->{$start+$j}=unpack('n',$buf);
            } 
        }
        elsif ($s->{Format} == 10)
        {
            my ($len,$start,$count);
            $fh->read($buf, 18);
            ($len, $s->{Ver},$start,$count) = unpack('x2N4', $buf);
            $s->{val}={};
            foreach my $j (0..$count-1)
            {
                read($fh,$buf, 2);
                $s->{val}->{$start+$j}=unpack('n',$buf);
            } 
        }
        elsif ($s->{Format} == 8 || $s->{Format} == 12)
        {
            my ($len,$count);
            $fh->read($buf, 10);
            ($len, $s->{Ver}) = unpack('x2N2', $buf);
            $s->{val}={};
            if($s->{Format} == 8)
            {
                read($fh, $buf, 8192);
                read($fh, $buf, 4);
            }
            else
            {
                read($fh, $buf, 4);
            }
            $count = unpack('N', $buf);
            foreach my $j (0..$count-1)
            {
                read($fh,$buf, 12);
                my ($start,$end,$cid)=unpack('N3',$buf);
                foreach my $k ($start..$end)
                {
                    $s->{val}->{$k}=$cid+$k-$start;
                } 
            } 
        }
    }

    my $alt;
    foreach my $s (@{$cmap->{Tables}})
    {
        if($s->{Platform} == 3)
        {
            $cmap->{mstable} = $s;
            last if(($s->{Encoding} == 1) || ($s->{Encoding} == 0));
        } 
        elsif($s->{Platform} == 0 || ($s->{Platform} == 2 && $s->{Encoding} == 1))
        { 
            $alt = $s;
        }
    }
    $cmap->{mstable}||=$alt if($alt);
    
    $data->{V}->{uni}=[];
    foreach my $i (keys %{$cmap->{mstable}->{val}})
    {
        $data->{V}->{uni}->[$cmap->{mstable}->{val}->{$i}]=$i;
    }

    foreach my $i (0..$data->{V}->{numGlyphs})
    {
        $data->{V}->{uni}->[$i]||=0;
    }
}

sub read_post_table
{
    my ($data, $fh, $buf) = @_;
    my $post=$data->{post};
    seek($fh,$post->{OFF},0);
    
    my @base_set=qw[
        .notdef .null nonmarkingreturn space exclam quotedbl numbersign dollar 
        percent ampersand quotesingle parenleft parenright asterisk plus comma 
        hyphen period slash zero one two three four five six seven eight nine 
        colon semicolon less equal greater question at A B C D E F G H I J K L 
        M N O P Q R S T U V W X Y Z bracketleft backslash bracketright 
        asciicircum underscore grave a b c d e f g h i j k l m n o p q r s t u 
        v w x y z braceleft bar braceright asciitilde Adieresis Aring Ccedilla 
        Eacute Ntilde Odieresis Udieresis aacute agrave acircumflex adieresis 
        atilde aring ccedilla eacute egrave ecircumflex edieresis iacute 
        igrave icircumflex idieresis ntilde oacute ograve ocircumflex 
        odieresis otilde uacute ugrave ucircumflex udieresis dagger degree 
        cent sterling section bullet paragraph germandbls registered copyright 
        trademark acute dieresis notequal AE Oslash infinity plusminus 
        lessequal greaterequal yen mu partialdiff summation product pi 
        integral ordfeminine ordmasculine Omega ae oslash questiondown 
        exclamdown logicalnot radical florin approxequal Delta guillemotleft 
        guillemotright ellipsis nonbreakingspace Agrave Atilde Otilde OE oe 
        endash emdash quotedblleft quotedblright quoteleft quoteright divide 
        lozenge ydieresis Ydieresis fraction currency guilsinglleft 
        guilsinglright fi fl daggerdbl periodcentered quotesinglbase 
        quotedblbase perthousand Acircumflex Ecircumflex Aacute Edieresis 
        Egrave Iacute Icircumflex Idieresis Igrave Oacute Ocircumflex apple 
        Ograve Uacute Ucircumflex Ugrave dotlessi circumflex tilde macron breve 
        dotaccent ring cedilla hungarumlaut ogonek caron Lslash lslash Scaron 
        scaron Zcaron zcaron brokenbar Eth eth Yacute yacute Thorn thorn minus 
        multiply onesuperior twosuperior threesuperior onehalf onequarter 
        threequarters franc Gbreve gbreve Idotaccent Scedilla scedilla Cacute 
        cacute Ccaron ccaron dcroat
    ];

    read($fh,$buf, 4);
    $post->{Format}=unpack('N',$buf);
    read($fh,$buf,4);
    $data->{V}->{italicangle}=unpack_fixed($buf);
    read($fh,$buf,2);
    $data->{V}->{underlineposition}=unpack_f2dot14($buf)*1000;
    read($fh,$buf,2);
    $data->{V}->{underlinethickness}=unpack_f2dot14($buf)*1000;
    read($fh,$buf,4);
    $data->{V}->{isfixedpitch}=unpack_ulong($buf);
    read($fh,$buf,16);
    
    if($post->{Format} == 0x00010000)
    {
        $post->{Format}='10';
        $post->{val}=[ @base_set ];
        $post->{strings}={};
        foreach my $i (0..257)
        {
            $post->{strings}->{$post->{val}->[$i]}=$i;
        }
    }
    elsif($post->{Format} == 0x00020000)
    {
        $post->{Format}='20';
        $post->{val}=[];
        $post->{strings}={};
        read($fh,$buf,2);
        $post->{numGlyphs}=unpack_ushort($buf);
        foreach my $i (0..$post->{numGlyphs}-1)
        {
            read($fh,$buf,2);
            $post->{val}->[$i]=unpack_ushort($buf);
        }
        while(tell($fh) < $post->{OFF}+$post->{LEN})
        {
            read($fh,$buf,1);
            my $strlen=unpack('C',$buf);
            read($fh,$buf,$strlen);
            push(@base_set,$buf);
        }
        foreach my $i (0..$post->{numGlyphs}-1)
        {
            $post->{val}->[$i]=$base_set[$post->{val}->[$i]];
            $post->{strings}->{$post->{val}->[$i]}||=$i;
        }
    }
    elsif($post->{Format} == 0x00025000)
    {
        $post->{Format}='25';
        $post->{val}=[];
        $post->{strings}={};
        read($fh,$buf,2);
        my $num=unpack_ushort($buf);
        foreach my $i (0..$num)
        {
            read($fh,$buf,1);
            $post->{val}->[$i]=$base_set[$i+unpack('c',$buf)];
            $post->{strings}->{$post->{val}->[$i]}||=$i;
        }
    }
    elsif($post->{Format} == 0x00030000)
    {
        $post->{Format}='30';
        $post->{val}=[];
        $post->{strings}={};
    }

    $data->{V}->{name}=[];
    foreach my $i (0..$data->{V}->{numGlyphs})
    {
        $data->{V}->{name}->[$i] = $post->{val}->[$i] 
            || nameByUni($data->{V}->{uni}->[$i]) 
            || '.notdef';
    }

    $data->{V}->{n2i}={};
    foreach my $i (0..$data->{V}->{numGlyphs})
    {
        $data->{V}->{n2i}->{$data->{V}->{name}->[$i]}||=$i;
    }
}

sub read_loca_table
{
    my ($data, $fh, $buf) = @_;

    seek($fh,$data->{'loca'}->{OFF},0);
    my $ilen=$data->{'head'}->{indexToLocFormat} ? 4 : 2;
    my $ipak=$data->{'head'}->{indexToLocFormat} ? 'N' : 'n';
    my $isif=$data->{'head'}->{indexToLocFormat} ? 0 : 1;
    
    $data->{'loca'}->{gOFF}=[];
    
    for(my $i=0; $i<$data->{'maxp'}->{numGlyphs}+1; $i++)
    {
        read($fh, $buf, $ilen);
        $buf=unpack($ipak,$buf);
        $buf<<=$isif;
        push @{$data->{'loca'}->{gOFF}},$buf;
    }
}

sub read_glyf_table
{
    my ($data, $fh, $buf) = @_;

    $data->{'glyf'}->{glyphs}=[];
    
    for(my $i=0; $i<$data->{'maxp'}->{numGlyphs}; $i++)
    {
        my $G={};
        $data->{'glyf'}->{glyphs}->[$i]=$G;
        next if($data->{'loca'}->{gOFF}->[$i]-$data->{'loca'}->{gOFF}->[$i+1] == 0);
        seek($fh,$data->{'loca'}->{gOFF}->[$i]+$data->{'glyf'}->{OFF},0);
        read($fh, $buf, 2);
        $G->{numOfContours}=unpack_short($buf);
        read($fh, $buf, 2);
        $G->{xMin}=unpack_short($buf);
        read($fh, $buf, 2);
        $G->{yMin}=unpack_short($buf);
        read($fh, $buf, 2);
        $G->{xMax}=unpack_short($buf);
        read($fh, $buf, 2);
        $G->{yMax}=unpack_short($buf);        
    }
}

sub find_name
{
    my ($self, $nid) = @_;
    my ($res, $pid, $eid, $lid, $look, $k);

    my (@lookup) = ([3, 1, 1033], [3, 1, -1], [2, 1, -1], [2, 2, -1], [2, 0, -1],
                    [0, 0, 0], [1, 0, 0]);
    foreach $look (@lookup)
    {
        ($pid, $eid, $lid) = @$look;
        if ($lid == -1)
        {
            foreach $k (keys %{$self->{'strings'}->[$nid]->[$pid]->[$eid]})
            {
                if (($res = $self->{strings}->[$nid]->[$pid]->[$eid]->{$k}) ne '')
                {
                    $lid = $k;
                    last;
                }
            }
        } else
        { $res = $self->{strings}->[$nid]->[$pid]->[$eid]->{$lid} }
        if ($res ne '')
        { return wantarray ? ($res, $pid, $eid, $lid) : $res; }
    }
    return '';
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


sub get_otf_data {
    my $file=shift @_;
    my $filename=basename($file);
    my $fh=IO::File->new($file);
    my $data={};
    binmode($fh,':raw');
    my($buf,$ver,$num,$i);

    read($fh,$buf, 12);
    ($ver, $num) = unpack("Nn", $buf);

    $ver == 1 << 16     # TTF version 1
        || $ver == 0x74727565   # support Mac sfnts
        || $ver == 0x4F54544F   # OpenType with diverse Outlines
        or next; #die "$file not a valid true/opentype font"; 

    for ($i = 0; $i < $num; $i++)
    {
        read($fh,$buf, 16) || last; #die "Reading table entry";
        my ($name, $check, $off, $len) = unpack("a4NNN", $buf);
        $data->{$name} = {
            OFF => $off,
            LEN => $len,
        };
    }

    next unless(defined $data->{name} && defined $data->{'OS/2'});

    $data->{V}={};

    read_name_table($data,$fh);

    read_os2_table($data,$fh);

    read_maxp_table($data,$fh);

    read_head_table($data,$fh);

    read_hhea_table($data,$fh);

    read_hmtx_table($data,$fh);

    read_cmap_table($data,$fh);

    read_post_table($data,$fh);

    if(0)
    {
        read_loca_table($data,$fh);
        read_glyf_table($data,$fh);
    }

    $data->{V}->{fontfamily}=find_name($data->{name},1);
    $data->{V}->{fontname}=find_name($data->{name},4);
    $data->{V}->{stylename}=find_name($data->{name},2);

    my $name = lc find_name($data->{name},1);
    my $subname = lc find_name($data->{name},2);
    my $slant='';

    if (defined $subname) {
        $weight_name = "$subname";
    } else {
        $weight_name = "Regular";
    }
    $weight_name =~ s/-/ /g;

    $_ = $weight_name;
    if (/^(regular|normal|medium)$/i) {
        $weight_name = "Regular";
        $slant = "";
        $subname='';
    } elsif (/^bold$/i) {
        $weight_name = "Bold";
        $slant = "";
        $subname='';
    } elsif (/^bold *(italic|oblique)$/i) {
        $weight_name = "Bold";
        $slant = "-Italic";
        $subname='';
    } elsif (/^(italic|oblique)$/i) {
        $weight_name = "Regular";
        $slant = "-Italic";
        $subname='';
    } else {
        # we need to find it via the OS/2 table
        if($data->{V}->{usWeightClass} == 0) {
            $weight_name = "Regular";
        } elsif($data->{V}->{usWeightClass} < 150) {
            $weight_name = "Thin";
        } elsif($data->{V}->{usWeightClass} < 250) {
            $weight_name = "ExtraLight";
        } elsif($data->{V}->{usWeightClass} < 350) {
            $weight_name = "Light";
        } elsif($data->{V}->{usWeightClass} < 450) {
            $weight_name = "Regular";
        } elsif($data->{V}->{usWeightClass} < 550) {
            $weight_name = "Regular";
        } elsif($data->{V}->{usWeightClass} < 650) {
            $weight_name = "SemiBold";
        } elsif($data->{V}->{usWeightClass} < 750) {
            $weight_name = "Bold";
        } elsif($data->{V}->{usWeightClass} < 850) {
            $weight_name = "ExtraBold";
        } else {
            $weight_name = "Black";
        } 
        # $slant = "";
        # $subname='';
    }

    $data->{V}->{fontweight}=$data->{V}->{usWeightClass};

    if($data->{V}->{usWidthClass} == 1) {
        $setwidth_name = "-UltraCondensed";
        $data->{V}->{fontstretch}="UltraCondensed";
    } elsif($data->{V}->{usWidthClass} == 2) {
        $setwidth_name = "-ExtraCondensed"; 
        $data->{V}->{fontstretch}="ExtraCondensed";
    } elsif($data->{V}->{usWidthClass} == 3) {
        $setwidth_name = "-Condensed"; 
        $data->{V}->{fontstretch}="Condensed";
    } elsif($data->{V}->{usWidthClass} == 4) {
        $setwidth_name = "-SemiCondensed"; 
        $data->{V}->{fontstretch}="SemiCondensed";
    } elsif($data->{V}->{usWidthClass} == 5) {
        $setwidth_name = ""; 
        $data->{V}->{fontstretch}="Normal";
    } elsif($data->{V}->{usWidthClass} == 6) {
        $setwidth_name = "-SemiExpanded"; 
        $data->{V}->{fontstretch}="SemiExpanded";
    } elsif($data->{V}->{usWidthClass} == 7) {
        $setwidth_name = "-Expanded"; 
        $data->{V}->{fontstretch}="Expanded";
    } elsif($data->{V}->{usWidthClass} == 8) {
        $setwidth_name = "-ExtraExpanded"; 
        $data->{V}->{fontstretch}="ExtraExpanded";
    } elsif($data->{V}->{usWidthClass} == 9) {
        $setwidth_name = "-UltraExpanded"; 
        $data->{V}->{fontstretch}="UltraExpanded";
    } else {
        $setwidth_name = ""; # normal | condensed | narrow | semicondensed
        $data->{V}->{fontstretch}="Normal";
    }

    $data->{V}->{fontname}=$name;
    $data->{V}->{subname}="$weight_name$slant$setwidth_name";
    $data->{V}->{subname}=~s|\-| |g;

    if(defined $data->{'CFF '})
    {
        # read CFF table
        seek($fh,$data->{'CFF '}->{OFF},0);
        read($fh,$buf, 4);
        my ($cffmajor,$cffminor,$cffheadsize,$cffglobaloffsize)=unpack('C4',$buf);

        $data->{'CFF '}->{name}=readcffindex($fh,$data->{'CFF '}->{OFF}+$cffheadsize);
        foreach my $dict (@{$data->{'CFF '}->{name}})
        {
            seek($fh,$dict->{OFF},0);
            read($fh,$dict->{VAL},$dict->{LEN});
        }

        $data->{'CFF '}->{topdict}=readcffindex($fh,$data->{'CFF '}->{name}->[-1]->{OFF}+$data->{'CFF '}->{name}->[-1]->{LEN});
        foreach my $dict (@{$data->{'CFF '}->{topdict}})
        {
            $dict->{VAL}=readcffdict($fh,$dict->{OFF},$dict->{LEN},$data->{'CFF '}->{OFF});
        }

        $data->{'CFF '}->{string}=readcffindex($fh,$data->{'CFF '}->{topdict}->[-1]->{OFF}+$data->{'CFF '}->{topdict}->[-1]->{LEN});
        foreach my $dict (@{$data->{'CFF '}->{string}})
        {
            seek($fh,$dict->{OFF},0);
            read($fh,$dict->{VAL},$dict->{LEN});
        }
        push @{$data->{'CFF '}->{string}},{ 'VAL' => '001.000' };
        push @{$data->{'CFF '}->{string}},{ 'VAL' => '001.001' };
        push @{$data->{'CFF '}->{string}},{ 'VAL' => '001.002' };
        push @{$data->{'CFF '}->{string}},{ 'VAL' => '001.003' };
        push @{$data->{'CFF '}->{string}},{ 'VAL' => 'Black' };
        push @{$data->{'CFF '}->{string}},{ 'VAL' => 'Bold' };
        push @{$data->{'CFF '}->{string}},{ 'VAL' => 'Book' };
        push @{$data->{'CFF '}->{string}},{ 'VAL' => 'Light' };
        push @{$data->{'CFF '}->{string}},{ 'VAL' => 'Medium' };
        push @{$data->{'CFF '}->{string}},{ 'VAL' => 'Regular' };
        push @{$data->{'CFF '}->{string}},{ 'VAL' => 'Roman' };
        push @{$data->{'CFF '}->{string}},{ 'VAL' => 'Semibold' };

        foreach my $dict (@{$data->{'CFF '}->{topdict}})
        {
            foreach my $k (keys %{$dict->{VAL}})
            {
                my $dt=$dict->{VAL}->{$k};
                if($k eq 'ROS')
                {
                    $dict->{VAL}->{$k}->[0]=$data->{'CFF '}->{string}->[$dict->{VAL}->{$k}->[0]-391]->{VAL};
                    $dict->{VAL}->{$k}->[1]=$data->{'CFF '}->{string}->[$dict->{VAL}->{$k}->[1]-391]->{VAL};
                    $data->{V}->{$k}=$dict->{VAL}->{$k};
                    next;
                }
                next unless(ref($dt) eq 'HASH' && defined $dt->{SID});
                if($dt->{SID}>=379)
                {
                    $dict->{VAL}->{$k}=$data->{'CFF '}->{string}->[$dt->{SID}-391]->{VAL};
                }
            }
        }
    }
    
    close($fh);
    
    nameByUni();
    
    my $g = scalar @{$data->{V}->{uni}};
    $data->{V}->{wx}={};
    for(my $i = 0; $i<$g ; $i++)
    {
    	if(defined $data->{hmtx}->{wx}->[$i])
    	{
    		$data->{V}->{wx}->{nameByUni($data->{V}->{uni}->[$i])} = $data->{hmtx}->{wx}->[$i];
    	}
    	else
    	{
    		$data->{V}->{wx}->{nameByUni($data->{V}->{uni}->[$i])} = $data->{hmtx}->{wx}->[-1];
    	}
    }
    
    $data->{V}->{glyphs}=$data->{glyf}->{glyphs};
    $data=$data->{V};
    $data->{firstchar}=0;
    $data->{lastchar}=255;

    $data->{flags} |= 1 if($data->{isfixedpitch} > 0);
    $data->{flags} |= 64 if($data->{italicangle} != 0);
    $data->{flags} |= (1<<18) if($data->{usWeightClass} >= 600);
    
    return($data);
}


sub new 
{
    my ($class,$pdf,$name,%opts) = @_;
    my ($self,$data);
    $data=get_otf_data($name);
    
    $class = ref $class if ref $class;
    $self = $class->SUPER::new($pdf, $data->{apiname}.pdfkey().'~'.time());
    $pdf->new_obj($self) unless($self->is_obj($pdf));
    $self->{' data'}=$data;
    $self->{-dokern}=1 if($opts{-dokern});

    $self->{'Subtype'} = PDFName('TrueType');
    if($opts{-fontname})
    {
	    $self->{'BaseFont'} = PDFName($opts{-fontname});
    }
    else
    {
    	my $fn=$data->{fontfamily};
    	$fn=~s|\s+||go;
    	if(($data->{stylename}=~m<(italic|oblique)>i) && ($data->{usWeightClass}>600))
    	{
	    	$fn.=',BoldItalic';
    	}
    	elsif($data->{stylename}=~m<(italic|oblique)>i)
    	{
	    	$fn.=',Italic';
    	}
    	elsif($data->{usWeightClass}>600)
    	{
	    	$fn.=',Bold';
    	}
    	
	    $self->{'BaseFont'} = PDFName($fn);
    }
    if($opts{-pdfname}) 
    {
        $self->name($opts{-pdfname});
    }

    $self->{FontDescriptor}=$self->descrByData();
    $self->encodeByData($opts{-encode});

    return($self);
}

=item $font = PDF::API2::Resource::Font::neTrueType->new_api $api, $fontname, %options

Returns a ne-truetype 8bit only object. This method is different from 'new' that
it needs an PDF::API2-object rather than a PDF::API2::PDF::File-object.

=cut

sub new_api 
{
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);

    $api->{pdf}->new_obj($obj) unless($obj->is_obj($api->{pdf}));

    $api->{pdf}->out_obj($api->{pages});
    return($obj);
}


1;

__END__

=back

=head1 AUTHOR

alfred reibenschuh



