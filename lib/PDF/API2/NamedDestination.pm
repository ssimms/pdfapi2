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
package PDF::API2::NamedDestination;

=head1 NAME

PDF::API2::NamedDestination

=head1 SYNOPSIS

=head1 METHODS

=over 4

=cut

BEGIN 
{
    use utf8;
    use Encode qw(:all);

    use vars qw( @ISA $VERSION );

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Basic::PDF::Dict;
    
    @ISA=qw(PDF::API2::Basic::PDF::Dict);

    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$
}

no warnings qw[ recursion uninitialized ];

=item $dest = PDF::API2::NamedDestination->new $pdf

=cut

sub new 
{
    my ($class,$pdf) = @_;
    my ($self);
 
    $class = ref $class if ref $class;
    $self = $class->SUPER::new($pdf);
    
    $pdf->new_obj($self) unless($self->is_obj($pdf));
    
    return($self);
}

=item $dest = PDF::API2::NamedDestination->new_api $api

Returns a destination object. This method is different from 'new' that
it needs an PDF::API2-object rather than a PDF::API2::PDF::File-object.

=cut

sub new_api {
  my ($class,$api,@opts)=@_;

  my $obj=$class->new($api->{pdf},@opts);

  $api->{pdf}->new_obj($obj) unless($obj->is_obj($api->{pdf}));

  $api->{pdf}->out_obj($api->{pages});

  return($obj);
}

=item $dest->link $page, %opts

Defines the destination as launch-page with page $page and
options %opts (-rect, -border or 'dest-options').

=cut

sub link 
{
    my ($self,$page,%opts)=@_;

    $self->{S}=PDFName('GoTo');
    $self->dest($page,%opts);
    
    return($self);
}

=item $dest->url $url, %opts

Defines the destination as launch-url with url $url and
options %opts (-rect and/or -border).

=cut

sub url 
{
    my ($self,$url,%opts)=@_;

    $self->{S}=PDFName('URI');
    if(is_utf8($url)) 
    {
        # URI must be 7-bit ascii
        utf8::downgrade($url);
    }
    $self->{URI}=PDFStr($url);
    
    # this will come again -- since the utf8 urls are coming !
    # -- fredo
    #if(is_utf8($url) || utf8::valid($url)) {
    #    $self->{URI}=PDFUtf($url);
    #} else {
    #    $self->{URI}=PDFStr($url);
    #}
    return($self);
}

=item $dest->file $file, %opts

Defines the destination as launch-file with filepath $file and
options %opts (-rect and/or -border).

=cut

sub file 
{
    my ($self,$url,%opts)=@_;

    $self->{S}=PDFName('Launch');
    if(is_utf8($url)) 
    {
        # URI must be 7-bit ascii
        utf8::downgrade($url);
    }
    $self->{F}=PDFStr($url);
    
    # this will come again -- since the utf8 urls are coming !
    # -- fredo
    #if(is_utf8($url) || utf8::valid($url)) {
    #    $self->{F}=PDFUtf($url);
    #} else {
    #    $self->{F}=PDFStr($url);
    #}
    return($self);
}

=item $dest->pdfile $pdfile, $pagenum, %opts

Defines the destination as pdf-file with filepath $pdfile, $pagenum
and options %opts (same as dest).

=cut

sub pdfile 
{
    my ($self,$url,$pnum,%opts)=@_;

    $self->{S}=PDFName('GoToR');
    if(is_utf8($url)) 
    {
        # URI must be 7-bit ascii
        utf8::downgrade($url);
    }
    $self->{F}=PDFStr($url);
    
    # this will come again -- since the utf8 urls are coming !
    # -- fredo
    #if(is_utf8($url) || utf8::valid($url)) {
    #    $self->{F}=PDFUtf($url);
    #} else {
    #    $self->{F}=PDFStr($url);
    #}

    $self->dest(PDFNum($pnum),%opts);

    return($self);
}

=item $dest->dest( $page, -fit => 1 )

Display the page designated by page, with its contents magnified just enough to
fit the entire page within the window both horizontally and vertically. If the
required horizontal and vertical magnification factors are different, use the
smaller of the two, centering the page within the window in the other dimension.

=item $dest->dest( $page, -fith => $top )

Display the page designated by page, with the vertical coordinate top positioned
at the top edge of the window and the contents of the page magnified just enough
to fit the entire width of the page within the window.

=item $dest->dest( $page, -fitv => $left )

Display the page designated by page, with the horizontal coordinate left positioned
at the left edge of the window and the contents of the page magnified just enough
to fit the entire height of the page within the window.

=item $dest->dest( $page, -fitr => [ $left, $bottom, $right, $top ] )

Display the page designated by page, with its contents magnified just enough to
fit the rectangle specified by the coordinates left, bottom, right, and top
entirely within the window both horizontally and vertically. If the required
horizontal and vertical magnification factors are different, use the smaller of
the two, centering the rectangle within the window in the other dimension.

=item $dest->dest( $page, -fitb => 1 )

(PDF 1.1) Display the page designated by page, with its contents magnified just
enough to fit its bounding box entirely within the window both horizontally and
vertically. If the required horizontal and vertical magnification factors are
different, use the smaller of the two, centering the bounding box within the
window in the other dimension.

=item $dest->dest( $page, -fitbh => $top )

(PDF 1.1) Display the page designated by page, with the vertical coordinate top
positioned at the top edge of the window and the contents of the page magnified
just enough to fit the entire width of its bounding box within the window.

=item $dest->dest( $page, -fitbv => $left )

(PDF 1.1) Display the page designated by page, with the horizontal coordinate
left positioned at the left edge of the window and the contents of the page
magnified just enough to fit the entire height of its bounding box within the
window.

=item $dest->dest( $page, -xyz => [ $left, $top, $zoom ] )

Display the page designated by page, with the coordinates (left, top) positioned
at the top-left corner of the window and the contents of the page magnified by
the factor zoom. A zero (0) value for any of the parameters left, top, or zoom
specifies that the current value of that parameter is to be retained unchanged.

=cut

sub dest 
{
    my ($self,$page,%opts)=@_;

    if(ref $page)
    {
        $opts{-xyz}=[undef,undef,undef] if(scalar(keys %opts)<1);

        if(defined $opts{-fit}) 
        {
            $self->{D}=PDFArray($page,PDFName('Fit'));
        } 
        elsif(defined $opts{-fith}) 
        {
            $self->{D}=PDFArray($page,PDFName('FitH'),PDFNum($opts{-fith}));
        } 
        elsif(defined $opts{-fitb}) 
        {
            $self->{D}=PDFArray($page,PDFName('FitB'));
        } 
        elsif(defined $opts{-fitbh}) 
        {
            $self->{D}=PDFArray($page,PDFName('FitBH'),PDFNum($opts{-fitbh}));
        } 
        elsif(defined $opts{-fitv}) 
        {
            $self->{D}=PDFArray($page,PDFName('FitV'),PDFNum($opts{-fitv}));
        } 
        elsif(defined $opts{-fitbv}) 
        {
            $self->{D}=PDFArray($page,PDFName('FitBV'),PDFNum($opts{-fitbv}));
        } 
        elsif(defined $opts{-fitr}) 
        {
            die "insufficient parameters to ->dest( page, -fitr => [] ) " unless(scalar @{$opts{-fitr}} == 4);
            $self->{D}=PDFArray($page,PDFName('FitR'),map {PDFNum($_)} @{$opts{-fitr}});
        } 
        elsif(defined $opts{-xyz}) 
        {
            die "insufficient parameters to ->dest( page, -xyz => [] ) " unless(scalar @{$opts{-xyz}} == 3);
            $self->{D}=PDFArray($page,PDFName('XYZ'),map {defined $_ ? PDFNum($_) : PDFNull()} @{$opts{-xyz}});
        }
    }

    return($self);
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=cut
