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
package PDF::API2::Resource::XObject::Image::JPEG;

BEGIN {

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Resource::XObject::Image;

    use POSIX;

    use vars qw(@ISA $VERSION);

    @ISA = qw( PDF::API2::Resource::XObject::Image );

    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$

}
no warnings qw[ deprecated recursion uninitialized ];

=item $res = PDF::API2::Resource::XObject::Image::JPEG->new $pdf, $file [, $name]

Returns a jpeg-image object.

=cut

sub new 
{
    my ($class,$pdf,$file,$name) = @_;
    my $self;
    my $fh = IO::File->new;

    $class = ref $class if ref $class;

    $self=$class->SUPER::new($pdf,$name|| 'Jx'.pdfkey());
    $pdf->new_obj($self) unless($self->is_obj($pdf));

    $self->{' apipdf'}=$pdf;

    if(ref $file) 
    {
        $fh=$file;
    } 
    else 
    {
        open($fh,$file);
    }
    binmode($fh,':raw');

    $self->read_jpeg($fh);

    if(ref($file) eq 'PDF::API2::IOString') 
    {
        $self->{' stream'}=${*$fh->{buf}};
        $self->{Length}=PDFNum(length $self->{' stream'});
    } 
    elsif(ref $file) 
    {
        seek($fh,0,0);
        $self->{' stream'}='';
        my $buf='';
        while(!eof($fh)) {
            read($fh,$buf,512);
            $self->{' stream'}.=$buf;
        }
        $self->{Length}=PDFNum(length $self->{' stream'});
    } 
    else 
    {
        $self->{Length}=PDFNum(-s $file);
        $self->{' streamfile'}=$file;
    }

    $self->filters('DCTDecode');
    $self->{' nofilt'}=1;

    return($self);
}

=item $res = PDF::API2::Resource::XObject::Image::JPEG->new_api $api, $file [, $name]

Returns a jpeg-image object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $obj->{' api'}=$api;

    return($obj);
}

sub read_jpeg {
    my $self = shift @_;
    my $fh = shift @_;

    my ($buf, $p, $h, $w, $c, $ff, $mark, $len);

    $fh->seek(0,0);
    $fh->read($buf,2);
    while (1) {
        $fh->read($buf,4);
        my($ff, $mark, $len) = unpack("CCn", $buf);
        last if( $ff != 0xFF);
        last if( $mark == 0xDA || $mark == 0xD9);  # SOS/EOI
        last if( $len < 2);
        last if( $fh->eof);
        $fh->read($buf,$len-2);
        next if ($mark == 0xFE);
        next if ($mark >= 0xE0 && $mark <= 0xEF);
        if (($mark >= 0xC0) && ($mark <= 0xCF) && 
            ($mark != 0xC4) && ($mark != 0xC8) && ($mark != 0xCC)) {
            ($p, $h, $w, $c) = unpack("CnnC", substr($buf, 0, 6));
            last;
        }
    }

    $self->width($w);
    $self->height($h);

    $self->bpc($p);

    if($c==3) {
            $self->colorspace('DeviceRGB');
    } elsif($c==4) {
            $self->colorspace('DeviceCMYK');
    } elsif($c==1) {
            $self->colorspace('DeviceGray');
    }

    return($self);
}



1;

__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 2.0  2005/11/16 02:18:23  areibens
    revision workaround for SF cvs import not to screw up CPAN

    Revision 1.2  2005/11/16 01:27:50  areibens
    genesis2

    Revision 1.1  2005/11/16 01:19:27  areibens
    genesis

    Revision 1.11  2005/09/28 17:02:47  fredo
    fixed iostring handling

    Revision 1.10  2005/06/17 19:44:04  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.9  2005/06/17 18:53:34  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.8  2005/03/14 22:01:31  fredo
    upd 2005

    Revision 1.7  2004/12/16 00:30:55  fredo
    added no warn for recursion

    Revision 1.6  2004/06/15 09:14:54  fredo
    removed cr+lf

    Revision 1.5  2004/06/07 19:44:44  fredo
    cleaned out cr+lf for lf

    Revision 1.4  2004/03/02 21:55:24  fredo
    fixed reading jpeg image info marker according to ITU-T T.81 spec

    Revision 1.3  2003/12/08 13:06:11  Administrator
    corrected to proper licencing statement

    Revision 1.2  2003/11/30 17:37:16  Administrator
    merged into default

    Revision 1.1.1.1.2.2  2003/11/30 16:57:09  Administrator
    merged into default

    Revision 1.1.1.1.2.1  2003/11/30 16:00:42  Administrator
    added CVS id/log


=cut
