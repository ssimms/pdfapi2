package PDF::API2::XS::ImagePNG;
require XSLoader;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(split_channels unfilter);
XSLoader::load();
1;
