#!/usr/local/bin/perl
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
#   Copyright 1999-2004 Alfred Reibenschuh <areibens@cpan.org>.
#
#=======================================================================
#
#   PERMISSION TO USE, COPY, MODIFY, AND DISTRIBUTE THIS FILE FOR
#   ANY PURPOSE WITH OR WITHOUT FEE IS HEREBY GRANTED, PROVIDED THAT
#   THE ABOVE COPYRIGHT NOTICE AND THIS PERMISSION NOTICE APPEAR IN ALL
#   COPIES.
#
#   THIS FILE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
#   WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#   MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#   IN NO EVENT SHALL THE AUTHORS AND COPYRIGHT HOLDERS AND THEIR
#   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
#   USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#   ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#   OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
#   OF THE USE OF THIS FILE, EVEN IF ADVISED OF THE POSSIBILITY OF
#   SUCH DAMAGE.
#
#   $Id$
#
#=======================================================================

use PDF::API2::Basic::PDF::File;
use PDF::API2::Basic::PDF::Utils;
use PDF::API2;
use Compress::Zlib;

sub walk_obj {
    my ($objs,$spdf,$tpdf,$obj,@keys)=@_;

    my $tobj;

    if(ref($obj)=~/Objind$/) {
        $obj->realise;
    }

    return($objs->{scalar $obj}) if(defined $objs->{scalar $obj});

  die "object already copied" if(   $obj->{' copied'});

    $tobj=$obj->copy($spdf);
    $obj->{' copied'}=1;
    $tpdf->new_obj($tobj) if($obj->is_obj($spdf) && !$tobj->is_obj($tpdf));

  $objs->{scalar $obj}=$tobj;

    if(ref($obj)=~/Array$/ || (UNIVERSAL::can($obj,'isa') && $obj->isa('PDF::API2::Basic::PDF::Array'))) {
        $tobj->{' val'}=[];
        foreach my $k ($obj->elementsof) {
            $k->realise if(ref($k)=~/Objind$/);
            $tobj->add_elements(walk_obj($objs,$spdf,$tpdf,$k));
        }
    } elsif(ref($obj)=~/Dict$/ || (UNIVERSAL::can($obj,'isa') && $obj->isa('PDF::API2::Basic::PDF::Dict'))) {
        @keys=keys(%{$tobj}) if(scalar @keys <1);
        foreach my $k (@keys) {
            next if($k=~/^ /);
            next unless(defined($obj->{$k}));
            $tobj->{$k}=walk_obj($objs,$spdf,$tpdf,$obj->{$k});
        }
        if($obj->{' stream'}) {
            if($tobj->{Filter} && !$tobj->{DecodeParms}) {
                my $f=$tobj->{Filter};
                $f=PDFArray($f) unless(ref($f)=~/Array/);
                if(scalar($f->elementsof) == 1) {
                    my ($t)=$f->elementsof;
                    if($t->val eq 'FlateDecode') {
                        $tobj->{' stream'}=uncompress($obj->{' stream'});
                        delete $tobj->{Filter};
                        $tobj->{Length}=PDFNum(length($tobj->{' stream'}));
                    } else {
                        $tobj->{' stream'}=$obj->{' stream'};
                    }
                } else {
                    $tobj->{' stream'}=$obj->{' stream'};
                }
                $tobj->{' nofilt'}=1;
            } else {
                $tobj->{' stream'}=$obj->{' stream'};
            }
        }
    }
    delete $tobj->{' streamloc'};
    delete $tobj->{' streamsrc'};
    return($tobj);
}

if(scalar @ARGV<2) {
    print "usage: $0 infile outfile\n";
    exit(1);
}
$spdf=PDF::API2::Basic::PDF::File->open($ARGV[0]);
$tpdf=PDF::API2::Basic::PDF::File->_new;
$mycache={};
$tpdf->{Root}=walk_obj($mycache,$spdf,$tpdf,$spdf->{Root});
$tpdf->{Info}=walk_obj($mycache,$spdf,$tpdf,$spdf->{Info});

$tpdf->out_file($ARGV[1]);


__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 1.1  2005/11/16 01:19:24  areibens
    genesis

    Revision 1.3  2004/06/07 19:45:04  fredo
    cleaned out cr+lf for lf

    Revision 1.2  2004/01/28 14:12:00  fredo
    updated licence statement

    Revision 1.1  2004/01/19 19:59:42  fredo
    initial import


=cut
