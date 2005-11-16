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

package PDF::API2::Resource::ColorSpace::DeviceN;

BEGIN {

    use strict;
    use vars qw(@ISA $VERSION);
    use PDF::API2::Resource::ColorSpace;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Util;
    use Math::Trig;

    @ISA = qw( PDF::API2::Resource::ColorSpace );
    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$

}
no warnings qw[ deprecated recursion uninitialized ];

=item $cs = PDF::API2::Resource::ColorSpace::DeviceN->new $pdf, $key, %parameters

Returns a new colorspace object.

=cut

sub new {
    my ($class,$pdf,$key,@opts)=@_;
    my ($clrs,$sampled)=@opts;
    
    $sampled=2;
    
    $class = ref $class if ref $class;
    $self=$class->SUPER::new($pdf,$key);
    $pdf->new_obj($self) unless($self->is_obj($pdf));
    $self->{' apipdf'}=$pdf;

    my $fct=PDFDict();

    my $csname=$clrs->[0]->type;
    my @xclr=map { $_->color } @{$clrs};
    my @xnam=map { $_->tintname } @{$clrs};
    # $self->{' comments'}="DeviceN ColorSpace\n";
    if($csname eq 'DeviceCMYK') {
        @xclr=map { [ namecolor_cmyk($_) ] } @xclr;

        $fct->{FunctionType}=PDFNum(0);
        $fct->{Order}=PDFNum(3);
        $fct->{Range}=PDFArray(map {PDFNum($_)} (0,1,0,1,0,1,0,1));
        $fct->{BitsPerSample}=PDFNum(8);
        $fct->{Domain}=PDFArray();
        $fct->{Size}=PDFArray();
        foreach (@xclr) {
            $fct->{Size}->add_elements(PDFNum($sampled));
            $fct->{Domain}->add_elements(PDFNum(0),PDFNum(1));
        }
        my @spec=();
        foreach my $xc (0..(scalar @xclr)-1) {
            foreach my $n (0..($sampled**(scalar @xclr))-1) {
                $spec[$n]||=[0,0,0,0];
                my $factor=($n/($sampled**$xc)) % $sampled;
                # $self->{' comments'}.="C($n): xc=$xc i=$factor ";
                my @thiscolor=map { ($_*$factor)/($sampled-1) } @{$xclr[$xc]};
                # $self->{' comments'}.="(@{$xclr[$xc]}) --> (@thiscolor) ";
                foreach my $s (0..3) {
                    $spec[$n]->[$s]+=$thiscolor[$s];
                }
                @{$spec[$n]}=map { $_>1?1:$_ } @{$spec[$n]};
                # $self->{' comments'}.="--> (@{$spec[$n]})\n";
                # $self->{' comments'}.="\n";
            }                
        }
        my @b=();
        foreach my $s (@spec) {
            push @b,(map { pack('C',($_*255)) } @{$s});
        }
        $fct->{' stream'}=join('',@b);
    } else {
        die "unsupported colorspace specification (=$csname).";
    }
    $fct->{Filter}=PDFArray(PDFName('ASCIIHexDecode'));
    $self->type($csname);
    $pdf->new_obj($fct);
    my $attr=PDFDict();
    foreach my $cs (@{$clrs}) {
        $attr->{$cs->tintname}=$cs;
    }
    $self->add_elements(PDFName('DeviceN'), PDFArray(map { PDFName($_) } @xnam), PDFName($csname), $fct);

    return($self);
}

=item $cs = PDF::API2::Resource::ColorSpace::DeviceN->new_api $api

Returns a DeviceN color-space object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},pdfkey(),@opts);
    $self->{' api'}=$api;

    return($obj);
}

sub param {
    my $self=shift @_;
    return(@_);
}


1;

__END__

=head1 HISTORY

    $Log$
    Revision 1.1  2005/11/16 01:19:27  areibens
    genesis

    Revision 1.5  2005/06/17 19:44:03  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.4  2005/06/17 18:53:34  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.3  2005/03/14 22:01:27  fredo
    upd 2005

    Revision 1.2  2004/12/16 00:30:53  fredo
    added no warn for recursion

    Revision 1.1  2004/07/20 20:27:43  fredo
    genesis


=cut
