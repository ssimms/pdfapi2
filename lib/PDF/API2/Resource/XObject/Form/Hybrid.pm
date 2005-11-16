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
package PDF::API2::Resource::XObject::Form::Hybrid;

BEGIN {

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Basic::PDF::Dict;
    use PDF::API2::Resource::XObject::Form;

    use PDF::API2::Content;

    use POSIX;

    use vars qw(@ISA $VERSION);

    @ISA = (
        'PDF::API2::Content',
        'PDF::API2::Resource::XObject::Form'
    );

    ( $VERSION ) = sprintf '%i.%03i', split(/\./,('$Revision$' =~ /Revision: (\S+)\s/)[0]); # $Date$
}
no warnings qw[ deprecated recursion uninitialized ];

=item $res = PDF::API2::Resource::XObject::Form::Hybrid->new $pdf

Returns a hybrid-form object.

=cut

sub new {
    my ($class,$pdf) = @_;
    my $self;

    $class = ref $class if ref $class;

    $self=PDF::API2::Resource::XObject::Form::new($class,$pdf,pdfkey());
    $pdf->new_obj($self) unless($self->is_obj($pdf));

    $self->{' apipdf'}=$pdf;

    $self->{' stream'}='';
    $self->{' poststream'}='';
    $self->{' font'}=undef;
    $self->{' fontsize'}=0;
    $self->{' charspace'}=0;
    $self->{' hspace'}=100;
    $self->{' wordspace'}=0;
    $self->{' lead'}=0;
    $self->{' rise'}=0;
    $self->{' render'}=0;
    $self->{' matrix'}=[1,0,0,1,0,0];
    $self->{' fillcolor'}=[0];
    $self->{' strokecolor'}=[0];
    $self->{' translate'}=[0,0];
    $self->{' scale'}=[1,1];
    $self->{' skew'}=[0,0];
    $self->{' rotate'}=0;
    $self->{' apiistext'}=0;

    $self->{Resources}=PDFDict();
    $self->{Resources}->{ProcSet}=PDFArray(map { PDFName($_) } qw[ PDF Text ImageB ImageC ImageI ]);

    $self->compress;

    return($self);
}

=item $res = PDF::API2::Resource::XObject::Form::Hybrid->new_api $api, $name

Returns a hybrid-form object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $obj->{' api'}=$api;

    return($obj);
}

sub outobjdeep {
    my ($self, @opts) = @_;
    $self->textend unless($self->{' nofilt'});
    foreach my $k (qw/ api apipdf apipage font fontsize charspace hspace wordspace lead rise render matrix fillcolor strokecolor translate scale skew rotate /) {
        $self->{" $k"}=undef;
        delete($self->{" $k"});
    }
    PDF::API2::Basic::PDF::Dict::outobjdeep($self,@opts);
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=head1 HISTORY

    $Log$
    Revision 1.1  2005/11/16 01:19:27  areibens
    genesis

    Revision 1.10  2005/06/17 19:44:03  fredo
    fixed CPAN modulefile versioning (again)

    Revision 1.9  2005/06/17 18:53:34  fredo
    fixed CPAN modulefile versioning (dislikes cvs)

    Revision 1.8  2005/03/14 22:01:30  fredo
    upd 2005

    Revision 1.7  2004/12/16 00:30:54  fredo
    added no warn for recursion

    Revision 1.6  2004/06/15 09:14:54  fredo
    removed cr+lf

    Revision 1.5  2004/06/07 19:44:44  fredo
    cleaned out cr+lf for lf

    Revision 1.4  2003/12/08 13:06:09  Administrator
    corrected to proper licencing statement

    Revision 1.3  2003/11/30 17:35:24  Administrator
    merged into default

    Revision 1.2.2.1  2003/11/30 16:57:09  Administrator
    merged into default

    Revision 1.2  2003/11/30 11:50:46  Administrator
    added CVS id/log


=cut
