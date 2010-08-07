package PDF::API2::Outlines;

BEGIN {

    use strict;
    use vars qw(@ISA $VERSION);

    use PDF::API2::Outline;
    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;

    @ISA = qw(PDF::API2::Outline);

    ( $VERSION ) = '2.000';

}

no warnings qw[ deprecated recursion uninitialized ];

sub new {
    my ($class,$api)=@_;
    my $self = $class->SUPER::new($api);
    $self->{Type}=PDFName('Outlines');

    return($self);
}

1;
