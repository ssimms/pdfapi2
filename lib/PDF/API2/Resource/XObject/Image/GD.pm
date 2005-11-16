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
package PDF::API2::Resource::XObject::Image::GD;

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

=item $res = PDF::API2::Resource::XObject::Image::GD->new $pdf, $obj [, $name]

Returns a image object from a GD::Image.

=cut

sub new {
    my ($class,$pdf,$obj,$name,@opts) = @_;
    my $self;

    $class = ref $class if ref $class;

    $self=$class->SUPER::new($pdf,$name|| 'Jx'.pdfkey());
    $pdf->new_obj($self) unless($self->is_obj($pdf));

    $self->{' apipdf'}=$pdf;

    $self->read_gd($obj,@opts);

    return($self);
}

=item $res = PDF::API2::Resource::XObject::Image::GD->new_api $api, $obj [, $name]

Returns a image object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $obj->{' api'}=$api;

    return($obj);
}

sub read_gd {
    my $self = shift @_;
    my $gd = shift @_;
    my %opts = @_;
    
    my ($w,$h) = $gd->getBounds();
    my $c = $gd->colorsTotal();

    $self->width($w);
    $self->height($h);

    $self->bpc(8);
    $self->colorspace('DeviceRGB');

    if(UNIVERSAL::can($gd,'jpeg') && ($c > 256) && !$opts{-lossless}) {

        $self->filters('DCTDecode');
        $self->{' nofilt'}=1;
        $self->{' stream'}=$gd->jpeg(75);

    } elsif(UNIVERSAL::can($gd,'raw')) {

        $self->filters('FlateDecode');
        $self->{' stream'}=$gd->raw;

    } else {

        $self->filters('FlateDecode');
        for(my $y=0;$y<$h;$y++) {
            for(my $x=0;$x<$w;$x++) {
                my $index=$gd->getPixel($x,$y);
                my @rgb=$gd->rgb($index);
                $self->{' stream'}.=pack('CCC',@rgb);
            }
        }

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

    Revision 1.4  2004/05/28 11:29:01  fredo
    added -lossless param to gd images

    Revision 1.3  2003/12/08 13:06:10  Administrator
    corrected to proper licencing statement

    Revision 1.2  2003/11/30 17:37:16  Administrator
    merged into default

    Revision 1.1.1.1.2.2  2003/11/30 16:57:09  Administrator
    merged into default

    Revision 1.1.1.1.2.1  2003/11/30 16:00:42  Administrator
    added CVS id/log


=cut