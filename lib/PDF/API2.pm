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

package PDF::API2;

BEGIN {

    use vars qw( $VERSION $seq @FontDirs );

    ($VERSION) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]);  # $Date$

    @FontDirs = ( (map { "$_/PDF/API2/fonts" } @INC), 
        qw[ /usr/share/fonts /usr/local/share/fonts c:/windows/fonts c:/winnt/fonts ] );

    $seq="AA";

    require 5.008; # we need this for unicode support

    use PDF::API2::Basic::PDF::File;
    use PDF::API2::Basic::PDF::Page;
    use PDF::API2::Basic::PDF::Utils;

    use PDF::API2::Util;
    use PDF::API2::Page;
    use PDF::API2::IOString;

    use PDF::API2::Outlines;
    use PDF::API2::NamedDestination;

    use PDF::API2::Version;

    use PDF::API2::Resource::ExtGState;
    use PDF::API2::Resource::Pattern;
    use PDF::API2::Resource::Shading;

    use PDF::API2::Resource::Font::CoreFont;
    use PDF::API2::Resource::Font::Postscript;
    use PDF::API2::Resource::Font::BdFont;
    use PDF::API2::Resource::Font::SynFont;
    use PDF::API2::Resource::CIDFont::TrueType;
    use PDF::API2::Resource::CIDFont::CJKFont;
    use PDF::API2::Resource::UniFont;

    use PDF::API2::Resource::XObject::Image::JPEG;
    use PDF::API2::Resource::XObject::Image::TIFF;
    use PDF::API2::Resource::XObject::Image::PNM;
    use PDF::API2::Resource::XObject::Image::PNG;
    use PDF::API2::Resource::XObject::Image::GIF;
    use PDF::API2::Resource::XObject::Image::GD;

    use PDF::API2::Resource::XObject::Form::Hybrid;

    use PDF::API2::Resource::XObject::Form::BarCode::int2of5;
    use PDF::API2::Resource::XObject::Form::BarCode::codabar;
    use PDF::API2::Resource::XObject::Form::BarCode::code128;
    use PDF::API2::Resource::XObject::Form::BarCode::code3of9;
    use PDF::API2::Resource::XObject::Form::BarCode::ean13;

    use PDF::API2::Resource::ColorSpace::Indexed::ACTFile;
    use PDF::API2::Resource::ColorSpace::Indexed::Hue;
    use PDF::API2::Resource::ColorSpace::Indexed::WebColor;

    use PDF::API2::Resource::ColorSpace::Separation;
    use PDF::API2::Resource::ColorSpace::DeviceN;
    
    use Compress::Zlib;

    use Math::Trig;

    use POSIX qw( ceil floor );

    use utf8;
    use Encode qw(:all);

}

no warnings qw[ deprecated recursion uninitialized ];

=head1 NAME

PDF::API2 - A Perl Module Chain to faciliate the Creation and Modification of High-Quality "Portable Document Format (aka. PDF)" Files.

=head1 SYNOPSIS

    use PDF::API2;
    #
    $pdf = PDF::API2->new;
    $pdf = PDF::API2->open('some.pdf');
    $page = $pdf->page;
    $page = $pdf->openpage($pagenum);
    $img = $pdf->image('some.jpg');
    $font = $pdf->corefont('Times-Roman');
    $font = $pdf->ttfont('TimesNewRoman.ttf');

=head1 GENERIC METHODS

=over 4

=item $pdf = PDF::API->new %opts

Creates a new pdf-file object. If you know beforehand
to save the pdf to file you can give the '-file' option,
to minimize possible memory requirements later-on.

B<Example:>

    $pdf = PDF::API2->new();
    ...
    print $pdf->stringify;

    $pdf = PDF::API2->new();
    ...
    $pdf->saveas("our/new.pdf");

    $pdf = PDF::API2->new(-file => 'our/new.pdf');
    ...
    $pdf->save;

=cut

sub new {
    my $class=shift(@_);
    my %opt=@_;
    my $self={};
    bless($self,$class);
    $self->{pdf}=PDF::API2::Basic::PDF::File->new();
    $self->{time}='_'.pdfkey(time());

    $self->{pdf}->{' version'} = 4;
    $self->{pages} = PDF::API2::Basic::PDF::Pages->new($self->{pdf});
    $self->{pages}->proc_set(qw( PDF Text ImageB ImageC ImageI ));
    $self->{pages}->{Resources}||=PDFDict();
    $self->{pdf}->new_obj($self->{pages}->{Resources}) unless($self->{pages}->{Resources}->is_obj($self->{pdf}));
    $self->{catalog}=$self->{pdf}->{Root};
    $self->{fonts}={};
    $self->{pagestack}=[];
    $self->{forcecompress}= ($^O eq 'os390') ? 0 : 1;
    $self->preferences(%opt);
    if($opt{-file}) {
        $self->{' filed'}=$opt{-file};
        $self->{pdf}->create_file($opt{-file});
    }
    $self->{infoMeta}=[qw(  Author CreationDate ModDate Creator Producer Title Subject Keywords  )];
    $self->info( 'Producer' => $PDF::API2::Version::CVersion{vFredo}." [$^O]" );
    return $self;
}

=item $pdf = PDF::API->open $pdffile

Opens an existing PDF for modification.

B<Example:>

    $pdf = PDF::API2->open('my/old.pdf');
    ...
    $pdf->saveas("our/new.pdf");

    $pdf = PDF::API2->open('our/to/be/updated.pdf');
    ...
    $pdf->update;

=cut

sub open {
    my $class=shift(@_);
    my $file=shift(@_);
    my %opt=@_;
    my $self={};
    bless($self,$class);
    $self->default('Compression',1);
    $self->default('subset',1);
    $self->default('update',1);
    foreach my $para (keys(%opt)) {
        $self->default($para,$opt{$para});
    }
    die "File '$file' does not exist." unless(-f $file);
    my $fh=PDF::API2::IOString->new();
    $fh->import_from_file($file);
    $self->{pdf}=PDF::API2::Basic::PDF::File->open_swallowed($fh,1);
    $self->{pdf}->{' fname'}=$file;
    $self->{pdf}->{'Root'}->realise;
    $self->{pages}=$self->{pdf}->{'Root'}->{'Pages'}->realise;
    $self->{pdf}->{' version'} = 3;
    $self->{pdf}->{' apipagecount'} = 0;
    my @pages=proc_pages($self->{pdf},$self->{pages});
    $self->{pagestack}=[sort {$a->{' pnum'} <=> $b->{' pnum'}} @pages];
    $self->{catalog}=$self->{pdf}->{Root};
    $self->{reopened}=1;
    $self->{time}='_'.pdfkey(time());
    $self->{forcecompress}= ($^O eq 'os390') ? 0 : 1;
    $self->{fonts}={};
    $self->{infoMeta}=[qw(  Author CreationDate ModDate Creator Producer Title Subject Keywords  )];
    return $self;
}

=item $pdf = PDF::API->openScalar $pdfstream

Opens an existing PDF-stream for modification.

B<Example:>

    open($fh,'our/stream.pdf') or die "$@";
    @pdf = <$fh>;
    $pdf = PDF::API->openScalar(join('',@pdf));
    ...
    $pdf->saveas('our/new.pdf');

=cut

sub openScalar {
    my $class=shift(@_);
    my $file=shift(@_);
    my %opt=@_;
    my $self={};
    bless($self,$class);
    $self->default('Compression',1);
    $self->default('subset',1);
    $self->default('update',1);
    foreach my $para (keys(%opt)) {
        $self->default($para,$opt{$para});
    }
    my $fh=PDF::API2::IOString->new();
    $fh->import_from_scalar($file);
    $self->{pdf}=PDF::API2::Basic::PDF::File->open_swallowed($fh,1);
    $self->{pdf}->{'Root'}->realise;
    $self->{pages}=$self->{pdf}->{'Root'}->{'Pages'}->realise;
    $self->{pdf}->{' version'} = 3;
    $self->{pdf}->{' apipagecount'} = 0;
    my @pages=proc_pages($self->{pdf},$self->{pages});
    $self->{pagestack}=[sort {$a->{' pnum'} <=> $b->{' pnum'}} @pages];
    $self->{catalog}=$self->{pdf}->{Root};
    $self->{reopened}=1;
    $self->{time}='_'.pdfkey(time());
    $self->{forcecompress}= ($^O eq 'os390') ? 0 : 1;
    $self->{fonts}={};
    $self->{infoMeta}=[qw(  Author CreationDate ModDate Creator Producer Title Subject Keywords  )];
    return $self;
}

=item $pdf->preferences %opts

Controls viewing-preferences for the pdf.

=cut

=pod

B<Page Mode Options:>

I<-fullscreen>
... Full-screen mode, with no menu bar, window controls, or any other window visible.

I<-thumbs>
... Thumbnail images visible.

I<-outlines>
... Document outline visible.

=cut

=pod

B<Page Layout Options:>

I<-singlepage>
... Display one page at a time.

I<-onecolumn>
... Display the pages in one column.

I<-twocolumnleft>
... Display the pages in two columns, with oddnumbered pages on the left.

I<-twocolumnrigth>
... Display the pages in two columns, with oddnumbered pages on the right.

=cut

=pod

B<Viewer Options:>

I<-hidetoolbar>
        ... Specifying whether to hide tool bars.

I<-hidemenubar>
        ... Specifying whether to hide menu bars.

I<-hidewindowui>
        ... Specifying whether to hide user interface elements.

I<-fitwindow>
        ... Specifying whether to resize the document’s window to the size of the displayed page.

I<-centerwindow>
        ... Specifying whether to position the document’s window in the center of the screen.

I<-displaytitle>
        ... Specifying whether the window’s title bar should display the document title
        taken from the Title entry of the document information dictionary.

I<-afterfullscreenthumbs>
        ... Thumbnail images visible after Full-screen mode.

I<-afterfullscreenoutlines>
        ... Document outline visible after Full-screen mode.

=cut

=pod

B<Initial Page Option:>

I<-firstpage> => [ $pageobj, %opts]
        ... Specifying the page to be displayed, plus one of the following options:

=cut

=pod

B<Initial Page Options:>

I<-fit> => 1
            ... Display the page designated by page, with its contents magnified just enough to
            fit the entire page within the window both horizontally and vertically. If the
            required horizontal and vertical magnification factors are different, use the
            smaller of the two, centering the page within the window in the other dimension.

I<-fith> => $top
            ... Display the page designated by page, with the vertical coordinate top positioned
            at the top edge of the window and the contents of the page magnified just enough
            to fit the entire width of the page within the window.

I<-fitv> => $left
            ... Display the page designated by page, with the horizontal coordinate left positioned
            at the left edge of the window and the contents of the page magnified just enough
            to fit the entire height of the page within the window.

I<-fitr> => [ $left, $bottom, $right, $top ]
            ... Display the page designated by page, with its contents magnified just enough to
            fit the rectangle specified by the coordinates left, bottom, right, and top
            entirely within the window both horizontally and vertically. If the required
            horizontal and vertical magnification factors are different, use the smaller of
            the two, centering the rectangle within the window in the other dimension.

I<-fitb> => 1
            ... Display the page designated by page, with its contents magnified just enough
            to fit its bounding box entirely within the window both horizontally and
            vertically. If the required horizontal and vertical magnification factors are
            different, use the smaller of the two, centering the bounding box within the
            window in the other dimension.

I<-fitbh> => $top
            ... Display the page designated by page, with the vertical coordinate top
            positioned at the top edge of the window and the contents of the page
            magnified just enough to fit the entire width of its bounding box
            within the window.

I<-fitbv> => $left
            ... Display the page designated by page, with the horizontal coordinate
            left positioned at the left edge of the window and the contents of the page
            magnified just enough to fit the entire height of its bounding box within the
            window.

I<-xyz> => [ $left, $top, $zoom ]
            ... Display the page designated by page, with the coordinates (left, top) positioned
            at the top-left corner of the window and the contents of the page magnified by
            the factor zoom. A zero (0) value for any of the parameters left, top, or zoom
            specifies that the current value of that parameter is to be retained unchanged.

=cut

=pod

B<Example:>

    $pdf->preferences(
        -fullscreen => 1,
        -onecolumn => 1,
        -afterfullscreenoutlines => 1,
        -firstpage => [ $pageobj , -fit => 1],
    );

=cut

sub preferences {
    my $self=shift @_;
    my %opt=@_;
    if($opt{-fullscreen}) {
        $self->{catalog}->{PageMode}=PDFName('FullScreen');
    } elsif($opt{-thumbs}) {
        $self->{catalog}->{PageMode}=PDFName('UseThumbs');
    } elsif($opt{-outlines}) {
        $self->{catalog}->{PageMode}=PDFName('UseOutlines');
    } else {
        $self->{catalog}->{PageMode}=PDFName('UseNone');
    }
    if($opt{-singlepage}) {
        $self->{catalog}->{PageLayout}=PDFName('SinglePage');
    } elsif($opt{-onecolumn}) {
        $self->{catalog}->{PageLayout}=PDFName('OneColumn');
    } elsif($opt{-twocolumnleft}) {
        $self->{catalog}->{PageLayout}=PDFName('TwoColumnLeft');
    } elsif($opt{-twocolumnrigth}) {
        $self->{catalog}->{PageLayout}=PDFName('TwoColumnRight');
    } else {
        $self->{catalog}->{PageLayout}=PDFName('SinglePage');
    }

    $self->{catalog}->{ViewerPreferences}||=PDFDict();
    $self->{catalog}->{ViewerPreferences}->realise;

    if($opt{-hidetoolbar}) {
        $self->{catalog}->{ViewerPreferences}->{HideToolbar}=PDFBool(1);
    }
    if($opt{-hidemenubar}) {
        $self->{catalog}->{ViewerPreferences}->{HideMenubar}=PDFBool(1);
    }
    if($opt{-hidewindowui}) {
        $self->{catalog}->{ViewerPreferences}->{HideWindowUI}=PDFBool(1);
    }
    if($opt{-fitwindow}) {
        $self->{catalog}->{ViewerPreferences}->{FitWindow}=PDFBool(1);
    }
    if($opt{-centerwindow}) {
        $self->{catalog}->{ViewerPreferences}->{CenterWindow}=PDFBool(1);
    }
    if($opt{-displaytitle}) {
        $self->{catalog}->{ViewerPreferences}->{DisplayDocTitle}=PDFBool(1);
    }
    if($opt{-righttoleft}) {
        $self->{catalog}->{ViewerPreferences}->{Direction}=PDFName("R2L");
    }

    if($opt{-afterfullscreenthumbs}) {
        $self->{catalog}->{ViewerPreferences}->{NonFullScreenPageMode}=PDFName('UseThumbs');
    } elsif($opt{-afterfullscreenoutlines}) {
        $self->{catalog}->{ViewerPreferences}->{NonFullScreenPageMode}=PDFName('UseOutlines');
    } else {
        $self->{catalog}->{ViewerPreferences}->{NonFullScreenPageMode}=PDFName('UseNone');
    }

    if($opt{-firstpage}) {
        my ($page,%o)=@{$opt{-firstpage}};

        $o{-fit}=1 if(scalar(keys %o)<1);

        if(defined $o{-fit}) {
            $self->{catalog}->{OpenAction}=PDFArray($page,PDFName('Fit'));
        } elsif(defined $o{-fith}) {
            $self->{catalog}->{OpenAction}=PDFArray($page,PDFName('FitH'),PDFNum($o{-fith}));
        } elsif(defined $o{-fitb}) {
            $self->{catalog}->{OpenAction}=PDFArray($page,PDFName('FitB'));
        } elsif(defined $o{-fitbh}) {
            $self->{catalog}->{OpenAction}=PDFArray($page,PDFName('FitBH'),PDFNum($o{-fitbh}));
        } elsif(defined $o{-fitv}) {
            $self->{catalog}->{OpenAction}=PDFArray($page,PDFName('FitV'),PDFNum($o{-fitv}));
        } elsif(defined $o{-fitbv}) {
            $self->{catalog}->{OpenAction}=PDFArray($page,PDFName('FitBV'),PDFNum($o{-fitbv}));
        } elsif(defined $o{-fitr}) {
            die "insufficient parameters to -fitr => [] " unless(scalar @{$o{-fitr}} == 4);
            $self->{catalog}->{OpenAction}=PDFArray($page,PDFName('FitR'),map {PDFNum($_)} @{$o{-fitr}});
        } elsif(defined $o{-xyz}) {
            die "insufficient parameters to -xyz => [] " unless(scalar @{$o{-xyz}} == 3);
            $self->{catalog}->{OpenAction}=PDFArray($page,PDFName('XYZ'),map {PDFNum($_)} @{$o{-xyz}});
        }
    }
    $self->{pdf}->out_obj($self->{catalog});

    return $self;
}

=item $val = $pdf->default $parameter

=item $pdf->default $parameter, $val

Gets/Sets default values for the behaviour of ::API2.

B<Supported Parameters:>

I<nounrotate> ... prohibits API2 from rotating imported/opened page to re-create a default pdf-context.

I<pageencaps> ... enables than API2 will add save/restore commands upon imported/opened pages to preserve graphics-state for modification.

I<copyannots> ... enables importing of annotations (B<*EXPERIMENTAL*>).

=cut

sub default {
    my ($self,$parameter,$var)=@_;
    $parameter=~s/[^a-zA-Z\d]//g;
    $parameter=lc($parameter);
    my $temp=$self->{$parameter};
    if(defined $var) {
        $self->{$parameter}=$var;
    }
    return($temp);
}

=item $bool = $pdf->isEncrypted

Checks if the previously opened pdf is encrypted.

=cut

sub isEncrypted {
    my $self=shift @_;
    return(defined($self->{pdf}->{'Encrypt'}) ? 1 : 0);
}
    
=item %infohash = $pdf->info %infohash

Sets/Gets the info structure of the document.

B<Example:>

    %h = $pdf->info(
        'Author'       => " Alfred Reibenschuh ",
        'CreationDate' => "D:20020911000000+01'00'",
        'ModDate'      => "D:YYYYMMDDhhmmssOHH'mm'",
        'Creator'      => "fredos-script.pl",
        'Producer'     => "PDF::API2",
        'Title'        => "some Publication",
        'Subject'      => "perl ?",
        'Keywords'     => "all good things are pdf"
    );
    print "Author: $h{Author}\n";
    

=cut

sub info {
    my $self=shift @_;
    my %opt=@_;

    if(!defined($self->{pdf}->{'Info'})) {
            $self->{pdf}->{'Info'}=PDFDict();
            $self->{pdf}->new_obj($self->{'pdf'}->{'Info'});
    } else {
        $self->{pdf}->{'Info'}->realise;
    }

    if(scalar @_) {
      foreach my $k (@{$self->{infoMeta}}) {
        next unless(defined $opt{$k});
        if(is_utf8($opt{$k})) {
            $self->{pdf}->{'Info'}->{$k}=PDFUtf($opt{$k}||'NONE');
        #} elsif(is_utf8($opt{$k}) || utf8::valid($opt{$k})) {
        #    $self->{pdf}->{'Info'}->{$k}=PDFUtf($opt{$k}||'NONE');
        } else {
            $self->{pdf}->{'Info'}->{$k}=PDFStr($opt{$k}||'NONE');
        }
      }
      $self->{pdf}->out_obj($self->{pdf}->{'Info'});
    }


    if(defined $self->{pdf}->{'Info'}) {
      %opt=();
      foreach my $k (@{$self->{infoMeta}}) {
        next unless(defined $self->{pdf}->{'Info'}->{$k});
        $opt{$k}=$self->{pdf}->{'Info'}->{$k}->val;
        if(unpack('n',$opt{$k})==0xfffe) {
            my ($mark,@c)=unpack('n*',$opt{$k});
            $opt{$k}=pack('U*',@c);
        } elsif(unpack('n',$opt{$k})==0xfeff) {
            my ($mark,@c)=unpack('v*',$opt{$k});
            $opt{$k}=pack('U*',@c);
        }
      }
  }
  return(%opt);
}

=item @meta_data_attribs = $pdf->infoMetaAttributes @meta_data_attribs

Sets/Gets the supported info-structure tags.

B<Example:>

    @attrs = $pdf->infoMetaAttributes;
    print "Supported Attributes: @attr\n";
    @attrs = $pdf->infoMetaAttributes('CustomField1');
    print "Supported Attributes: @attr\n";

=cut

sub infoMetaAttributes 
{
    my ($self,@attr) = @_;
    if(scalar @attr > 0) {
        my %at = map { $_ => $_ } (@{$self->{infoMeta}},@attr);
        @{$self->{infoMeta}}=(keys %at);
    }
    return(@{$self->{infoMeta}});
}

=item $xml = $pdf->xmpMetadata $xml

Sets/Gets the XMP XML data-stream.

B<Example:>

    $xml = $pdf->xmpMetadata;
    print "PDFs Metadata reads: $xml\n";
    $xml=<<EOT;
    <?xpacket begin='ï»¿' id='W5M0MpCehiHzreSzNTczkc9d'?>
    <?adobe-xap-filters esc="CRLF"?>
    <x:xmpmeta xmlns:x='adobe:ns:meta/' x:xmptk='XMP toolkit 2.9.1-14, framework 1.6'>
    <rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' xmlns:iX='http://ns.adobe.com/iX/1.0/'>
    <rdf:Description rdf:about='uuid:b8659d3a-369e-11d9-b951-000393c97fd8' xmlns:pdf='http://ns.adobe.com/pdf/1.3/' pdf:Producer='Acrobat Distiller 6.0.1 for Macintosh'></rdf:Description>
    <rdf:Description rdf:about='uuid:b8659d3a-369e-11d9-b951-000393c97fd8' xmlns:xap='http://ns.adobe.com/xap/1.0/' xap:CreateDate='2004-11-14T08:41:16Z' xap:ModifyDate='2004-11-14T16:38:50-08:00' xap:CreatorTool='FrameMaker 7.0' xap:MetadataDate='2004-11-14T16:38:50-08:00'></rdf:Description>
    <rdf:Description rdf:about='uuid:b8659d3a-369e-11d9-b951-000393c97fd8' xmlns:xapMM='http://ns.adobe.com/xap/1.0/mm/' xapMM:DocumentID='uuid:919b9378-369c-11d9-a2b5-000393c97fd8'/>
    <rdf:Description rdf:about='uuid:b8659d3a-369e-11d9-b951-000393c97fd8' xmlns:dc='http://purl.org/dc/elements/1.1/' dc:format='application/pdf'><dc:description><rdf:Alt><rdf:li xml:lang='x-default'>Adobe Portable Document Format (PDF)</rdf:li></rdf:Alt></dc:description><dc:creator><rdf:Seq><rdf:li>Adobe Systems Incorporated</rdf:li></rdf:Seq></dc:creator><dc:title><rdf:Alt><rdf:li xml:lang='x-default'>PDF Reference, version 1.6</rdf:li></rdf:Alt></dc:title></rdf:Description>
    </rdf:RDF>
    </x:xmpmeta>
    <?xpacket end='w'?>
    EOT
    $xml = $pdf->xmpMetadata($xml);
    print "PDFs Metadata now reads: $xml\n";
    
=cut

sub xmpMetadata {
    my $self=shift @_;

    if(!defined($self->{catalog}->{Metadata})) 
    {
            $self->{catalog}->{Metadata}=PDFDict();
            $self->{catalog}->{Metadata}->{Type}=PDFName('Metadata');
            $self->{catalog}->{Metadata}->{Subtype}=PDFName('XML');
            $self->{pdf}->new_obj($self->{catalog}->{Metadata});
    } 
    else 
    {
        $self->{catalog}->{Metadata}->realise;
        $self->{catalog}->{Metadata}->{' stream'}=unfilter($self->{catalog}->{Metadata}->{Filter}, $self->{catalog}->{Metadata}->{' stream'});
        delete $self->{catalog}->{Metadata}->{' nofilt'};
        delete $self->{catalog}->{Metadata}->{Filter};
    }
    
    my $md=$self->{catalog}->{Metadata};
    
    if(defined $_[0])
    {
        $md->{' stream'}=$_[0];
        delete $md->{Filter};
        delete $md->{' nofilt'};
        $self->{pdf}->out_obj($md);
    }
    return($md->{' stream'});
}

=item $pdf->finishobjects @objects

Force objects to be written to file if available.

B<Example:>

    $pdf = PDF::API2->new(-file => 'our/new.pdf');
    ...
    $pdf->finishobjects($page, $gfx, $txt);
    ...
    $pdf->save;

=cut

sub finishobjects {
    my ($self,@objs)=@_;
    if($self->{reopened}) {
        die "invalid method invokation: no file, use 'saveas' instead.";
    } elsif($self->{' filed'}) {
        $self->{pdf}->ship_out(@objs);
    } else {
        die "invalid method invokation: no file, use 'saveas' instead.";
    }
}

sub proc_pages {
    my ($pdf, $pgs) = @_;
    my ($pg, $pgref, @pglist);

    if(defined($pgs->{Resources})) {
        eval {
            $pgs->{Resources}->realise;
        };
    }
    foreach $pg ($pgs->{'Kids'}->elementsof) {
        $pg->realise;
        if ($pg->{'Type'}->val =~ m/^Pages$/o) 
        {
            my @morepages = proc_pages($pdf, $pg);
            push(@pglist, @morepages);
        } 
        else 
        {
            $pdf->{' apipagecount'}++;
            $pg->{' pnum'} = $pdf->{' apipagecount'};
            if(defined($pg->{Resources})) {
                eval {
                    $pg->{Resources}->realise;
                };
            }
            push (@pglist, $pg);
        }
    }
    return(@pglist);
}

=item $pdf->update

Updates a previously "opened" document after all changes have been applied.

B<Example:>

    $pdf = PDF::API2->open('our/to/be/updated.pdf');
    ...
    $pdf->update;

=cut

sub update {
    my $self=shift @_;
    $self->saveas($self->{pdf}->{' fname'});
}

=item $pdf->saveas $file

Saves the document to file.

B<Example:>

    $pdf = PDF::API2->new();
    ...
    $pdf->saveas("our/new.pdf");

=cut

sub saveas {
    my ($self,$file)=@_;
    if($self->{reopened}) {
        $self->{pdf}->append_file;
        CORE::open(OUTF,">$file");
        binmode(OUTF,':raw');
        print OUTF ${$self->{pdf}->{' OUTFILE'}->string_ref};
        CORE::close(OUTF);
    } elsif($self->{' filed'}) {
        $self->{pdf}->close_file;
    } else {
        $self->{pdf}->out_file($file);
    }
    $self->end;
}

sub save {
    my ($self,$file)=@_;
    if($self->{reopened}) {
        die "invalid method invokation: use 'saveas' instead.";
    } elsif($self->{' filed'}) {
        $self->{pdf}->close_file;
    } else {
        die "invalid method invokation: use 'saveas' instead.";
    }
    $self->end;
}

sub save_xml {
    my ($self,$file)=@_;
    my $fh=IO::File->new;
    $fh->open("> $file");
    $self->{pdf}->save_xml($fh);
    $fh->close;
    $self->end;
}


=item $string = $pdf->stringify

Returns the document in a string.

B<Example:>

    $pdf = PDF::API2->new();
    ...
    print $pdf->stringify;

=cut

sub stringify {
    my ($self)=@_;
    my $str;
    if((defined $self->{reopened}) && ($self->{reopened}==1)) {
        $self->{pdf}->append_file;
        $str=${$self->{pdf}->{' OUTFILE'}->string_ref};
    } else {
        my $fh = PDF::API2::IOString->new();
        $fh->open();
        eval {
            $self->{pdf}->out_file($fh);
        };
        $str=${$fh->string_ref};
        $fh->realclose;
    }
    $self->end;
    return($str);
}

sub release { $_[0]->end; return(undef);}

=item $pdf->end

Destroys the document.

=cut

sub end {
    my $self=shift(@_);
    $self->{pdf}->release if(defined($self->{pdf}));

        foreach my $key (keys %{$self})
        {
            $self->{$key}=undef;
            delete ($self->{$key});
        }

    undef;
}

=back

=head1 PAGE METHODS

=over 4

=item $page = $pdf->page

=item $page = $pdf->page $index

Returns a new page object or inserts-and-returns a new page at $index.

B<Note:> on $index

    -1 ... is inserted before the last page
    1 ... is inserted before page number 1 (the first page)
    0 ... is simply appended

=cut

sub page {
    my $self=shift;
    my $index=shift || 0;
    my $page;
    if($index==0) {
        $page=PDF::API2::Page->new($self->{pdf},$self->{pages});
    } else {
        $page=PDF::API2::Page->new($self->{pdf},$self->{pages},$index);
    }
    $page->{' apipdf'}=$self->{pdf};
    $page->{' api'}=$self;
    $self->{pdf}->out_obj($page);
    $self->{pdf}->out_obj($self->{pages});
    if($index==0) {
        push(@{$self->{pagestack}},$page);
    } elsif($index<0) {
        splice(@{$self->{pagestack}},$index,0,$page);
    } else {
        splice(@{$self->{pagestack}},$index-1,0,$page);
    }
 #   $page->{Resources}=$self->{pages}->{Resources};
    return $page;
}

=item $pageobj = $pdf->openpage $index

Returns the pageobject of page $index.

B<Note:> on $index

    -1,0 ... returns the last page
    1 ... returns page number 1

B<Example:> (A Document with 99 Pages)

    $page = $pdf->openpage(1);   # returns the first page
    $page = $pdf->openpage(99);  # returns the last page
    $page = $pdf->openpage(-1);  # returns the last page
    $page = $pdf->openpage(999); # returns undef

=cut

sub openpage {
    my $self=shift @_;
    my $index=shift @_||0;
    my ($page,$rotate,$media,$trans);

    if($index==0) 
    {
        $page=$self->{pagestack}->[-1];
    } 
    elsif($index<0) 
    {
        $page=$self->{pagestack}->[$index];
    } 
    else 
    {
        $page=$self->{pagestack}->[$index-1];
    }
    return undef unless(ref $page);
    
    if(ref($page) ne 'PDF::API2::Page') 
    {
        bless($page,'PDF::API2::Page');
        $page->{' apipdf'}=$self->{pdf};
        $page->{' api'}=$self;
        $self->{pdf}->out_obj($page);
        if(($rotate=$page->find_prop('Rotate')) && (!defined($page->{' fixed'}) || $page->{' fixed'}<1)) 
        {
            $rotate=($rotate->val+360)%360;

            if($rotate!=0 && !$self->default('nounrotate')) {
                $page->{Rotate}=PDFNum(0);
                foreach my $mediatype (qw( MediaBox CropBox BleedBox TrimBox ArtBox )) {
                    if($media=$page->find_prop($mediatype)) {
                        $media=[ map{ $_->val } $media->elementsof ];
                    } else {
                        $media=[0,0,612,792];
                        next if($mediatype ne 'MediaBox');
                    }
                    if($rotate==90) {
                        $trans="0 -1 1 0 0 $media->[2] cm" if($mediatype eq 'MediaBox');
                        $media=[$media->[1],$media->[0],$media->[3],$media->[2]];
                    } elsif($rotate==180) {
                        $trans="-1 0 0 -1 $media->[2] $media->[3] cm" if($mediatype eq 'MediaBox');
                    } elsif($rotate==270) {
                        $trans="0 1 -1 0 $media->[3] 0 cm" if($mediatype eq 'MediaBox');
                        $media=[$media->[1],$media->[0],$media->[3],$media->[2]];
                    }
                    $page->{$mediatype}=PDFArray(map { PDFNum($_) } @{$media});
                }
            } else {
                $trans="";
            }
        } else {
            $trans="";
        }

        if(defined $page->{Contents} && (!defined($page->{' fixed'}) || $page->{' fixed'}<1) ) {
            $page->fixcontents;
            my $uncontent=$page->{Contents};
            delete $page->{Contents};
            my $content=$page->gfx();
            $content->add(" $trans ");

            if($self->default('pageencaps'))
            {
                $content->{' stream'}.=" q ";
            }
            foreach my $k ($uncontent->elementsof) 
            {
                $k->realise;
                    $content->{' stream'}.=" ".unfilter($k->{Filter}, $k->{' stream'})." ";
            }
            if($self->default('pageencaps'))
            {
                $content->{' stream'}.=" Q ";
            }

            ## $content->{Length}=PDFNum(length($content->{' stream'}));
            # this  will be fixed by the following code or content or filters

            ## if we like compress we will do it now to do quicker saves
            if($self->{forcecompress}>0){
            ##    $content->compress;
                $content->{' stream'}=dofilter($content->{Filter}, $content->{' stream'});
                $content->{' nofilt'}=1;
                delete $content->{-docompress};
                $content->{Length}=PDFNum(length($content->{' stream'}));
            }
            $page->{' fixed'}=1;
        }
    }

    $self->{pdf}->out_obj($page);
    $self->{pdf}->out_obj($self->{pages});
    $page->{' apipdf'}=$self->{pdf};
    $page->{' api'}=$self;
    $page->{' reopened'}=1;
    return($page);
}


# $target_object = walk_obj $obj_cache, $source_pdf, $target_pdf, $source_object [, @keys_to_copy ]

sub walk_obj {
    my ($objs,$spdf,$tpdf,$obj,@keys)=@_;

    my $tobj;


    if(ref($obj)=~/Objind$/) {
        $obj->realise;
    }

    return($objs->{scalar $obj}) if(defined $objs->{scalar $obj});
####die "infinite loop while copying objects" if($obj->{' copied'});

    $tobj=$obj->copy($spdf); ## thanks to: yaheath // Fri, 17 Sep 2004
    
####$obj->{' copied'}=1;
    $tpdf->new_obj($tobj) if($obj->is_obj($spdf));

    $objs->{scalar $obj}=$tobj;

    if(ref($obj)=~/Array$/) {
        $tobj->{' val'}=[];
        foreach my $k ($obj->elementsof) {
            $k->realise if(ref($k)=~/Objind$/);
            $tobj->add_elements(walk_obj($objs,$spdf,$tpdf,$k));
        }
    } elsif(ref($obj)=~/Dict$/) {
        @keys=keys(%{$tobj}) if(scalar @keys <1);
        foreach my $k (@keys) {
            next if($k=~/^ /);
            next unless(defined($obj->{$k}));
            $tobj->{$k}=walk_obj($objs,$spdf,$tpdf,$obj->{$k});
        }
        if($obj->{' stream'}) {
            if($tobj->{Filter}) {
                $tobj->{' nofilt'}=1;
            } else {
                delete $tobj->{' nofilt'};
                $tobj->{Filter}=PDFArray(PDFName('FlateDecode'));
            }
            $tobj->{' stream'}=$obj->{' stream'};
        }
    }
    delete $tobj->{' streamloc'};
    delete $tobj->{' streamsrc'};
    return($tobj);
}

=item $xoform = $pdf->importPageIntoForm $sourcepdf, $sourceindex

Returns a form-xobject created from $sourcepdf,$sourceindex.
This is useful if you want to transpose the imported page-description
somewhat differently onto a page (ie. two-up, four-up, duplex, etc.).

B<Note:> on $index

    -1,0 ... returns the last page
    1 ... returns page number 1

B<Example:>

    $pdf = PDF::API2->new;
    $old = PDF::API2->open('my/old.pdf');
    $xo = $pdf->importPageIntoForm($old,2); # get page 2
    $page = $pdf->page;
    $gfx = $page->gfx;
    $gfx->formimage($xo,0,0,1); # put it on page 1 with scale x1
    $pdf->saveas("our/new.pdf");

=cut

sub importPageIntoForm {
    my $self=shift @_;
    my $s_pdf=shift @_;
    my $s_idx=shift @_||0;

    my ($s_page,$xo);

    $xo=$self->xo_form;

    if(ref($s_idx) eq 'PDF::API2::Page') {
        $s_page=$s_idx;
    } else {
        $s_page=$s_pdf->openpage($s_idx);
    }

    $self->{apiimportcache}||={};
    $self->{apiimportcache}->{$s_pdf}||={};

    foreach my $k (qw( MediaBox ArtBox TrimBox BleedBox CropBox )) {
        #next unless(defined $s_page->{$k});
        #my $box = walk_obj($self->{apiimportcache}->{$s_pdf},$s_pdf->{pdf},$self->{pdf},$s_page->{$k});
        next unless(defined $s_page->find_prop($k));
        my $box = walk_obj($self->{apiimportcache}->{$s_pdf},$s_pdf->{pdf},$self->{pdf},$s_page->find_prop($k));
        $xo->bbox(map { $_->val } $box->elementsof);
        last;
    }
    $xo->bbox( 0, 0, 612, 792) unless(defined $xo->{BBox});

    foreach my $k (qw( Resources )) {
        $s_page->{$k}=$s_page->find_prop($k);
        next unless(defined $s_page->{$k});
        $s_page->{$k}->realise if(ref($s_page->{$k})=~/Objind$/);

        foreach my $sk (qw( XObject ExtGState Font ProcSet Properties ColorSpace Pattern Shading )) {
            next unless(defined $s_page->{$k}->{$sk});
            $s_page->{$k}->{$sk}->realise if(ref($s_page->{$k}->{$sk})=~/Objind$/);
            foreach my $ssk (keys %{$s_page->{$k}->{$sk}}) {
                next if($ssk=~/^ /);
                $xo->resource($sk,$ssk,walk_obj($self->{apiimportcache}->{$s_pdf},$s_pdf->{pdf},$self->{pdf},$s_page->{$k}->{$sk}->{$ssk}));
            }
        }
    }

    # create a whole content stream
    ## technically it is possible to submit an unfinished
    ## (eg. newly created) source-page, but thats non-sense,
    ## so we expect a page fixed by openpage and die otherwise
    die "page not processed via openpage ... " unless($s_page->{' fixed'}==1);

    # since the source page comes from openpage it may already
    # contain the required starting 'q' without the final 'Q'
    # if forcecompress is in effect
    if(defined $s_page->{Contents}) {
        $s_page->fixcontents;

        $xo->{' stream'}="";
        # openpage pages only contain one stream
        my ($k)=$s_page->{Contents}->elementsof;
        $k->realise;
        if($k->{' nofilt'}) {
          # we have a finished stream here
          # so we unfilter
          $xo->add('q',unfilter($k->{Filter}, $k->{' stream'}),'Q');
        } else {
          # stream is an unfinished/unfiltered content
          # so we just copy it and add the required "qQ"
            $xo->add('q',$k->{' stream'},'Q');
        }
        $xo->compress if($self->{forcecompress}>0);
    }

    return($xo);
}

=item $pageobj = $pdf->importpage $sourcepdf, $sourceindex, $targetindex

Returns the pageobject of page $targetindex, imported from $sourcepdf,$sourceindex.

B<Note:> on $index

    -1,0 ... returns the last page
    1 ... returns page number 1

B<Note:> you can specify a page object instead as $targetindex
so that the contents of the sourcepage will be 'merged into'.

B<Example:>

    $pdf = PDF::API2->new;
    $old = PDF::API2->open('my/old.pdf');
    $page = $pdf->importPage($old,2); # get page 2 into page 1
    $pdf->saveas("our/new.pdf");

=cut

# B<Note:> the interactive forms of a page will also be imported, but may
# cause problems if forms of another document have already been imported.

sub importpage {
    my $self=shift @_;
    my $s_pdf=shift @_;
    my $s_idx=shift @_||0;
    my $t_idx=shift @_||0;
    my ($s_page,$t_page);

    if(ref($s_idx) eq 'PDF::API2::Page') {
        $s_page=$s_idx;
    } else {
        $s_page=$s_pdf->openpage($s_idx);
    }

    if(ref($t_idx) eq 'PDF::API2::Page') {
        $t_page=$t_idx;
    } else {
        if($self->pages<$t_idx) {
            $t_page=$self->page;
        } else {
            $t_page=$self->page($t_idx);
        }
    }

    $self->{apiimportcache}=$self->{apiimportcache}||{};
    $self->{apiimportcache}->{$s_pdf}=$self->{apiimportcache}->{$s_pdf}||{};

    # we now import into a form to keep
    # all that nasty resources from polluting
    # our very own resource naming space.
    my $xo = $self->importPageIntoForm($s_pdf,$s_page);
    $t_page->mediabox( map { $_->val } $xo->{BBox}->elementsof) if(defined $xo->{BBox});
    $t_page->gfx->formimage($xo,0,0,1);

    # copy annotations and/or form elements as well
    if (exists $s_page->{Annots} and $s_page->{Annots} and $self->{copyannots}) {

            # first set up the AcroForm, if required
            my $AcroForm;
            if (my $a = $s_pdf->{pdf}->{Root}->realise->{AcroForm}) {
                    $a->realise;

                    $AcroForm = walk_obj({},$s_pdf->{pdf},$self->{pdf},$a,qw( NeedAppearances SigFlags CO DR DA Q ));
            }
            my @Fields = ();
            my @Annots = ();
            foreach my $a ($s_page->{Annots}->elementsof) {
                    $a->realise;
                    my $t_a = PDFDict();
                    $self->{pdf}->new_obj($t_a);
                    # these objects are likely to be both annotations and Acroform fields
                    # key names are copied from PDF Reference 1.4 (Tables)
                    my @k = (
                            qw( Type Subtype Contents P Rect NM M F BS Border AP AS C CA T Popup A AA StructParent Rotate
                            ),                                      # Annotations - Common (8.10)
                            qw( Subtype Contents Open Name ),       # Text Annotations (8.15)
                            qw( Subtype Contents Dest H PA ),       # Link Annotations (8.16)
                            qw( Subtype Contents DA Q ),            # Free Text Annotations (8.17)
                            qw( Subtype Contents L BS LE IC ) ,     # Line Annotations (8.18)
                            qw( Subtype Contents BS IC ),           # Square and Circle Annotations (8.20)
                            qw( Subtype Contents QuadPoints ),      # Markup Annotations (8.21)
                            qw( Subtype Contents Name ),            # Rubber Stamp Annotations (8.22)
                            qw( Subtype Contents InkList BS ),      # Ink Annotations (8.23)
                            qw( Subtype Contents Parent Open ),     # Popup Annotations (8.24)
                            qw( Subtype FS Contents Name ),         # File Attachment Annotations (8.25)
                            qw( Subtype Sound Contents Name ),      # Sound Annotations (8.26)
                            qw( Subtype Movie Contents A ),         # Movie Annotations (8.27)
                            qw( Subtype Contents H MK ),            # Widget Annotations (8.28)
                                                                    # Printers Mark Annotations (none)
                                                                    # Trap Network Annotations (none)
                    );
                    push @k, (
                            qw( Subtype FT Parent Kids T TU TM Ff V DV AA
                            ),                                      # Fields - Common (8.49)
                            qw( DR DA Q ),                          # Fields containing variable text (8.51)
                            qw( Opt ),                              # Checkbox field (8.54)
                            qw( Opt ),                              # Radio field (8.55)
                            qw( MaxLen ),                           # Text field (8.57)
                            qw( Opt TI I ),                         # Choice field (8.59)
                    ) if $AcroForm;
                    # sorting out dups
                    my %ky=map { $_ => 1 } @k;
                    # we do P separately, as it points to the page the Annotation is on
                    delete $ky{P};
                    # copy everything else
                    foreach my $k (keys %ky) {
                            next unless defined $a->{$k};
                            $a->{$k}->realise;
                            $t_a->{$k} = walk_obj({},$s_pdf->{pdf},$self->{pdf},$a->{$k});
                    }
                    $t_a->{P} = $t_page;
                    push @Annots, $t_a;
                    push @Fields, $t_a if ($AcroForm and $t_a->{Subtype}->val eq 'Widget');
            }
            $t_page->{Annots} = PDFArray(@Annots);
            $AcroForm->{Fields} = PDFArray(@Fields) if $AcroForm;
            $self->{pdf}->{Root}->{AcroForm} = $AcroForm;
    }
    $t_page->{' imported'} = 1;

    $self->{pdf}->out_obj($t_page);
    $self->{pdf}->out_obj($self->{pages});

    return($t_page);
}

=item $pagenumber = $pdf->pages

Returns the number of pages in the document.

=cut

sub pages {
    my $self=shift @_;
    return scalar @{$self->{pagestack}};
}

=item $pdf->mediabox $name

=item $pdf->mediabox $w, $h

=item $pdf->mediabox $llx, $lly, $urx, $ury

Sets the global mediabox. Other methods: cropbox, bleedbox, trimbox and artbox.

B<Example:>

    $pdf = PDF::API2->new;
    $pdf->mediabox('A4');
    ...
    $pdf->saveas("our/new.pdf");

    $pdf = PDF::API2->new;
    $pdf->mediabox(595,842);
    ...
    $pdf->saveas("our/new.pdf");

    $pdf = PDF::API2->new;
    $pdf->mediabox(0,0,595,842);
    ...
    $pdf->saveas("our/new.pdf");


=cut

sub mediabox {
    my ($self,$x1,$y1,$x2,$y2) = @_;
    $self->{pages}->{'MediaBox'}=PDFArray( map { PDFNum(float($_)) } page_size($x1,$y1,$x2,$y2) );
    $self;
}

=item $pdf->cropbox $name

=item $pdf->cropbox $w, $h

=item $pdf->cropbox $llx, $lly, $urx, $ury

Sets the global cropbox.

B<Example:>

    $pdf = PDF::API2->new;
    $pdf->cropbox('A4');
    ...
    $pdf->saveas("our/new.pdf");

    $pdf = PDF::API2->new;
    $pdf->cropbox(595,842);
    ...
    $pdf->saveas("our/new.pdf");

    $pdf = PDF::API2->new;
    $pdf->cropbox(0,0,595,842);
    ...
    $pdf->saveas("our/new.pdf");

=cut

sub cropbox {
    my ($self,$x1,$y1,$x2,$y2) = @_;
    $self->{pages}->{'CropBox'}=PDFArray( map { PDFNum(float($_)) } page_size($x1,$y1,$x2,$y2) );
    $self;
}

=item $pdf->bleedbox $name

=item $pdf->bleedbox $w, $h

=item $pdf->bleedbox $llx, $lly, $urx, $ury

Sets the global bleedbox.

B<Example:>

    $pdf = PDF::API2->new;
    $pdf->bleedbox('A4');
    ...
    $pdf->saveas("our/new.pdf");

    $pdf = PDF::API2->new;
    $pdf->bleedbox(595,842);
    ...
    $pdf->saveas("our/new.pdf");

    $pdf = PDF::API2->new;
    $pdf->bleedbox(0,0,595,842);
    ...
    $pdf->saveas("our/new.pdf");

=cut

sub bleedbox {
    my ($self,$x1,$y1,$x2,$y2) = @_;
    $self->{pages}->{'BleedBox'}=PDFArray( map { PDFNum(float($_)) } page_size($x1,$y1,$x2,$y2) );
    $self;
}

=item $pdf->trimbox $name

=item $pdf->trimbox $w, $h

=item $pdf->trimbox $llx, $lly, $urx, $ury

Sets the global trimbox.

B<Example:>

    $pdf = PDF::API2->new;
    $pdf->trimbox('A4');
    ...
    $pdf->saveas("our/new.pdf");

    $pdf = PDF::API2->new;
    $pdf->trimbox(595,842);
    ...
    $pdf->saveas("our/new.pdf");

    $pdf = PDF::API2->new;
    $pdf->trimbox(0,0,595,842);
    ...
    $pdf->saveas("our/new.pdf");

=cut

sub trimbox {
    my ($self,$x1,$y1,$x2,$y2) = @_;
    $self->{pages}->{'TrimBox'}=PDFArray( map { PDFNum(float($_)) } page_size($x1,$y1,$x2,$y2) );
    $self;
}

=item $pdf->artbox $name

=item $pdf->artbox $w, $h

=item $pdf->artbox $llx, $lly, $urx, $ury

Sets the global artbox.

B<Example:>

    $pdf = PDF::API2->new;
    $pdf->artbox('A4');
    ...
    $pdf->saveas("our/new.pdf");

    $pdf = PDF::API2->new;
    $pdf->artbox(595,842);
    ...
    $pdf->saveas("our/new.pdf");

    $pdf = PDF::API2->new;
    $pdf->artbox(0,0,595,842);
    ...
    $pdf->saveas("our/new.pdf");

=cut

sub artbox {
    my ($self,$x1,$y1,$x2,$y2) = @_;
    $self->{pages}->{'ArtBox'}=PDFArray( map { PDFNum(float($_)) } page_size($x1,$y1,$x2,$y2) );
    $self;
}

=back

=head1 FONT METHODS

=over 4

=item @allFontDirs = PDF::API2::addFontDirs $dir1, ..., $dirN

Adds one or more directories to the search-path for finding font files.
Returns the list of searched directories.

=cut

sub addFontDirs {
    push( @FontDirs, @_ );
    return( @FontDirs );
}

sub _findFont {
    my $font=shift @_;
    my @fonts=($font,map { "$_/$font" } @FontDirs);
    while((scalar @fonts > 0) && (! -f $fonts[0])) { shift @fonts; }
    return($fonts[0]);
}

=item $font = $pdf->corefont $fontname [, %options]

Returns a new adobe core font object.

=cut

=pod

See L<PDF::API2::Resource::Font::CoreFont> for an explanation.


B<Examples:>

    $font = $pdf->corefont('Times-Roman');
    $font = $pdf->corefont('Times-Bold');
    $font = $pdf->corefont('Helvetica');
    $font = $pdf->corefont('ZapfDingbats');


Valid %options are:

  '-encode' ... changes the encoding of the font from its default.

  '-dokern' ... enables kerning if data is available.

=cut

sub corefont {
    my ($self,$name,@opts)=@_;
    my $obj=PDF::API2::Resource::Font::CoreFont->new_api($self,$name,@opts);
    $self->resource('Font',$obj->name,$obj);
    $self->{pdf}->out_obj($self->{pages});
    $obj->tounicodemap;
    return($obj);
}

=item $font = $pdf->psfont $psfile  [, %options]

Returns a new adobe type1 font object.

=cut

=pod

See L<PDF::API2::Resource::Font::Postscript> for an explanation.

B<Examples:>

    $font = $pdf->psfont( 'Times-Book.pfa', -afmfile => 'Times-Book.afm' );
    $font = $pdf->psfont( '/fonts/Synest-FB.pfb', -pfmfile => '/fonts/Synest-FB.pfm' );

Valid %options are:

  '-encode' ... changes the encoding of the font from its default.

  '-afmfile' ... specifies that font metrics to be read from the
                adobe font metrics file (AFM).

  '-pfmfile' ... specifies that font metrics to be read from the
                windows printer font metrics file (PFM).
                (this option overrides the -encode option)

  '-dokern' ... enables kerning if data is available.

=cut

sub psfont {
    my ($self,$psf,%opts)=@_;

    foreach my $o (qw(-afmfile -pfmfile)) {
        next unless(defined $opts{$o});
        $opts{$o}=_findFont($opts{$o});
    }
    $psf=_findFont($psf);
    my $obj=PDF::API2::Resource::Font::Postscript->new_api($self,$psf,%opts);

    $self->resource('Font',$obj->name,$obj,$self->{reopened});

    $self->{pdf}->out_obj($self->{pages});
    $obj->tounicodemap;
    return($obj);
}

=item $font = $pdf->ttfont $ttfile  [, %options]

Returns a new truetype or opentype font object.

=cut

=pod

See L<PDF::API2::Resource::CIDFont::TrueType> for an explanation.

B<Examples:>

    $font = $pdf->ttfont('Times.ttf');
    $font = $pdf->ttfont('Georgia.otf');

Valid %options are:

  '-encode' ... changes the encoding of the font from its default.

  '-isocmap' ... per default the MS Unicode Map is used, if this 
                 option is given the ISO Unicode Map will be used.

  '-dokern' ... enables kerning if data is available.

=cut

sub ttfont {
    my ($self,$file,%opts)=@_;

    $file=_findFont($file);
    my $obj=PDF::API2::Resource::CIDFont::TrueType->new_api($self,$file,%opts);

    $self->resource('Font',$obj->name,$obj,$self->{reopened});

    $self->{pdf}->out_obj($self->{pages});
    $obj->tounicodemap;
    return($obj);
}

=item $font = $pdf->cjkfont $cjkname  [, %options]

Returns a new cjk font object.

=cut

=pod

See L<PDF::API2::Resource::CIDFont::CJKFont> for an explanation.

B<Examples:>

    $font = $pdf->cjkfont('korean');
    $font = $pdf->cjkfont('traditional');

Valid %options are:

  '-encode' ... changes the encoding of the font from its default.

=cut

sub cjkfont {
    my ($self,$name,%opts)=@_;

    my $obj=PDF::API2::Resource::CIDFont::CJKFont->new_api($self,$name,%opts);

    $self->resource('Font',$obj->name,$obj,$self->{reopened});

    $self->{pdf}->out_obj($self->{pages});
    $obj->tounicodemap;
    return($obj);
}

=item $font = $pdf->synfont $basefont  [, %options]

Returns a new synthetic font object.

=cut

=pod

See L<PDF::API2::Resource::Font::SynFont> for an explanation.

B<Examples:>

    $cf = $pdf->corefont('Times-Roman',-encode=>'latin1');
    $sf = $pdf->synfont($cf,-slant=>0.85);  # compressed 85%
    $sfb= $pdf->synfont($cf,-bold=>1);      # embolden by 10em
    $sfi= $pdf->synfont($cf,-oblique=>-12); # italic at -12 degrees

Valid %options are:

I<-slant>
... slant/expansion factor (0.1-0.9 = slant, 1.1+ = expansion).

I<-oblique>
... italic angle (+/-)

I<-bold>
... embolding factor (0.1+, bold=1, heavy=2, ...)

I<-space>
... additional charspacing in em (0-1000)

=cut

sub synfont {
    my ($self,@opts)=@_;

    my $obj=PDF::API2::Resource::Font::SynFont->new_api($self,@opts);

    $self->resource('Font',$obj->name,$obj,$self->{reopened});

    $self->{pdf}->out_obj($self->{pages});
    $obj->tounicodemap;
    return($obj);
}

=item $font = $pdf->bdfont $bdffile

Returns a new BDF font object, based on the specified adobe-bdf file.

=cut

=pod

See L<PDF::API2::Resource::Font::BdFont> for an explanation.

=cut

sub bdfont {
    my ($self,@opts)=@_;

    my $obj=PDF::API2::Resource::Font::BdFont->new_api($self,@opts);

    $self->resource('Font',$obj->name,$obj,$self->{reopened});

    $self->{pdf}->out_obj($self->{pages});
    ## $obj->tounicodemap; # does not support unicode!
    return($obj);
}

=item $font = $pdf->unifont @fontspecs, %options

Returns a new uni-font object, based on the specified fonts and options.

=cut

=pod

B<BEWARE:> This is not a true pdf-object, but a virtual/abstract font-definition !

See L<PDF::API2::Resource::UniFont> for an explanation.

Valid %options are:

  '-encode' ... changes the encoding of the font from its default.

=cut

sub unifont {
    my ($self,@opts)=@_;

    my $obj=PDF::API2::Resource::UniFont->new_api($self,@opts);

    return($obj);
}

=back

=head1 IMAGE METHODS

=over 4

=item $jpeg = $pdf->image_jpeg $file

Returns a new jpeg image object.

=cut

sub image_jpeg {
    my ($self,$file,%opts)=@_;

    my $obj=PDF::API2::Resource::XObject::Image::JPEG->new_api($self,$file);

    $self->resource('XObject',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $tiff = $pdf->image_tiff $file

Returns a new tiff image object.

=cut

sub image_tiff {
    my ($self,$file,%opts)=@_;

    my $obj=PDF::API2::Resource::XObject::Image::TIFF->new_api($self,$file);

    $self->resource('XObject',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $pnm = $pdf->image_pnm $file

Returns a new pnm image object.

=cut

sub image_pnm {
    my ($self,$file,%opts)=@_;

    my $obj=PDF::API2::Resource::XObject::Image::PNM->new_api($self,$file);

    $self->resource('XObject',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $png = $pdf->image_png $file

Returns a new png image object.

=cut

sub image_png {
    my ($self,$file,%opts)=@_;

    my $obj=PDF::API2::Resource::XObject::Image::PNG->new_api($self,$file);

    $self->resource('XObject',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $gif = $pdf->image_gif $file

Returns a new gif image object.

=cut

sub image_gif {
    my ($self,$file,%opts)=@_;

    my $obj=PDF::API2::Resource::XObject::Image::GIF->new_api($self,$file);

    $self->resource('XObject',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $gdf = $pdf->image_gd $gdobj, %options

Returns a new image object from GD::Image.

B<Options:> The only option currently supported is C<-lossless =E<gt> 1>.

=cut

sub image_gd {
    my ($self,$gd,%opts)=@_;

    my $obj=PDF::API2::Resource::XObject::Image::GD->new_api($self,$gd,undef,%opts);

    $self->resource('XObject',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

#=item $img = $pdf->image_rgb $file_or_ref, %options
#
#Returns a new image object from a raw RGB image.
#
#B<Options:> C<-width>, C<-height>, C<-bits> (required).
#
#=cut
#
#sub image_rgb {
#    my ($self,$rgb,@opts)=@_;
#
#    my $obj=PDF::API2::Resource::XObject::Image::RGBA->new_api($self,$rgb,-alpha=>0,@opts);
#
#    $self->resource('XObject',$obj->name,$obj);
#
#    $self->{pdf}->out_obj($self->{pages});
#    return($obj);
#}

#=item $img = $pdf->image_rgba $file_or_ref, %options
#
#Returns a new image object from a raw RGBA image.
#
#B<Options:> C<-width>, C<-height>, C<-bits> (required).
#
#=cut
#
#sub image_rgba {
#    my ($self,$rgb,@opts)=@_;
#
#    my $obj=PDF::API2::Resource::XObject::Image::RGBA->new_api($self,$rgb,-alpha=>1,@opts);
#
#    $self->resource('XObject',$obj->name,$obj);
#
#    $self->{pdf}->out_obj($self->{pages});
#    return($obj);
#}

#=item $img = $pdf->image_cmyk $file_or_ref, %options
#
#Returns a new image object from a raw CMYK image.
#
#B<Options:> C<-width>, C<-height>, C<-bits> (required).
#
#=cut
#
#sub image_cmyk {
#    my ($self,$rgb,@opts)=@_;
#
#    my $obj=PDF::API2::Resource::XObject::Image::CMYKA->new_api($self,$rgb,-alpha=>0,@opts);
#
#    $self->resource('XObject',$obj->name,$obj);
#
#    $self->{pdf}->out_obj($self->{pages});
#    return($obj);
#}

#=item $img = $pdf->image_cmyka $file_or_ref, %options
#
#Returns a new image object from a raw CMYKA image.
#
#B<Options:> C<-width>, C<-height>, C<-bits> (required).
#
#=cut
#
#sub image_cmyka {
#    my ($self,$rgb,@opts)=@_;
#
#    my $obj=PDF::API2::Resource::XObject::Image::CMYKA->new_api($self,$rgb,-alpha=>1,@opts);
#
#    $self->resource('XObject',$obj->name,$obj);
#
#    $self->{pdf}->out_obj($self->{pages});
#    return($obj);
#}

#=item $img = $pdf->image_indexed $file_or_ref, %options
#
#Returns a new image object from a raw indexed image.
#
#B<Options:> C<-width>, C<-height>, C<-bits>, C<-colorspace> (required).
#
#=cut
#
#sub image_indexed {
#    my ($self,$rgb,@opts)=@_;
#
#    my $obj=PDF::API2::Resource::XObject::Image::Indexed->new_api($self,$rgb,-alpha=>0,@opts);
#
#    $self->resource('XObject',$obj->name,$obj);
#
#    $self->{pdf}->out_obj($self->{pages});
#    return($obj);
#}

#=item $img = $pdf->image_indexedalpha $file_or_ref, %options
#
#Returns a new image object from a raw indexed-alpha image.
#
#B<Options:> C<-width>, C<-height>, C<-bits>, C<-colorspace> (required).
#
#=cut
#
#sub image_indexedalpha {
#    my ($self,$rgb,@opts)=@_;
#
#    my $obj=PDF::API2::Resource::XObject::Image::Indexed->new_api($self,$rgb,-alpha=>1,@opts);
#
#    $self->resource('XObject',$obj->name,$obj);
#
#    $self->{pdf}->out_obj($self->{pages});
#    return($obj);
#}

=pod

B<Examples:>

    $jpeg = $pdf->image_jpeg('../some/nice/picture.jpeg');
    $tiff = $pdf->image_tiff('../some/nice/picture.tiff');
    $pnm = $pdf->image_pnm('../some/nice/picture.pnm');
    $png = $pdf->image_png('../some/nice/picture.png');
    $gif = $pdf->image_gif('../some/nice/picture.gif');
    $gdf = $pdf->image_gd($gdobj);

=back

=head1 COLORSPACE METHODS

=over 4

=item $cs = $pdf->colorspace_act $file

Returns a new colorspace-object based on a adobe-color-table file.

=cut

=pod

See L<PDF::API2::Resource::ColorSpace::Indexed::ACTFile> for an explanation of the file format.

=cut

sub colorspace_act {
    my ($self,$file,%opts)=@_;

    my $obj=PDF::API2::Resource::ColorSpace::Indexed::ACTFile->new_api($self,$file);

    $self->resource('ColorSpace',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $cs = $pdf->colorspace_web

Returns a new colorspace-object based on the web color palette.

=cut

=pod

See L<PDF::API2::Resource::ColorSpace::Indexed::WebColor> for an explanation.

=cut

sub colorspace_web {
    my ($self,$file,%opts)=@_;

    my $obj=PDF::API2::Resource::ColorSpace::Indexed::WebColor->new_api($self);

    $self->resource('ColorSpace',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $cs = $pdf->colorspace_hue

Returns a new colorspace-object based on the hue color palette.

=cut

=pod

See L<PDF::API2::Resource::ColorSpace::Indexed::Hue> for an explanation.

=cut

sub colorspace_hue {
    my ($self,$file,%opts)=@_;

    my $obj=PDF::API2::Resource::ColorSpace::Indexed::Hue->new_api($self);

    $self->resource('ColorSpace',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $cs = $pdf->colorspace_separation $tint, $color

Returns a new separation colorspace-object based on the parameters.

=cut

=pod

I<$tint> can be any valid ink-identifier, including but not limited to:
'Cyan', 'Magenta', 'Yellow', 'Black', 'Red', 'Green', 'Blue' or 'Orange'.

I<$color> must be a valid color-specification limited to:
'#rrggbb', '!hhssvv', '%ccmmyykk' or a "named color" (rgb).

The colorspace model for will be automatically chosen based on the specified color.

=cut

sub colorspace_separation {
    my ($self,$name,@clr)=@_;
    my $obj=PDF::API2::Resource::ColorSpace::Separation->new_api($self,$name,@clr);

    $self->resource('ColorSpace',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $cs = $pdf->colorspace_devicen \@tintCSx [, $samples]

Returns a new DeviceN colorspace-object based on the parameters.

B<Example:> 

    $cy = $pdf->colorspace_separation('Cyan',    '%f000');
    $ma = $pdf->colorspace_separation('Magenta', '%0f00');
    $ye = $pdf->colorspace_separation('Yellow',  '%00f0');
    $bk = $pdf->colorspace_separation('Black',   '%000f');
    $pms023 = $pdf->colorspace_separation('PANTONE 032CV', '%0ff0');

    $dncs = $pdf->colorspace_devicen( [ $cy,$ma,$ye,$bk,$pms023 ] );
    
=cut

=pod

The colorspace model for will be automatically chosen based on the first colorspace specified.

=cut

sub colorspace_devicen {
    my ($self,$clrs,$samples)=@_;
    $samples||=2;
    
    my $obj=PDF::API2::Resource::ColorSpace::DeviceN->new_api($self,$clrs,$samples);

    $self->resource('ColorSpace',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=back

=head1 BARCODE METHODS

=over 4

=item $bc = $pdf->xo_codabar %opts

=item $bc = $pdf->xo_code128 %opts

=item $bc = $pdf->xo_2of5int %opts

=item $bc = $pdf->xo_3of9 %opts

=item $bc = $pdf->xo_ean13 %opts

creates the specified barcode object as a form-xo.

=cut

sub xo_code128 {
    my ($self,@opts)=@_;

    my $obj=PDF::API2::Resource::XObject::Form::BarCode::code128->new_api($self,@opts);

    $self->resource('XObject',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

sub xo_codabar {
    my ($self,@opts)=@_;

    my $obj=PDF::API2::Resource::XObject::Form::BarCode::codabar->new_api($self,@opts);

    $self->resource('XObject',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

sub xo_2of5int {
    my ($self,@opts)=@_;

    my $obj=PDF::API2::Resource::XObject::Form::BarCode::int2of5->new_api($self,@opts);

    $self->resource('XObject',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

sub xo_3of9 {
    my ($self,@opts)=@_;

    my $obj=PDF::API2::Resource::XObject::Form::BarCode::code3of9->new_api($self,@opts);

    $self->resource('XObject',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

sub xo_ean13 {
    my ($self,@opts)=@_;

    my $obj=PDF::API2::Resource::XObject::Form::BarCode::ean13->new_api($self,@opts);

    $self->resource('XObject',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=back

=head1 OTHER METHODS

=over 4

=item $xo = $pdf->xo_form

Returns a new form-xobject.

B<Examples:>

    $xo = $pdf->xo_form;

=cut

sub xo_form {
    my ($self)=@_;

    my $obj=PDF::API2::Resource::XObject::Form::Hybrid->new_api($self);

    $self->resource('XObject',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $egs = $pdf->egstate

Returns a new extended graphics state object.

B<Examples:>

    $egs = $pdf->egstate;

=cut

sub egstate {
    my ($self)=@_;

    my $obj=PDF::API2::Resource::ExtGState->new_api($self,pdfkey());

    $self->resource('ExtGState',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $obj = $pdf->pattern

Returns a new pattern-object.

=cut

sub pattern {
    my ($self,%opts)=@_;

    my $obj=PDF::API2::Resource::Pattern->new_api($self,undef,%opts);

    $self->resource('Pattern',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $obj = $pdf->shading

Returns a new shading-object.

=cut

sub shading {
    my ($self,%opts)=@_;

    my $obj=PDF::API2::Resource::Shading->new_api($self,undef,%opts);

    $self->resource('Shading',$obj->name,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $otls = $pdf->outlines

Returns a new or existing outlines object.

=cut

sub outlines {
    my ($self)=@_;

    $self->{pdf}->{Root}->{Outlines}||=PDF::API2::Outlines->new($self);

    my $obj=$self->{pdf}->{Root}->{Outlines};

    $self->{pdf}->new_obj($obj) if(!$obj->is_obj($self->{pdf}));
    $self->{pdf}->out_obj($obj);
    $self->{pdf}->out_obj($self->{pdf}->{Root});

    return($obj);

}

#=item $dst $pdf->named_destination $category, $name
#
#Returns a new or existing outlines object.
#
#=cut

sub named_destination
{
    my ($self,$cat,$name,$obj)=@_;
    my $root=$self->{catalog};

    $root->{Names}||=PDFDict();
    $root->{Names}->{$cat}||=PDFDict();
    $root->{Names}->{$cat}->{-vals}||={};
    $root->{Names}->{$cat}->{Limits}||=PDFArray();
    $root->{Names}->{$cat}->{Names}||=PDFArray();
    
    unless(defined $obj)
    {
        $obj=PDF::API2::NamedDestination->new_api($self);
    }
    $root->{Names}->{$cat}->{-vals}->{$name}=$obj;
    
    my @names=sort {$a cmp $b} keys %{$root->{Names}->{$cat}->{-vals}};
    
    $root->{Names}->{$cat}->{Limits}->{' val'}->[0]=PDFStr($names[0]);
    $root->{Names}->{$cat}->{Limits}->{' val'}->[1]=PDFStr($names[-1]);
    
    @{$root->{Names}->{$cat}->{Names}->{' val'}}=();
    
    foreach my $k (@names)
    {
        push @{$root->{Names}->{$cat}->{Names}->{' val'}},
            PDFStr($k),$root->{Names}->{$cat}->{-vals}->{$k};
    }

    return($obj);
}

=back

=head1 RESOURCE METHODS

=over 4

=item $pdf->resource $type, $key, $obj, $force

Adds a resource to the global pdf tree.

B<Example:>

    $pdf->resource('Font',$fontkey,$fontobj);
    $pdf->resource('XObject',$imagekey,$imageobj);
    $pdf->resource('Shading',$shadekey,$shadeobj);
    $pdf->resource('ColorSpace',$spacekey,$speceobj);

B<Note:> You only have to add the required resources, if
they are NOT handled by the *font*, *image*, *shade* or *space*
methods.

=cut

sub resource 
{
    return(undef);
    my ($self, $type, $key, $obj, $force) = @_;

    $self->{pages}->{Resources}||=PDFDict();

    my $dict=$self->{pages}->{Resources};
    $dict->realise if(ref($dict)=~/Objind$/);

    $self->{pdf}->new_obj($dict) unless($dict->is_obj($self->{pdf}));

    $dict->{$type}=$dict->{$type} || PDFDict();
    $dict->{$type}->realise if(ref($dict->{$type})=~/Objind$/);

    if(defined($obj)) 
    {
        if($force) 
        {
            $dict->{$type}->{$key}=$obj;
        } 
        else 
        {
            $dict->{$type}->{$key}=$dict->{$type}->{$key} || $obj;
        }

        $self->{pdf}->out_obj($dict)
            if($dict->is_obj($self->{pdf}));

        $self->{pdf}->out_obj($dict->{$type})
            if($dict->{$type}->is_obj($self->{pdf}));

        $self->{pdf}->out_obj($obj)
            if($obj->is_obj($self->{pdf}));

        $self->{pdf}->out_obj($self->{pages});

        return($dict);
    }
    return($dict->{$type}->{$key} || undef);
}

1;

__END__

=back

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 1.2  2005/11/16 01:27:48  areibens
    genesis2

    Revision 1.1  2005/11/16 01:19:24  areibens
    genesis

    Revision 1.86  2005/10/21 19:51:05  fredo
    fixed proc_pages

    Revision 1.85  2005/10/20 21:06:39  fredo
    documented '-dokern' option for ttfonts

    Revision 1.84  2005/10/19 21:23:26  fredo
    documented '-dokern' option for core- and psfonts

    Revision 1.83  2005/09/12 16:54:21  fredo
    added -isocmap option

    Revision 1.82  2005/06/17 19:43:45  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.81  2005/06/17 18:53:04  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.80  2005/06/10 16:12:49  fredo
    documentation update

    Revision 1.79  2005/03/23 16:42:06  fredo
    fixed typo in infoMetaAttributes

    Revision 1.78  2005/03/21 22:36:36  fredo
    fix for landscape imports

    Revision 1.77  2005/03/15 17:31:06  fredo
    corrected utf8 handling in info tags

    Revision 1.76  2005/03/14 23:53:51  fredo
    added xmpMetadata method to get/set XMP document data

    Revision 1.75  2005/03/14 22:01:05  fredo
    upd 2005

    Revision 1.74  2005/02/25 18:07:48  fredo
    no message

    Revision 1.73  2005/02/17 07:03:14  fredo
    added 'pageencaps' default option to fix unusual styled content streams

    Revision 1.72  2005/02/14 20:09:48  fredo
    fixed an openpage recompression bug / thanks to steve_wu@iinet.net.au

    Revision 1.71  2005/01/03 03:47:52  fredo
    fixed use named destination

    Revision 1.70  2005/01/03 03:46:25  fredo
    added named destination support

    Revision 1.69  2004/12/31 03:12:09  fredo
    no message

    Revision 1.68  2004/12/16 00:30:51  fredo
    added no warn for recursion

    Revision 1.67  2004/11/29 15:19:23  fredo
    added docs for bdfont, synfont and unifont

    Revision 1.66  2004/11/24 20:09:57  fredo
    added unifont

    Revision 1.65  2004/10/17 03:57:21  fredo
    added ToUnicode call for supported fonts

    Revision 1.64  2004/10/01 01:39:24  fredo
    reverted annotations import fix

    Revision 1.63  2004/09/30 23:57:26  fredo
    versioning beautify

    Revision 1.62  2004/09/30 22:40:41  fredo
    fixed pdf-producer to include OS

    Revision 1.61  2004/09/30 21:18:21  fredo
    changed file version back to cvs

    Revision 1.60  2004/09/20 11:22:18  fredo
    added default param to fix import-rotation
    added default param to fix annotation-import

    Revision 1.59  2004/09/03 12:35:09  fredo
    pop'd to new version

    Revision 1.58  2004/08/25 02:59:25  fredo
    disabled memoize since long-running scripts bug from reused adresses

    Revision 1.57  2004/07/24 23:10:55  fredo
    fixed memoize bug for bdf fonts

    Revision 1.56  2004/07/24 23:09:26  fredo
    added bdf fonts

    Revision 1.55  2004/07/23 13:41:11  fredo
    fixed in decoding info dictionary

    Revision 1.54  2004/07/21 08:07:17  fredo
    added devicen colorspace

    Revision 1.53  2004/07/15 14:28:21  fredo
    added devicen colorspace

    Revision 1.52  2004/06/22 01:33:43  fredo
    corrected spelling

    Revision 1.51  2004/06/21 22:33:10  fredo
    added basic pattern/shading handling

    Revision 1.50  2004/06/15 09:06:26  fredo
    forced version to 1.50 for beta state

    Revision 1.30  2004/06/15 08:09:07  fredo
    fixed memoized bug

    Revision 1.29  2004/06/01 00:09:57  fredo
    memoized *font methods for braindead invokers

    Revision 1.28  2004/05/28 11:29:01  fredo
    added -lossless param to gd images

    Revision 1.27  2004/05/21 10:12:29  fredo
    fixed slight importpage quirk

    Revision 1.26  2004/04/18 18:07:19  fredo
    fixed _findFont method

    Revision 1.25  2004/04/07 17:38:00  fredo
    added infoMetaAttributes and support code

    Revision 1.24  2004/04/07 10:48:53  fredo
    fixed handling of ColorSpace/Separation

    Revision 1.23  2004/04/06 21:00:52  fredo
    separation colorspace now a full resource

    Revision 1.22  2004/04/04 23:42:10  fredo
    fixed 270 degree rotation in openpage

    Revision 1.21  2004/04/04 23:36:33  fredo
    added simple separation colorspace

    Revision 1.20  2004/03/20 09:11:45  fredo
    modified font search path methodname

    Revision 1.19  2004/03/20 08:38:38  fredo
    added isEncrypted determinator

    Revision 1.18  2004/03/18 09:43:32  fredo
    added font search path handling

    Revision 1.17  2004/02/12 14:38:33  fredo
    added openScalar method

    Revision 1.16  2004/02/05 13:18:39  fredo
    corrected info hash utf8 usage

    Revision 1.15  2004/02/04 23:43:53  fredo
    pdf info method now properly recognized utf8 parameters

    Revision 1.14  2004/01/21 12:29:06  fredo
    moved release versioning to PDF::API2::Version

    Revision 1.13  2004/01/19 14:16:32  fredo
    update for 0.40_16

    Revision 1.12  2004/01/15 21:26:04  fredo
    docbug: fixed inconsistent links

    Revision 1.11  2004/01/14 18:25:41  fredo
    release update 0.40_15

    Revision 1.10  2004/01/12 13:52:41  fredo
    update for 0.40_14

    Revision 1.9  2004/01/08 23:56:20  fredo
    corrected producer tag versioning, updated to release 0.40_13

    Revision 1.8  2003/12/08 13:05:18  Administrator
    corrected to proper licencing statement

    Revision 1.7  2003/12/08 11:47:38  Administrator
    change step 3 for proper module versioning

    Revision 1.6  2003/12/08 11:46:25  Administrator
    change step 2 for proper module versioning

    Revision 1.5  2003/12/08 11:43:10  Administrator
    change step 1 for proper module versioning

    Revision 1.4  2003/11/30 19:00:43  Administrator
    added Code128/EAN128

    Revision 1.3  2003/11/30 17:07:11  Administrator
    merged into default


=cut

