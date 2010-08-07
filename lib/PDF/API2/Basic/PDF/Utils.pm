#=======================================================================
#
#   THIS IS A REUSED PERL MODULE, FOR PROPER LICENCING TERMS SEE BELOW:
#
#   Copyright Martin Hosken <Martin_Hosken@sil.org>
#
#   No warranty or expression of effectiveness, least of all regarding
#   anyone's safety, is implied in this software or documentation.
#
#   This specific module is licensed under the Perl Artistic License.
#
#=======================================================================
package PDF::API2::Basic::PDF::Utils;

=head1 NAME

PDF::API2::Basic::PDF::Utils - Utility functions for PDF library

=head1 DESCRIPTION

A set of utility functions to save the fingers of the PDF library users!

=head1 FUNCTIONS

=cut

use strict;

use PDF::API2::Basic::PDF::Array;
use PDF::API2::Basic::PDF::Bool;
use PDF::API2::Basic::PDF::Dict;
use PDF::API2::Basic::PDF::Name;
use PDF::API2::Basic::PDF::Null;
use PDF::API2::Basic::PDF::Number;
use PDF::API2::Basic::PDF::String;
use PDF::API2::Basic::PDF::Literal;

use Exporter;
use vars qw(@EXPORT @ISA);
@ISA = qw(Exporter);
@EXPORT = qw(PDFBool PDFArray PDFDict PDFLiteral PDFName PDFNull PDFNum PDFStr PDFStrHex PDFUtf
             asPDFBool asPDFName asPDFNum asPDFStr);
no warnings qw[ deprecated recursion uninitialized ];


=head2 PDFBool

Creates a Bool via PDF::API2::Basic::PDF::Bool->new

=cut

sub PDFBool
{ PDF::API2::Basic::PDF::Bool->new(@_); }


=head2 PDFArray

Creates an array via PDF::API2::Basic::PDF::Array->new

=cut

sub PDFArray
{ PDF::API2::Basic::PDF::Array->new(@_); }


=head2 PDFDict

Creates a dict via PDF::API2::Basic::PDF::Dict->new

=cut

sub PDFDict
{ PDF::API2::Basic::PDF::Dict->new(@_); }


=head2 PDFName

Creates a name via PDF::API2::Basic::PDF::Name->new

=cut

sub PDFName
{ PDF::API2::Basic::PDF::Name->new(@_); }


=head2 PDFNull

Creates a null via PDF::API2::Basic::PDF::Null->new

=cut

sub PDFNull
{ PDF::API2::Basic::PDF::Null->new(@_); }


=head2 PDFNum

Creates a number via PDF::API2::Basic::PDF::Number->new

=cut

sub PDFNum
{ PDF::API2::Basic::PDF::Number->new(@_); }


=head2 PDFStr

Creates a string via PDF::API2::Basic::PDF::String->new

=cut

sub PDFStr
{ PDF::API2::Basic::PDF::String->new(@_); }

=head2 PDFStrHex

Creates a hex-string via PDF::API2::Basic::PDF::String->new

=cut

sub PDFStrHex
{ my $x=PDF::API2::Basic::PDF::String->new(@_); $x->{' ishex'}=1; return($x); }

=head2 PDFUtf

Creates a utf8-string via PDF::API2::Basic::PDF::String->new

=cut

sub PDFUtf
{ my $x=PDF::API2::Basic::PDF::String->new(@_); $x->{' isutf'}=1; return($x); }

=head2 PDFLiteral

Creates a pdf-literal via PDF::API2::Basic::PDF::Literal->new

=cut

sub PDFLiteral
{ PDF::API2::Basic::PDF::Literal->new(@_); }

=head2 asPDFBool

Returns a literal value in PDF output form

=cut

sub asPDFBool
{ PDF::API2::Basic::PDF::Bool->new(@_)->as_pdf; }


=head2 asPDFStr

Returns a string in PDF output form (including () or <>)

=cut

sub asPDFStr
{ PDF::API2::Basic::PDF::String->new(@_)->as_pdf; }


=head2 asPDFName

Returns a Name in PDF Output form (including /)

=cut

sub asPDFName
{ PDF::API2::Basic::PDF::Name->new(@_)->as_pdf (@_); }


=head2 asPDFNum

Returns a number in PDF output form

=cut

sub asPDFNum
{ $_[0]; }          # no translation needed


=head2 unpacku($str)

Returns a list of unicode values for the given UTF8 string

=cut

sub unpacku
{
    my ($str) = @_;
    my (@res);

    return (unpack("U*", $str));
}


1;

