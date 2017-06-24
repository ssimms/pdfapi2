use Test::More;

use PDF::API2::Basic::PDF::File;

my ($result, $remainder);

sub readval {
    my ($read, $unread, %options) = @_;
    open my $fh, '<', \$unread;
    my $parser = { ' INFILE' => $fh };
    bless $parser, 'PDF::API2::Basic::PDF::File';
    my ($result, $remainder) = $parser->readval($read, %options);
    close $fh;
    return ($result, $remainder);
}

($result, $remainder) = readval('1 0 R', '');
is(ref($result), 'PDF::API2::Basic::PDF::Objind',
   q{Basic indirect reference});

($result, $remainder) = readval('1 0 obj << >> endobj', '');
is(ref($result), 'PDF::API2::Basic::PDF::Dict',
   q{Basic indirect object});

($result, $remainder) = readval('1', '');
is(ref($result), 'PDF::API2::Basic::PDF::Number',
   q{Basic number});

($result, $remainder) = readval("1\n0 R", '');
is(ref($result), 'PDF::API2::Basic::PDF::Objind',
   q{Indirect reference on multiple already-read lines});

($result, $remainder) = readval("1\n0 obj << >> endobj", '');
is(ref($result), 'PDF::API2::Basic::PDF::Dict',
   q{Indirect object on multiple already-read lines});

($result, $remainder) = readval("1 %comment\n0 R", '');
is(ref($result), 'PDF::API2::Basic::PDF::Objind',
   q{Indirect reference with embedded comment 1/2});

($result, $remainder) = readval("1 0 %comment\nR", '');
is(ref($result), 'PDF::API2::Basic::PDF::Objind',
   q{Indirect reference with embedded comment 2/2});

($result, $remainder) = readval("1 %comment\n0 obj << >> endobj", '');
is(ref($result), 'PDF::API2::Basic::PDF::Dict',
   q{Indirect object with embedded comment 1/3});

($result, $remainder) = readval("1 0 %comment\nobj << >> endobj", '');
is(ref($result), 'PDF::API2::Basic::PDF::Dict',
   q{Indirect object with embedded comment 2/3});

($result, $remainder) = readval("1 0 obj %comment\n<< >> endobj", '');
is(ref($result), 'PDF::API2::Basic::PDF::Dict',
   q{Indirect object with embedded comment 3/3});

($result, $remainder) = readval('1', ' 0 R');
is(ref($result), 'PDF::API2::Basic::PDF::Objind',
   q{Indirect reference on partially-read line});

($result, $remainder) = readval('1', ' 0 obj << >> endobj');
is(ref($result), 'PDF::API2::Basic::PDF::Dict',
   q{Indirect object on partially-read line});

($result, $remainder) = readval("1\n", '0 R');
is(ref($result), 'PDF::API2::Basic::PDF::Objind',
   q{Indirect reference on multiple lines with only the first line read 1/3});

($result, $remainder) = readval("1 0\n", 'R');
is(ref($result), 'PDF::API2::Basic::PDF::Objind',
   q{Indirect reference on multiple lines with only the first line read 2/3});

($result, $remainder) = readval("1 0%comment\n", 'R');
is(ref($result), 'PDF::API2::Basic::PDF::Objind',
   q{Indirect reference on multiple lines with only the first line read 3/3});

($result, $remainder) = readval("1\n", '0 obj << >> endobj');
is(ref($result), 'PDF::API2::Basic::PDF::Dict',
   q{Indirect object on multiple lines with only the first line read});

($result, $remainder) = readval("1\n", '(string)');
is(ref($result), 'PDF::API2::Basic::PDF::Number',
   q{Number on a line by itself followed by a non-number});
is($remainder, '(string)',
   q{Remainder doesn't get lost});

done_testing();
