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
package PDF::API2::Resource::XObject::Image::PNM;

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

=item $res = PDF::API2::Resource::XObject::Image::PNM->new $pdf, $file [, $name]

Returns a pnm-image object.

=cut

sub new {
    my ($class,$pdf,$file,$name) = @_;
    my $self;
    my $fh = IO::File->new;

    $class = ref $class if ref $class;

    $self=$class->SUPER::new($pdf,$name || 'Nx'.pdfkey());
    $pdf->new_obj($self) unless($self->is_obj($pdf));

    $self->{' apipdf'}=$pdf;

    $self->read_pnm($pdf,$file);

    return($self);
}

=item $res = PDF::API2::Resource::XObject::Image::PNM->new_api $api, $file [, $name]

Returns a pnm-image object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $obj->{' api'}=$api;

    return($obj);
}

# READPPMHEADER 
# taken from Image::PBMLib
# Copyright by Benjamin Elijah Griffin (28 Feb 2003)
#
sub readppmheader($) {
  my $gr = shift; # input file glob ref
  my $in = '';
  my $no_comments;
  my %info;
  my $rc;
  $info{error} = undef;
  
  $rc = read($gr, $in, 3);

  if (!defined($rc) or $rc != 3) {
    $info{error} = 'Read error or EOF';
    return \%info;
  }

  if ($in =~ /^P([123456])\s/) {
    $info{type} = $1;
    if ($info{type} > 3) {
      $info{raw} = 1;
    } else {
      $info{raw} = 0;
    }

    if ($info{type} == 1 or $info{type} == 4) {
      $info{max} = 1;
      $info{bgp} = 'b';
    } elsif ($info{type} == 2 or $info{type} == 5) {
      $info{bgp} = 'g';
    } else {
      $info{bgp} = 'p';
    }

    while(1) {
      $rc = read($gr, $in, 1, length($in));
      if (!defined($rc) or $rc != 1) {
        $info{error} = 'Read error or EOF';
        return \%info;
      }

      $no_comments = $in;
      $info{comments} = '';
      while ($no_comments =~ /#.*\n/) {
        $no_comments =~ s/#(.*\n)/ /;
        $info{comments} .= $1;
      }

      if ($info{bgp} eq 'b') {
        if ($no_comments =~ /^P\d\s+(\d+)\s+(\d+)\s/) {
            $info{width}  = $1;
            $info{height} = $2;
            last;
        }
      } else {
        if ($no_comments =~ /^P\d\s+(\d+)\s+(\d+)\s+(\d+)\s/) {
            $info{width}  = $1;
            $info{height} = $2;
            $info{max}    = $3;
            last;
        }
      }
    } # while reading header

    $info{fullheader} = $in;

  } else {
    $info{error} = 'Wrong magic number';
  }

  return \%info;
}

sub read_pnm {
    my $self = shift @_;
    my $pdf = shift @_;
    my $file = shift @_;

    my ($buf,$t,$s,$line);
    my ($w,$h,$bpc,$cs,$img,@img)=(0,0,'','','');
    open(INF,$file);
    binmode(INF,':raw');
    my $info=readppmheader(INF);
    if($info->{type} == 4) {
        $bpc=1;
        read(INF,$self->{' stream'},($info->{width}*$info->{height}/8));
        $cs='DeviceGray';
    } elsif($info->{type} == 5) {
        $buf.=<INF>;
        if($info->{max}==255){
            $s=0;
        } else {
            $s=255/$info->{max};
        }
        $bpc=8;
        if($s>0) {
            for($line=($info->{width}*$info->{height});$line>0;$line--) {
                read(INF,$buf,1);
                $self->{' stream'}.=pack('C',(unpack('C',$buf)*$s));
            }
        } else {
            read(INF,$self->{' stream'},$info->{width}*$info->{height});
        }
        $cs='DeviceGray';
    } elsif($info->{type} == 6) {
        if($info->{max}==255){
            $s=0;
        } else {
            $s=255/$info->{max};
        }
        $bpc=8;
        if($s>0) {
            for($line=($info->{width}*$info->{height});$line>0;$line--) {
                read(INF,$buf,1);
                $self->{' stream'}.=pack('C',(unpack('C',$buf)*$s));
                read(INF,$buf,1);
                $self->{' stream'}.=pack('C',(unpack('C',$buf)*$s));
                read(INF,$buf,1);
                $self->{' stream'}.=pack('C',(unpack('C',$buf)*$s));
            }
        } else {
            read(INF,$self->{' stream'},$info->{width}*$info->{height}*3);
        }
        $cs='DeviceRGB';
    }
    close(INF);

    $self->width($info->{width});
    $self->height($info->{height});

    $self->bpc($bpc);

    $self->filters('FlateDecode');

    $self->colorspace($cs);

    return($self);
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 1.1  2005/11/16 01:19:27  areibens
    genesis

    Revision 1.10  2005/06/17 19:44:04  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.9  2005/06/17 18:53:35  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.8  2005/03/14 22:01:31  fredo
    upd 2005

    Revision 1.7  2004/12/16 00:30:55  fredo
    added no warn for recursion

    Revision 1.6  2004/07/24 23:38:47  fredo
    added new headerparser and simplified loading

    Revision 1.5  2004/06/15 09:14:54  fredo
    removed cr+lf

    Revision 1.4  2004/06/07 19:44:44  fredo
    cleaned out cr+lf for lf

    Revision 1.3  2003/12/08 13:06:11  Administrator
    corrected to proper licencing statement

    Revision 1.2  2003/11/30 17:37:17  Administrator
    merged into default

    Revision 1.1.1.1.2.2  2003/11/30 16:57:10  Administrator
    merged into default

    Revision 1.1.1.1.2.1  2003/11/30 16:00:42  Administrator
    added CVS id/log


=cut

pam(5) pam(5)
NAME
pam - portable arbitrary map file format
DESCRIPTION
The PAM image format is a lowest common denominator 2 dimensional map format.
It is designed to be used for any of myriad kinds of graphics, but can theoretically be used for any kind
of data that is arranged as a two dimensional rectangular array. Actually, from another perspective it
can be seen as a format for data arranged as a three dimensional array.
This format does not define the meaning of the data at any particular point in the array. It could be red,
green, and blue light intensities such that the array represents a visual image, or it could be the same
red, green, and blue components plus a transparency component, or it could contain annual rainfalls for
places on the surface of the Earth. Any process that uses the PAM format must further define the format
to specify the meanings of the data.
A PAM image describes a two dimensional grid of tuples. The tuples are arranged in rows and
columns. The width of the image is the number of columns. The height of the image is the number of
rows. All rows are the same width and all columns are the same height. The tuples may have any
degree, but all tuples have the same degree. The degree of the tuples is called the depth of the image.
Each member of a tuple is called a sample. A sample is an unsigned integer which represents a locus
along a scale which starts at zero and ends at a certain maximum value greater than zero called the
maxval. The maxval is the same for every sample in the image. The two dimensional array of all the
Nth samples of each tuple is called the Nth plane or Nth channel of the image.
Though the format does not assign any meaning to the tuple values, it does include an optional string
that describes that meaning. The contents of this string, called the tuple type, are arbitrary from the
point of view of the PAM format, but users of the format may assign meaning to it by convention so
they can identify their particular implementations of the PAM format.
The Layout
A PAM file consists of a sequence of one or more PAM images. There are no data, delimiters, or
padding before, after, or between images.
Each PAM image consists of a header followed immediately by a raster.
Here is an example header:
P7
WIDTH 227
HEIGHT 149
DEPTH 3
MAXVAL 255
TUPLETYPE RGB
ENDHDR
The header begins with the ASCII characters "P7" followed by newline. This is the magic number.
The header continues with an arbitrary number of lines of ASCII text. Each line ends with and is
delimited by a newline character.
Each header line consists of zero or more whitespace-delimited tokens or begins with "#". If it begins
with "#" it is a comment and the rest of this specification does not apply to it.
A header line which has zero tokens is valid but has no meaning.
The type of header line is identified by its first token, which is 8 characters or less:
31 July 2000 355
pam(5) pam(5)
ENDHDR
This is the last line in the header. The header must contain exactly one of these header lines.
HEIGHT
The second token is a decimal number representing the height of the image (number of rows).
The header must contain exactly one of these header lines.
WIDTH
The second token is a decimal number representing the width of the image (number of
columns). The header must contain exactly one of these header lines.
DEPTH
The second token is a decimal number representing the depth of the image (number of planes
or channels). The header must contain exactly one of these header lines.
MAXVAL
The second token is a decimal number representing the maxval of the image. The header must
contain exactly one of these header lines.
TUPLTYPE
The header may contain any number of these header lines, including zero. The rest of the line
is part of the tuple type. The rest of the line is not tokenized, but the tuple type does not
include any white space immediately following TUPLTYPE or at the very end of the line. It
does not include a newline. If there are multiple TUPLTYPE header lines, the tuple type is
the concatenation of the values from each of them, separated by a single blank, in the order in
which they appear in the header. If there are no TUPLETYPE header lines the tuple type is
the null string.
The raster consists of each row of the image, in order from top to bottom, consecutive with no delimiter
of any kind between, before, or after, rows.
Each row consists of every tuple in the row, in order from left to right, consecutive with no delimiter of
any kind between, before, or after, tuples.
Each tuple consists of every sample in the tuple, in order, consecutive with no delimiter of any kind
between, before, or after, samples.
Each sample consists of an unsigned integer in pure binary format, with the most significant byte first.
The number of bytes is the minimum number of bytes required to represent the maxval of the image.
PAMUsed For PNM (PBM, PGM, or PPM) Images
A common use of PAM images is to represent the older and more concrete PBM, PGM, and PPM
images.
A PBM image is conventionally represented as a PAM image of depth 1 with maxval 1 where the one
sample in each tuple is 0 to represent a black pixel and 1 to represent a white one. The height, width,
and raster bear the obvious relationship to those of the PBM image. The tuple type for PBM images
represented as PAM images is conventionally "BLACKANDWHITE".
A PGM image is conventionally represented as a PAM image of depth 1. The maxval, height, width,
and raster bear the obvious relationship to those of the PGM image. The tuple type for PGM images
represented as PAM images is conventionally "GRAYSCALE".
A PPM image is conventionally represented as a PAM image of depth 3. The maxval, height, width,
356 31July 2000
pam(5) pam(5)
and raster bear the obvious relationship to those of the PPM image. The first plane represents red, the
second blue, and the third green. The tuple type for PPM images represented as PAM images is conventionally
"RGB".
The Confusing Universe of Netpbm Formats
It is easy to get confused about the relationship between the PAM format and PBM, PGM, PPM, and
PNM. Here is a little enlightenment:
"PNM" is not really a format. It is a shorthand for the PBM, PGM, and PPM formats collectively. It is
also the name of a group of library functions that can each handle all three of those formats.
"PAM" is in fact a fourth format. But it is so general that you can represent the same information in a
PAM image as you can in a PBM, PGM, or PPM image. And in fact a program that is designed to read
PBM, PGM, or PPM and does so with a recent version of the Netpbm library, will read an equivalent
PAM image just fine and the program will never know the difference.
To confuse things more, there is a collection of library routines called the "pam" functions that read and
write the PAM format, but also read and write the PBM, PGM, and PPM formats. They do this because
the latter formats are much older and more popular, so this makes it convenient to write programs that
use the newer PAM format.
SEE ALSO
pbm(5), pgm(5), ppm(5), pnm(5), libpnm(3).THpbm505 March 2000
NAME
pbm - portable bitmap file format
DESCRIPTION
The portable bitmap format is a lowest common denominator monochrome file format. It serves as the
common language of a large family of bitmap conversion filters. Because the format pays no heed to
efficiency, it is simple and general enough that one can easily develop programs to convert to and from
just about any other graphics format, or to manipulate the image.
This is not a format that one would normally use to store a file or to transmit it to someone -- it’s too
expensive and not expressive enough for that. It’s just an intermediary format. In it’s purest use, it
lives only in a pipe between two other programs.
The format definition is as follows.
A PBM file consists of a sequence of one or more PBM images. There are no data, delimiters, or
padding before, after, or between images.
Each PBM image consists of the following:
- A"magic number" for identifying the file type. A pbm image’s magic number is the two characters
"P4".
- Whitespace (blanks, TABs, CRs, LFs).
- The width in pixels of the image, formatted as ASCII characters in decimal.
- Whitespace.
- The height in pixels of the image, again in ASCII decimal.
- Newline or other single whitespace character.
- A raster of Height rows, in order from top to bottom. Each row is Width bits, packed 8 to a byte,
with don’t care bits to fill out the last byte in the row. Each bit represents a pixel: 1 is black, 0 is
white. The order of the pixels is left to right. The order of their storage within each file byte is most
significant bit to least significant bit. The order of the file bytes is from the beginning of the file
toward the end of the file.
- Characters from a "#" to the next end-of-line, before the width/height line, are comments and are
ignored.
There is actually another version of the PBM format, even more more simplistic, more lavishly
31 July 2000 357
pam(5) pam(5)
wasteful of space than PBM, called Plain PBM. Plain PBM actually came first, but even its inventor
couldn’t stand its recklessly squanderous use of resources after a while and switched to what we now
know as the regular PBM format. But Plain PBM is so redundant -- so overstated -- that it’s virtually
impossible to break. You can send it through the most liberal mail system (which was the original purpose
of the PBM format) and it will arrive still readable. You can flip a dozen random bits and easily
piece back together the original image. And we hardly need to define the format here, because you can
decode it by inspection.
The difference is:
- There is exactly one image in a file.
- The "magic number" is "P1" instead of "P4".
- Each pixel in the raster is represented by a byte containing ASCII ’1’ or ’0’, representing black and
white respectively. There are no fill bits at the end of a row.
- White space in the raster section is ignored.
- You can put any junk you want after the raster, if it starts with a white space character.
- No line should be longer than 70 characters.
Here is an example of a small bitmap in the plain PBM format:
P1
# feep.pbm
24 7
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 1 1 1 1 0 0 1 1 1 1 0 0 1 1 1 1 0 0 1 1 1 1 0
0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 1 0
0 1 1 1 0 0 0 1 1 1 0 0 0 1 1 1 0 0 0 1 1 1 1 0
0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0
0 1 0 0 0 0 0 1 1 1 1 0 0 1 1 1 1 0 0 1 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
You can generate the Plain PBM format from the regular PBM format (first image in the file only) with
the pnmtoplainpnm program.
Programs that read this format should be as lenient as possible, accepting anything that looks remotely
like a bitmap.
COMPATIBILITY
Before July 2000, there could be at most one image in a PBM file. As a result, most tools to process
PBM files ignore (and don’t read) any data after the first image.
SEE ALSO
libpbm(3),pnm(5),pgm(5),ppm(5)
AUTHOR
Copyright (C) 1989, 1991 by Jef Poskanzer.
358 31July 2000
pgm(5) pgm(5)
NAME
pgm - portable graymap file format
DESCRIPTION
The PGM format is a lowest common denominator grayscale file format. It is designed to be extremely
easy to learn and write programs for. (It’s so simple that most people will simply reverse engineer it
because it’s easier than reading this specification).
A PGM image represents a grayscale graphic image. There are many psueudo-PGM formats in use
where everything is as specified herein except for the meaning of individual pixel values. For most purposes,
a PGM image can just be thought of an array of arbitrary integers, and all the programs in the
world that think they’re processing a grayscale image can easily be tricked into processing something
else.
One official variant of PGM is the transparency mask. A transparency mask in Netpbm is represented
by a PGM image, except that in place of pixel intensities, there are opaqueness values. See below.
The format definition is as follows.
A PGM file consists of a sequence of one or more PGM images. There are no data, delimiters, or
padding before, after, or between images.
Each PGM image consists of the following:
- A"magic number" for identifying the file type. A pgm image’s magic number is the two characters
"P5".
- Whitespace (blanks, TABs, CRs, LFs).
- Awidth, formatted as ASCII characters in decimal.
- Whitespace.
- Aheight, again in ASCII decimal.
- Whitespace.
- The maximum gray value (Maxval), again in ASCII decimal. Must be less than 65536.
- Newline or other single whitespace character.
- A raster of Width * Height gray values, proceeding through the image in normal English reading
order. Each gray value is a number from 0 through Maxval, with 0 being black and Maxval being
white. Each gray value is represented in pure binary by either 1 or 2 bytes. If the Maxval is less
than 256, it is 1 byte. Otherwise, it is 2 bytes. The most significant byte is first.
- Each gray value is a number proportional to the intensity of the pixel, adjusted by the CIE Rec. 709
gamma transfer function. (That transfer function specifies a gamma number of 2.2 and has a linear
section for small intensities). A value of zero is therefore black. A value of Maxval represents CIE
D65 white and the most intense value in the image and any other image to which the image might be
compared.
- Note that a common variation on the PGM format is to have the gray value be "linear," i.e. as speci-
fied above except without the gamma adjustment. pnmgamma takes such a PGM variant as input
and produces a true PGM as output.
- In the transparency mask variation on PGM, the value represents opaqueness. It is proportional to
the fraction of intensity of a pixel that would show in place of an underlying pixel, with the same
gamma transfer function mentioned above applied. So what normally means white represents total
opaqueness and what normally means black represents total transparency. In between, you would
compute the intensity of a composite pixel of an "under" and "over" pixel as under *
(1-(alpha/alpha_maxval)) + over * (alpha/alpha_maxval).<
- Characters from a "#" to the next end-of-line, before the maxval line, are comments and are ignored.
Note that you can use pnmdepth To convert between a the format with 1 byte per gray value and the
one with 2 bytes per gray value.
12 November 1991 359
pgm(5) pgm(5)
There is actually another version of the PGM format that is fairly rare: "plain" PGM format. The format
above, which generally considered the normal one, is known as the "raw" PGM format. See
pbm(5) for some commentary on how plain and raw formats relate to one another.
The difference in the plain format is:
- There is exactly one image in a file.
- The magic number is P2 instead of P5.
- Each pixel in the raster is represented as an ASCII decimal number (of arbitrary size).
- Each pixel in the raster has white space before and after it. There must be at least one character of
white space between any two pixels, but there is no maximum.
- No line should be longer than 70 characters.
Here is an example of a small graymap in this format:
P2
# feep.pgm
24 7
15
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 3 3 3 3 0 0 7 7 7 7 0 0 11 11 11 11 0 0 15 15 15 15 0
0 3 0 0 0 0 0 7 0 0 0 0 0 11 0 0 0 0 0 15 0 0 15 0
0 3 3 3 0 0 0 7 7 7 0 0 0 11 11 11 0 0 0 15 15 15 15 0
0 3 0 0 0 0 0 7 0 0 0 0 0 11 0 0 0 0 0 15 0 0 0 0
0 3 0 0 0 0 0 7 7 7 7 0 0 11 11 11 11 0 0 15 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
Programs that read this format should be as lenient as possible, accepting anything that looks remotely
like a graymap.
COMPATIBILITY
Before April 2000, a raw format PGM file could not have a maxval greater than 255. Hence, it could
not have more than one byte per sample. Old programs may depend on this.
Before July 2000, there could be at most one image in a PGM file. As a result, most tools to process
PGM files ignore (and don’t read) any data after the first image.
SEE ALSO
fitstopgm(1), fstopgm(1), hipstopgm(1), lispmtopgm(1), psidtopgm(1), rawtopgm(1), pgmbentley(1),
pgmcrater(1), pgmedge(1), pgmenhance(1), pgmhist(1), pgmnorm(1), pgmoil(1), pgmramp(1), pgmtexture(
1), pgmtofits(1), pgmtofs(1), pgmtolispm(1), pgmtopbm(1), pnm(5), pbm(5), ppm(5)
AUTHOR
Copyright (C) 1989, 1991 by Jef Poskanzer.
360 12November 1991
pnm(5) pnm(5)
NAME
pnm - portable anymap file format
DESCRIPTION
The pnm programs operate on portable bitmaps, graymaps, and pixmaps, produced by the pbm, pgm,
and ppm segments. There is no file format associated with pnm itself.
SEE ALSO
anytopnm(1), rasttopnm(1), tifftopnm(1), xwdtopnm(1), pnmtops(1), pnmtorast(1), pnmtotiff(1), pnmtoxwd(
1), pnmarith(1), pnmcat(1), pnmconvol(1), pnmcrop(1), pnmcut(1), pnmdepth(1), pnmenlarge(
1), pnmfile(1), pnmflip(1), pnmgamma(1), pnmindex(1), pnminvert(1), pnmmargin(1), pnmnoraw(
1), pnmpaste(1), pnmrotate(1), pnmscale(1), pnmshear(1), pnmsmooth(1), pnmtile(1), ppm(5),
pgm(5), pbm(5)
AUTHOR
Copyright (C) 1989, 1991 by Jef Poskanzer.
27 September 1991 361
ppm(5) ppm(5)
NAME
ppm - portable pixmap file format
DESCRIPTION
The portable pixmap format is a lowest common denominator color image file format.
It should be noted that this format is egregiously inefficient. It is highly redundant, while containing a
lot of information that the human eye can’t even discern. Furthermore, the format allows very little
information about the image besides basic color, which means you may have to couple a file in this format
with other independent information to get any decent use out of it. However, it is very easy to
write and analyze programs to process this format, and that is the point.
It should also be noted that files often conform to this format in every respect except the precise semantics
of the sample values. These files are useful because of the way PPM is used as an intermediary format.
They are informally called PPM files, but to be absolutely precise, you should indicate the variation
from true PPM. For example, "PPM using the red, green, and blue colors that the scanner in question
uses."
The format definition is as follows.
A PPM file consists of a sequence of one or more PPM images. There are no data, delimiters, or
padding before, after, or between images.
Each PPM image consists of the following:
- A"magic number" for identifying the file type. A ppm image’s magic number is the two characters
"P6".
- Whitespace (blanks, TABs, CRs, LFs).
- Awidth, formatted as ASCII characters in decimal.
- Whitespace.
- Aheight, again in ASCII decimal.
- Whitespace.
- The maximum color value (Maxval), again in ASCII decimal. Must be less than 65536.
- Newline or other single whitespace character.
- A raster of Width * Height pixels, proceeding through the image in normal English reading order.
Each pixel is a triplet of red, green, and blue samples, in that order. Each sample is represented in
pure binary by either 1 or 2 bytes. If the Maxval is less than 256, it is 1 byte. Otherwise, it is 2
bytes. The most significant byte is first.
- In the raster, the sample values are "nonlinear." They are proportional to the intensity of the CIE
Rec. 709 red, green, and blue in the pixel, adjusted by the CIE Rec. 709 gamma transfer function.
(That transfer function specifies a gamma number of 2.2 and has a linear section for small intensities).
A value of Maxval for all three samples represents CIE D65 white and the most intense color
in the color universe of which the image is part (the color universe is all the colors in all images to
which this image might be compared).
- Note that a common variation on the PPM format is to have the sample values be "linear," i.e. as
specified above except without the gamma adjustment. pnmgamma takes such a PPM variant as
input and produces a true PPM as output.
- Characters from a "#" to the next end-of-line, before the maxval line, are comments and are ignored.
Note that you can use pnmdepth to convert between a the format with 1 byte per sample and the one
with 2 bytes per sample.
There is actually another version of the PPM format that is fairly rare: "plain" PPM format. The format
above, which generally considered the normal one, is known as the "raw" PPM format. See pbm(5) for
some commentary on how plain and raw formats relate to one another.
The difference in the plain format is:
362 08April 2000
ppm(5) ppm(5)
- There is exactly one image in a file.
- The magic number is P3 instead of P6.
- Each sample in the raster is represented as an ASCII decimal number (of arbitrary size).
- Each sample in the raster has white space before and after it. There must be at least one character of
white space between any two samples, but there is no maximum. There is no particular separation of
one pixel from another -- just the required separation between the blue sample of one pixel from the
red sample of the next pixel.
- No line should be longer than 70 characters.
Here is an example of a small pixmap in this format:
P3
# feep.ppm
4 4
15
0 0 0 0 0 0 0 0 0 15 0 15
0 0 0 0 15 7 0 0 0 0 0 0
0 0 0 0 0 0 0 15 7 0 0 0
15 0 15 0 0 0 0 0 0 0 0 0
Programs that read this format should be as lenient as possible, accepting anything that looks remotely
like a pixmap.
COMPATIBILITY
Before April 2000, a raw format PPM file could not have a maxval greater than 255. Hence, it could
not have more than one byte per sample. Old programs may depend on this.
Before July 2000, there could be at most one image in a PPM file. As a result, most tools to process
PPM files ignore (and don’t read) any data after the first image.
SEE ALSO
giftopnm(1), gouldtoppm(1), ilbmtoppm(1), imgtoppm(1), mtvtoppm(1), pcxtoppm(1), pgmtoppm(1),
pi1toppm(1), picttoppm(1), pjtoppm(1), qrttoppm(1), rawtoppm(1), rgb3toppm(1), sldtoppm(1), spctoppm(
1), sputoppm(1), tgatoppm(1), ximtoppm(1), xpmtoppm(1), yuvtoppm(1), ppmtoacad(1), ppmtogif(
1), ppmtoicr(1), ppmtoilbm(1), ppmtopcx(1), ppmtopgm(1), ppmtopi1(1), ppmtopict(1), ppmtopj(
1), ppmtopuzz(1), ppmtorgb3(1), ppmtosixel(1), ppmtotga(1), ppmtouil(1), ppmtoxpm(1), ppmtoyuv(
1), ppmdither(1), ppmforge(1), ppmhist(1), ppmmake(1), ppmpat(1), ppmquant(1), ppmquantall(
1), ppmrelief(1), pnm(5), pgm(5), pbm(5)
AUTHOR
Copyright (C) 1989, 1991 by Jef Poskanzer.