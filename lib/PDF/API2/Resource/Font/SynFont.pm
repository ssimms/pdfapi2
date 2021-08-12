package PDF::API2::Resource::Font::SynFont;

use base 'PDF::API2::Resource::Font';

use strict;
use warnings;

# VERSION

use Math::Trig;
use Unicode::UCD 'charinfo';

use PDF::API2::Util;
use PDF::API2::Basic::PDF::Utils;

=head1 NAME

PDF::API2::Resource::Font::SynFont - Module for creating synthetic Fonts.

=head1 SYNOPSIS

    $pdf = PDF::API2->new;
    $sft = $pdf->synfont($cft);

=head1 METHODS

=over

=item $font = PDF::API2::Resource::Font::SynFont->new $pdf, $fontobj, %options

Returns a synfont object.

Valid %options are:

I<-encode>
... changes the encoding of the font from its default.
See I<perl's Encode> for the supported values.

I<-pdfname>
... changes the reference-name of the font from its default.
The reference-name is normally generated automatically and can be
retrieved via $pdfname=$font->name.

I<-slant>
... slant/expansion factor (0.1-0.9 = slant, 1.1+ = expansion).

I<-oblique>
... italic angle (+/-)

I<-bold>
... embolding factor (0.1+, bold=1, heavy=2, ...).

I<-space>
... additional charspacing in em (0-1000).

I<-caps>
... create synthetic small-caps.

=back

=cut

sub new {
    my ($class, $pdf, $font, %opts) = @_;
    my $first = 1;
    my $last = 255;
    my $slant = $opts{'-slant'} || 1;
    my $oblique = $opts{'-oblique'} || 0;
    my $space = $opts{'-space'} || 0;
    my $bold = ($opts{'-bold'} || 0) * 10; # convert to em

    $font->encodeByName($opts{'-encode'}) if $opts{'-encode'};

    $class = ref($class) if ref($class);
    my $self = $class->SUPER::new($pdf,
                                  pdfkey()
                                  . '+' . $font->name()
                                  . ($opts{'-caps'} ? '+Caps' : '')
                                  . ($opts{'-vname'} ? '+' . $opts{'-vname'} : ''));
    $pdf->new_obj($self) unless $self->is_obj($pdf);
    $self->{' font'} = $font;
    $self->{' data'} = {
        'type' => 'Type3',
        'ascender' => $font->ascender(),
        'capheight' => $font->capheight(),
        'descender' => $font->descender(),
        'iscore' => '0',
        'isfixedpitch' => $font->isfixedpitch(),
        'italicangle' => $font->italicangle() + $oblique,
        'missingwidth' => $font->missingwidth() * $slant,
        'underlineposition' => $font->underlineposition(),
        'underlinethickness' => $font->underlinethickness(),
        'xheight' => $font->xheight(),
        'firstchar' => $first,
        'lastchar' => $last,
        'char' => [ '.notdef' ],
        'uni' => [ 0 ],
        'u2e' => { 0 => 0 },
        'fontbbox' => '',
        'wx' => { 'space' => '600' },
    };

    my $data = $self->data();
    if (ref($font->fontbbox())) {
        $data->{'fontbbox'} = [ @{$font->fontbbox()} ];
    }
    else {
        $data->{'fontbbox'} = [ $font->fontbbox() ];
    }
    $data->{'fontbbox'}->[0] *= $slant;
    $data->{'fontbbox'}->[2] *= $slant;

    $self->{'Subtype'} = PDFName('Type3');
    $self->{'FirstChar'} = PDFNum($first);
    $self->{'LastChar'} = PDFNum($last);
    $self->{'FontMatrix'} = PDFArray(map { PDFNum($_) } (0.001, 0, 0, 0.001, 0, 0));
    $self->{'FontBBox'} = PDFArray(map { PDFNum($_) } $self->fontbbox());

    my $procs = PDFDict();
    $pdf->new_obj($procs);
    $self->{'CharProcs'} = $procs;

    $self->{'Resources'} = PDFDict();
    $self->{'Resources'}->{'ProcSet'} = PDFArray(map { PDFName($_) }
                                                 qw(PDF Text ImageB ImageC ImageI));
    my $xo = PDFDict();
    $self->{'Resources'}->{'Font'} = $xo;
    $self->{'Resources'}->{'Font'}->{'FSN'} = $font;
    foreach my $w ($first .. $last) {
        $data->{'char'}->[$w] = $font->glyphByEnc($w);
        $data->{'uni'}->[$w] = uniByName($data->{'char'}->[$w]);
        if (defined $data->{'uni'}->[$w]) {
            $data->{'u2e'}->{$data->{'uni'}->[$w]} = $w;
        }
    }

    if ($font->isa('PDF::API2::Resource::CIDFont')) {
        $self->{'Encoding'} = PDFDict();
        $self->{'Encoding'}->{'Type'} = PDFName('Encoding');
        $self->{'Encoding'}->{'Differences'} = PDFArray();
        foreach my $w ($first .. $last) {
            my $char = $data->{'char'}->[$w];
            if (defined $char and $char ne '.notdef') {
                $self->{'Encoding'}->{'Differences'}->add_elements(PDFNum($w),
                                                                   PDFName($char));
            }
        }
    }
    else {
        $self->{'Encoding'} = $font->{'Encoding'};
    }

    my @widths;
    foreach my $w ($first .. $last) {
        if ($data->{'char'}->[$w] eq '.notdef') {
            push @widths, $self->missingwidth();
            next;
        }
        my $char = PDFDict();

        my $uni = $data->{'uni'}->[$w];
        my $wth = int($font->width(chr($uni)) * 1000 * $slant + 2 * $space);

        $procs->{$font->glyphByEnc($w)} = $char;
        #$char->{'Filter'} = PDFArray(PDFName('FlateDecode'));
        $char->{' stream'} = $wth . ' 0 ' . join(' ', map { int($_) } $self->fontbbox()) . " d1\n";
        $char->{' stream'} .= "BT\n";
        if ($oblique) {
            my @matrix = (1, 0, tan(deg2rad($oblique)), 1, 0, 0);
            $char->{' stream'} .= join(' ', @matrix) . " Tm\n";
        }
        $char->{' stream'} .= "2 Tr " . $bold . " w\n" if $bold;
        my $ci = {};
        if ($data->{'uni'}->[$w] ne '') {
            $ci = charinfo($data->{'uni'}->[$w]);
        }
        if ($opts{'-caps'} and $ci->{'upper'}) {
            $char->{' stream'} .= "/FSN 800 Tf\n";
            $char->{' stream'} .= ($slant * 110) . " Tz\n";
            $char->{' stream'} .= " [ -$space ] TJ\n" if $space;
            $wth = int($font->width(uc chr($uni)) * 800 * $slant * 1.1 + 2 * $space);
            $char->{' stream'} .= $font->text(uc chr($uni));
        }
        else {
            $char->{' stream'} .= "/FSN 1000 Tf\n";
            $char->{' stream'} .= ($slant * 100) . " Tz\n" if $slant != 1;
            $char->{' stream'} .= " [ -$space ] TJ\n" if $space;
            $char->{' stream'} .= $font->text(chr($uni));
        }
        $char->{' stream'} .= " Tj\nET\n";
        push @widths, $wth;
        $data->{'wx'}->{$font->glyphByEnc($w)} = $wth;
        $pdf->new_obj($char);
    }

    $procs->{'.notdef'} = $procs->{$font->data->{'char'}->[32]};
    $self->{'Widths'} = PDFArray(map { PDFNum($_) } @widths);
    $data->{'e2n'} = $data->{'char'};
    $data->{'e2u'} = $data->{'uni'};

    $data->{'u2c'} = {};
    $data->{'u2e'} = {};
    $data->{'u2n'} = {};
    $data->{'n2c'} = {};
    $data->{'n2e'} = {};
    $data->{'n2u'} = {};

    foreach my $n (reverse 0 .. 255) {
        $data->{'n2c'}->{$data->{'char'}->[$n] // '.notdef'} //= $n;
        $data->{'n2e'}->{$data->{'e2n'}->[$n] // '.notdef'} //= $n;

        $data->{'n2u'}->{$data->{'e2n'}->[$n] // '.notdef'} //= $data->{'e2u'}->[$n];
        $data->{'n2u'}->{$data->{'char'}->[$n] // '.notdef'} //= $data->{'uni'}->[$n];

        if (defined $data->{'uni'}->[$n]) {
            $data->{'u2c'}->{$data->{'uni'}->[$n]} //= $n;
        }
        if (defined $data->{'e2u'}->[$n]) {
            $data->{'u2e'}->{$data->{'e2u'}->[$n]} //= $n;

            my $value = ($data->{'e2n'}->[$n] // '.notdef');
            $data->{'u2n'}->{$data->{'e2u'}->[$n]} //= $value;
        }
        if (defined $data->{'uni'}->[$n]) {
            my $value = ($data->{'char'}->[$n] // '.notdef');
            $data->{'u2n'}->{$data->{'uni'}->[$n]} //= $value;
        }
    }

    return $self;
}

1;
