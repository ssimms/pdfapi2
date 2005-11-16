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
package PDF::API2::Resource::Font::SynFont;

BEGIN {

    use utf8;
    use Encode qw(:all);

    use vars qw( @ISA $VERSION );
    use PDF::API2::Resource::Font;
    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use Math::Trig;
    use Unicode::UCD 'charinfo';

    @ISA=qw(PDF::API2::Resource::Font);

    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$

}
no warnings qw[ deprecated recursion uninitialized ];

=head1 NAME

PDF::API2::Resource::Font::SynFont - Module for using synthetic Fonts.

=head1 SYNOPSIS

    #
    use PDF::API2;
    #
    $pdf = PDF::API2->new;
    $sft = $pdf->synfont($cft);
    #

=head1 METHODS

=over 4

=cut

=item $font = PDF::API2::Resource::Font::SynFont->new $pdf, $fontobj, %options

Returns a synfont object.

=cut

=pod

Valid %options are:

I<-encode>
... changes the encoding of the font from its default.
See I<perl's Encode> for the supported values.

I<-pdfname> 
... changes the reference-name of the font from its default.
The reference-name is normally generated automatically and can be
retrived via $pdfname=$font->name.

I<-slant>
... slant/expansion factor (0.1-0.9 = slant, 1.1+ = expansion).

I<-oblique>
... italic angle (+/-)

I<-bold>
... embolding factor (0.1+, bold=1, heavy=2, ...).

I<-space>
... additional charspacing in em (0-1000).

I<-caps>
... create synthetic small-caps.

=cut

sub new 
{
    my ($class,$pdf,$font,@opts) = @_;
    my ($self,$data);
    my %opts=@opts;
    my $first=1;
    my $last=255;
    my $slant=$opts{-slant}||1;
    my $oblique=$opts{-oblique}||0;
    my $space=$opts{-space}||'0';
    my $bold=($opts{-bold}||0)*10; # convert to em

    $self->{' slant'}=$slant;
    $self->{' oblique'}=$oblique;
    $self->{' bold'}=$bold;
    $self->{' boldmove'}=0.001;
    $self->{' space'}=$space;

    $class = ref $class if ref $class;
    $self = $class->SUPER::new($pdf, 
        pdfkey()
        .'+'.($font->name)
        .($opts{-caps} ? '+Caps' : '')
        .($opts{-vname} ? '+'.$opts{-vname} : '')
    );
    $pdf->new_obj($self) unless($self->is_obj($pdf));
    $self->{' font'}=$font;
    $self->{' data'}={
        'type' => 'Type3',
        'ascender' => $font->ascender,
        'capheight' => $font->capheight,
        'descender' => $font->descender,
        'iscore' => '0',
        'isfixedpitch' => $font->isfixedpitch,
        'italicangle' => $font->italicangle + $oblique,
        'missingwidth' => $font->missingwidth * $slant,
        'underlineposition' => $font->underlineposition,
        'underlinethickness' => $font->underlinethickness,
        'xheight' => $font->xheight,
        'firstchar' => $first,
        'lastchar' => $last,
        'char' => [ '.notdef' ],
        'uni' => [ 0 ],
        'u2e' => { 0 => 0 },
        'fontbbox' => '',
        'wx' => { 'space' => '600' },
    };

    if(ref($font->fontbbox)) 
    {
        $self->data->{fontbbox}=[ @{$font->fontbbox} ];
    } 
    else 
    {
        $self->data->{fontbbox}=[ $font->fontbbox ];
    }
    $self->data->{fontbbox}->[0]*=$slant;
    $self->data->{fontbbox}->[2]*=$slant;

    $self->{'Subtype'} = PDFName('Type3');
    $self->{'FirstChar'} = PDFNum($first);
    $self->{'LastChar'} = PDFNum($last);
    $self->{'FontMatrix'} = PDFArray(map { PDFNum($_) } ( 0.001, 0, 0, 0.001, 0, 0 ) );
    $self->{'FontBBox'} = PDFArray(map { PDFNum($_) } ( $self->fontbbox ) );

    $self->{'Encoding'}=$font->{Encoding};

    my $procs=PDFDict();
    $pdf->new_obj($procs);
    $self->{'CharProcs'} = $procs;

    $self->{Resources}=PDFDict();
    $self->{Resources}->{ProcSet}=PDFArray(map { PDFName($_) } qw[ PDF Text ImageB ImageC ImageI ]);
    my $xo=PDFDict();
    $self->{Resources}->{Font}=$xo;
    $self->{Resources}->{Font}->{FSN}=$font;
    foreach my $w ($first..$last) 
    {
        $self->data->{char}->[$w]=$font->glyphByEnc($w);
        $self->data->{uni}->[$w]=uniByName($self->data->{char}->[$w]);
        $self->data->{u2e}->{$self->data->{uni}->[$w]}=$w;
    }
    #use Data::Dumper;
    #print Dumper($self->data);
    my @widths=();
    foreach my $w ($first..$last) 
    {
        if($self->data->{char}->[$w] eq '.notdef') 
        {
            push @widths,$self->missingwidth;
            next;
        }
        my $char=PDFDict();
        my $wth=int($font->width(chr($w))*1000*$slant+2*$space);
        $procs->{$font->glyphByEnc($w)}=$char;
        $char->{Filter}=PDFArray(PDFName('FlateDecode'));
        $char->{' stream'}=$wth." 0 ".join(' ',map { int($_) } $self->fontbbox)." d1\n";
        $char->{' stream'}.="BT\n";
        $char->{' stream'}.=join(' ',1,0,tan(deg2rad($oblique)),1,0,0)." Tm\n" if($oblique);
        $char->{' stream'}.="2 Tr ".($bold)." w\n" if($bold);
        my $ci = charinfo($self->data->{uni}->[$w]);
        if($opts{-caps} && $ci->{upper}) 
        {
            $char->{' stream'}.="/FSN 800 Tf\n";
            $char->{' stream'}.=($slant*110)." Tz\n";
            $char->{' stream'}.=" [ -$space ] TJ\n" if($space);
            my $ch=$self->encByUni(hex($ci->{upper}));
            $wth=int($font->width(chr($ch))*800*$slant*1.1+2*$space);
            $char->{' stream'}.=$self->text(chr($ch));
        } 
        else 
        {
            $char->{' stream'}.="/FSN 1000 Tf\n";
            $char->{' stream'}.=($slant*100)." Tz\n" if($slant!=1);
            $char->{' stream'}.=" [ -$space ] TJ\n" if($space);
            $char->{' stream'}.=$self->text(chr($w));
        }
        $char->{' stream'}.=" Tj\nET\n";
        push @widths,$wth;
        $self->data->{wx}->{$font->glyphByEnc($w)}=$wth;
        $pdf->new_obj($char);
    }

    $procs->{'.notdef'}=$procs->{$font->data->{char}->[32]};
    $self->{Widths}=PDFArray(map { PDFNum($_) } @widths);
    $self->data->{e2n}=$self->data->{char};
    $self->data->{e2u}=$self->data->{uni};

    $self->data->{u2c}={};
    $self->data->{u2e}={};
    $self->data->{u2n}={};
    $self->data->{n2c}={};
    $self->data->{n2e}={};
    $self->data->{n2u}={};

    foreach my $n (reverse 0..255) 
    {
        $self->data->{n2c}->{$self->data->{char}->[$n] || '.notdef'}=$n unless(defined $self->data->{n2c}->{$self->data->{char}->[$n] || '.notdef'});
        $self->data->{n2e}->{$self->data->{e2n}->[$n] || '.notdef'}=$n unless(defined $self->data->{n2e}->{$self->data->{e2n}->[$n] || '.notdef'});

        $self->data->{n2u}->{$self->data->{e2n}->[$n] || '.notdef'}=$self->data->{e2u}->[$n] unless(defined $self->data->{n2u}->{$self->data->{e2n}->[$n] || '.notdef'});
        $self->data->{n2u}->{$self->data->{char}->[$n] || '.notdef'}=$self->data->{uni}->[$n] unless(defined $self->data->{n2u}->{$self->data->{char}->[$n] || '.notdef'});

        $self->data->{u2c}->{$self->data->{uni}->[$n]}=$n unless(defined $self->data->{u2c}->{$self->data->{uni}->[$n]});
        $self->data->{u2e}->{$self->data->{e2u}->[$n]}=$n unless(defined $self->data->{u2e}->{$self->data->{e2u}->[$n]});

        $self->data->{u2n}->{$self->data->{e2u}->[$n]}=($self->data->{e2n}->[$n] || '.notdef') unless(defined $self->data->{u2n}->{$self->data->{e2u}->[$n]});
        $self->data->{u2n}->{$self->data->{uni}->[$n]}=($self->data->{char}->[$n] || '.notdef') unless(defined $self->data->{u2n}->{$self->data->{uni}->[$n]});
    }

    return($self);
}


=item $font = PDF::API2::Resource::Font::SynFont->new_api $api, $fontobj, %options

Returns a synfont object. This method is different from 'new' that
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

=head1 HISTORY

    $Log$
    Revision 2.0  2005/11/16 02:18:14  areibens
    revision workaround for SF cvs import not to screw up CPAN

    Revision 1.2  2005/11/16 01:27:50  areibens
    genesis2

    Revision 1.1  2005/11/16 01:19:27  areibens
    genesis

    Revision 1.17  2005/06/17 19:44:03  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.16  2005/06/17 18:53:34  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.14  2004/12/29 01:13:21  fredo
    documented -caps option

    Revision 1.13  2004/12/16 00:30:54  fredo
    added no warn for recursion

    Revision 1.12  2004/11/29 10:00:54  fredo
    added charspacer docs

    Revision 1.11  2004/11/26 15:14:59  fredo
    fixed docs

    Revision 1.10  2004/11/26 15:10:38  fredo
    added spacer mod option

    Revision 1.9  2004/06/15 09:14:53  fredo
    removed cr+lf

    Revision 1.8  2004/06/07 19:44:43  fredo
    cleaned out cr+lf for lf

    Revision 1.7  2004/02/10 15:55:42  fredo
    fixed glyph generation for .notdef glyphs

    Revision 1.6  2004/02/01 22:06:26  fredo
    beautified caps generation

    Revision 1.5  2004/02/01 19:27:18  fredo
    fixed width calc for caps

    Revision 1.4  2004/02/01 19:04:31  fredo
    added caps capability

    Revision 1.3  2003/12/08 13:06:01  Administrator
    corrected to proper licencing statement

    Revision 1.2  2003/11/30 17:32:48  Administrator
    merged into default

    Revision 1.1.1.1.2.2  2003/11/30 16:57:05  Administrator
    merged into default

    Revision 1.1.1.1.2.1  2003/11/30 14:45:23  Administrator
    added CVS id/log


=cut

