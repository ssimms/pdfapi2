#!/usr/bin/perl
#
# txt2pdf.pl from mcollins@fcnetwork.com
#
# MC's Q&D text to PDF converter.
#
# FYI,
#
# I wrote a simple text file to PDF converter that uses PDF::API2::Lite.
# It isn't full-featured by any stretch but it does illustrate one of the
# many uses of this cool module.  I'm submitting it here for your perusal.
# If you think of any useful things to add to it please let me know.
# Fredo, please feel free to include it in the contributed items if you
# would like.
#
# Thanks!  (Sorry about the long comments that wrap around to the next
# line...)
#
# -MC
#
use strict;
use warnings;
use PDF::API2::Lite;
use Getopt::Long;
use File::Basename;

$|++;                   # turn off buffering

my $pdf;              	# main PDF document object
my $page;             	# current page being processed
my $text;             	# current page's text object
my $font;             	# current font being used

# variables from the command line
my $left;             	# left margin/starting point; default = 36pts from page
my $top;              	# top margin/starting point; default = 36pts from page
my $infile;           	# input path & file (from cmd line arg - could be glob)
my $lpp;              	# lines per page
my $layout;           	# portrait or landscape; default = portrait
my $landscape;          # landscape cmd line flag
my $fontsize;           # font size; default = 7.25
my $bold;             	# set to 1 for bold on; default = 0;
my $spacing;          	# text spacing ($pdf->textleading); default = 8

# other variables
my @FILES;            	# list of input files, in case of glob
my $file;             	# Current file being converted
my $destpath;           # destination path
my $outfile;          	# output path & file
my $linecount;        	# how many lines have been processed on this page
my $arg;              	# command line argument being processed
my $help;               # Flag for displaying help

$fontsize = 7.25;     	# unless otherwise specified, font size is 7.25
$spacing  = 8;        	# unless otherwise specified, spacing is 8

$layout = "Portrait"; 	# default page layout


if ($#ARGV < 0) {
  print "Usage:\n";
  print "txt2pdf <options> <textfilename>\n";
  exit(1);
}
# get those cmd line args!
my $opts_okay = GetOptions(
	'h'             => \$help,
	'help'          => \$help,		# Can use -h or --help
	'lpp=i'         => \$lpp,
	'left=f'        => \$left,
	'top=f'         => \$top,
	'fontsize=f'    => \$fontsize,
	'spacing=f'     => \$spacing,
	'b'             => \$bold,
	'l'             => \$landscape,
	'in=s'          => \$infile,
	'dir=s'         => \$destpath,
);

# if help, then display usage
if ( $help ) { &usage; exit(0); }

# Check filename
if ( ! $infile ) {
	die "Please specify a file name or glob with --in=<filename>\n";
	exit(1);
}

# Check path
if ( ! $destpath ) { $destpath = '/default/path/'; }

# Check for filename vs. filespec(glob)
if ( $infile =~ m/\*|\?/ ) {
	print "Found glob spec, checking...\n";
	@FILES = glob($infile);
	if ( ! @FILES ) {
		die "No files match spec: '$infile', exiting...\n";
	} # if no files match
	print "Found file";
	if ( $#FILES > 0 ) { print "s"; }               # Be nice, use plural
	print ":\n";
	foreach ( @FILES ) {
		print "$_\n";
	} # foreach @FILES

} else {
	if ( ! -f $infile ) {
		die "Could not locate file '$infile', exiting...\n";
	} # if $infile not found
	@FILES = ( $infile );
} # if $infile contains wildcards

# Validate remaining cmd line args

if ( $landscape ) {
	## Set up landscape defaults and maxima
	$layout = 'landscape';

	## Set default lines per page if necessary
	if ( ! $lpp	) { $lpp 	= 45; }     # Landscape default lines per page

	## If left margin not specified, default to 1/2" or 36 points
	if ( ! $left 	) { $left 	= 36; }   # Default left margin

	## Left margin shouldn't be more than 10.5" (756 points) from left edge of page
	if ( ! $left > 756 ) {
		$left = 756;            # Landscape max left margin (in points)
	} # if $left greater than 756 points

	## For top margin, need to calculate number of points from top of page
	## Example, 1/2" margin is 36 points from top of page
	## Top of page is 612 points, 1/2" down is 576 points (612 - 36 = 576)
	if ( ! $top  ) {
		$top = 612 - 36;      # Calculate 36 pts (1/2") from top of page
	} else {
		$top = 612 - $top;    # Calculate $top pts from top of page
	} # if top margin not specified

} else {
	## Set up portrait defaults and maxima

	## Set default lines per page if necessary
	if ( ! $lpp      ) { $lpp 	= 60; }         # Landscape default lines per page

	## If left margin not specified, default to 1/2" or 36 points
	if ( ! $left     ) { $left 	= 36; }         # Default left margin

	## Left margin shouldn't be more than 8" (576 points) from left edge of page
	if ( ! $left > 576 ) {
		$left = 576;                            # Landscape max left margin (in points)
	} # if $left greater than 576 points

	## For top margin, need to calculate number of points from top of page
	## Example, 1/2" margin is 36 points from top of page
	## Top of page is 792 points, 1/2" down is 756 points (792 - 36 = 756)
	if ( ! $top  ) {
		$top = 792 - 36;                        # Calculate 36pts (1/2") from top of page
	} else {
		$top = 792 - $top;                      # Calculate $top pts from top of page
	} # if top margin not specified

} # if landscape or portrait

# Set max, min spacing
if ( $spacing > 720 ) { $spacing = 720;	}         # why would anyone want this much spacing?
if ( $spacing < 1   ) { $spacing = 1; 	}         # That's awfully crammed together...

foreach $file ( @FILES ) {
  	print "Processing $file...\n";
  	my ($name,$dir,$suf) = fileparse($file,qr/\.[^.]*/);

  	if ( $suf =~ m/txt2pdf|txt/) {
  		# replace .txt or .txt2pdf with .pdf
    	$outfile = $destpath . $name . '.pdf';
  	} else {
  		# just append .pdf to end of filename
  		$outfile = $destpath . $name . $suf . '.pdf';
  	} # if suffix is '.txt' or '.txt2pdf'

	$pdf = PDF::API2::Lite->new;

  	&newpage;      # create first page in PDF document

  	open (FILEIN,"$file") or die "$file - $!\n";
  	while(<FILEIN>) {
    	#chomp;
	# chomp is insufficient when dealing with EOL from different systems
    	# this little regex will make things a bit easier
    	s/(\r)|(\n)//g;

    	if (m/\x0C/ || $linecount >= $lpp) {    # found page break
          &newpage;
	    next;
    	} # if
    	$pdf->text($_);
    	$pdf->nl;
    	$linecount++;

  	} # while(<FILEIN>)
  	$pdf->textend;
  	close(FILEIN);
  	$pdf->save($outfile);
} # foreach $file (@FILES)

sub newpage() {
  	if ($layout =~ m/l/i) { $pdf->page(792,612);}
  	else { $pdf->page(612,792); }

  	if ( $bold ) { $font = $pdf->corefont('CourierBold');}
  	else {$font = $pdf->corefont('Courier');}

  	$pdf->textstart;
  	$pdf->textleading($spacing);
  	$pdf->transform(-translate => [$left,$top]);
  	$pdf->textfont($font,$fontsize);
  	$linecount = 1;
}

sub usage() {
print << 'END_OF_USAGE'

MC's Text to PDF converter (very cheesy, but useful nonetheless)

Usage:
txt2pdf [options] <source file name>

Options:

  --lpp=##    specify number of lines per page
              Note: portrait/landscape, margins and font size all affect the
              placement of text on a page.  You may need to experiment

  --left=##   specify left margin in points. 72 points = 1 inch

  --top=##    specify top margin in points. 36 points = .5 inch

  -h, --help  This help page

  --size=##   Set font size; default is 7.25

  --spacing=# Set the spacing between lines; default is 8

  -b, -B      Set bold type to on; default is not bold

  -l, -L      Set doc to landscape; default is portrait


  Special thanks to Alfred Reibenschuh for such a cool Perl module!
  Also, many thanks to the PDF::API2 community for such great ideas.

END_OF_USAGE
}

__END__
