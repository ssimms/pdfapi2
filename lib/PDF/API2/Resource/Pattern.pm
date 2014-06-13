package PDF::API2::Resource::Pattern;

# VERSION

use base 'PDF::API2::Resource';

use strict;
use warnings;

sub new {
    my ($class, $pdf, $name) = @_;
    my $self = $class->SUPER::new($pdf, $name);

    $self->type('Pattern');

    return $self;
}

# Deprecated (rolled into new)
sub new_api { return new(@_); }

1;
