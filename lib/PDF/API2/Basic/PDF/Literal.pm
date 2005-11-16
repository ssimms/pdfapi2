#=======================================================================
#    ____  ____  _____              _    ____ ___   ____
#   |  _ \|  _ \|  ___|  _   _     / \  |  _ \_ _| |___ \
#   | |_) | | | | |_    (_) (_)   / _ \ | |_) | |    __) |
#   |  __/| |_| |  _|    _   _   / ___ \|  __/| |   / __/
#   |_|   |____/|_|     (_) (_) /_/   \_\_|  |___| |_____|
#
#   A Perl Module Chain to faciliate the Creation and Modification
#   of High-Quality "Portable Document Format (PDF)" Files.
#
#   Copyright 1999-2005 Alfred Reibenschuh <areibens@cpan.org>.
#
#=======================================================================
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU Lesser General Public
#   License as published by the Free Software Foundation; either
#   version 2 of the License, or (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   Lesser General Public License for more details.
#
#   You should have received a copy of the GNU Lesser General Public
#   License along with this library; if not, write to the
#   Free Software Foundation, Inc., 59 Temple Place - Suite 330,
#   Boston, MA 02111-1307, USA.
#
#   $Id$
#
#=======================================================================
# Literal PDF Object for Dirty Hacks ...
package PDF::API2::Basic::PDF::Literal;

use strict;
use vars qw( @ISA );

use PDF::API2::Basic::PDF::Objind;

@ISA = qw(PDF::API2::Basic::PDF::Objind);

use PDF::API2::Basic::PDF::Filter;
use PDF::API2::Basic::PDF::Name;

no warnings qw[ deprecated recursion uninitialized ];

sub new
{
    my ($class, @opts) = @_;
    my ($self);

    $class = ref $class if ref $class;
    $self = $class->SUPER::new(@_);
    $self->{' realised'} = 1;
    if(scalar @opts > 1) {
        $self->{-isdict}=1;
        my %opt=@opts;
        foreach my $k (sort keys %opt) {
            $self->{$k} = $opt{$k};
        }
    } elsif(scalar @opts == 1) {
        $self->{-literal}=$opts[0];
    }
    return $self;
}

sub outobjdeep
{
    my ($self, $fh, $pdf, %opts) = @_;
    if($self->{-isdict}) 
    {
        if(defined $self->{' stream'}) 
        {
            $self->{Length} = length($self->{' stream'}) + 1;
        } 
        else 
        {
            delete $self->{Length};
        }
        $fh->print("<< ");
        foreach my $k (sort keys %{$self}) 
        {
            next if($k=~m|^[ \-]|o);
            $fh->print('/'.PDF::API2::Basic::PDF::Name::string_to_name($k).' ');
            if(ref($self->{$k}) eq 'ARRAY') 
            {
                $fh->print('['.join(' ',@{$self->{$k}})."]\n");
            } 
            elsif(ref($self->{$k}) eq 'HASH') 
            {
                $fh->print('<<'.join(' ', map { '/'.PDF::API2::Basic::PDF::Name::string_to_name($_).' '.$self->{$k}->{$_} } sort keys %{$self->{$k}})." >>\n");
            } 
            elsif(UNIVERSAL::can($self->{$k},'outobj')) 
            {
                $self->{$k}->outobj($fh, $pdf, %opts);
                $fh->print("\n");
            } 
            else 
            {
                $fh->print("$self->{$k}\n");
            }
        }
        $fh->print(">>\n");
        if(defined $self->{' stream'}) 
        {
            $fh->print("stream\n$self->{' stream'}\nendstream"); # next is endobj which has the final cr
        }
    } 
    else 
    {
        $fh->print($self->{-literal}); # next is endobj which has the final cr
    }
}

sub outxmldeep
{
    my ($self, $fh, $pdf, %opts) = @_;
    $opts{-xmlfh}->print("<Literal>NOT HANDLED HERE.</Literal>\n");
}

sub val
{ $_[0]; }



