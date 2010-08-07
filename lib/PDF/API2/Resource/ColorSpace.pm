package PDF::API2::Resource::ColorSpace;

BEGIN {

    use strict;
    use vars qw(@ISA);
    use PDF::API2::Basic::PDF::Array;
    use PDF::API2::Basic::PDF::Utils;
    use PDF::API2::Util;
    use Math::Trig;

    @ISA = qw(PDF::API2::Basic::PDF::Array);

}
no warnings qw[ deprecated recursion uninitialized ];

=head1 NAME

PDF::API2::Resource::ColorSpace

=head1 METHODS

=over

=item $cs = PDF::API2::Resource::ColorSpace->new $pdf, $key, %parameters

Returns a new colorspace object. base class for all colorspaces.

=cut

sub new {
    my ($class,$pdf,$key,%opts)=@_;

    $class = ref $class if ref $class;
    $self=$class->SUPER::new();
    $pdf->new_obj($self) unless($self->is_obj($pdf));
    $self->name($key || pdfkey());
    $self->{' apipdf'}=$pdf;

    return($self);
}

=item $cs = PDF::API2::Resource::ColorSpace->new_api $api, $name

Returns a color-space object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api {
    my ($class,$api,@opts)=@_;

    my $obj=$class->new($api->{pdf},@opts);
    $self->{' api'}=$api;

    return($obj);
}

=item $name = $res->name $name

Returns or sets the Name of the resource.

=cut

sub name {
    my $self=shift @_;
    if(scalar @_ >0 && defined($_[0])) {
        $self->{' name'}=$_[0];
    }
    return($self->{' name'});
}
sub type {
    my $self=shift @_;
    if(scalar @_ >0 && defined($_[0])) {
        $self->{' type'}=$_[0];
    }
    return($self->{' type'});
}

=item @param = $cs->param @param

Returns properly formatted color-parameters based on the colorspace.

=cut

sub param {
    my $self=shift @_;
    return(@_);
}

sub outobjdeep {
    my ($self, @opts) = @_;
    foreach my $k (qw/ api apipdf /) {
        $self->{" $k"}=undef;
        delete($self->{" $k"});
    }
    $self->SUPER::outobjdeep(@opts);
}

1;

__END__

=back

=head1 AUTHOR

Alfred Reibenschuh

=cut

if($opts{-type} eq 'CalRGB') {

my $csd=PDFDict();
$opts{-whitepoint}||=[ 0.95049, 1, 1.08897 ];
$opts{-blackpoint}||=[ 0, 0, 0 ];
$opts{-gamma}||=[ 2.22218, 2.22218, 2.22218 ];
$opts{-matrix}||=[
0.41238, 0.21259, 0.01929,
0.35757, 0.71519, 0.11919,
0.1805,  0.07217, 0.95049
];

$csd->{WhitePoint}=PDFArray(map {PDFNum($_)} @{$opts{-whitepoint}});
$csd->{BlackPoint}=PDFArray(map {PDFNum($_)} @{$opts{-blackpoint}});
$csd->{Gamma}=PDFArray(map {PDFNum($_)} @{$opts{-gamma}});
$csd->{Matrix}=PDFArray(map {PDFNum($_)} @{$opts{-matrix}});

$self->add_elements(PDFName($opts{-type}),$csd);

$self->{' type'}='rgb';

} elsif($opts{-type} eq 'CalGray') {

my $csd=PDFDict();
$opts{-whitepoint}||=[ 0.95049, 1, 1.08897 ];
$opts{-blackpoint}||=[ 0, 0, 0 ];
$opts{-gamma}||=2.22218;
$csd->{WhitePoint}=PDFArray(map {PDFNum($_)} @{$opts{-whitepoint}});
$csd->{BlackPoint}=PDFArray(map {PDFNum($_)} @{$opts{-blackpoint}});
$csd->{Gamma}=PDFNum($opts{-gamma});

$self->add_elements(PDFName($opts{-type}),$csd);

$self->{' type'}='gray';

} elsif($opts{-type} eq 'Lab') {

my $csd=PDFDict();
$opts{-whitepoint}||=[ 0.95049, 1, 1.08897 ];
$opts{-blackpoint}||=[ 0, 0, 0 ];
$opts{-range}||=[ -200, 200, -200, 200 ];
$opts{-gamma}||=[ 2.22218, 2.22218, 2.22218 ];

$csd->{WhitePoint}=PDFArray(map {PDFNum($_)} @{$opts{-whitepoint}});
$csd->{BlackPoint}=PDFArray(map {PDFNum($_)} @{$opts{-blackpoint}});
$csd->{Gamma}=PDFArray(map {PDFNum($_)} @{$opts{-gamma}});
$csd->{Range}=PDFArray(map {PDFNum($_)} @{$opts{-range}});

$self->add_elements(PDFName($opts{-type}),$csd);

$self->{' type'}='lab';

} elsif($opts{-type} eq 'Indexed') {

$opts{-base}||='DeviceRGB';
$opts{-whitepoint}||=[ 0.95049, 1, 1.08897 ];
$opts{-blackpoint}||=[ 0, 0, 0 ];
$opts{-gamma}||=[ 2.22218, 2.22218, 2.22218 ];

#       my $csd=PDFDict();
#       $csd->{WhitePoint}=PDFArray(map {PDFNum($_)} @{$opts{-whitepoint}});
#       $csd->{BlackPoint}=PDFArray(map {PDFNum($_)} @{$opts{-blackpoint}});
#       $csd->{Gamma}=PDFArray(map {PDFNum($_)} @{$opts{-gamma}});

my $csd=PDFDict();
$pdf->new_obj($csd);
$csd->{Filter}=PDFArray(PDFName('FlateDecode'));
$self->{' index'}=[];

if(defined $opts{-actfile}) {
} elsif(defined $opts{-acofile}) {
} elsif(defined $opts{-colors}) {
$opts{-maxindex}||=scalar(@{$opts{-colors}})-1;

foreach my $col (@{$opts{-colors}}) {
map { $csd->{' stream'}.=pack('C',$_); } @{$col};
}

foreach my $col (0..$opts{-maxindex}) {
if($opts{-base}=~/RGB/i) {
my $r=(shift(@{$opts{-colors}})||0)/255;
my $g=(shift(@{$opts{-colors}})||0)/255;
my $b=(shift(@{$opts{-colors}})||0)/255;
push(@{$self->{' index'}},[$r,$g,$b]);
} elsif($opts{-base}=~/CMYK/i) {
my $c=(shift(@{$opts{-colors}})||0)/255;
my $m=(shift(@{$opts{-colors}})||0)/255;
my $y=(shift(@{$opts{-colors}})||0)/255;
my $k=(shift(@{$opts{-colors}})||0)/255;
push(@{$self->{' index'}},[$c,$m,$y,$k]);
}
}
} else {
die "unspecified color index table.";
}

$self->add_elements(PDFName($opts{-type}),PDFName($opts{-base}),PDFNum($opts{-maxindex}),$csd);

$self->{' type'}='index-'.(
$opts{-base}=~/RGB/i ? 'rgb' :
$opts{-base}=~/CMYK/i ? 'cmyk' : 'unknown'
);

} elsif($opts{-type} eq 'ICCBased') {

my $csd=PDFDict();

$csd->{Filter}=PDFArray(PDFName('FlateDecode'));
$csd->{Alternate}=PDFName($opts{-base}) if(defined $opts{-base});
$csd->{N}=PDFNum($opts{-components});
$csd->{' streamfile'}=$opts{-iccfile};
$pdf->new_obj($csd);
$self->add_elements(PDFName($opts{-type}),$csd);

$self->{' type'} =
$opts{-base}=~/RGB/i ? 'rgb' :
$opts{-base}=~/CMYK/i ? 'cmyk' :
$opts{-base}=~/Lab/i ? 'lab' :
$opts{-base}=~/Gr[ae]y/i ? 'gray' :
$opts{-base}=~/Index/i ? 'index' : 'other'
;

}
