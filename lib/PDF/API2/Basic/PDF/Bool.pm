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
package PDF::API2::Basic::PDF::Bool;

use strict;
use vars qw(@ISA);
no warnings qw[ deprecated recursion uninitialized ];

use PDF::API2::Basic::PDF::String;
@ISA = qw(PDF::API2::Basic::PDF::String);

=head1 NAME

PDF::API2::Basic::PDF::Bool - A special form of L<PDF::String> which holds the strings
B<true> or B<false>

=head1 METHODS

=head2 $b->convert($str)

Converts a string into the string which will be stored.

=cut

sub convert
{ return $_[1] eq "true"; }


=head2 as_pdf

Converts the value to a PDF output form

=cut

sub as_pdf
{ $_[0]->{'val'} ? "true" : "false"; }

sub outxmldeep
{
    my ($self, $fh, $pdf, %opts) = @_;

    $opts{-xmlfh}->print("<Bool>".$self->as_pdf."</Bool>\n");
}

1;

