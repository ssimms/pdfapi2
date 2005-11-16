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
#=======================================================================
#
#   THIS IS A REUSED PERL MODULE, FOR PROPER LICENCING TERMS SEE BELOW:
#
#
#   Copyright Martin Hosken <Martin_Hosken@sil.org>
#
#   No warranty or expression of effectiveness, least of all regarding
#   anyone's safety, is implied in this software or documentation.
#
#   This specific module is licensed under the Perl Artistic License.
#
#
#   $Id$
#
#=======================================================================
package PDF::API2::Basic::PDF::Null;

=head1 NAME

PDF::API2::Basic::PDF::Null - PDF Null type object.  This is a subclass of
PDF::API2::Basic::PDF::Objind and cannot be subclassed.

=head1 METHODS

=cut

use strict;

use vars qw(@ISA);
@ISA = qw(PDF::API2::Basic::PDF::Objind);

no warnings qw[ deprecated recursion uninitialized ];

# There is only one null object  (section 3.2.8).
my ($null_obj) = {};
bless $null_obj, "PDF::API2::Basic::PDF::Null";


=head2 PDF::API2::Basic::PDF::Null->new

Returns the null object.  There is only one null object.

=cut

sub new {
    return $null_obj;
}

=head2 $s->realise

Pretends to finish reading the object.

=cut

sub realise {
    return $null_obj;
}

=head2 $s->outobjdeep

Output the object in PDF format.

=cut

sub outobjdeep
{
    my ($self, $fh, $pdf) = @_;
    $fh->print ("null");
}

sub outxmldeep
{
    my ($self, $fh, $pdf, %opts) = @_;

    $opts{-xmlfh}->print("<Null/>\n");
}

=head2 $s->is_obj

Returns false because null is not a full object.

=cut

sub is_obj {
    return 0;
}

=head2 $s->copy

Another no-op.

=cut

sub copy {
    return $null_obj;
}

=head2 $s->val

Return undef.

=cut

sub val
{
    return undef;
}

1;
