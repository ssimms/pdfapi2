use Test::More tests => 9;

use strict;
use warnings;

use PDF::API2;
use PDF::API2::Basic::PDF::File;

my $pdf = PDF::API2->open('t/resources/sample-encrypted-R2.pdf');
isa_ok($pdf, 'PDF::API2');
is($pdf->pages(), 1, q{R2 encrypted PDF has one page});
my $object = $pdf->{'pdf'}->read_objnum(7, 0);
isa_ok($object, 'PDF::API2::Basic::PDF::Dict');
is($object->{'Type'}->val(), 'Pages', q{Object stream object is decrypted});
is($object->{'Count'}->val(), 1, q{Decrypted Pages object has one page});
my $file = PDF::API2::Basic::PDF::File->open(
    't/resources/sample-encrypted-R2.pdf',
);
$object = $file->read_objnum(7, 0);
isa_ok(
    $object,
    'PDF::API2::Basic::PDF::Dict',
    q{Direct File API decrypts an object stream object},
);

{
    local $@;
    eval {
        PDF::API2->open(
            't/resources/sample-encrypted-R2.pdf',
            password => 'wrong-password',
        );
    };
    like($@, qr/^Invalid PDF password/, q{Wrong R2 password is rejected});
}

{
    local $@;
    eval { PDF::API2->open('t/resources/sample-encrypted-R3.pdf') };
    like(
        $@,
        qr/^PDF encryption is not implemented yet: Filter=Standard R=3 V=2 CFM=\?/,
        q{R3 encryption is rejected with a descriptive error},
    );
}

{
    local $@;
    eval { PDF::API2::Basic::PDF::File->open('t/resources/sample-encrypted-R3.pdf') };
    like(
        $@,
        qr/^PDF encryption is not implemented yet: Filter=Standard R=3 V=2 CFM=\?/,
        q{Direct File->open() also rejects R3 encryption before object access},
    );
}
