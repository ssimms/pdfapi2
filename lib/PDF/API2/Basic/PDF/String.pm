#=======================================================================
#
#   THIS IS A REUSED PERL MODULE, FOR PROPER LICENCING TERMS SEE BELOW:
#
#   Copyright Martin Hosken <Martin_Hosken@sil.org>
#
#   No warranty or expression of effectiveness, least of all regarding
#   anyone's safety, is implied in this software or documentation.
#
#   This specific module is licensed under the Perl Artistic License.
#
#=======================================================================
package PDF::API2::Basic::PDF::String;

=head1 NAME

PDF::API2::Basic::PDF::String - PDF String type objects and superclass for simple objects
that are basically stringlike (Number, Name, etc.)

=head1 METHODS

=cut

use strict;
use vars qw(@ISA %trans %out_trans);
no warnings qw[ deprecated recursion uninitialized ];

use PDF::API2::Basic::PDF::Objind;
@ISA = qw(PDF::API2::Basic::PDF::Objind);

%trans = (
    "n" => "\n",
    "r" => "\r",
    "t" => "\t",
    "b" => "\b",
    "f" => "\f",
    "\\" => "\\",
    "(" => "(",
    ")" => ")"
        );

%out_trans = (
    "\n" => "n",
    "\r" => "r",
    "\t" => "t",
    "\b" => "b",
    "\f" => "f",
    "\\" => "\\",
    "(" => "(",
    ")" => ")"
             );


=head2 PDF::API2::Basic::PDF::String->from_pdf($string)

Creates a new string object (not a full object yet) from a given string.
The string is parsed according to input criteria with escaping working.

=cut

sub from_pdf
{
    my ($class, $str) = @_;
    my ($self) = {};

    bless $self, $class;
    $self->{'val'} = $self->convert($str);
    $self->{' realised'} = 1;
    return $self;
}


=head2 PDF::API2::Basic::PDF::String->new($string)

Creates a new string object (not a full object yet) from a given string.
The string is parsed according to input criteria with escaping working.

=cut

sub new
{
    my ($class, $str) = @_;
    my ($self) = {};

    bless $self, $class;
    $self->{'val'} = $str;
    $self->{' realised'} = 1;
    return $self;
}


=head2 $s->convert($str)

Returns $str converted as per criteria for input from PDF file

=cut

sub convert
{
    my ($self, $str) = @_;

    if($str=~m|^\s*\<|o) 
    { 
        # cleaning up hex-strings, since spec is very loose,
        # at least openoffice exporter needs this ! - fredo
        $str=~s|[^0-9a-f]+||gio;
        $str="<$str>";
        $self->{' ishex'}=1;

        1 while $str =~ s/\<([0-9a-f]{2})/chr(hex($1))."\<"/oige;
        $str =~ s/\<([0-9a-f]?)\>/chr(hex($1."0"))/oige;
        $str =~ s/\<\>//og;
    }
    else
    {
        # if we import binary escapes,
        # let it be hex on output -- fredo
        if($str =~ s/\\([nrtbf\\()])/$trans{$1}/ogi)
        {
            $self->{' ishex'}=1;
        }  
        if($str =~ s/\\([0-7]{1,3})/chr(oct($1))/oeg)
        {
            $self->{' ishex'}=1;
        }  
    }
        
    return $str;
}


=head2 $s->val

Returns the value of this string (the string itself).

=cut

sub val
{ $_[0]->{'val'}; }


=head2 $->as_pdf

Returns the string formatted for output as PDF for PDF File object $pdf.

=cut

sub as_pdf
{
    my ($self) = @_;
    my ($str) = $self->{'val'};

    if($self->{' isutf'}) { 
        $str = join( '', map { sprintf('%04X',$_) } unpack('U*',$str) );
        return "<FEFF$str>";
    } elsif($self->{' ishex'}) { # imported as hex ?
        $str = unpack('H*',$str);
        return "<$str>";
    } else {
        if ($str =~ m/[^\n\r\t\b\f\040-\176\200-\377]/oi)
        {
            $str =~ s/(.)/sprintf("%02X", ord($1))/oge;
            return "<$str>";
        } else
        {
            $str =~ s/([\n\r\t\b\f\\()])/\\$out_trans{$1}/ogi;
            return "($str)";
        }
    }
}


=head2 $s->outobjdeep

Outputs the string in PDF format, complete with necessary conversions

=cut

sub outobjdeep
{
    my ($self, $fh, $pdf, %opts) = @_;

    $fh->print($self->as_pdf ($pdf));
}

sub outxmldeep
{
    my ($self, $fh, $pdf, %opts) = @_;

    $opts{-xmlfh}->print("<String>".$self->val."</String>\n");
}

