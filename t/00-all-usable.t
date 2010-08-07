use Test::More;

use File::Find;

use warnings;
use strict;

# Test all of the modules to make sure that a simple "use Module"
# won't result in a crash.

my @files;
find(\&add_to_files, 'lib');

sub add_to_files {
    return unless -f $_;
    return unless $_ =~ /\.pm$/;
    push @files, $File::Find::name;
}

plan tests => scalar @files;

my @win32_modules;
foreach my $file (@files) {
    ($file) = $file =~ m|^lib/(.*)\.pm$|;
    $file =~ s|/|::|g;
    if ($file =~ /Win32/) {
        push @win32_modules, $file;
        next;
    }
    use_ok($file);
}

TODO: {
    local $TODO = q{Win32 modules currently die when "use"d on non-Win32 platforms};

    foreach my $file (@win32_modules) {
        use_ok($file);
    }
}
