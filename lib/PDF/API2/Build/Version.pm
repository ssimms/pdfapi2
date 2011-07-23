package PDF::API2::Build::Version;

use warnings;
use strict;

use Moose;
with 'Dist::Zilla::Role::FileMunger';

sub munge_file {
    my ($self, $file) = @_;

    return $self->munge_content($file) if $file->name =~ /\.pm$/i;
    return;
}

sub munge_content {
    my ($self, $file) = @_;

    my $content = $file->content();

    my $version = $self->zilla->version();
    $content =~ s/^(package \S+;)$/$1\n\nour \$VERSION = '$version';/smg;
    $file->content($content);
}

1;
