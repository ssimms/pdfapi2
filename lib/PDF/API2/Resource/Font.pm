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
package PDF::API2::Resource::Font;

BEGIN {

    use utf8;
    use Encode qw(:all);

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Resource::BaseFont;

    use POSIX;

    use vars qw(@ISA $VERSION);

    @ISA = qw( PDF::API2::Resource::BaseFont );

    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$

}
no warnings qw[ deprecated recursion uninitialized ];

=item $font->encodeByData $encoding

Encodes the font in the specified byte-encoding.

=cut

sub encodeByData {
    my ($self,$encoding)=@_;
    my $data=undef;

    my ($firstChar,$lastChar);

    if($self->issymbol || $encoding eq 'asis') {
        $encoding=undef;
    }

    if(defined $encoding && $encoding=~m|^uni(\d+)$|o) 
    {
        my $blk=$1;
        $self->data->{e2u}=[ map { $blk*256+$_ } (0..255) ];
        $self->data->{e2n}=[ map { nameByUni($_) || '.notdef' } @{$self->data->{e2u}} ];
    }
    elsif(defined $encoding) 
    {
        $self->data->{e2u}=[ unpack('U*',decode($encoding,pack('C*',(0..255)))) ];
        $self->data->{e2n}=[ map { nameByUni($_) || '.notdef' } @{$self->data->{e2u}} ];
    } 
    elsif(defined $self->data->{uni}) 
    {
        $self->data->{e2u}=[ @{$self->data->{uni}} ];
        $self->data->{e2n}=[ map { $_ || '.notdef' } @{$self->data->{char}} ];
    } 
    else 
    {
        $self->data->{e2u}=[ map { uniByName($_) } @{$self->data->{char}} ];
        $self->data->{e2n}=[ map { $_ || '.notdef' } @{$self->data->{char}} ];
    }

    $self->data->{u2c}={};
    $self->data->{u2e}={};
    $self->data->{u2n}={};
    $self->data->{n2c}={};
    $self->data->{n2e}={};
    $self->data->{n2u}={};

    foreach my $n (0..255) {
        my $xchar=undef;
        my $xuni=undef;
        if(defined $self->data->{char}->[$n]) {
            $xchar=$self->data->{char}->[$n];
        } else {
            $xchar='.notdef';
        }
        $self->data->{n2c}->{$xchar}=$n unless(defined $self->data->{n2c}->{$xchar});

        if(defined $self->data->{e2n}->[$n]) {
            $xchar=$self->data->{e2n}->[$n];
        } else {
            $xchar='.notdef';
        }
        $self->data->{n2e}->{$xchar}=$n unless(defined $self->data->{n2e}->{$xchar});

        $self->data->{n2u}->{$xchar}=$self->data->{e2u}->[$n] unless(defined $self->data->{n2u}->{$xchar});

        if(defined $self->data->{char}->[$n]) {
            $xchar=$self->data->{char}->[$n];
        } else {
            $xchar='.notdef';
        }
        if(defined $self->data->{uni}->[$n]) {
            $xuni=$self->data->{uni}->[$n];
        } else {
            $xuni=0;
        }
        $self->data->{n2u}->{$xchar}=$xuni unless(defined $self->data->{n2u}->{$xchar});

        $self->data->{u2c}->{$xuni}||=$n unless(defined $self->data->{u2c}->{$xuni});
        
        if(defined $self->data->{e2u}->[$n]) {
            $xuni=$self->data->{e2u}->[$n];
        } else {
            $xuni=0;
        }
        $self->data->{u2e}->{$xuni}||=$n unless(defined $self->data->{u2e}->{$xuni});

        if(defined $self->data->{e2n}->[$n]) {
            $xchar=$self->data->{e2n}->[$n];
        } else {
            $xchar='.notdef';
        }
        $self->data->{u2n}->{$xuni}=$xchar unless(defined $self->data->{u2n}->{$xuni});

        if(defined $self->data->{char}->[$n]) {
            $xchar=$self->data->{char}->[$n];
        } else {
            $xchar='.notdef';
        }
        if(defined $self->data->{uni}->[$n]) {
            $xuni=$self->data->{uni}->[$n];
        } else {
            $xuni=0;
        }
        $self->data->{u2n}->{$xuni}=$xchar unless(defined $self->data->{u2n}->{$xuni});
    }

    my $en = PDFDict();
    $self->{Encoding}=$en;

    $en->{Type}=PDFName('Encoding');
    $en->{BaseEncoding}=PDFName('WinAnsiEncoding');

    $en->{Differences}=PDFArray(PDFNum(0));
    foreach my $n (0..255) {
        $en->{Differences}->add_elements( PDFName($self->glyphByEnc($n) || '.notdef') );
    }

    $self->{'FirstChar'} = PDFNum($self->data->{firstchar});
    $self->{'LastChar'} = PDFNum($self->data->{lastchar});

    $self->{Widths}=PDFArray();
    foreach my $n ($self->data->{firstchar}..$self->data->{lastchar}) {
        $self->{Widths}->add_elements( PDFNum($self->wxByEnc($n)) );
    }

#use Data::Dumper;
#    print Dumper($self->data);

    return($self);
}

sub automap {
    my ($self)=@_;

    my %gl=map { $_=>defineName($_) } keys %{$self->data->{wx}};

    foreach my $n (0..255) {
        delete $gl{$self->data->{e2n}->[$n]};
    }
    
    if(defined $self->data->{comps} && !$self->{-nocomps})
    {
        foreach my $n (keys %{$self->data->{comps}}) 
        {
            delete $gl{$n};
        }
    }

    my @nm=sort { $gl{$a} <=> $gl{$b} } keys %gl;

    my @fnts=();
    my $count=0;
    while(@glyphs=splice(@nm,0,223)) 
    {
        my $obj=$self->SUPER::new($self->{' apipdf'},$self->name.'am'.$count);
        $obj->{' data'}={ %{$self->data} };
        $obj->data->{firstchar}=32;
        $obj->data->{lastchar}=32+scalar(@glyphs);
        push @fnts,$obj;
        foreach my $key (qw( Subtype BaseFont FontDescriptor )) 
        {
            $obj->{$key}=$self->{$key} if(defined $self->{$key});
        }
        $obj->data->{char}=[];
        $obj->data->{uni}=[];
        foreach my $n (0..31) 
        {
            $obj->data->{char}->[$n]='.notdef';
            $obj->data->{uni}->[$n]=0;
        }
        $obj->data->{char}->[32]='space';
        $obj->data->{uni}->[32]=32;
        foreach my $n (33..$obj->data->{lastchar}) 
        {
            $obj->data->{char}->[$n]=$glyphs[$n-33];
            $obj->data->{uni}->[$n]=$gl{$glyphs[$n-33]};
        }
        foreach my $n (($obj->data->{lastchar}+1)..255) 
        {
            $obj->data->{char}->[$n]='.notdef';
            $obj->data->{uni}->[$n]=0;
        }
        $obj->encodeByData(undef);

        $count++;
    }

    return(@fnts);
}

sub remap {
    my ($self,$enc)=@_;

    my $obj=$self->SUPER::new($self->{' apipdf'},$self->name.'rm'.pdfkey());
    $obj->{' data'}={ %{$self->data} };
    foreach my $key (qw( Subtype BaseFont FontDescriptor )) {
        $obj->{$key}=$self->{$key} if(defined $self->{$key});
    }

    $obj->encodeByData($enc);

    return($obj);
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 2.0  2005/11/16 02:16:04  areibens
    revision workaround for SF cvs import not to screw up CPAN

    Revision 1.2  2005/11/16 01:27:48  areibens
    genesis2

    Revision 1.1  2005/11/16 01:19:25  areibens
    genesis

    Revision 1.17  2005/10/19 19:07:15  fredo
    added handling of composites in automap

    Revision 1.16  2005/09/26 20:06:02  fredo
    removed composite glyphs from automap

    Revision 1.15  2005/06/17 19:44:03  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.14  2005/06/17 18:53:34  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.13  2005/03/14 22:01:06  fredo
    upd 2005

    Revision 1.12  2004/12/16 00:30:53  fredo
    added no warn for recursion

    Revision 1.11  2004/11/26 01:25:28  fredo
    added unicode block mapping

    Revision 1.10  2004/11/25 23:50:26  fredo
    fixed unicode maps for unmapped corefonts

    Revision 1.9  2004/11/24 20:11:10  fredo
    added virtual font handling

    Revision 1.8  2004/10/17 03:46:20  fredo
    restructured encoding vs. unicode vs. glyph-name lookup

    Revision 1.7  2004/06/15 09:14:41  fredo
    removed cr+lf

    Revision 1.6  2004/06/07 19:44:36  fredo
    cleaned out cr+lf for lf

    Revision 1.5  2004/05/21 15:10:29  fredo
    worked around some unicode probs

    Revision 1.4  2003/12/08 13:05:33  Administrator
    corrected to proper licencing statement

    Revision 1.3  2003/11/30 17:28:55  Administrator
    merged into default

    Revision 1.2.2.1  2003/11/30 16:56:35  Administrator
    merged into default

    Revision 1.2  2003/11/30 11:44:49  Administrator
    added CVS id/log


=cut
