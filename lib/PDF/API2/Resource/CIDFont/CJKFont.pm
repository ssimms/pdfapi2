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
package PDF::API2::Resource::CIDFont::CJKFont;

BEGIN {

    use utf8;
    use Encode qw(:all);

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Resource::CIDFont;
    use PDF::API2::IOString;

    use PDF::API2::Basic::TTF::Font;

    use POSIX;

    use vars qw( @ISA $fonts $cmap $alias $subs $VERSION );

    @ISA = qw( PDF::API2::Resource::CIDFont );

    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$

    $fonts = { };
    $cmap = { };
}
no warnings qw[ deprecated recursion uninitialized ];

=item $font = PDF::API2::Resource::CIDFont::CJKFont->new $pdf, $cjkname, %options

Returns a cjk-font object.

Traditional Chinese: Ming Ming-Bold Ming-Italic Ming-BoldItalic

Simplified Chinese: Song Song-Bold Song-Italic Song-BoldItalic

Korean: MyungJo MyungJo-Bold MyungJo-Italic MyungJo-BoldItalic

Japanese (Mincho): KozMin KozMin-Bold KozMin-Italic KozMin-BoldItalic

Japanese (Gothic): KozGo KozGo-Bold KozGo-Italic KozGo-BoldItalic

Defined Options:

    -encode ... specify fonts encoding for non-utf8 text.

=cut

sub _look_for_font {
    my $fname=lc(shift);
    $fname=~s/[^a-z0-9]+//gi;
    $fname=$alias->{$fname} if(defined $alias->{$fname});
    return({%{$fonts->{$fname}}}) if(defined $fonts->{$fname});

    if(defined $subs->{$fname}) {
        $data=_look_for_font($subs->{$fname}->{-alias});
        foreach my $k (keys %{$subs->{$fname}}) {
          next if($k=~/^\-/);
          if(substr($k,0,1) eq '+')
          {
              $data->{substr($k,1)}.=$subs->{$fname}->{$k};
          }
          else
          {
              $data->{$k}=$subs->{$fname}->{$k};
          }
        }
        $fonts->{$fname}=$data;
        return({%{$data}})
    }

    eval "require PDF::API2::Resource::CIDFont::CJKFont::$fname; ";
    unless($@){
        return({%{$fonts->{$fname}}});
    } else {
        die "requested font '$fname' not installed ";
    }
}

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
sub new {
    my ($class,$pdf,$name,@opts) = @_;
    my %opts=();
    %opts=@opts if((scalar @opts)%2 == 0);
    $opts{-encode}||='ident';
    
    my $data = _look_for_font($name);

    my $cmap = _look_for_cmap($data->{cmap});

    $data->{u2g} = { %{$cmap->{u2g}} };
    $data->{g2u} = [ @{$cmap->{g2u}} ];

    $class = ref $class if ref $class;
    my $self=$class->SUPER::new($pdf,$data->{apiname}.pdfkey());
    $pdf->new_obj($self) if(defined($pdf) && !$self->is_obj($pdf));

    $self->{' data'}=$data;

    my $des=$self->descrByData;

    my $de=$self->{' de'};

    if(defined $opts{-encode} && $opts{-encode} ne 'ident') {
        $self->data->{encode}=$opts{-encode};
    }

    my $emap={
        'reg'=>'Adobe',
        'ord'=>'Identity',
        'sup'=> 0,
        'map'=>'Identity',
        'dir'=>'H',
        'dec'=>'ident',
    };
    
    if(defined $cmap->{ccs}) {
        $emap->{reg}=$cmap->{ccs}->[0];
        $emap->{ord}=$cmap->{ccs}->[1];
        $emap->{sup}=$cmap->{ccs}->[2];
    }

    #if(defined $cmap->{cmap} && defined $cmap->{cmap}->{$opts{-encode}} ) {
    #    $emap->{dec}=$cmap->{cmap}->{$opts{-encode}}->[0];
    #    $emap->{map}=$cmap->{cmap}->{$opts{-encode}}->[1];
    #} elsif(defined $cmap->{cmap} && defined $cmap->{cmap}->{'utf8'} ) {
    #    $emap->{dec}=$cmap->{cmap}->{'utf8'}->[0];
    #    $emap->{map}=$cmap->{cmap}->{'utf8'}->[1];
    #}

    $self->data->{decode}=$emap->{dec};

    $self->{'BaseFont'} = PDFName($self->fontname."-$emap->{map}-$emap->{dir}");
    $self->{'Encoding'} = PDFName("$emap->{map}-$emap->{dir}");

    $de->{'FontDescriptor'} = $des;
    $de->{'Subtype'} = PDFName('CIDFontType0');
    $de->{'BaseFont'} = PDFName($self->fontname);
    $de->{'DW'} = PDFNum($self->missingwidth);
    $de->{'CIDSystemInfo'}->{Registry} = PDFStr($emap->{reg});
    $de->{'CIDSystemInfo'}->{Ordering} = PDFStr($emap->{ord});
    $de->{'CIDSystemInfo'}->{Supplement} = PDFNum($emap->{sup});
    ## $de->{'CIDToGIDMap'} = PDFName($emap->{map}); # ttf only

    return($self);
}

=item $font = PDF::API2::Resource::CIDFont::CJKFont->new_api $api, $cjkname, %options

Returns a cjk-font object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $self->{' api'}=$api;

    $api->{pdf}->out_obj($api->{pages});
    return($obj);
}

sub tounicodemap {
    my $self=shift @_;
    # noop since pdf knows its char-collection
    return($self);
}

sub glyphByCId
{ 
    my ($self,$cid)=@_;
    my $uni = $self->uniByCId($cid);
    return( nameByUni($uni) ); 
}

sub outobjdeep {
    my ($self, $fh, $pdf, %opts) = @_;

    return $self->SUPER::outobjdeep($fh, $pdf) if defined $opts{'passthru'};

    my $notdefbefore=1;

    my $wx=PDFArray();
    $self->{' de'}->{'W'} = $wx;
    my $ml;

    foreach my $w (0..(scalar @{$self->data->{g2u}} - 1 )) {
        if(ref($self->data->{wx}) eq 'ARRAY' 
            && (defined $self->data->{wx}->[$w])
            && ($self->data->{wx}->[$w] != $self->missingwidth)
            && $notdefbefore==1) 
        {
            $notdefbefore=0;
            $ml=PDFArray();
            $wx->add_elements(PDFNum($w),$ml);
            $ml->add_elements(PDFNum($self->data->{wx}->[$w]));
        } 
        elsif(ref($self->data->{wx}) eq 'HASH' 
            && (defined $self->data->{wx}->{$w}) 
            && ($self->data->{wx}->{$w} != $self->missingwidth)
            && $notdefbefore==1) 
        {
            $notdefbefore=0;
            $ml=PDFArray();
            $wx->add_elements(PDFNum($w),$ml);
            $ml->add_elements(PDFNum($self->data->{wx}->{$w}));
        } 
        elsif(ref($self->data->{wx}) eq 'ARRAY' 
            && (defined $self->data->{wx}->[$w]) 
            && ($self->data->{wx}->[$w] != $self->missingwidth)
            && $notdefbefore==0) 
        {
            $notdefbefore=0;
            $ml->add_elements(PDFNum($self->data->{wx}->[$w]));
        } 
        elsif(ref($self->data->{wx}) eq 'HASH' 
            && (defined $self->data->{wx}->{$w}) 
            && ($self->data->{wx}->{$w} != $self->missingwidth)
            && $notdefbefore==0) 
        {
            $notdefbefore=0;
            $ml->add_elements(PDFNum($self->data->{wx}->{$w}));
        } 
        else 
        {
            $notdefbefore=1;
        }
    }

    $self->SUPER::outobjdeep($fh, $pdf, %opts);
}

BEGIN {

    $alias={
        'traditional'           => 'adobemingstdlightacro',
        'traditionalbold'       => 'mingbold',
        'traditionalitalic'     => 'mingitalic',
        'traditionalbolditalic' => 'mingbolditalic',
        'ming'                  => 'adobemingstdlightacro',
        
        'simplified'            => 'adobesongstdlightacro',
        'simplifiedbold'        => 'songbold',
        'simplifieditalic'      => 'songitalic',
        'simplifiedbolditalic'  => 'songbolditalic',
        'song'                  => 'adobesongstdlightacro',

        'korean'                => 'adobemyungjostdmediumacro',
        'koreanbold'            => 'myungjobold',      
        'koreanitalic'          => 'myungjoitalic',    
        'koreanbolditalic'      => 'myungjobolditalic',
        'myungjo'               => 'adobemyungjostdmediumacro',

        'japanese'              => 'kozminproregularacro',
        'japanesebold'          => 'kozminbold',
        'japaneseitalic'        => 'kozminitalic',
        'japanesebolditalic'    => 'kozminbolditalic',
        'kozmin'                => 'kozminproregularacro',
        'kozgo'                 => 'kozgopromediumacro',

    };
    $subs={
    # Chinese Traditional (ie. Taiwan) Fonts
        'mingitalic' => {
            '-alias'            => 'adobemingstdlightacro',
            '+fontname'          => ',Italic', 
        },
        'mingbold' => {
            '-alias'            => 'adobemingstdlightacro',
            '+fontname'          => ',Bold', 
        },
        'mingbolditalic' => {
            '-alias'            => 'adobemingstdlightacro',
            '+fontname'          => ',BoldItalic', 
        },
    # Chinese Simplified (ie. Mainland China) Fonts
        'songitalic' => {
            '-alias'            => 'adobesongstdlightacro',
            '+fontname'          => ',Italic', 
        },
        'songbold' => {
            '-alias'            => 'adobesongstdlightacro',
            '+fontname'          => ',Bold', 
        },
        'songbolditalic' => {
            '-alias'            => 'adobesongstdlightacro',
            '+fontname'          => ',BoldItalic', 
        },
    # Japanese Gothic (ie. sans) Fonts
        'kozgoitalic' => {
            '-alias'            => 'kozgopromediumacro',
            '+fontname'          => ',Italic', 
        },
        'kozgobold' => {
            '-alias'            => 'kozgopromediumacro',
            '+fontname'          => ',Bold', 
        },
        'kozgobolditalic' => {
            '-alias'            => 'kozgopromediumacro',
            '+fontname'          => ',BoldItalic', 
        },
    # Japanese Mincho (ie. serif) Fonts
        'kozminitalic' => {
            '-alias'            => 'kozminproregularacro',
            '+fontname'          => ',Italic', 
        },
        'kozminbold' => {
            '-alias'            => 'kozminproregularacro',
            '+fontname'          => ',Bold', 
        },
        'kozminbolditalic' => {
            '-alias'            => 'kozminproregularacro',
            '+fontname'          => ',BoldItalic', 
        },
    # Korean Fonts
        'myungjoitalic' => {
            '-alias'            => 'adobemyungjostdmediumacro',
            '+fontname'          => ',Italic', 
        },
        'myungjobold' => {
            '-alias'            => 'adobemyungjostdmediumacro',
            '+fontname'          => ',Bold', 
        },
        'myungjobolditalic' => {
            '-alias'            => 'adobemyungjostdmediumacro',
            '+fontname'          => ',BoldItalic', 
        },
    };

}
1;

__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 1.2  2005/11/16 01:27:48  areibens
    genesis2

    Revision 1.1  2005/11/16 01:19:25  areibens
    genesis

    Revision 1.17  2005/06/17 19:44:03  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.16  2005/06/17 18:53:34  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.15  2003/04/09 11:13:12  fredo
    added/fixed proper alias/substitutions

    Revision 1.14  2005/03/14 22:01:07  fredo
    upd 2005

    Revision 1.13  2004/12/16 00:30:53  fredo
    added no warn for recursion

    Revision 1.12  2004/11/25 15:07:21  fredo
    fixed prototype warning

    Revision 1.11  2004/11/22 21:07:55  fredo
    fixed multibyte-encoding support to work consistently acress cjk/ttf/otf

    Revision 1.10  2004/11/22 02:04:27  fredo
    added missing substitutes

    Revision 1.9  2004/11/22 01:03:24  fredo
    fixed supplement set, added substitute handling

    Revision 1.8  2004/11/21 02:58:51  fredo
    fixed multibyte encoding issues

    Revision 1.7  2004/10/26 14:43:25  fredo
    added alternative glyph-width storage/retrieval

    Revision 1.6  2004/06/15 09:14:42  fredo
    removed cr+lf

    Revision 1.5  2004/06/07 19:44:36  fredo
    cleaned out cr+lf for lf

    Revision 1.4  2004/02/24 00:08:54  fredo
    added utf8 fallback for encoding

    Revision 1.3  2003/12/08 13:05:33  Administrator
    corrected to proper licencing statement

    Revision 1.2  2003/11/30 17:30:40  Administrator
    merged into default

    Revision 1.1.1.1.2.2  2003/11/30 16:56:36  Administrator
    merged into default

    Revision 1.1.1.1.2.1  2003/11/30 14:13:33  Administrator
    added CVS id/log


=cut



            ------- Chinese -------
    Traditional                 Simplified                  Japanese                Korean
Acrobat 6:
    AdobeMingStd-Light-Acro     AdobeSongStd-Light-Acro     KozGoPro-Medium-Acro    AdobeMyungjoStd-Medium-Acro
                                                            KozMinPro-Regular-Acro
Acrobat 5:
    MSungStd-Light-Acro         STSongStd-Light-Acro        KozMinPro-Regular-Acro  HYSMyeongJoStd-Medium-Acro
Acrobat 4:
    MSung-Light                 STSong-Light                HeiseiKakuGo-W5         HYSMyeongJo-Medium
    MHei-Medium                                             HeiseiMin-W3            HYGoThic-Medium
