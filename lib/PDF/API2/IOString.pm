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
#=======================================================================
#
#   PDF::API2::IOString
#   Original Copyright 1998-2000 Gisle Aas.
#   modified by Alfred Reibenschuh <areibens@cpan.org> for PDF::API2
#
#   $Id$
#
#=======================================================================
package PDF::API2::IOString;

require 5.006;
    use vars qw($VERSION $DEBUG $IO_CONSTANTS);
    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$
use Symbol ();
use FileHandle;
no warnings qw[ deprecated recursion uninitialized ];

sub new  {
    my $class = shift;
    my $self = bless Symbol::gensym(), ref($class) || $class;
    tie *$self, $self;
    $self->open(@_);
    $self;
}

sub __import_from_file 
{
    my $self = shift @_;
    my $file = shift @_;
    my $buf = "";
    *$self->{buf} = \$buf;
    *$self->{pos} = 0;
    *$self->{lno} = 0;
    return unless($file);

    my $in;
    my $inf = undef;
    open($inf,$file);
    binmode($inf,':raw');

    $inf->seek(0,0);
    while(!$inf->eof) {
        $inf->read($in,512);
        $buf.=$in;
    }
    $inf->close;
    $self->seek(0,0);

    $self;
}

sub import_from_file {
    my $self = shift @_;
    my $file = shift @_;
    my $buf = "";
    *$self->{buf} = \$buf;
    *$self->{pos} = 0;
    *$self->{lno} = 0;
    return unless($file);

    my $in;
    my $inf = new FileHandle;
    open($inf,$file);
    binmode($inf,':raw');

    $inf->seek(0,0);
    while(!$inf->eof) {
        $inf->read($in,512);
        $self->print($in);
    }
    $inf->close;
    $self->seek(0,0);

    $self;
}
sub import_from_scalar {
    my $self = shift @_;
    my $file = shift @_;
    my $buf = "";
    *$self->{buf} = \$buf;
    *$self->{pos} = 0;
    *$self->{lno} = 0;
    $self->print($file);
    $self->seek(0,0);
    $self;
}

sub open
{
    my $self = shift;
    return $self->new(@_) unless ref($self);

    if (@_) {
    my $bufref = ref($_[0]) ? $_[0] : \$_[0];
    $$bufref = "" unless defined $$bufref;
    *$self->{buf} = $bufref;
    } else {
    my $buf = "";
    *$self->{buf} = \$buf;
    }
    *$self->{pos} = 0;
    *$self->{lno} = 0;
    $self;
}

sub pad
{
    my $self = shift;
    my $old = *$self->{pad};
    *$self->{pad} = substr($_[0], 0, 1) if @_;
    return "\0" unless defined($old) && length($old);
    $old;
}

sub dump
{
    require Data::Dumper;
    my $self = shift;
    print Data::Dumper->Dump([$self], ['*self']);
    print Data::Dumper->Dump([*$self{HASH}], ['$self{HASH}']);
}

sub TIEHANDLE
{
    print "TIEHANDLE @_\n" if $DEBUG;
    return $_[0] if ref($_[0]);
    my $class = shift;
    my $self = bless Symbol::gensym(), $class;
    $self->open(@_);
    $self;
}

sub DESTROY
{
    print "DESTROY @_\n" if $DEBUG;
}

sub close {
    my $self = shift;
    $self;
}

sub realclose
{
    my $self = shift;
    delete *$self->{buf};
    delete *$self->{pos};
    delete *$self->{lno};
    $self;
}

sub opened
{
    my $self = shift;
    defined *$self->{buf};
}

sub getc
{
    my $self = shift;
    my $buf;
    return $buf if $self->read($buf, 1);
    return undef;
}

sub ungetc
{
    my $self = shift;
    $self->setpos($self->getpos() - 1)
}

sub eof
{
    my $self = shift;
    length(${*$self->{buf}}) <= *$self->{pos};
}

sub print
{
    my $self = shift;
    if (defined $\) {
    if (defined $,) {
        $self->write(join($,, @_).$\);
    } else {
        $self->write(join("",@_).$\);
    }
    } else {
    if (defined $,) {
        $self->write(join($,, @_));
    } else {
        $self->write(join("",@_));
    }
    }
}
*printflush = \*print;

sub printf
{
    my $self = shift;
    print "PRINTF(@_)\n" if $DEBUG;
    my $fmt = shift;
    $self->write(sprintf($fmt, @_));
}


my($SEEK_SET, $SEEK_CUR, $SEEK_END);

sub _init_seek_constants
{
    if ($IO_CONSTANTS) {
    require IO::Handle;
    $SEEK_SET = &IO::Handle::SEEK_SET;
    $SEEK_CUR = &IO::Handle::SEEK_CUR;
    $SEEK_END = &IO::Handle::SEEK_END;
    } else {
    $SEEK_SET = 0;
    $SEEK_CUR = 1;
    $SEEK_END = 2;
    }
}


sub seek
{
    my($self,$off,$whence) = @_;
    my $buf = *$self->{buf} || return;
    my $len = length($$buf);
    my $pos = *$self->{pos};

    _init_seek_constants() unless defined $SEEK_SET;

    if    ($whence == $SEEK_SET) { $pos = $off }
    elsif ($whence == $SEEK_CUR) { $pos += $off }
    elsif ($whence == $SEEK_END) { $pos = $len + $off }
    else { die "Bad whence ($whence)" }
    print "SEEK(POS=$pos,OFF=$off,LEN=$len)\n" if $DEBUG;

    $pos = 0 if $pos < 0;
    $self->truncate($pos) if $pos > $len;  # extend file
    *$self->{lno} = 0;
    *$self->{pos} = $pos;
}

sub pos
{
    my $self = shift;
    my $old = *$self->{pos};
    if (@_) {
    my $pos = shift || 0;
    my $buf = *$self->{buf};
    my $len = $buf ? length($$buf) : 0;
    $pos = $len if $pos > $len;
    *$self->{lno} = 0;
    *$self->{pos} = $pos;
    }
    $old;
}

sub getpos { shift->pos; }

*sysseek = \&seek;
*setpos  = \&pos;
*tell    = \&getpos;



sub getline
{
    my $self = shift;
    my $buf  = *$self->{buf} || return;
    my $len  = length($$buf);
    my $pos  = *$self->{pos};
    return if $pos >= $len;

    unless (defined $/) {  # slurp
    *$self->{pos} = $len;
    return substr($$buf, $pos);
    }

    unless (length $/) {  # paragraph mode
    # XXX slow&lazy implementation using getc()
    my $para = "";
    my $eol = 0;
    my $c;
    while (defined($c = $self->getc)) {
        if ($c eq "\n") {
        $eol++;
        } elsif ($eol > 1) {
        $self->ungetc($c);
        last;
        }
        $para .= $c;
    }
    return $para;   # XXX wantarray
    }

    my $idx = index($$buf,$/,$pos);
    if ($idx < 0) {
    # return rest of it
    *$self->{pos} = $len;
    $. = ++ *$self->{lno};
    return substr($$buf, $pos);
    }
    $len = $idx - $pos + length($/);
    *$self->{pos} += $len;
    $. = ++ *$self->{lno};
    return substr($$buf, $pos, $len);
}

sub getlines
{
    die "getlines() called in scalar context\n" unless wantarray;
    my $self = shift;
    my($line, @lines);
    push(@lines, $line) while defined($line = $self->getline);
    return @lines;
}

sub READLINE
{
    goto &getlines if wantarray;
    goto &getline;
}

sub input_line_number
{
    my $self = shift;
    my $old = *$self->{lno};
    *$self->{lno} = shift if @_;
    $old;
}

sub truncate
{
    my $self = shift;
    my $len = shift || 0;
    my $buf = *$self->{buf};
    if (length($$buf) >= $len) {
    substr($$buf, $len) = '';
    *$self->{pos} = $len if $len < *$self->{pos};
    } else {
    $$buf .= ($self->pad x ($len - length($$buf)));
    }
    $self;
}

sub read
{
    my $self = shift;
    my $buf = *$self->{buf};
    return unless $buf;

    my $pos = *$self->{pos};
    my $rem = length($$buf) - $pos;
    my $len = $_[1];
    $len = $rem if $len > $rem;
    if (@_ > 2) { # read offset
    substr($_[0],$_[2]) = substr($$buf, $pos, $len);
    } else {
    $_[0] = substr($$buf, $pos, $len);
    }
    *$self->{pos} += $len;
    return $len;
}

sub write
{
    my $self = shift;
    my $buf = *$self->{buf};
    return unless $buf;

    my $pos = *$self->{pos};
    my $slen = length($_[0]);
    my $len = $slen;
    my $off = 0;
    if (@_ > 1) {
    $len = $_[1] if $_[1] < $len;
    if (@_ > 2) {
        $off = $_[2] || 0;
        die "Offset outside string" if $off > $slen;
        if ($off < 0) {
        $off += $slen;
        die "Offset outside string" if $off < 0;
        }
        my $rem = $slen - $off;
        $len = $rem if $rem < $len;
    }
    }
    substr($$buf, $pos, $len) = substr($_[0], $off, $len);
    *$self->{pos} += $len;
    $len;
}

*sysread = \&read;
*syswrite = \&write;

sub stat
{
    my $self = shift;
    return unless $self->opened;
    return 1 unless wantarray;
    my $len = length ${*$self->{buf}};

    return (
     undef, undef,  # dev, ino
     0666,          # filemode
     1,             # links
     $>,            # user id
     $),            # group id
     undef,         # device id
     $len,          # size
     undef,         # atime
     undef,         # mtime
     undef,         # ctime
     512,           # blksize
     int(($len+511)/512)  # blocks
    );
}

sub blocking {
    my $self = shift;
    my $old = *$self->{blocking} || 0;
    *$self->{blocking} = shift if @_;
    $old;
}

my $notmuch = sub { return };

*binmode   = $notmuch;
*BINMODE   = $notmuch;

*fileno    = $notmuch;
*FILENO    = $notmuch; # for activeperl ?
*error     = $notmuch;
*clearerr  = $notmuch;
*sync      = $notmuch;
*flush     = $notmuch;
*setbuf    = $notmuch;
*setvbuf   = $notmuch;

*untaint   = $notmuch;
*autoflush = $notmuch;
*fcntl     = $notmuch;
*ioctl     = $notmuch;

*GETC   = \&getc;
*PRINT  = \&print;
*PRINTF = \&printf;
*READ   = \&read;
*WRITE  = \&write;
*CLOSE  = \&close;
*SEEK   = \&seek;
*TELL   = \&getpos;

sub string_ref
{
    my $self = shift;
    *$self->{buf};
}
*sref = \&string_ref;

1;

__END__
