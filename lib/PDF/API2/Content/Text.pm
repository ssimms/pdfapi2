package PDF::API2::Content::Text;

BEGIN {

    use strict;
    use vars qw(@ISA $VERSION);

    use PDF::API2::Util;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Content;

    @ISA = qw(PDF::API2::Content);

    ( $VERSION ) = '2.000';

}
no warnings qw[ deprecated recursion uninitialized ];

sub new {
  my ($class)=@_;
  my $self = $class->SUPER::new(@_);
  $self->textstart;
  return($self);
}

1;
