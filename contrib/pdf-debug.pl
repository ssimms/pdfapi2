#!/usr/bin/perl

use strict;
use warnings;

# VERSION

use PDF::API2::Basic::PDF::File;

my $file = shift(@ARGV);
unless ($file) {
    print "Usage: $0 <file.pdf>\n\nDisplays information about a PDF file.\n";
    exit;
}

my $pdf = PDF::API2::Basic::PDF::File->open($file) or die "Unable to open $file: $!";
my $command = shift(@ARGV);

unless ($command) {
    print "PDF Version: " . $pdf->{' version'} . "\n";
    print "XRef Table:  " . $pdf->{' xref_position'} . "\n";
    print "Info:        " . _obj_reference($pdf->{'Info'}) . "\n" if $pdf->{'Info'};
    print "Root:        " . _obj_reference($pdf->{'Root'}) . "\n" if $pdf->{'Root'};
    print "\n";
    print "To view an object:\n";
    print "$0 <file.pdf> obj <id> [generation]\n";
    print "\n";
    print "To view a cross-reference dictionary (with optional offset in bytes):\n";
    print "$0 <file.pdf> xref [offset]\n";
    print "\n";
}
elsif ($command eq 'xref') {
    my $location = shift(@ARGV);
    $location = $pdf->{' xref_position'} unless defined $location;
    my $object = $pdf->readxrtr($location);
    print "XRef at $location\n";
    print '--------' . ('-' x length($location)) . "\n";
    _print_obj($object);
}
elsif ($command eq 'obj') {
    my $id = shift(@ARGV);
    die "Missing required object number" unless $id and $id =~ /^[0-9]+$/;
    my $generation = shift(@ARGV) || 0;

    my $location = $pdf->locate_obj($id, $generation);
    my $object = $pdf->read_objnum($id, $generation);
    print "Object $id";
    unless (ref($location)) {
        print " (file position $location)\n";
    }
    else {
        my ($obj_num, $obj_idx) = @$location;
        print " (object stream $obj_num index $obj_idx)\n";
    }
    print '-------' . ('-' x length($id)) . "\n";
    unless ($object) {
        print "[Unable to read object]\n";
    }
    else {
        _print_obj($object);
    }
}

sub _print_obj {
    my $object = shift();
    if ($object->isa('PDF::API2::Basic::PDF::Dict')) {
        print _obj_dictionary($object);
    }
    elsif ($object->isa('PDF::API2::Basic::PDF::Array')) {
        print _obj_array($object) . "\n";
    }
    elsif ($object->isa('PDF::API2::Basic::PDF::Name') or
           $object->isa('PDF::API2::Basic::PDF::Number') or
           $object->isa('PDF::API2::Basic::PDF::String')) {
        if ($object->val() =~ /^[[:print:]]+$/) {
            print $object->val() . "\n";
        }
        else {
            print $object->as_pdf() . "\n";
        }
    }
    elsif ($object->isa('PDF::API2::Basic::PDF::Null')) {
        print "<Null>\n"
    }
    else {
        print "[" . ref($object) . "]\n";
    }

    if ($object->{' stream'}) {
        print "\n";
        print "Stream\n";
        print "------\n";
        eval { $object->read_stream(1) };
        if ($@) {
            print "[Stream could not be read or decoded]\n";
        }
        elsif ($ENV{'FORCE'} or $object->{' stream'} =~ /^[[:print:]\s]*$/) {
            print $object->{' stream'} . "\n";
        }
        else {
            print "[Stream contains non-printable characters.  Set environment FORCE=1 to show the stream anyway.]\n";
        }
    }
}

sub _obj_reference {
    my $object = shift();
    return '<Object ' . $object->{' objnum'} . ($object->{' objgen'} ? ' ' . $object->{' objgen'} : '') . '>';
}

sub _obj_dictionary {
    my $object = shift();
    my $indent = shift() || 0;
    my $data = {};
    foreach my $key (keys %$object) {
        next if $key =~ /^ /;
        if (ref($object->{$key})) {
            if ($object->{$key}->isa('PDF::API2::Basic::PDF::Array')) {
                $data->{$key} = _obj_array($object->{$key}, $indent + 1);
                chomp $data->{$key};
            }
            elsif ($object->{$key}->isa('PDF::API2::Basic::PDF::Dict')) {
                if ($object->{$key}->{' objnum'}) {
                    $data->{$key} = '<Object ' . $object->{$key}->{' objnum'} . ($object->{$key}->{' objgen'} ? ' ' . $object->{$key}->{' objgen'} : '') . '>';
                }
                else {
                    unless (scalar grep { $_ !~ /^ / } keys %{$object->{$key}}) {
                        $data->{$key} = '<Empty Dictionary>';
                    }
                    else {
                        $data->{$key} = "\n" . _obj_dictionary($object->{$key}, $indent + 1);
                        chomp $data->{$key};
                    }
                }
            }
            elsif ($object->{$key}->isa('PDF::API2::Basic::PDF::Name') or
                   $object->{$key}->isa('PDF::API2::Basic::PDF::Number') or
                   $object->{$key}->isa('PDF::API2::Basic::PDF::String')) {
                if ($object->{$key}->val() =~ /^[[:print:]]+$/) {
                    $data->{$key} = $object->{$key}->val();
                }
                else {
                    $data->{$key} = $object->{$key}->as_pdf();
                }
            }
            elsif ($object->{$key}->isa('PDF::API2::Basic::PDF::Null')) {
                $data->{$key} = '<Null>';
            }
            elsif ($object->{$key}->isa('PDF::API2::Basic::PDF::Objind') and $object->{$key}->{' objnum'}) {
                $data->{$key} = '<Object ' . $object->{$key}->{' objnum'} . ($object->{$key}->{' objgen'} ? ' ' . $object->{$key}->{' objgen'} : '') . '>';
            }
            else {
                $data->{$key} = '[' . ref($object->{$key}) . ']';
            }
        }
        else {
            $data->{$key} = $object->{$key};
        }
    }
    my $longest_key = 0;
    foreach my $key (keys %$data) {
        next if $data->{$key} =~ /^\n/;
        $longest_key = length($key) if length($key) > $longest_key;
    }
    $longest_key++;
    my $value = '';
    my $cr = sub {  return 1 if substr($data->{$_[0]}, 0, 1) eq "\n"; return -1; };
    foreach my $key (sort { &$cr($a) <=> &$cr($b) or $a cmp $b } keys %$data) {
        if ($indent) {
            $value .= ' ' x ($indent * 4);
        }
        $value .= sprintf("%-${longest_key}s ", $key . ':') . $data->{$key} . "\n";
    }
    return $value;
}

sub _obj_array {
    my $object = shift();
    my $indent = shift() || 0;

    return '[ ]' unless scalar $object->elements();

    my @elements;
    my $is_complex = 0;
    foreach my $element ($object->elements()) {
        unless (ref($element)) {
            push @elements, $element;
        }
        else {
            if ($element->isa('PDF::API2::Basic::PDF::Array')) {
                push @elements, _obj_array($element, $indent + 1);
            }
            elsif ($element->isa('PDF::API2::Basic::PDF::Dict')) {
                if ($element->{' objnum'}) {
                    push @elements, '<Object ' . $element->{' objnum'} . ($element->{' objgen'} ? ' ' . $element->{' objgen'} : '') . '>';
                }
                else {
                    unless (scalar grep { $_ !~ /^ / } keys %$element) {
                        push @elements, "<Empty Dictionary>";
                    }
                    else {
                        $is_complex = 1;
                        push @elements, "Dictionary: \n" . _obj_dictionary($element, $indent + 1);
                        chomp $elements[-1];
                    }
                }
            }
            elsif ($element->isa('PDF::API2::Basic::PDF::Name') or
                   $element->isa('PDF::API2::Basic::PDF::Number') or
                   $element->isa('PDF::API2::Basic::PDF::String')) {
                if ($element->val() =~ /^[[:print:]]+$/) {
                    push @elements, $element->val();
                }
                else {
                    push @elements, $element->as_pdf();
                }
            }
            elsif ($element->isa('PDF::API2::Basic::PDF::Null')) {
                push @elements, '<Null>';
            }
            elsif ($element->isa('PDF::API2::Basic::PDF::Objind') and $element->{' objnum'}) {
                push @elements, '<Object ' . $element->{' objnum'} . ($element->{' objgen'} ? ' ' . $element->{' objgen'} : '') . '>';
            }
            else {
                push @elements, '[' . ref($element) . ']';
            }
        }
    }
    my $value;
    unless ($is_complex) {
        $value = '[ ' . join(' ', @elements) . ' ]';
    }
    else {
        $value = "\n";
        foreach my $element (@elements) {
            $value .= ' ' x ($indent * 4) if $indent;
            $value .= '- ' . $element . "\n";
        }
    }
    return $value;
}
