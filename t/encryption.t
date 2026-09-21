use Test::More tests => 4;

use strict;
use warnings;

use PDF::API2;
use PDF::API2::Basic::PDF::File;

{
    local $@;
    eval { PDF::API2->open('t/resources/sample-encrypted-R2.pdf') };
    like(
        $@,
        qr/^PDF encryption is not implemented yet: Filter=Standard R=2 V=1 CFM=\?/,
        q{R2 encryption is rejected with a descriptive error},
    );
}

{
    local $@;
    eval { PDF::API2::Basic::PDF::File->open('t/resources/sample-encrypted-R2.pdf') };
    like(
        $@,
        qr/^PDF encryption is not implemented yet: Filter=Standard R=2 V=1 CFM=\?/,
        q{Direct File->open() also rejects R2 encryption before object access},
    );
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
