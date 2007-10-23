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
package PDF::API2::Resource::CIDFont::TrueType;

BEGIN {

    use utf8;
    use Encode qw(:all);

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Resource::CIDFont;

    use PDF::API2::Basic::TTF::Font;
    use PDF::API2::Resource::CIDFont::TrueType::FontFile;

    use POSIX;

    use vars qw(@ISA $VERSION);

    @ISA = qw( PDF::API2::Resource::CIDFont );

    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$

}
no warnings qw[ deprecated recursion uninitialized ];

=item $font = PDF::API2::Resource::CIDFont::TrueType->new $pdf, $file, %options

Returns a font object.

Defined Options:

    -encode ... specify fonts encoding for non-utf8 text.

    -nosubset ... disables subsetting.

=cut

sub new {
    my ($class,$pdf,$file,@opts) = @_;
    my %opts=();
    %opts=@opts if((scalar @opts)%2 == 0);
    $opts{-encode}||='latin1';
    my ($ff,$data)=PDF::API2::Resource::CIDFont::TrueType::FontFile->new($pdf,$file,@opts);

    $class = ref $class if ref $class;
    my $self=$class->SUPER::new($pdf,$data->{apiname}.pdfkey().'~'.time());
    $pdf->new_obj($self) if(defined($pdf) && !$self->is_obj($pdf));

    $self->{' data'}=$data;

    my $des=$self->descrByData;

    $self->{'BaseFont'} = PDFName($self->fontname);

    my $de=$self->{' de'};

    $de->{'FontDescriptor'} = $des;
    $de->{'Subtype'} = PDFName($self->iscff ? 'CIDFontType0' : 'CIDFontType2');
    $de->{'BaseFont'} = PDFName(pdfkey().'+'.($self->fontname).'~'.time());
    $de->{'DW'} = PDFNum($self->missingwidth);
    $des->{$self->data->{iscff} ? 'FontFile3' : 'FontFile2'}=$ff;

    unless($self->issymbol) {
        $self->encodeByName($opts{-encode});
        $self->data->{encode}=$opts{-encode};
        $self->data->{decode}='ident';
    }

    if($opts{-nosubset}) {
        $self->data->{nosubset}=1;
    }


    $self->{' ff'} = $ff;
    $pdf->new_obj($ff);

    $self->{-dokern}=1 if($opts{-dokern});

    return($self);
}


sub fontfile { return( $_[0]->{' ff'} ); }
sub fontobj { return( $_[0]->data->{obj} ); }

=item $font = PDF::API2::Resource::CIDFont::TrueType->new_api $api, $file, %options

Returns a truetype-font object. This method is different from 'new' that
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

sub wxByCId 
{
    my $self=shift @_;
    my $g=shift @_;
    my $w;

    if(defined $self->fontobj->{'hmtx'}->read->{'advance'}[$g]) 
    {
        $w = int($self->fontobj->{'hmtx'}->read->{'advance'}[$g]*1000/$self->data->{upem});
    } 
    else 
    {
        $w = $self->missingwidth;
    }

    return($w);
}

sub haveKernPairs 
{
    my $self = shift @_;
    return($self->fontfile->haveKernPairs(@_));
}

sub kernPairCid
{
    my $self = shift @_;
    return($self->fontfile->kernPairCid(@_));
}

sub subsetByCId 
{
    my $self = shift @_;
    return if($self->iscff);
    my $g = shift @_;
    $self->fontfile->subsetByCId($g);
}
sub subvec 
{
    my $self = shift @_;
    return(1) if($self->iscff);
    my $g = shift @_;
    $self->fontfile->subvec($g);
}

sub glyphNum { return ( $_[0]->fontfile->glyphNum ); }

sub outobjdeep 
{
    my ($self, $fh, $pdf, %opts) = @_;

    return $self->SUPER::outobjdeep($fh, $pdf) if defined $opts{'passthru'};

    my $notdefbefore=1;

    my $wx=PDFArray();
    $self->{' de'}->{'W'} = $wx;
    my $ml;

    foreach my $w (0..(scalar @{$self->data->{g2u}} - 1 )) 
    {
        if($self->subvec($w) && $notdefbefore==1) 
        {
            $notdefbefore=0;
            $ml=PDFArray();
            $wx->add_elements(PDFNum($w),$ml);
        #    $ml->add_elements(PDFNum($self->data->{wx}->[$w]));
            $ml->add_elements(PDFNum($self->wxByCId($w)));
        } 
        elsif($self->subvec($w) && $notdefbefore==0) 
        {
            $notdefbefore=0;
        #    $ml->add_elements(PDFNum($self->data->{wx}->[$w]));
            $ml->add_elements(PDFNum($self->wxByCId($w)));
        } 
        else 
        {
            $notdefbefore=1;
        }
        # optimization for cjk
        #if($self->subvec($w) && $notdefbefore==1 && $self->data->{wx}->[$w]!=$self->missingwidth) {
        #    $notdefbefore=0;
        #    $ml=PDFArray();
        #    $wx->add_elements(PDFNum($w),$ml);
        #    $ml->add_elements(PDFNum($self->data->{wx}->[$w]));
        #} elsif($self->subvec($w) && $notdefbefore==0 && $self->data->{wx}->[$w]!=$self->missingwidth) {
        #    $notdefbefore=0;
        #    $ml->add_elements(PDFNum($self->data->{wx}->[$w]));
        #} else {
        #    $notdefbefore=1;
        #}
    }

    $self->SUPER::outobjdeep($fh, $pdf, %opts);
}


1;

__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 2.2  2007/10/23 07:45:49  areibens
    fixed width encoding for wrong advance codes

    Revision 2.1  2007/03/17 20:38:51  areibens
    replaced IOString dep. with scalar IO.

    Revision 2.0  2005/11/16 02:16:04  areibens
    revision workaround for SF cvs import not to screw up CPAN

    Revision 1.2  2005/11/16 01:27:48  areibens
    genesis2

    Revision 1.1  2005/11/16 01:19:25  areibens
    genesis

    Revision 1.15  2005/10/20 21:04:57  fredo
    added handling of optional kerning

    Revision 1.14  2005/10/01 22:30:16  fredo
    fixed font-naming race condition for multiple document updates

    Revision 1.13  2005/09/12 16:53:23  fredo
    added -isocmap option

    Revision 1.12  2005/06/17 19:44:03  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.11  2005/06/17 18:53:34  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.10  2005/03/21 17:31:57  fredo
    cleanup

    Revision 1.9  2005/03/14 22:01:07  fredo
    upd 2005

    Revision 1.8  2005/01/21 10:01:59  fredo
    added -nosubset option

    Revision 1.7  2004/12/16 00:30:53  fredo
    added no warn for recursion

    Revision 1.6  2004/11/22 21:07:55  fredo
    fixed multibyte-encoding support to work consistently acress cjk/ttf/otf

    Revision 1.5  2004/06/15 09:14:42  fredo
    removed cr+lf

    Revision 1.4  2004/06/07 19:44:37  fredo
    cleaned out cr+lf for lf

    Revision 1.3  2003/12/08 13:05:33  Administrator
    corrected to proper licencing statement

    Revision 1.2  2003/11/30 17:30:41  Administrator
    merged into default

    Revision 1.1.1.1.2.2  2003/11/30 16:56:36  Administrator
    merged into default

    Revision 1.1.1.1.2.1  2003/11/30 14:13:33  Administrator
    added CVS id/log


=cut
