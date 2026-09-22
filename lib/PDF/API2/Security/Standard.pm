package PDF::API2::Security::Standard;

use strict;
use warnings;

# VERSION

use Carp qw(croak);
use Crypt::RC4 qw(RC4);
use Digest::MD5 qw(md5);

my $PASSWORD_PADDING = pack(
    'H*',
    '28bf4e5e4e758a4164004e56fffa0108'
        . '2e2e00b6d0683e802f0ca9fe6453697a',
);

sub new {
    my ($class, %options) = @_;

    return bless {
        ' file'       => $options{'file'},
        ' encrypt'    => $options{'encrypt'},
        ' identifier' => $options{'identifier'},
        ' password'   => defined $options{'password'} ? $options{'password'} : '',
    }, $class;
}

sub authenticate {
    my ($self) = @_;

    my $encrypt = $self->{' encrypt'};
    my $revision = $encrypt->{'R'}->val();
    croak "Unsupported Standard security handler revision: $revision"
        unless $revision == 2;

    my $owner_entry = $encrypt->{'O'}->val();
    my $user_entry = $encrypt->{'U'}->val();
    my $permissions = $encrypt->{'P'}->val();
    my $identifier = $self->_identifier();

    croak 'Invalid Standard security handler dictionary'
        unless defined $owner_entry
            && length($owner_entry) == 32
            && defined $user_entry
            && length($user_entry) == 32
            && defined $permissions
            && defined $identifier;

    my $password = $self->{' password'};
    my $file_key = $self->_file_key(_pad_password($password), $owner_entry,
        $permissions, $identifier);

    unless (_secure_equal(RC4($file_key, $PASSWORD_PADDING), $user_entry)) {
        my $owner_key = substr(md5(_pad_password($password)), 0, 5);
        my $user_padding = RC4($owner_key, $owner_entry);
        $file_key = $self->_file_key($user_padding, $owner_entry,
            $permissions, $identifier);

        croak 'Invalid PDF password'
            unless _secure_equal(RC4($file_key, $PASSWORD_PADDING), $user_entry);
    }

    $self->{' file_key'} = $file_key;
    return $self;
}

sub decrypt_string {
    my ($self, $objnum, $objgen, $data) = @_;

    return RC4($self->object_key($objnum, $objgen), $data);
}

sub decrypt_stream {
    my ($self, $objnum, $objgen, $data) = @_;

    return RC4($self->object_key($objnum, $objgen), $data);
}

sub stream_cipher {
    my ($self, $objnum, $objgen) = @_;

    return Crypt::RC4->new($self->object_key($objnum, $objgen));
}

sub object_key {
    my ($self, $objnum, $objgen) = @_;

    croak 'Object number is required for encrypted PDF data'
        unless defined $objnum;

    my $object_bytes = pack(
        'C3',
        $objnum & 0xff,
        ($objnum >> 8) & 0xff,
        ($objnum >> 16) & 0xff,
    );
    my $generation_bytes = pack(
        'C2',
        $objgen & 0xff,
        ($objgen >> 8) & 0xff,
    );

    return substr(
        md5($self->{' file_key'} . $object_bytes . $generation_bytes),
        0,
        10,
    );
}

sub _file_key {
    my ($self, $password, $owner_entry, $permissions, $identifier) = @_;

    return substr(
        md5(
            $password
                . $owner_entry
                . pack('l<', $permissions)
                . $identifier,
        ),
        0,
        5,
    );
}

sub _identifier {
    my ($self) = @_;
    my $identifier = $self->{' identifier'};

    return unless $identifier && $identifier->can('elements');

    my ($first) = $identifier->elements();
    return $first->val() if $first && $first->can('val');
    return;
}

sub _pad_password {
    my ($password) = @_;

    $password = substr($password, 0, 32);
    return substr($password . $PASSWORD_PADDING, 0, 32);
}

sub _secure_equal {
    my ($left, $right) = @_;

    return 0 unless defined $left && defined $right;
    return 0 unless length($left) == length($right);

    my $different = 0;
    for my $index (0 .. length($left) - 1) {
        $different |= ord(substr($left, $index, 1))
            ^ ord(substr($right, $index, 1));
    }

    return $different == 0;
}

1;
