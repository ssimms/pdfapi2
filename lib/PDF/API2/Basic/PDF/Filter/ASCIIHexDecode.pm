package PDF::API2::Basic::PDF::Filter::ASCIIHexDecode;

use base 'PDF::API2::Basic::PDF::Filter';

use strict;
no warnings qw[ deprecated recursion uninitialized ];

=head1 NAME

PDF::API2::Basic::PDF::ASCIIHexDecode - Ascii Hex encoding (very inefficient) for PDF streams.
Inherits from L<PDF::API2::Basic::PDF::Filter>

=cut

sub outfilt
{
    my ($self, $str, $isend) = @_;

    $str =~ s/(.)/sprintf("%02x", ord($1))/oge;
    $str .= ">" if $isend;
    $str;
}

sub infilt
{
    my ($self, $str, $isend) = @_;

    $isend = ($str =~ s/>$//og);
    $str =~ s/\s//oig;
    $str =~ s/([0-9a-z])/pack("C", hex($1 . "0"))/oige if ($isend && length($str) & 1);
    $str =~ s/([0-9a-z]{2})/pack("C", hex($1))/oige;
    $str;
}

1;
