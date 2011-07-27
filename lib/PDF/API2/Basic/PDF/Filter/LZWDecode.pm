package PDF::API2::Basic::PDF::Filter::LZWDecode;

use base 'PDF::API2::Basic::PDF::Filter::FlateDecode';

no warnings qw[ deprecated recursion uninitialized ];

our @basedict = map {pack("C", $_)} (0 .. 255, 0, 0);

sub new
{
    my ($class) = @_;
    my ($self) = {};

    $self->{indict} = [@basedict];
    $self->{bits} = 9;
    $self->{insize} = $self->{bits};
    $self->{resetcode}=1<<($self->{insize}-1);
    $self->{endcode}=$self->{resetcode}+1;
    $self->{nextcode}=$self->{endcode}+1;

    bless $self, $class;
}

sub infilt
{
    my ($self, $dat, $last) = @_;
    my ($num, $cache, $cache_size, $res);

    while ($dat ne '' || $cache_size > 0)
    {
        ($num, $cache, $cache_size) = $self->read_dat(\$dat, $cache, $cache_size, $self->{'insize'});

        # this was a little arkward to comprehand
        # here is a better version -- fredo
        $self->{'insize'}++ if($self->{nextcode} == (1<<$self->{'insize'}));
        if($num==$self->{resetcode}) {
            $self->{'insize'}=$self->{bits};
            $self->{nextcode}=$self->{endcode}+1;
            next;
        } elsif($num==$self->{endcode}) {
            last;
        } elsif($num<$self->{resetcode}) {
            $self->{'indict'}[$self->{nextcode}] = $self->{'indict'}[$num];
            $res.=$self->{'indict'}[$self->{nextcode}];
            $self->{nextcode}++;
        } elsif($num>$self->{endcode}) {
            $self->{'indict'}[$self->{nextcode}] = $self->{'indict'}[$num];
            $self->{'indict'}[$self->{nextcode}].= substr($self->{'indict'}[$num+1],0,1);
            $res.=$self->{'indict'}[$self->{nextcode}];
            $self->{nextcode}++;
        } else {
            die "we shouldn't be here !";
        }
    }
    return $res;
}

sub infilt2
{
    my ($self, $dat, $last) = @_;
    my ($num, $cache, $cache_size, $res);

    while ($dat ne '' || $cache_size > 0)
    {
        ($num, $cache, $cache_size) = $self->read_dat(\$dat, $cache, $cache_size, $self->{'insize'});

        # this was a little arkward to comprehand
        # here is a better version -- fredo
        if($num==$self->{resetcode}) {
            $self->{'insize'}=$self->{bits};
            $self->{nextcode}=$self->{endcode}+1;
            next;
        } elsif($num==$self->{endcode}) {
            last;
        } elsif($num<$self->{resetcode}) {
            $self->{'indict'}[$self->{nextcode}] = $self->{'indict'}[$num];
            $res.=$self->{'indict'}[$self->{nextcode}];
            $self->{nextcode}++;
        } elsif($num>$self->{endcode}) {
            $self->{'indict'}[$self->{nextcode}] = $self->{'indict'}[$num];
            $self->{'indict'}[$self->{nextcode}].= substr($self->{'indict'}[$num+1],0,1);
            $res.=$self->{'indict'}[$self->{nextcode}];
            $self->{nextcode}++;
        } else {
            die "we shouldn't be here !";
        }
        $self->{'insize'}++ if($self->{nextcode} == (1<<$self->{'insize'}));
    }
    return $res;
}

sub read_dat
{
    my ($self, $rdat, $cache, $size, $len) = @_;
    my ($res);

    while ($size < $len)
    {
        $cache = ($cache << 8) + unpack("C", $$rdat);
        substr($$rdat, 0, 1) = '';
        $size += 8;
    }

    $res = $cache >> ($size - $len);
    $cache &= (1 << ($size - $len)) - 1;
    $size -= $len;
    ($res, $cache, $size);
}

1;
