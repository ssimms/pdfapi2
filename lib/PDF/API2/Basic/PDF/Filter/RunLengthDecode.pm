package PDF::API2::Basic::PDF::Filter::RunLengthDecode;

use base 'PDF::API2::Basic::PDF::Filter';

use strict;
no warnings qw[ deprecated recursion uninitialized ];

=head1 NAME

PDF::API2::Basic::PDF::RunLengthDecode - Run Length encoding filter for PDF streams. Inherits from
L<PDF::API2::Basic::PDF::Filter>

=cut

sub outfilt
{
    my ($self, $str, $isend) = @_;
    my ($res, $s, $r);

# no state information, just slight inefficiency at block boundaries
    while ($str ne "")
    {
        if ($str =~ m/^(.*?)((.)\2{2,127})(.*?)$/so)
        {
            $s = $1;
            $r = $2;
            $str = $3;
        } else
        {
            $s = $str;
            $r = '';
            $str = '';
        }
        while (length($s) > 127)
        {
            $res .= pack("C", 127) . substr($s, 0, 127);
            substr($s, 0, 127) = '';
        }
        $res .= pack("C", length($s)) . $s if length($s) > 0;
        $res .= pack("C", 257 - length($r));
    }
    $res .= "\x80" if ($isend);
    $res;
}

sub infilt
{
    my ($self, $str, $isend) = @_;
    my ($res, $l, $d);

    if ($self->{'incache'} ne "")
    {
        $str = $self->{'incache'} . $str;
        $self->{'incache'} = "";
    }
    while ($str ne "")
    {
        $l = unpack("C", $str);
        if ($l == 128)
        {
            $isend = 1;
            return $res;
        }
        if ($l > 128)
        {
            if (length($str) < 2)
            {
                warn "Premature end to data in RunLengthEncoded data" if $isend;
                $self->{'incache'} = $str;
                return $res;
            }
            $res .= substr($str, 1, 1) x (257 - $l);
            substr($str, 0, 2) = "";
        } else
        {
            if (length($str) < $l + 1)
            {
                warn "Premature end to data in RunLengthEncoded data" if $isend;
                $self->{'incache'} = $str;
                return $res;
            }
            $res .= substr($str, 1, $l);
            substr($str, 0, $l + 1) = "";
        }
    }
    $res;
}

1;
