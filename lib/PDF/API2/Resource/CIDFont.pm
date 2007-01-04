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
package PDF::API2::Resource::CIDFont;

BEGIN 
{

    use utf8;
    use Encode qw(:all);

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Resource::BaseFont;
    use PDF::API2::IOString;

    use POSIX;

    use vars qw(@ISA $VERSION);

    @ISA = qw( PDF::API2::Resource::BaseFont );

    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$
}

no warnings qw[ deprecated recursion uninitialized ];

=item $font = PDF::API2::Resource::CIDFont->new $pdf, $name

Returns a cid-font object. base class form all CID based fonts.

=cut

sub new 
{
    my ($class,$pdf,$name,@opts) = @_;
    my %opts=();
    %opts=@opts if((scalar @opts)%2 == 0);

    $class = ref $class if ref $class;
    my $self=$class->SUPER::new($pdf,$name);
    $pdf->new_obj($self) if(defined($pdf) && !$self->is_obj($pdf));

    $self->{Type} = PDFName('Font');
    $self->{'Subtype'} = PDFName('Type0');
    $self->{'Encoding'} = PDFName('Identity-H');

    my $de=PDFDict();
    $pdf->new_obj($de);
    $self->{'DescendantFonts'} = PDFArray($de);

    $de->{'Type'} = PDFName('Font');
    $de->{'CIDSystemInfo'} = PDFDict();
    $de->{'CIDSystemInfo'}->{Registry} = PDFStr('Adobe');
    $de->{'CIDSystemInfo'}->{Ordering} = PDFStr('Identity');
    $de->{'CIDSystemInfo'}->{Supplement} = PDFNum(0);
    $de->{'CIDToGIDMap'} = PDFName('Identity');

    $self->{' de'} = $de;

    return($self);
}

=item $font = PDF::API2::Resource::CIDFont->new_api $api, $name, %options

Returns a cid-font object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api 
{
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $self->{' api'}=$api;

    $api->{pdf}->out_obj($api->{pages});
    return($obj);
}

sub glyphByCId { return( $_[0]->data->{g2n}->[$_[1]] ); }

sub uniByCId { return( $_[0]->data->{g2u}->[$_[1]] ); }

sub cidByUni { return( $_[0]->data->{u2g}->{$_[1]} ); }

sub cidByEnc { return( $_[0]->data->{e2g}->[$_[1]] ); }

sub wxByCId 
{
    my $self=shift @_;
    my $g=shift @_;
    my $w;

    if(ref($self->data->{wx}) eq 'ARRAY' && defined $self->data->{wx}->[$g]) 
    {
        $w = int($self->data->{wx}->[$g]);
    } 
    elsif(ref($self->data->{wx}) eq 'HASH' && defined $self->data->{wx}->{$g}) 
    {
        $w = int($self->data->{wx}->{$g});
    } 
    else 
    {
        $w = $self->missingwidth;
    }

    return($w);
}

sub wxByUni { return( $_[0]->wxByCId($_[0]->data->{u2g}->{$_[1]}) ); }
sub wxByEnc { return( $_[0]->wxByCId($_[0]->data->{e2g}->[$_[1]]) ); }

sub width 
{
    my ($self,$text)=@_;
    return($self->width_cid($self->cidsByStr($text)));
}

sub width_cid 
{
    my ($self,$text)=@_;
    my $width=0;
    my $lastglyph=0;
    foreach my $n (unpack('n*',$text)) 
    {
        $width+=$self->wxByCId($n);
        if($self->{-dokern} && $self->haveKernPairs())
        {
            if($self->kernPairCid($lastglyph, $n))
            {
                $width-=$self->kernPairCid($lastglyph, $n);
            }
        }
        $lastglyph=$n;                    
    }
    $width/=1000;
    return($width);
}

=item $cidstring = $font->cidsByStr $string

Returns the cid-string from string based on the fonts encoding map.

=cut

sub _cidsByStr 
{
    my ($self,$s)=@_;
    $s=pack('n*',map { $self->cidByEnc($_) } unpack('C*',$s));
    return($s);
}

sub cidsByStr
{
    my ($self,$text)=@_;
    if(is_utf8($text) && defined $self->data->{decode} && $self->data->{decode} ne 'ident') 
    {
        $text=encode($self->data->{decode},$text);
    }
    elsif(is_utf8($text) && $self->data->{decode} eq 'ident') 
    {
        $text=$self->cidsByUtf($text);
    } 
    elsif(!is_utf8($text) && defined $self->data->{encode} && $self->data->{decode} eq 'ident') 
    {
        $text=$self->cidsByUtf(decode($self->data->{encode},$text));
    } 
    elsif(!is_utf8($text) && UNIVERSAL::can($self,'issymbol') && $self->issymbol && $self->data->{decode} eq 'ident') 
    {
        $text=pack('U*',(map { $_+0xf000 } unpack('C*',$text)));
        $text=$self->cidsByUtf($text);
    }
    else 
    {
        $text=$self->_cidsByStr($text);
    }
    return($text);
}

=item $cidstring = $font->cidsByUtf $utf8string

Returns the cid-encoded string from utf8-string.

=cut

sub cidsByUtf {
    my ($self,$s)=@_;
    $s=pack('n*',map { $self->cidByUni($_) } (map { $_>0x7f && $_<0xA0 ? uniByName(nameByUni($_)): $_ } unpack('U*',$s)));
    utf8::downgrade($s);
    return($s);
}

sub textByStr 
{
    my ($self,$text)=@_;
    return($self->text_cid($self->cidsByStr($text)));
}

sub textByStrKern 
{
    my ($self,$text,$size,$ident)=@_;
    return($self->text_cid_kern($self->cidsByStr($text),$size,$ident));
}

sub text 
{ 
    my ($self,$text,$size,$ident)=@_;
    my $newtext=$self->textByStr($text);
    if(defined $size && $self->{-dokern})
    {
        $newtext=$self->textByStrKern($text,$size,$ident);
        return($newtext);
    }
    elsif(defined $size)
    {
        if(defined($ident) && $ident!=0)
        {
	        return("[ $ident $newtext ] TJ");
        }
        else
        {
	        return("$newtext Tj");
        }        
    }
    else
    {
        return($newtext);
    }
}

sub text_cid 
{
    my ($self,$text,$size)=@_;
    if(UNIVERSAL::can($self,'fontfile'))
    {
        foreach my $g (unpack('n*',$text)) 
        {
            $self->fontfile->subsetByCId($g);
        }
    }
    my $newtext=unpack('H*',$text);
    if(defined $size)
    {
        return("<$newtext> Tj");
    }
    else
    {
        return("<$newtext>");
    }
}

sub text_cid_kern 
{
    my ($self,$text,$size,$ident)=@_;
    if(UNIVERSAL::can($self,'fontfile'))
    {
        foreach my $g (unpack('n*',$text)) 
        {
            $self->fontfile->subsetByCId($g);
        }
    }
    if(defined $size && $self->{-dokern} && $self->haveKernPairs())
    {
        my $newtext=' ';
        my $lastglyph=0;
        my $tBefore=0;
        foreach my $n (unpack('n*',$text)) 
        {
            if($self->kernPairCid($lastglyph, $n))
            {
                $newtext.='> ' if($tBefore);
                $newtext.=sprintf('%i ',$self->kernPairCid($lastglyph, $n));
                $tBefore=0;
            }
            $lastglyph=$n;
            my $t=sprintf('%04X',$n);
            $newtext.='<' if(!$tBefore);
            $newtext.=$t;
            $tBefore=1;
        }
        $newtext.='> ' if($tBefore);
        if(defined($ident) && $ident!=0)
        {
	        return("[ $ident $newtext ] TJ");
        }
        else
        {
            return("[ $newtext ] TJ");
        }
    }
    elsif(defined $size)
    {
        my $newtext=unpack('H*',$text);
        if(defined($ident) && $ident!=0)
        {
	        return("[ $ident <$newtext> ] TJ");
        }
        else
        {
	        return("<$newtext> Tj");
        }
    }
    else
    {
        my $newtext=unpack('H*',$text);
        return("<$newtext>");
    }
}

sub kernPairCid 
{
    return(0);
}

sub haveKernPairs 
{
    return(0);
}

sub encodeByName 
{
    my ($self,$enc) = @_;
    return if($self->issymbol);

    $self->data->{e2u}=[ map { $_>0x7f && $_<0xA0 ? uniByName(nameByUni($_)): $_ } unpack('U*',decode($enc, pack('C*',0..255))) ] if(defined $enc);
    $self->data->{e2n}=[ map { $self->data->{g2n}->[$self->data->{u2g}->{$_} || 0] || '.notdef' } @{$self->data->{e2u}} ];
    $self->data->{e2g}=[ map { $self->data->{u2g}->{$_} || 0 } @{$self->data->{e2u}} ];

    $self->data->{u2e}={};
    foreach my $n (reverse 0..255) 
    {
        $self->data->{u2e}->{$self->data->{e2u}->[$n]}=$n unless(defined $self->data->{u2e}->{$self->data->{e2u}->[$n]});
    }

    return($self);
}

sub subsetByCId 
{
    return(1);
}

sub subvec 
{
    return(1);
}

sub glyphNum 
{ 
    my $self=shift @_;
    if(defined $self->data->{glyphs}) 
    {
        return ( $self->data->{glyphs} ); 
    }
    return ( scalar @{$self->data->{wx}} ); 
}

sub outobjdeep 
{
    my ($self, $fh, $pdf, %opts) = @_;

    return $self->SUPER::outobjdeep($fh, $pdf) if defined $opts{'passthru'};

    $self->SUPER::outobjdeep($fh, $pdf, %opts);
}


1;

__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 2.2  2007/01/04 16:02:28  areibens
    applied untested fix for acrobat 8 "<ident> TJ" bug

    Revision 2.1  2006/06/19 19:22:07  areibens
    removed dup sub

    Revision 2.0  2005/11/16 02:16:04  areibens
    revision workaround for SF cvs import not to screw up CPAN

    Revision 1.2  2005/11/16 01:27:48  areibens
    genesis2

    Revision 1.1  2005/11/16 01:19:25  areibens
    genesis

    Revision 1.15  2005/10/20 21:05:05  fredo
    added handling of optional kerning

    Revision 1.14  2005/06/17 19:44:03  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.13  2005/06/17 18:53:34  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.12  2005/03/14 22:01:06  fredo
    upd 2005

    Revision 1.11  2004/12/16 00:30:53  fredo
    added no warn for recursion

    Revision 1.10  2004/11/24 20:10:55  fredo
    added virtual font handling

    Revision 1.9  2004/11/22 21:07:55  fredo
    fixed multibyte-encoding support to work consistently acress cjk/ttf/otf

    Revision 1.8  2004/11/21 02:57:53  fredo
    cosmetic change

    Revision 1.7  2004/10/26 14:42:49  fredo
    added alternative glyph-width storage/retrieval

    Revision 1.6  2004/06/15 09:14:41  fredo
    removed cr+lf

    Revision 1.5  2004/06/07 19:44:36  fredo
    cleaned out cr+lf for lf

    Revision 1.4  2003/12/08 13:05:33  Administrator
    corrected to proper licencing statement

    Revision 1.3  2003/11/30 17:28:54  Administrator
    merged into default

    Revision 1.2.2.1  2003/11/30 16:56:35  Administrator
    merged into default

    Revision 1.2  2003/11/30 11:44:49  Administrator
    added CVS id/log


=cut

